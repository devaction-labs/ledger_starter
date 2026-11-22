defmodule LedgerStarter.Companies.Invitation do
  @moduledoc "An invitation to join a company. Only the token hash is stored."
  use Ecto.Schema
  import Ecto.Changeset

  @validity_days 7

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "invitations" do
    field :email, :string
    field :role, :string, default: "sales"
    field :token_hash, :binary
    field :expires_at, :utc_datetime
    field :accepted_at, :utc_datetime

    belongs_to :company, LedgerStarter.Companies.Company
    belongs_to :invited_by, LedgerStarter.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc "Builds `{raw_token, changeset}`. The raw token is only sent by e-mail."
  def build(company, invited_by, email, role) do
    token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    changeset =
      %__MODULE__{company_id: company.id, invited_by_id: invited_by && invited_by.id}
      |> cast(%{email: email, role: role}, [:email, :role])
      |> validate_required([:email, :role])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/, message: "e-mail inválido")
      |> put_change(:token_hash, hash(token))
      |> put_change(:expires_at, DateTime.add(DateTime.utc_now(:second), @validity_days, :day))

    {token, changeset}
  end

  def hash(token), do: :crypto.hash(:sha256, token)

  def pending?(%__MODULE__{accepted_at: nil, expires_at: expires_at}),
    do: DateTime.compare(expires_at, DateTime.utc_now()) == :gt

  def pending?(_), do: false
end
