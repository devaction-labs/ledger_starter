defmodule LedgerStarterWeb.RolesLive do
  @moduledoc """
  "Papéis e permissões": the matrix of roles x permission groups, the role
  cards with their member counts and the "Editar papel" / "Novo papel" drawer.

  Anyone with `team:read` sees the matrix; only whoever holds `team:write`
  can open the drawer and save (Dono and Admin are locked, and nobody can grant
  a permission they do not hold themselves; see `LedgerStarter.Permissions`).
  """
  use LedgerStarterWeb, :live_view

  alias LedgerStarter.Accounts.Scope
  alias LedgerStarter.{Companies, Permissions}
  alias LedgerStarterWeb.TeamComponents

  on_mount {LedgerStarterWeb.UserAuth, {:require_permission, "team:read", :papeis}}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      companies={@companies}
      current={~p"/equipe"}
      crumb={gettext("Papéis e permissões")}
    >
      <.page_header
        title={gettext("Papéis e permissões")}
        description={
          gettext("Defina o que cada papel pode ver e fazer no workspace %{name}.",
            name: @current_company.name
          )
        }
      >
        <:actions>
          <.button
            :if={PermitEx.can?(@current_scope, "team:write")}
            id="new-role"
            patch={~p"/equipe/papeis/novo"}
            icon="plus"
          >
            {gettext("Novo papel")}
          </.button>
        </:actions>
      </.page_header>
      <TeamComponents.team_tabs current={:roles} count={@member_count} />

      <.async_result :let={roles} assign={@roles}>
        <:loading>
          <div class="px-7 py-6"><.skeleton class="h-40 w-full" /></div>
        </:loading>

        <div id="role-cards" class="grid grid-cols-2 gap-3 px-7 pb-5 lg:grid-cols-4">
          <.mini_card
            :for={role <- roles}
            id={"role-card-#{role.name}"}
            surface="card"
            icon="shield"
            tone={tone(role.tone)}
            label={role.label}
            navigate={edit_path(@current_scope, role)}
          >
            {people(role.members)} · {role.blurb}
          </.mini_card>
        </div>

        <div class="px-7 pb-8">
          <.card title={gettext("Matriz de permissões")}>
            <:actions>
              <.badge id="editable-roles">{editable_text(roles)}</.badge>
            </:actions>
            <.table id="perms">
              <.table_head>
                <:col label={gettext("Recurso")} />
                <:col :for={role <- roles} label={role.label} />
              </.table_head>
              <.table_body id="perms-body">
                <.table_row :for={group <- @groups} id={"perm-row-#{group.key}"}>
                  <.table_cell class="whitespace-nowrap">
                    <span class="flex items-center gap-2.5">
                      <.icon name={group.icon} /><b class="font-medium">{group.label}</b>
                    </span>
                  </.table_cell>
                  <.table_cell :for={role <- roles} class="whitespace-nowrap">
                    <.level_badge level={Permissions.level(group, role.permissions)} />
                  </.table_cell>
                </.table_row>
              </.table_body>
            </.table>
          </.card>
        </div>
      </.async_result>

      <:aside>
        <.drawer
          :if={@form}
          id="role-drawer"
          layout="page"
          open
          side="right"
          on_close="close_drawer"
        >
          <:header>
            <div>
              <h3>{@drawer_title}</h3>
              <p>{@drawer_description}</p>
            </div>
          </:header>
          <.form for={@form} id="role-form" phx-submit="save" class="flex flex-col gap-5">
            <.input field={@form[:label]} label={gettext("Nome do papel")} maxlength="40" />
            <div :for={group <- @groups} :if={group.editable} class="flex flex-col gap-3">
              <span class="flex items-center gap-2.5">
                <.icon name={group.icon} /><b class="font-medium">{group.label}</b>
              </span>
              <div class="flex flex-wrap gap-x-5 gap-y-2">
                <.switch
                  :for={{action, label} <- group.actions}
                  id={"sw-#{group.key}-#{action}"}
                  name={"role[#{group.key}][#{action}]"}
                  label={label}
                  checked={@state[group.key][action]}
                  disabled={not can_set?(@current_scope, group, action, @state)}
                />
              </div>
              <.segmented
                :if={group.scoped}
                id={"scope-#{group.key}"}
                name={"role[#{group.key}][scope]"}
                value={@state[group.key]["scope"]}
                options={[
                  {gettext("Só os seus"), "own"},
                  {gettext("Do time"), "team"},
                  {gettext("Todos"), "all"}
                ]}
              />
            </div>
          </.form>
          <:footer>
            <.button type="button" variant="outline" phx-click="close_drawer">
              {gettext("Cancelar")}
            </.button>
            <.button
              type="submit"
              form="role-form"
              icon="check"
              phx-disable-with={gettext("Salvando...")}
            >
              {gettext("Salvar papel")}
            </.button>
          </:footer>
        </.drawer>
      </:aside>
    </Layouts.app>
    """
  end

  attr :level, :any, required: true

  defp level_badge(%{level: :none} = assigns), do: ~H|<span class="text-muted">—</span>|

  defp level_badge(%{level: {:scope, label}} = assigns) do
    assigns = assign(assigns, :label, label)
    ~H|<.badge color="warning">{@label}</.badge>|
  end

  defp level_badge(%{level: :all} = assigns),
    do: ~H|<.badge color="success" icon="check">{gettext("Tudo")}</.badge>|

  defp level_badge(%{level: :view} = assigns),
    do: ~H|<.badge color="info" icon="eye">{gettext("Ver")}</.badge>|

  defp level_badge(%{level: :edit} = assigns),
    do: ~H|<.badge color="info">{gettext("Editar")}</.badge>|

  defp level_badge(assigns), do: ~H|<.badge color="neutral">{gettext("Parcial")}</.badge>|

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    {:ok,
     socket
     |> assign(
       page_title: gettext("Papéis e permissões"),
       groups: Permissions.groups(),
       member_count: nil,
       form: nil,
       state: %{}
     )
     |> assign_new(:companies, fn -> Companies.list_companies_for_user(scope.user) end)
     |> load_roles()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # The drawer only exists on the connected render: it reads the role from the database.
  defp apply_action(socket, :index, _params), do: close(socket)

  defp apply_action(socket, action, params) when action in [:new, :edit] do
    scope = socket.assigns.current_scope

    cond do
      not connected?(socket) ->
        close(socket)

      not PermitEx.can?(scope, "team:write") ->
        deny(socket, gettext("Você não tem permissão para editar papéis."))

      action == :new ->
        open(socket, nil, MapSet.new())

      true ->
        case Permissions.get_role(scope, params["role"]) do
          {:ok, %{locked: true}} ->
            deny(socket, gettext("Dono e Admin não podem ser editados."))

          {:ok, role} ->
            open(socket, role, role.permissions)

          {:error, _} ->
            deny(socket, gettext("Papel não encontrado."))
        end
    end
  end

  defp open(socket, role, permissions) do
    state = Permissions.form_state(permissions)
    label = role && role.label

    socket
    |> assign(
      role: role,
      state: state,
      form: to_form(%{"label" => label || ""}, as: :role),
      drawer_title:
        if(role,
          do: gettext("Editar papel · %{name}", name: role.label),
          else: gettext("Novo papel")
        ),
      drawer_description:
        if(role,
          do:
            ngettext(
              "%{count} pessoa usa este papel. A mudança vale no próximo clique delas.",
              "%{count} pessoas usam este papel. A mudança vale no próximo clique delas.",
              role.members
            ),
          else:
            gettext(
              "Escolha um nome e o que o papel pode fazer. Depois é só atribuí-lo na Equipe."
            )
        )
    )
  end

  defp close(socket), do: assign(socket, form: nil, role: nil)

  defp deny(socket, message) do
    socket |> put_flash(:error, message) |> push_patch(to: ~p"/equipe/papeis")
  end

  @impl true
  def handle_event("close_drawer", _params, socket),
    do: {:noreply, push_patch(socket, to: ~p"/equipe/papeis")}

  def handle_event("save", %{"role" => params}, socket) do
    scope = socket.assigns.current_scope

    attrs = %{
      "label" => params["label"],
      "permissions" => Permissions.permissions_from_params(params)
    }

    result =
      case socket.assigns do
        %{live_action: :new} -> Permissions.create_role(scope, attrs)
        %{live_action: :edit, role: %{name: name}} -> Permissions.update_role(scope, name, attrs)
        _ -> {:error, :not_found}
      end

    case result do
      {:ok, role} ->
        {:noreply,
         socket
         |> assign(current_scope: Scope.reload(scope))
         |> put_toast(gettext("Papel %{name} salvo.", name: role.label), color: "success")
         |> load_roles()
         |> push_patch(to: ~p"/equipe/papeis")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, error_message(reason))}
    end
  end

  defp error_message(:unauthorized), do: gettext("Você não tem permissão para editar papéis.")
  defp error_message(:role_locked), do: gettext("Dono e Admin não podem ser editados.")
  defp error_message(:blank_label), do: gettext("Dê um nome ao papel.")
  defp error_message(:label_too_long), do: gettext("O nome do papel pode ter até 40 caracteres.")

  defp error_message(:escalation),
    do: gettext("Você não pode liberar permissões que o seu próprio papel não tem.")

  defp error_message(_), do: gettext("Não foi possível salvar o papel.")

  defp load_roles(socket) do
    scope = socket.assigns.current_scope
    locale = LedgerStarter.Locale.current()

    socket
    |> assign(member_count: Companies.count_members(scope.company))
    |> assign_async(:roles, fn ->
      # the async task is another process: carry the Gettext locale over (role labels)
      LedgerStarter.Locale.put(locale)

      with {:ok, roles} <- Permissions.list_roles(scope), do: {:ok, %{roles: roles}}
    end)
  end

  defp edit_path(scope, role) do
    if not role.locked and PermitEx.can?(scope, "team:write"),
      do: ~p"/equipe/papeis/#{role.name}/editar"
  end

  # A switch is disabled when it is off and the editor could not turn it on (cannot grant what they lack).
  defp can_set?(scope, group, action, state) do
    state[group.key][action] or PermitEx.can?(scope, "#{group.key}:#{action}")
  end

  defp editable_text(roles) do
    case for(r <- roles, not r.locked, do: r.label) do
      [] ->
        gettext("Nenhum papel editável")

      [one] ->
        gettext("%{role} é editável", role: one)

      many ->
        gettext("%{roles} e %{last} são editáveis",
          roles: Enum.join(Enum.drop(many, -1), ", "),
          last: List.last(many)
        )
    end
  end

  defp people(n), do: ngettext("%{count} pessoa", "%{count} pessoas", n)

  defp tone("primary"), do: "accent"
  defp tone(t), do: t
end
