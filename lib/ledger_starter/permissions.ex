defmodule LedgerStarter.Permissions do
  @moduledoc """
  Role and permission catalog, backed by PermitEx.

  Global role templates (`owner`, `admin`, `member`) are seeded once and cloned
  into every company (PermitEx context = company id), so each tenant owns its
  own roles.
  """

  alias LedgerStarter.Repo

  @permissions [
    {"contacts:read", "Ver contatos"},
    {"contacts:create", "Criar contatos"},
    {"contacts:update", "Editar contatos"},
    {"contacts:delete", "Excluir contatos"},
    {"team:read", "Ver a equipe"},
    {"team:invite", "Convidar pessoas"},
    {"team:manage", "Gerenciar papéis e remover membros"},
    # Not "company:settings": PermitEx casts any 16-byte name as a raw UUID (see README, gaps).
    {"company:manage", "Configurações da empresa"}
  ]

  @roles [
    {"owner", "Proprietário", Enum.map(@permissions, &elem(&1, 0))},
    {"admin", "Administrador",
     ~w(contacts:read contacts:create contacts:update contacts:delete team:read team:invite)},
    {"member", "Membro", ~w(contacts:read contacts:create contacts:update team:read)}
  ]

  def permissions, do: @permissions
  def role_names, do: Enum.map(@roles, &elem(&1, 0))

  @doc "Idempotently seeds the global permissions and role templates."
  def seed_templates! do
    {:ok, :ok} = PermitEx.seed!([permissions: @permissions, roles: @roles], repo: Repo)
    :ok
  end

  @doc "Clones the templates into the company (context) and returns the roles."
  def setup_company!(company_id) do
    seed_templates!()
    {:ok, roles} = PermitEx.clone_roles_to_context(company_id, repo: Repo)
    roles
  end

  def assign_role(user_id, role, company_id) when role in ["owner", "admin", "member"] do
    PermitEx.sync_roles(user_id, [role], company_id, repo: Repo)
  end

  @doc "The role name the user holds inside the company (or nil)."
  def role_of(user_id, company_id) do
    case PermitEx.roles_for(user_id, company_id, repo: Repo) do
      [%{name: name} | _] -> name
      [] -> nil
    end
  end
end
