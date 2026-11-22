defmodule LedgerStarter.CompaniesFixtures do
  @moduledoc "Test helpers for companies, memberships and invitations."

  alias LedgerStarter.Accounts.Scope
  alias LedgerStarter.{AccountsFixtures, Companies}

  def unique_subdomain, do: "empresa#{System.unique_integer([:positive])}"

  def company_fixture(user \\ nil, attrs \\ %{}) do
    user = user || AccountsFixtures.user_fixture()

    {:ok, company} =
      Companies.create_company(
        user,
        Enum.into(attrs, %{name: "Empresa Teste", subdomain: unique_subdomain()})
      )

    company
  end

  @doc "A scope for `user` in a fresh company where they are the owner."
  def company_scope_fixture do
    user = AccountsFixtures.user_fixture()
    company_scope_fixture(user, company_fixture(user))
  end

  def company_scope_fixture(user, company) do
    user |> Scope.for_user() |> Scope.put_company(company)
  end

  @doc "Adds a new user to the company with the given role; returns `{user, scope}`."
  def member_fixture(company, role \\ "member") do
    user = AccountsFixtures.user_fixture()
    {:ok, _} = Companies.add_member(company, user, role)
    {user, company_scope_fixture(user, company)}
  end
end
