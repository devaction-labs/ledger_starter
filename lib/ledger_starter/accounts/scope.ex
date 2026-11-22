defmodule LedgerStarter.Accounts.Scope do
  @moduledoc """
  The caller's scope (Phoenix 1.8 scopes).

  Carries the authenticated `user`, the active tenant `company` (resolved from
  the request host) and the roles/permissions the user holds *inside* that
  company (loaded from PermitEx, with the company id as context).

  Tenant-scoped contexts receive this struct as their first argument and filter
  every query by `company_id`.
  """

  alias LedgerStarter.Accounts.User
  alias LedgerStarter.Companies.Company

  defstruct user: nil, company: nil, roles: [], permissions: MapSet.new()

  @type t :: %__MODULE__{
          user: User.t() | nil,
          company: Company.t() | nil,
          roles: list(),
          permissions: MapSet.t()
        }

  @doc """
  Creates a scope for the given user.

  Returns nil if no user is given.
  """
  def for_user(%User{} = user), do: %__MODULE__{user: user}
  def for_user(nil), do: nil

  @doc """
  Puts the active company in the scope and loads the user's PermitEx roles and
  permissions for that company.
  """
  def put_company(%__MODULE__{user: %User{} = user} = scope, %Company{} = company) do
    %{roles: roles, permissions: permissions} = PermitEx.Scope.for_user(user, company)
    %{scope | company: company, roles: roles, permissions: permissions}
  end

  def put_company(%__MODULE__{} = scope, nil),
    do: %{scope | company: nil, roles: [], permissions: MapSet.new()}

  @doc "Reloads roles and permissions (after a role change)."
  def reload(%__MODULE__{company: %Company{} = company} = scope), do: put_company(scope, company)
  def reload(scope), do: scope

  @doc "True when the scope holds `permission` in the active company."
  def can?(%__MODULE__{} = scope, permission), do: PermitEx.can?(scope, permission)
  def can?(_, _), do: false
end
