defmodule LedgerStarter.Companies.Membership do
  @moduledoc """
  Links a user to a company. The user's role lives in PermitEx, scoped by the
  company id (context), not here.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "memberships" do
    belongs_to :user, LedgerStarter.Accounts.User
    belongs_to :company, LedgerStarter.Companies.Company

    timestamps(type: :utc_datetime)
  end

  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:user_id, :company_id])
    |> validate_required([:user_id, :company_id])
    |> unique_constraint([:user_id, :company_id])
  end
end
