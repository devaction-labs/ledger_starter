defmodule LedgerStarter.Permissions do
  @moduledoc """
  Role and permission catalog, backed by PermitEx.

  The catalog is a list of *groups* (the rows of the "Papéis e permissões"
  matrix: "Contatos e empresas", "Equipe e convites", ...). Each group has up to
  three actions (`read`, `write`, `delete`) and, for the CRM groups, a data
  scope (own / team / all):

    * `recurso:acao` permissions: `contacts:read`, `contacts:write`,
      `contacts:delete`, `billing:write`, `company:delete`, ...
    * the scope is `recurso:team` / `recurso:all`; having neither means "só os
      seus" (own). The scope is stored and shown, but nothing in the data model
      filters by owner yet, so it is informational for now.

  Names never have exactly 16 bytes: PermitEx casts any 16-byte name as a raw
  UUID (see the README, gaps). `test/ledger_starter/permissions_test.exs` guards it.

  Role templates (`owner`, `admin`, `sales`, `viewer`) are seeded globally and
  cloned into every company once (PermitEx context = company id). From then on
  each tenant owns its roles: `owner` and `admin` are locked (PermitEx `locked`),
  `sales`, `viewer` and any custom role can be edited by whoever holds
  `team:write`. A role's display name is the PermitEx role `description`
  (PermitEx role names must be slugs).
  """

  import Ecto.Query, warn: false
  use Gettext, backend: LedgerStarterWeb.Gettext

  alias LedgerStarter.Accounts.Scope
  alias LedgerStarter.Repo

  @actions [
    {"read", gettext_noop("Ver")},
    {"write", gettext_noop("Criar e editar")},
    {"delete", gettext_noop("Excluir")}
  ]

  @groups [
    %{
      key: "contacts",
      label: gettext_noop("Contatos e empresas"),
      icon: "users",
      scoped: true,
      requires_read: true,
      actions: @actions
    },
    %{
      key: "deals",
      label: gettext_noop("Negócios e funil"),
      icon: "kanban",
      scoped: true,
      requires_read: true,
      actions: @actions
    },
    %{
      key: "tasks",
      label: gettext_noop("Tarefas"),
      icon: "check-circle",
      scoped: true,
      requires_read: true,
      actions: @actions
    },
    %{
      key: "reports",
      label: gettext_noop("Relatórios"),
      icon: "bar",
      scoped: true,
      requires_read: true,
      actions: @actions
    },
    %{
      key: "data",
      label: gettext_noop("Importar e exportar"),
      icon: "download",
      scoped: false,
      requires_read: false,
      actions: [{"read", gettext_noop("Exportar")}, {"write", gettext_noop("Importar")}]
    },
    %{
      key: "team",
      label: gettext_noop("Equipe e convites"),
      icon: "user-plus",
      scoped: false,
      requires_read: true,
      actions: [
        {"read", gettext_noop("Ver")},
        {"write", gettext_noop("Convidar e editar papéis")},
        {"delete", gettext_noop("Remover pessoas")}
      ]
    },
    %{
      key: "billing",
      label: gettext_noop("Cobrança e plano"),
      icon: "card",
      scoped: false,
      requires_read: true,
      actions: [{"read", gettext_noop("Ver")}, {"write", gettext_noop("Gerenciar plano")}]
    },
    %{
      key: "company",
      label: gettext_noop("Excluir o workspace"),
      icon: "trash",
      scoped: false,
      requires_read: false,
      editable: false,
      actions: [{"delete", gettext_noop("Excluir")}]
    }
  ]

  @doc "The permission groups, in matrix order. Groups with `editable: false` never appear in the drawer."
  def groups do
    Enum.map(@groups, fn g ->
      g
      |> Map.put_new(:editable, true)
      |> Map.update!(:label, &translate/1)
      |> Map.update!(:actions, fn actions -> for {a, l} <- actions, do: {a, translate(l)} end)
    end)
  end

  # Labels are stored as msgids (`gettext_noop`) and translated when shown, in the
  # locale of the calling process. `permissions/0` and `templates/0` keep the
  # msgids: they seed the database (PermitEx descriptions), not the screen.
  defp translate(msgid), do: Gettext.gettext(LedgerStarterWeb.Gettext, msgid)

  @doc "Every `{name, description}` of the catalog."
  def permissions do
    actions =
      for g <- @groups, {action, label} <- g.actions do
        {"#{g.key}:#{action}", "#{g.label}: #{String.downcase(label)}"}
      end

    scopes =
      for g <- @groups, g.scoped, {scope, label} <- [{"team", "do time"}, {"all", "todos"}] do
        {"#{g.key}:#{scope}", "#{g.label}: escopo #{label}"}
      end

    actions ++ scopes
  end

  def permission_names, do: Enum.map(permissions(), &elem(&1, 0))

  # Compile-time helper for the templates: `crm.("contacts", ~w(read write), "team")`.
  crm = fn key, actions, scope ->
    Enum.map(actions, &"#{key}:#{&1}") ++ if(scope, do: ["#{key}:#{scope}"], else: [])
  end

  @templates [
    %{
      name: "owner",
      label: gettext_noop("Dono"),
      blurb: gettext_noop("acesso total"),
      tone: "primary",
      locked: true,
      permissions: :all
    },
    %{
      name: "admin",
      label: gettext_noop("Admin"),
      blurb: gettext_noop("equipe e cobrança"),
      tone: "info",
      locked: true,
      permissions:
        Enum.flat_map(~w(contacts deals tasks reports), &crm.(&1, ~w(read write delete), "all")) ++
          ~w(data:read data:write team:read team:write team:delete billing:read)
    },
    %{
      name: "sales",
      label: gettext_noop("Vendas"),
      blurb: gettext_noop("CRM do time"),
      tone: "success",
      locked: false,
      permissions:
        crm.("contacts", ~w(read write), "team") ++
          crm.("deals", ~w(read write), nil) ++
          crm.("tasks", ~w(read write delete), nil) ++
          crm.("reports", ~w(read), "team")
    },
    %{
      name: "viewer",
      label: gettext_noop("Leitura"),
      blurb: gettext_noop("só relatórios"),
      tone: "neutral",
      locked: false,
      permissions:
        crm.("contacts", ~w(read), "all") ++
          crm.("deals", ~w(read), "all") ++ crm.("reports", ~w(read), "all")
    }
  ]

  @doc "The role templates (maps with `:name`, `:label`, `:blurb`, `:tone`, `:locked`, `:permissions`)."
  def templates do
    Enum.map(@templates, fn
      %{permissions: :all} = t -> %{t | permissions: permission_names()}
      t -> t
    end)
  end

  def role_names, do: Enum.map(@templates, & &1.name)

  @doc "Names of the roles that are locked in every company."
  def locked_role_names, do: for(t <- @templates, t.locked, do: t.name)

  def seed_templates! do
    roles = for t <- templates(), do: {t.name, t.label, t.permissions}
    {:ok, :ok} = PermitEx.seed!([permissions: permissions(), roles: roles], repo: Repo)
    :ok
  end

  @doc """
  Clones the templates into the company (context), once. Roles of a company that
  already has them are left alone: they may have been edited since.
  """
  def setup_company!(company_id) do
    if PermitEx.roles_for_context(company_id, repo: Repo) == [] do
      seed_templates!()
      {:ok, _} = PermitEx.clone_roles_to_context(company_id, repo: Repo)
      lock_system_roles!(company_id)
    end

    PermitEx.roles_for_context(company_id, repo: Repo)
  end

  defp lock_system_roles!(company_id) do
    for role <- PermitEx.roles_for_context(company_id, repo: Repo),
        role.name in locked_role_names() do
      {:ok, _} = PermitEx.update_role(role, %{locked: true}, repo: Repo, force?: true)
    end

    :ok
  end

  @doc """
  Brings the database to the current catalog: upserts permissions and templates,
  drops permissions that left the catalog and re-clones the template roles into
  every company (custom roles are left alone). Used by the data migration.
  """
  def sync_catalog! do
    seed_templates!()
    names = permission_names()

    for p <- PermitEx.list_permissions(repo: Repo), p.name not in names do
      {:ok, _} = PermitEx.delete_permission(p, repo: Repo)
    end

    company_ids =
      Repo.all(
        from r in PermitEx.Role,
          where: not is_nil(r.context_id),
          distinct: r.context_id,
          select: r.context_id
      )

    for id <- company_ids do
      {:ok, _} = PermitEx.clone_roles_to_context(id, repo: Repo, roles: role_names())
      lock_system_roles!(id)
    end

    :ok
  end

  @doc """
  Data migration of the old `member` role (and pending `member` invitations) to
  `sales` ("Vendas"), in place so every assignment is kept. Run before `sync_catalog!/0`.
  """
  def migrate_legacy_member_role! do
    Repo.query!(
      "UPDATE permit_ex_roles SET name = 'sales', description = 'Vendas' WHERE name = 'member'"
    )

    Repo.query!("UPDATE invitations SET role = 'sales' WHERE role = 'member'")
    :ok
  end

  def assign_role(user_id, role, company_id) when is_binary(role) do
    PermitEx.sync_roles(user_id, [role], company_id, repo: Repo)
  end

  @doc "The role name the user holds inside the company (or nil)."
  def role_of(user_id, company_id) do
    case PermitEx.roles_for(user_id, company_id, repo: Repo) do
      [%{name: name} | _] -> name
      [] -> nil
    end
  end

  @doc "The display name of the role the user holds inside the company (or nil)."
  def role_label_of(user_id, company_id) do
    case PermitEx.roles_for(user_id, company_id, repo: Repo) do
      [role | _] -> label(role)
      [] -> nil
    end
  end

  @doc "A role's display name (its PermitEx description, falling back to the name)."
  def label(%{name: name, description: d}) when is_binary(d) and d != "" do
    # a template role still carrying its seeded name is shown in the current language;
    # a renamed one keeps whatever name it was given
    case Enum.find(@templates, &(&1.name == name)) do
      %{label: ^d} -> translate(d)
      _ -> d
    end
  end

  def label(%{name: name}) do
    case Enum.find(@templates, &(&1.name == name)) do
      %{label: label} -> translate(label)
      nil -> name
    end
  end

  ## Reading roles (needs `team:read`)

  @doc """
  The company's roles as `%{role, name, label, blurb, tone, locked, custom,
  permissions, members}`, templates first (owner, admin, sales, viewer), then
  custom roles by name.
  """
  def list_roles(%Scope{company: company} = scope) do
    with :ok <- PermitEx.authorize(scope, "team:read") do
      {:ok,
       company.id
       |> PermitEx.list_roles(repo: Repo)
       |> Enum.filter(&(&1.context_id == company.id))
       |> Enum.map(&describe(&1, company.id))
       |> Enum.sort_by(fn r ->
         {Enum.find_index(role_names(), &(&1 == r.name)) || length(role_names()), r.name}
       end)}
    end
  end

  def get_role(scope, name) do
    with {:ok, roles} <- list_roles(scope) do
      case Enum.find(roles, &(&1.name == name)) do
        nil -> {:error, :not_found}
        role -> {:ok, role}
      end
    end
  end

  defp describe(role, company_id) do
    template = Enum.find(@templates, &(&1.name == role.name))

    %{
      role: role,
      name: role.name,
      label: label(role),
      blurb: if(template, do: translate(template.blurb), else: gettext("papel personalizado")),
      tone: (template && template.tone) || "neutral",
      locked: role.locked,
      custom: is_nil(template),
      permissions: MapSet.new(role.permissions, & &1.name),
      members: length(PermitEx.users_with_role(role, company_id, repo: Repo))
    }
  end

  ## Levels (the matrix cell of a group)

  @doc """
  The matrix cell of a group for a set of permission names: `:none`,
  `{:scope, label}` (own/team), `:all` ("Tudo"), `:edit`, `:view` or `:partial`.
  """
  def level(group, %MapSet{} = perms) do
    has = fn a -> MapSet.member?(perms, "#{group.key}:#{a}") end
    actions = Enum.map(group.actions, &elem(&1, 0))
    held = Enum.filter(actions, has)
    scope = if group.scoped, do: scope_of(group, perms)

    cond do
      held == [] ->
        :none

      group.scoped and not has.("read") ->
        :none

      scope in ["own", "team"] ->
        {:scope, if(scope == "team", do: gettext("Do time"), else: gettext("Só os seus"))}

      length(held) == length(actions) ->
        :all

      held == ["read"] ->
        :view

      has.("write") and not has.("delete") ->
        :edit

      true ->
        :partial
    end
  end

  @doc "`\"own\"`, `\"team\"` or `\"all\"`."
  def scope_of(group, perms) do
    cond do
      MapSet.member?(perms, "#{group.key}:all") -> "all"
      MapSet.member?(perms, "#{group.key}:team") -> "team"
      true -> "own"
    end
  end

  @doc "The state of the drawer's switches for a set of permissions: `%{group_key => %{...}}`."
  def form_state(%MapSet{} = perms) do
    for g <- groups(), g.editable, into: %{} do
      state =
        for({a, _} <- g.actions, into: %{}, do: {a, MapSet.member?(perms, "#{g.key}:#{a}")})
        |> Map.put("scope", scope_of(g, perms))

      {g.key, state}
    end
  end

  @doc """
  Turns the drawer params (`%{"contacts" => %{"read" => "true", ..., "scope" => "team"}}`)
  into permission names. Unknown keys are ignored; a group whose `read` is off keeps
  nothing when reading is required for it.
  """
  def permissions_from_params(params) when is_map(params) do
    for g <- groups(), g.editable, reduce: [] do
      acc ->
        gp = params[g.key] || %{}
        actions = for {a, _} <- g.actions, gp[a] in ["true", true, "on"], do: a
        actions = if g.requires_read and "read" not in actions, do: [], else: actions

        scope =
          if g.scoped and actions != [] and gp["scope"] in ["team", "all"],
            do: ["#{g.key}:#{gp["scope"]}"],
            else: []

        acc ++ Enum.map(actions, &"#{g.key}:#{&1}") ++ scope
    end
  end

  def permissions_from_params(_), do: []

  ## Writing roles (needs `team:write`)

  @doc """
  Updates a company role from `%{"label" => ..., "permissions" => [names]}`.
  Locked roles (Dono, Admin) are refused, and nobody can grant a permission they
  do not hold. Returns `{:ok, role}` or `{:error, reason}`
  (`:unauthorized`, `:not_found`, `:role_locked`, `:blank_label`, `:label_too_long`, `:escalation`).
  """
  def update_role(%Scope{} = scope, name, %{} = attrs) do
    with :ok <- PermitEx.authorize(scope, "team:write"),
         {:ok, role} <- get_role(scope, name),
         :ok <- check_unlocked(role),
         {:ok, label} <- clean_label(attrs["label"] || role.label),
         {:ok, perms} <- check_grant(scope, attrs["permissions"], role.permissions),
         {:ok, _} <- PermitEx.update_role(role.role, %{description: label}, repo: Repo),
         {:ok, _} <- PermitEx.sync_role_permissions(role.role, perms, repo: Repo) do
      get_role(scope, name)
    end
  end

  @doc "Creates a custom company role from a display name and permissions."
  def create_role(%Scope{company: company} = scope, %{} = attrs) do
    with :ok <- PermitEx.authorize(scope, "team:write"),
         {:ok, label} <- clean_label(attrs["label"]),
         {:ok, perms} <- check_grant(scope, attrs["permissions"], MapSet.new()),
         name = unique_name(company.id, label),
         {:ok, role} <-
           PermitEx.create_role(%{name: name, description: label, context_id: company.id},
             repo: Repo
           ),
         {:ok, _} <- PermitEx.sync_role_permissions(role, perms, repo: Repo) do
      get_role(scope, name)
    end
  end

  defp check_unlocked(%{locked: true}), do: {:error, :role_locked}
  defp check_unlocked(_), do: :ok

  defp clean_label(label) when is_binary(label) do
    case String.trim(label) do
      "" -> {:error, :blank_label}
      l when byte_size(l) > 40 -> {:error, :label_too_long}
      l -> {:ok, l}
    end
  end

  defp clean_label(_), do: {:error, :blank_label}

  defp check_grant(scope, perms, current) when is_list(perms) do
    perms = perms |> Enum.uniq() |> Enum.filter(&(&1 in permission_names()))
    added = MapSet.difference(MapSet.new(perms), current)

    if Enum.all?(added, &PermitEx.can?(scope, &1)),
      do: {:ok, perms},
      else: {:error, :escalation}
  end

  defp check_grant(_, _, _), do: {:ok, []}

  # "Vendas Sul" -> "vendas_sul"; skips taken names and 16-byte names (PermitEx reads those as UUIDs).
  defp unique_name(company_id, label) do
    taken = company_id |> PermitEx.roles_for_context(repo: Repo) |> MapSet.new(& &1.name)

    base =
      label
      |> String.normalize(:nfd)
      |> String.replace(~r/\p{Mn}/u, "")
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "_")
      |> String.trim("_")
      |> String.slice(0, 40)
      |> then(&if &1 == "", do: "papel", else: &1)

    1
    |> Stream.iterate(&(&1 + 1))
    |> Stream.map(&if &1 == 1, do: base, else: "#{base}_#{&1}")
    |> Enum.find(&(not MapSet.member?(taken, &1) and byte_size(&1) != 16))
  end
end
