defmodule LedgerStarter.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "contacts" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :company_name, :string
    field :stage, Ecto.Enum, values: [:lead, :qualified, :customer]
    belongs_to :owner, LedgerStarter.Accounts.User
    belongs_to :company, LedgerStarter.Companies.Company

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(contact, attrs, company_scope) do
    contact
    |> cast(attrs, [:name, :email, :phone, :company_name, :stage])
    |> validate_required([:name, :email, :stage])
    |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/, message: "e-mail inválido")
    |> validate_length(:name, max: 120)
    |> put_change(:company_id, company_scope.company.id)
    |> maybe_put_owner(company_scope)
  end

  defp maybe_put_owner(changeset, %{user: %{id: user_id}}) do
    if get_field(changeset, :owner_id),
      do: changeset,
      else: put_change(changeset, :owner_id, user_id)
  end

  defp maybe_put_owner(changeset, _), do: changeset
end
