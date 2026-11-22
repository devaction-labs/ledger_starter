defmodule LedgerStarter.CompaniesTest do
  use LedgerStarter.DataCase, async: true

  import LedgerStarter.AccountsFixtures
  import LedgerStarter.CompaniesFixtures

  alias LedgerStarter.{Companies, Permissions, Repo}
  alias LedgerStarter.Companies.{Company, Invitation}

  describe "subdomain validation" do
    test "accepts lowercase letters, digits and hyphen, 3 to 30 chars" do
      for sub <- ["orbit", "a-b", "abc", "x1y2z3", String.duplicate("a", 30)] do
        assert Company.changeset(%Company{}, %{name: "Orbit", subdomain: sub},
                 validate_unique: false
               ).valid?,
               "#{sub} should be valid"
      end
    end

    test "rejects uppercase-after-normalization failures, bad chars and bad length" do
      for sub <- [
            "ab",
            String.duplicate("a", 31),
            "a_b",
            "-abc",
            "abc-",
            "a b c",
            "açaí",
            "a.b.c"
          ] do
        refute Company.changeset(%Company{}, %{name: "Orbit", subdomain: sub},
                 validate_unique: false
               ).valid?,
               "#{inspect(sub)} should be invalid"
      end
    end

    test "downcases and trims the input" do
      changeset =
        Company.changeset(%Company{}, %{name: "Orbit", subdomain: "  OrBiT "},
          validate_unique: false
        )

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :subdomain) == "orbit"
    end

    test "rejects the reserved list" do
      for sub <- ~w(www app api admin mail static) do
        changeset =
          Company.changeset(%Company{}, %{name: "X Corp", subdomain: sub}, validate_unique: false)

        assert %{subdomain: ["este endereço é reservado"]} = errors_on(changeset)
      end
    end

    test "must be unique, case-insensitively" do
      company_fixture(nil, %{subdomain: "orbit"})

      assert {:error, changeset} =
               Companies.create_company(user_fixture(), %{name: "Outra", subdomain: "ORBIT"})

      assert %{subdomain: ["já está em uso"]} = errors_on(changeset)
    end

    test "the database enforces uniqueness too" do
      company_fixture(nil, %{subdomain: "unico"})

      assert {:error, changeset} =
               %Company{}
               |> Company.changeset(%{name: "Dup", subdomain: "unico"}, validate_unique: false)
               |> Repo.insert()

      assert %{subdomain: ["já está em uso"]} = errors_on(changeset)
    end

    test "subdomain_status/1 powers the live availability check" do
      company_fixture(nil, %{subdomain: "ocupado"})

      assert Companies.subdomain_status("livre-123") == :available
      assert Companies.subdomain_status("ocupado") == :taken
      assert {:invalid, _} = Companies.subdomain_status("www")
      assert {:invalid, _} = Companies.subdomain_status("ab")
    end
  end

  describe "create_company/2" do
    test "creates the company, the membership and makes the user owner" do
      user = user_fixture()

      assert {:ok, company} =
               Companies.create_company(user, %{name: "Orbit Cloud", subdomain: "orbit"})

      assert Companies.member?(user, company)
      assert Permissions.role_of(user.id, company.id) == "owner"
      assert Companies.get_company_by_subdomain("orbit").id == company.id
    end

    test "clones the role templates into the company (PermitEx context)" do
      company = company_fixture()

      roles = PermitEx.list_roles(company.id, repo: Repo)
      names = for %{context_id: id, name: name} <- roles, id == company.id, do: name

      assert Enum.sort(names) == ["admin", "owner", "sales", "viewer"]
    end

    test "leaves nothing behind when invalid" do
      user = user_fixture()
      assert {:error, _} = Companies.create_company(user, %{name: "X", subdomain: "www"})
      assert Companies.list_companies_for_user(user) == []
    end

    test "list_companies_for_user/1 returns only the user's companies" do
      user = user_fixture()
      mine = company_fixture(user)
      _other = company_fixture()

      assert [%{id: id}] = Companies.list_companies_for_user(user)
      assert id == mine.id
    end
  end

  describe "roles and permissions are scoped by company" do
    test "the same user is owner in one company and sales in another" do
      user = user_fixture()
      owned = company_fixture(user)
      other = company_fixture()
      {:ok, _} = Companies.add_member(other, user, "sales")

      owner_scope = company_scope_fixture(user, owned)
      member_scope = company_scope_fixture(user, other)

      assert PermitEx.can?(owner_scope, "team:write")
      assert PermitEx.can?(owner_scope, "company:delete")
      refute PermitEx.can?(member_scope, "team:write")
      refute PermitEx.can?(member_scope, "team:read")
      assert PermitEx.can?(member_scope, "contacts:write")
    end

    test "sales cannot invite, admin and owner can" do
      owner = company_scope_fixture()
      {_, admin} = member_fixture(owner.company, "admin")
      {_, member} = member_fixture(owner.company, "sales")

      url_fun = &"http://example.com/convites/#{&1}"

      assert {:error, :unauthorized} =
               Companies.invite_people(member, "a@example.com", "sales", url_fun)

      assert {:ok, %{sent: [_]}} =
               Companies.invite_people(admin, "b@example.com", "sales", url_fun)

      assert {:ok, %{sent: [_]}} =
               Companies.invite_people(owner, "c@example.com", "admin", url_fun)

      assert PermitEx.can?(owner, "team:write")
      assert PermitEx.can?(admin, "team:write")
      refute PermitEx.can?(member, "team:write")
    end

    test "only whoever holds team:write can change roles" do
      owner = company_scope_fixture()
      {_, sales} = member_fixture(owner.company, "sales")
      {member_user, _} = member_fixture(owner.company, "viewer")

      assert {:error, :unauthorized} =
               Companies.update_member_role(sales, member_user.id, "admin")

      assert {:error, :invalid_role} =
               Companies.update_member_role(owner, member_user.id, "inexistente")

      assert :ok = Companies.update_member_role(owner, member_user.id, "admin")
      assert Permissions.role_of(member_user.id, owner.company.id) == "admin"
    end

    test "the last owner cannot be demoted" do
      owner = company_scope_fixture()
      assert {:error, :last_owner} = Companies.update_member_role(owner, owner.user.id, "sales")
    end

    test "member lists are scoped to the company" do
      a = company_scope_fixture()
      b = company_scope_fixture()

      assert {:ok, [%{user: user}]} = Companies.list_members(a)
      assert user.id == a.user.id
      assert {:ok, [%{user: user_b}]} = Companies.list_members(b)
      assert user_b.id == b.user.id
    end
  end

  describe "invitations" do
    setup do
      owner = company_scope_fixture()
      %{owner: owner, url_fun: &"http://example.com/convites/#{&1}"}
    end

    defp flush_emails do
      receive do
        {:email, _} -> flush_emails()
      after
        0 -> :ok
      end
    end

    defp invite!(owner, email, role, url_fun) do
      flush_emails()
      {:ok, %{sent: [invitation]}} = Companies.invite_people(owner, email, role, url_fun)
      assert_received {:email, %{to: [{_, ^email}]} = email_msg}
      [_, token] = Regex.run(~r{/convites/([A-Za-z0-9_-]+)}, email_msg.text_body)
      {invitation, token}
    end

    test "stores only the token hash and e-mails the accept link", %{
      owner: owner,
      url_fun: url_fun
    } do
      {invitation, token} = invite!(owner, "nova@example.com", "sales", url_fun)

      assert invitation.token_hash == Invitation.hash(token)
      refute invitation.token_hash == token
      assert DateTime.compare(invitation.expires_at, DateTime.utc_now()) == :gt
      assert is_nil(invitation.accepted_at)
    end

    test "sends one e-mail per address, deduplicating and skipping members", %{
      owner: owner,
      url_fun: url_fun
    } do
      {:ok, %{sent: sent, skipped: skipped}} =
        Companies.invite_people(
          owner,
          "a@example.com, A@example.com; b@example.com #{owner.user.email}",
          "sales",
          url_fun
        )

      assert length(sent) == 2
      assert skipped == [owner.user.email]
    end

    test "rejects the owner role and invalid roles", %{owner: owner, url_fun: url_fun} do
      assert {:error, :invalid_role} =
               Companies.invite_people(owner, "a@example.com", "owner", url_fun)
    end

    test "respects the seat limit", %{owner: owner, url_fun: url_fun} do
      emails = Enum.map_join(1..Companies.seats_limit(), ",", &"p#{&1}@example.com")
      assert {:error, :seats_exceeded} = Companies.invite_people(owner, emails, "sales", url_fun)
      assert %{used: 1} = Companies.seats_info(owner)
    end

    test "accept: the matching user joins with the invited role", %{
      owner: owner,
      url_fun: url_fun
    } do
      invitee = user_fixture()
      {_inv, token} = invite!(owner, invitee.email, "admin", url_fun)

      assert {:ok, company} = Companies.accept_invitation(token, invitee)
      assert company.id == owner.company.id
      assert Companies.member?(invitee, company)
      assert Permissions.role_of(invitee.id, company.id) == "admin"
    end

    test "accept is single use", %{owner: owner, url_fun: url_fun} do
      invitee = user_fixture()
      {_inv, token} = invite!(owner, invitee.email, "sales", url_fun)

      assert {:ok, _} = Companies.accept_invitation(token, invitee)
      assert {:error, :invalid} = Companies.accept_invitation(token, invitee)
    end

    test "accept requires the matching e-mail", %{owner: owner, url_fun: url_fun} do
      stranger = user_fixture()
      {_inv, token} = invite!(owner, "someone@example.com", "sales", url_fun)

      assert {:error, :email_mismatch} = Companies.accept_invitation(token, stranger)
      refute Companies.member?(stranger, owner.company)
      # still pending
      assert Companies.get_invitation_by_token(token)
    end

    test "accept ignores the e-mail case", %{owner: owner, url_fun: url_fun} do
      invitee = user_fixture(%{email: "MixedCase@Example.com"})
      {_inv, token} = invite!(owner, "mixedcase@example.com", "sales", url_fun)
      assert {:ok, _} = Companies.accept_invitation(token, invitee)
    end

    test "expired and unknown tokens are invalid", %{owner: owner, url_fun: url_fun} do
      invitee = user_fixture()
      {invitation, token} = invite!(owner, invitee.email, "sales", url_fun)

      invitation
      |> Ecto.Changeset.change(expires_at: DateTime.add(DateTime.utc_now(:second), -1, :hour))
      |> Repo.update!()

      assert {:error, :invalid} = Companies.accept_invitation(token, invitee)
      assert {:error, :invalid} = Companies.accept_invitation("nope", invitee)
      assert is_nil(Companies.get_invitation_by_token(token))
    end

    test "pending invitations are scoped to the company and can be revoked", %{
      owner: owner,
      url_fun: url_fun
    } do
      other = company_scope_fixture()
      {invitation, _} = invite!(owner, "p@example.com", "sales", url_fun)

      assert {:ok, [%{id: id}]} = Companies.list_pending_invitations(owner)
      assert id == invitation.id
      assert {:ok, []} = Companies.list_pending_invitations(other)

      # another company cannot revoke it
      assert {:error, :not_found} = Companies.revoke_invitation(other, invitation.id)
      assert :ok = Companies.revoke_invitation(owner, invitation.id)
      assert {:ok, []} = Companies.list_pending_invitations(owner)
    end

    test "a member cannot revoke invitations", %{owner: owner, url_fun: url_fun} do
      {_, member} = member_fixture(owner.company, "sales")
      {invitation, _} = invite!(owner, "p@example.com", "sales", url_fun)

      assert {:error, :unauthorized} = Companies.revoke_invitation(member, invitation.id)
    end
  end
end
