defmodule LedgerStarter.Companies do
  @moduledoc """
  Tenants, memberships and invitations.

  Roles and permissions come from PermitEx with the company id as context
  (see `LedgerStarter.Permissions`). Functions that act inside a tenant take a
  `%LedgerStarter.Accounts.Scope{}` and check the permission.
  """

  import Ecto.Query, warn: false

  alias LedgerStarter.Accounts.{Scope, User}
  alias LedgerStarter.Companies.{Company, Invitation, InvitationNotifier, Membership}
  alias LedgerStarter.{Permissions, Repo}

  ## Companies

  def get_company!(id), do: Repo.get!(Company, id)

  def get_company_by_subdomain(subdomain) when is_binary(subdomain),
    do: Repo.get_by(Company, subdomain: String.downcase(subdomain))

  def get_company_by_subdomain(_), do: nil

  def change_company(company \\ %Company{}, attrs \\ %{}, opts \\ []),
    do: Company.changeset(company, attrs, opts)

  @doc "Whether the subdomain is valid and free (live check on the create form)."
  def subdomain_status(subdomain) when is_binary(subdomain) do
    changeset = Company.changeset(%Company{}, %{name: "x", subdomain: subdomain})

    case Keyword.get_values(changeset.errors, :subdomain) do
      [] -> :available
      [{"já está em uso", _} | _] -> :taken
      [{msg, _} | _] -> {:invalid, msg}
    end
  end

  @doc "Creates a company, makes `user` its owner and clones the PermitEx roles."
  def create_company(%User{} = user, attrs) do
    Repo.transaction(fn ->
      with {:ok, company} <- %Company{} |> Company.changeset(attrs) |> Repo.insert(),
           {:ok, _} <-
             %Membership{}
             |> Membership.changeset(%{user_id: user.id, company_id: company.id})
             |> Repo.insert() do
        Permissions.setup_company!(company.id)
        {:ok, _} = Permissions.assign_role(user.id, "owner", company.id)
        company
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  def list_companies_for_user(%User{id: user_id}) do
    Repo.all(
      from c in Company,
        join: m in Membership,
        on: m.company_id == c.id,
        where: m.user_id == ^user_id,
        order_by: [asc: c.name]
    )
  end

  ## Memberships

  def get_membership(%User{id: user_id}, %Company{id: company_id}),
    do: Repo.get_by(Membership, user_id: user_id, company_id: company_id)

  def member?(user, company), do: not is_nil(get_membership(user, company))

  @doc "Adds the user to the company with `role` (idempotent)."
  def add_member(%Company{} = company, %User{} = user, role) do
    Repo.transaction(fn ->
      case get_membership(user, company) do
        nil ->
          {:ok, _} =
            %Membership{}
            |> Membership.changeset(%{user_id: user.id, company_id: company.id})
            |> Repo.insert()

          Permissions.setup_company!(company.id)
          {:ok, _} = Permissions.assign_role(user.id, role, company.id)

        _ ->
          :ok
      end

      company
    end)
  end

  @doc "Lists members as `%{membership, user, role}`. Requires `team.read`."
  def list_members(%Scope{company: company} = scope) do
    with :ok <- PermitEx.authorize(scope, "team:read") do
      members =
        Repo.all(
          from m in Membership,
            where: m.company_id == ^company.id,
            join: u in assoc(m, :user),
            order_by: [asc: m.inserted_at],
            select: {m, u}
        )

      roles = roles_by_user(company.id)

      {:ok,
       for {m, u} <- members do
         %{membership: m, user: u, role: Map.get(roles, u.id)}
       end}
    end
  end

  defp roles_by_user(company_id) do
    for role <- PermitEx.list_roles(company_id, repo: Repo),
        user_id <- PermitEx.users_with_role(role, company_id, repo: Repo),
        into: %{},
        do: {user_id, role.name}
  end

  def count_members(%Company{id: id}),
    do: Repo.aggregate(from(m in Membership, where: m.company_id == ^id), :count)

  @doc "Changes a member's role. Requires `team.manage`; the last owner cannot be demoted."
  def update_member_role(%Scope{company: company} = scope, user_id, role) do
    with :ok <- PermitEx.authorize(scope, "team:manage"),
         true <- role in Permissions.role_names() or {:error, :invalid_role},
         :ok <- guard_last_owner(company.id, user_id, role),
         {:ok, _} <- Permissions.assign_role(user_id, role, company.id) do
      :ok
    end
  end

  defp guard_last_owner(company_id, user_id, new_role) do
    owners = PermitEx.users_with_role("owner", company_id, repo: Repo)

    if new_role != "owner" and owners == [user_id], do: {:error, :last_owner}, else: :ok
  end

  ## Invitations

  @seats_limit 10
  def seats_limit, do: Application.get_env(:ledger_starter, :seats_limit, @seats_limit)

  def seats_info(%Scope{company: company}) do
    used = count_members(company) + length(pending_query(company.id) |> Repo.all())
    %{used: used, limit: seats_limit()}
  end

  def list_pending_invitations(%Scope{company: company} = scope) do
    with :ok <- PermitEx.authorize(scope, "team:read") do
      {:ok, Repo.all(from i in pending_query(company.id), order_by: [desc: i.inserted_at])}
    end
  end

  defp pending_query(company_id) do
    now = DateTime.utc_now()

    from i in Invitation,
      where: i.company_id == ^company_id and is_nil(i.accepted_at) and i.expires_at > ^now
  end

  @doc """
  Invites several e-mails. Requires `team.invite`. Returns
  `{:ok, %{sent: [...], skipped: [...]}}` or `{:error, reason}`.
  """
  def invite_people(%Scope{company: company, user: inviter} = scope, emails, role, url_fun) do
    with :ok <- PermitEx.authorize(scope, "team:invite"),
         true <- role in Invitation.roles() or {:error, :invalid_role},
         emails = parse_emails(emails),
         true <- emails != [] or {:error, :no_emails},
         :ok <- check_seats(scope, length(emails)) do
      member_emails = member_emails(company.id)

      {sent, skipped} =
        Enum.reduce(emails, {[], []}, fn email, {sent, skipped} ->
          with false <- String.downcase(email) in member_emails,
               {token, changeset} <- Invitation.build(company, inviter, email, role),
               {:ok, invitation} <- Repo.insert(changeset) do
            InvitationNotifier.deliver(invitation, company, inviter, url_fun.(token))
            {[invitation | sent], skipped}
          else
            _ -> {sent, [email | skipped]}
          end
        end)

      {:ok, %{sent: Enum.reverse(sent), skipped: Enum.reverse(skipped)}}
    end
  end

  def parse_emails(emails) when is_binary(emails) do
    emails |> String.split(~r/[\s,;]+/, trim: true) |> parse_emails()
  end

  def parse_emails(emails) when is_list(emails) do
    emails
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq_by(&String.downcase/1)
  end

  defp check_seats(scope, n) do
    %{used: used, limit: limit} = seats_info(scope)
    if used + n > limit, do: {:error, :seats_exceeded}, else: :ok
  end

  defp member_emails(company_id) do
    Repo.all(
      from m in Membership,
        join: u in assoc(m, :user),
        where: m.company_id == ^company_id,
        select: u.email
    )
    |> Enum.map(&String.downcase/1)
  end

  def revoke_invitation(%Scope{company: company} = scope, invitation_id) do
    with :ok <- PermitEx.authorize(scope, "team:invite") do
      {n, _} =
        Repo.delete_all(
          from i in Invitation,
            where:
              i.id == ^invitation_id and i.company_id == ^company.id and is_nil(i.accepted_at)
        )

      if n == 1, do: :ok, else: {:error, :not_found}
    end
  end

  @doc "Finds a pending, unexpired invitation by raw token."
  def get_invitation_by_token(token) when is_binary(token) do
    hash = Invitation.hash(token)

    case Repo.one(from i in Invitation, where: i.token_hash == ^hash, preload: [:company]) do
      %Invitation{} = invitation ->
        if Invitation.pending?(invitation), do: invitation, else: nil

      nil ->
        nil
    end
  end

  def get_invitation_by_token(_), do: nil

  @doc """
  Accepts the invitation for `user`. The user's e-mail must match the
  invitation's. The invitation is single-use.
  """
  def accept_invitation(token, %User{} = user) do
    case get_invitation_by_token(token) do
      nil ->
        {:error, :invalid}

      %Invitation{} = invitation ->
        if String.downcase(invitation.email) != String.downcase(user.email) do
          {:error, :email_mismatch}
        else
          Repo.transaction(fn ->
            {1, _} =
              from(i in Invitation, where: i.id == ^invitation.id and is_nil(i.accepted_at))
              |> Repo.update_all(set: [accepted_at: DateTime.utc_now(:second)])

            {:ok, _} = add_member(invitation.company, user, invitation.role)
            invitation.company
          end)
        end
    end
  end
end
