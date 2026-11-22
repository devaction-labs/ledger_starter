defmodule LedgerStarter.Contacts do
  @moduledoc """
  The Contacts context.
  """

  import Ecto.Query, warn: false
  alias LedgerStarter.Repo

  alias LedgerStarter.Contacts.Contact
  alias LedgerStarter.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any contact changes.

  The broadcasted messages match the pattern:

    * {:created, %Contact{}}
    * {:updated, %Contact{}}
    * {:deleted, %Contact{}}

  """
  def subscribe_contacts(%Scope{} = scope) do
    key = scope.company.id

    Phoenix.PubSub.subscribe(LedgerStarter.PubSub, "company:#{key}:contacts")
  end

  defp broadcast_contact(%Scope{} = scope, message) do
    key = scope.company.id

    Phoenix.PubSub.broadcast(LedgerStarter.PubSub, "company:#{key}:contacts", message)
  end

  @doc """
  Returns the list of contacts.

  ## Examples

      iex> list_contacts(scope)
      [%Contact{}, ...]

  """
  def list_contacts(%Scope{} = scope, limit \\ 200) do
    Repo.all(
      from c in Contact,
        limit: ^limit,
        where: c.company_id == ^scope.company.id,
        order_by: [desc: c.inserted_at, desc: c.id],
        preload: [:owner]
    )
  end

  @doc "Counts contacts of the company per stage: `%{lead: n, qualified: n, customer: n}`."
  def count_by_stage(%Scope{} = scope) do
    counts =
      Repo.all(
        from c in Contact,
          where: c.company_id == ^scope.company.id,
          group_by: c.stage,
          select: {c.stage, count(c.id)}
      )
      |> Map.new()

    Map.merge(%{lead: 0, qualified: 0, customer: 0}, counts)
  end

  @doc """
  Gets a single contact.

  Raises `Ecto.NoResultsError` if the Contact does not exist.

  ## Examples

      iex> get_contact!(scope, 123)
      %Contact{}

      iex> get_contact!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_contact!(%Scope{} = scope, id) do
    Repo.get_by!(Contact, id: id, company_id: scope.company.id)
  end

  @doc "Like `get_contact!/2` but returns `nil` when missing or from another company."
  def get_contact(%Scope{} = scope, id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> Repo.get_by(Contact, id: uuid, company_id: scope.company.id)
      :error -> nil
    end
  end

  @doc """
  Creates a contact.

  ## Examples

      iex> create_contact(scope, %{field: value})
      {:ok, %Contact{}}

      iex> create_contact(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contact(%Scope{} = scope, attrs) do
    with :ok <- PermitEx.authorize(scope, "contacts:create"),
         {:ok, contact = %Contact{}} <-
           %Contact{}
           |> Contact.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_contact(scope, {:created, contact})
      {:ok, contact}
    end
  end

  @doc """
  Updates a contact.

  ## Examples

      iex> update_contact(scope, contact, %{field: new_value})
      {:ok, %Contact{}}

      iex> update_contact(scope, contact, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contact(%Scope{} = scope, %Contact{} = contact, attrs) do
    true = contact.company_id == scope.company.id

    with :ok <- PermitEx.authorize(scope, "contacts:update"),
         {:ok, contact = %Contact{}} <-
           contact
           |> Contact.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_contact(scope, {:updated, contact})
      {:ok, contact}
    end
  end

  @doc """
  Deletes a contact.

  ## Examples

      iex> delete_contact(scope, contact)
      {:ok, %Contact{}}

      iex> delete_contact(scope, contact)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contact(%Scope{} = scope, %Contact{} = contact) do
    true = contact.company_id == scope.company.id

    with :ok <- PermitEx.authorize(scope, "contacts:delete"),
         {:ok, contact = %Contact{}} <-
           Repo.delete(contact) do
      broadcast_contact(scope, {:deleted, contact})
      {:ok, contact}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contact changes.

  ## Examples

      iex> change_contact(scope, contact)
      %Ecto.Changeset{data: %Contact{}}

  """
  def change_contact(%Scope{} = scope, %Contact{} = contact, attrs \\ %{}) do
    true = contact.company_id == scope.company.id

    Contact.changeset(contact, attrs, scope)
  end
end
