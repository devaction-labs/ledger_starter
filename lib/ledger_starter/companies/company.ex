defmodule LedgerStarter.Companies.Company do
  @moduledoc "A tenant. Resolved from the request host subdomain."
  use Ecto.Schema
  import Ecto.Changeset

  @reserved ~w(www app api admin mail static)
  @subdomain_format ~r/^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$/

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "companies" do
    field :name, :string
    field :subdomain, :string

    has_many :memberships, LedgerStarter.Companies.Membership
    has_many :invitations, LedgerStarter.Companies.Invitation

    timestamps(type: :utc_datetime)
  end

  def reserved_subdomains, do: @reserved

  @doc "Changeset for creating a company."
  def changeset(company, attrs, opts \\ []) do
    company
    |> cast(attrs, [:name, :subdomain])
    |> update_change(:subdomain, &normalize/1)
    |> validate_required([:name, :subdomain])
    |> validate_length(:name, min: 2, max: 80)
    |> validate_length(:subdomain, min: 3, max: 30)
    |> validate_format(:subdomain, @subdomain_format,
      message: "use apenas letras minúsculas, números e hífen"
    )
    |> validate_exclusion(:subdomain, @reserved, message: "este endereço é reservado")
    |> maybe_unique(opts)
  end

  defp maybe_unique(changeset, opts) do
    if Keyword.get(opts, :validate_unique, true) do
      changeset
      |> unsafe_validate_unique(:subdomain, LedgerStarter.Repo, message: "já está em uso")
      |> unique_constraint(:subdomain, message: "já está em uso")
    else
      changeset
    end
  end

  defp normalize(value) when is_binary(value), do: value |> String.trim() |> String.downcase()
  defp normalize(value), do: value
end
