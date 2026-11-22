defmodule LedgerStarterWeb.TeamLive do
  use LedgerStarterWeb, :live_view

  alias LedgerStarter.Companies
  alias LedgerStarter.Accounts.Scope
  alias LedgerStarter.Permissions
  alias LedgerStarterWeb.{Layouts, TeamComponents, Tenant}

  on_mount {LedgerStarterWeb.UserAuth, {:require_permission, "team:read", :equipe}}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      companies={@companies}
      current={~p"/equipe"}
      crumb={gettext("Equipe")}
    >
      <.async_result :let={team} assign={@team}>
        <:loading>
          <div class="px-7 py-6"><.skeleton class="h-40 w-full" /></div>
        </:loading>
        <.page_header title={gettext("Equipe")} description={seats_text(team.seats)}>
          <:actions>
            <.button
              :if={PermitEx.can?(@current_scope, "team:write")}
              id="invite-people"
              patch={~p"/equipe/convidar"}
              icon="user-plus"
            >
              {gettext("Convidar pessoas")}
            </.button>
          </:actions>
        </.page_header>
        <TeamComponents.team_tabs current={:team} count={length(team.rows)} />

        <div class="px-7 pb-8">
          <.card_table
            id="team"
            rows={team.rows}
            row_id={& &1.id}
            retry_label={gettext("Tentar novamente")}
          >
            <:col :let={row} label={gettext("Pessoa")}>
              <span class="flex items-center gap-2.5">
                <.avatar initials={Layouts.initials(row.name || row.email)} size="34" />
                <span class="flex flex-col leading-tight">
                  <span class="font-medium">{row.name || row.email}</span>
                  <span class="text-[12.5px] text-muted">{row.email}</span>
                </span>
              </span>
            </:col>
            <:col :let={row} label={gettext("Papel")}>
              <.badge color={if row.role == "owner", do: "primary", else: "neutral"}>
                {row.role_label || gettext("Sem papel")}
              </.badge>
            </:col>
            <:col :let={row} label={gettext("Status")} role="status">
              <span class={row.status == :pending && "text-muted"}>
                {if row.status == :pending, do: gettext("Convite enviado"), else: gettext("Ativo")}
              </span>
            </:col>
            <:action :let={row}>
              <.dropdown
                :if={menu?(@current_scope, row)}
                id={"team-menu-#{row.id}"}
                trigger_style="ghost"
                part="action-menu"
                row_mark
                label={gettext("Ações")}
                placement="bottom-end"
              >
                <%= if row.status == :active do %>
                  <.dropdown_item
                    :for={{value, label, _} <- @roles}
                    :if={PermitEx.can?(@current_scope, "team:write") and row.role != "owner"}
                    selected={row.role == value}
                    phx-click="set_role"
                    phx-value-user-id={row.user_id}
                    phx-value-role={value}
                  >
                    {gettext("Tornar %{role}", role: label)}
                  </.dropdown_item>
                <% else %>
                  <.dropdown_item danger phx-click="revoke" phx-value-id={row.id}>
                    <:icon><.icon name="trash" /></:icon>
                    {gettext("Cancelar convite")}
                  </.dropdown_item>
                <% end %>
              </.dropdown>
            </:action>
          </.card_table>
        </div>
      </.async_result>

      <:aside>
        <.drawer
          :if={@live_action == :invite}
          id="invite-drawer"
          layout="page"
          open
          side="right"
          on_close="close_drawer"
        >
          <:header>
            <div>
              <h3>{gettext("Convidar pessoas")}</h3>
              <p>
                {gettext("Eles recebem um link para entrar em %{host}.",
                  host: Tenant.company_host(@current_company)
                )}
              </p>
            </div>
          </:header>
          <.form
            for={@form}
            id="invite-form"
            phx-submit="invite"
            phx-change="validate_invite"
            class="flex flex-col gap-5"
          >
            <.input
              field={@form[:emails]}
              label={gettext("E-mails")}
              placeholder={gettext("paula@empresa.com.br, joao@empresa.com.br")}
              help={gettext("Separe por vírgula.")}
              phx-debounce="200"
            />
            <div class="flex flex-col gap-1.5">
              <span class="text-[13px] font-medium">{gettext("Papel")}</span>
              <.radio_group
                field={@form[:role]}
                variant="card"
                options={
                  for {value, label, description} <- @roles,
                      do: %{label: label, value: value, description: description}
                }
              />
            </div>
            <.alert color={if @seats_after > @seats.limit, do: "warning", else: "info"}>
              {gettext("Você está usando %{used} de %{limit} assentos.",
                used: @seats.used,
                limit: @seats.limit
              )}
              <%= if @seats_after > @seats.limit do %>
                {gettext("Estes convites passam do limite.")}
              <% end %>
            </.alert>
          </.form>
          <:footer>
            <.button type="button" variant="outline" phx-click="close_drawer">
              {gettext("Cancelar")}
            </.button>
            <.button type="submit" form="invite-form" phx-disable-with={gettext("Enviando...")}>
              {send_label(@email_count)}
            </.button>
          </:footer>
        </.drawer>
      </:aside>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    roles = role_options(scope)

    {:ok,
     socket
     |> assign(
       roles: roles,
       page_title: gettext("Equipe"),
       seats: Companies.seats_info(scope),
       email_count: 0,
       seats_after: 0
     )
     |> assign(form: invite_form(%{"role" => default_role(roles)}))
     |> assign_new(:companies, fn -> Companies.list_companies_for_user(scope.user) end)
     |> load_team()}
  end

  @impl true
  def handle_params(_params, _uri, %{assigns: %{live_action: :invite}} = socket) do
    if PermitEx.can?(socket.assigns.current_scope, "team:write") do
      {:noreply, assign(socket, seats: Companies.seats_info(socket.assigns.current_scope))}
    else
      {:noreply,
       socket
       |> put_flash(:error, gettext("Você não tem permissão para convidar."))
       |> push_patch(to: ~p"/equipe")}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  # The roles an invitation or "Tornar ..." can give: every company role but the owner.
  defp role_options(scope) do
    case Permissions.list_roles(scope) do
      {:ok, roles} -> for r <- roles, r.name != "owner", do: {r.name, r.label, r.blurb}
      _ -> []
    end
  end

  defp default_role(roles) do
    case Enum.find(roles, fn {name, _, _} -> name == "sales" end) || List.first(roles) do
      {name, _, _} -> name
      nil -> nil
    end
  end

  defp menu?(scope, %{status: :pending}), do: PermitEx.can?(scope, "team:write")
  defp menu?(scope, %{role: role}), do: role != "owner" and PermitEx.can?(scope, "team:write")

  defp invite_form(params), do: to_form(Map.take(params, ["emails", "role"]), as: "invite")

  @impl true
  def handle_event("close_drawer", _params, socket),
    do: {:noreply, push_patch(socket, to: ~p"/equipe")}

  def handle_event("validate_invite", %{"invite" => params}, socket) do
    count = params["emails"] |> Companies.parse_emails() |> length()

    {:noreply,
     assign(socket,
       form: invite_form(params),
       email_count: count,
       seats_after: socket.assigns.seats.used + count
     )}
  end

  def handle_event("invite", %{"invite" => params}, socket) do
    scope = socket.assigns.current_scope
    url_fun = &Tenant.root_url("/convites/#{&1}")

    case Companies.invite_people(scope, params["emails"] || "", params["role"], url_fun) do
      {:ok, %{sent: sent, skipped: skipped}} ->
        sent_text =
          ngettext("%{count} convite enviado", "%{count} convites enviados", length(sent))

        msg =
          if skipped == [],
            do: sent_text <> ".",
            else:
              gettext("%{sent} (%{skipped} já na equipe ou inválido).",
                sent: sent_text,
                skipped: length(skipped)
              )

        {:noreply,
         socket
         |> put_flash(:info, msg)
         |> assign(
           email_count: 0,
           form: invite_form(%{"role" => default_role(socket.assigns.roles)})
         )
         |> load_team()
         |> push_patch(to: ~p"/equipe")}

      {:error, :unauthorized} ->
        {:noreply, put_flash(socket, :error, gettext("Você não tem permissão para convidar."))}

      {:error, :no_emails} ->
        {:noreply, put_flash(socket, :error, gettext("Informe ao menos um e-mail."))}

      {:error, :seats_exceeded} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           gettext("Limite de assentos atingido. Remova convites ou aumente o plano.")
         )}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Não foi possível enviar os convites."))}
    end
  end

  def handle_event("revoke", %{"id" => id}, socket) do
    case Companies.revoke_invitation(socket.assigns.current_scope, id) do
      :ok ->
        {:noreply,
         socket |> put_toast(gettext("Convite cancelado."), color: "success") |> load_team()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Não foi possível cancelar o convite."))}
    end
  end

  def handle_event("set_role", %{"user-id" => user_id, "role" => role}, socket) do
    scope = socket.assigns.current_scope

    case Companies.update_member_role(scope, user_id, role) do
      :ok ->
        scope = if user_id == scope.user.id, do: Scope.reload(scope), else: scope

        {:noreply,
         socket
         |> assign(current_scope: scope)
         |> put_toast(gettext("Papel atualizado."), color: "success")
         |> load_team()}

      {:error, :last_owner} ->
        {:noreply, put_flash(socket, :error, gettext("O workspace precisa de ao menos um dono."))}

      {:error, _} ->
        {:noreply,
         put_flash(socket, :error, gettext("Você não tem permissão para alterar papéis."))}
    end
  end

  defp load_team(socket) do
    scope = socket.assigns.current_scope
    locale = LedgerStarter.Locale.current()

    assign_async(socket, :team, fn ->
      # the async task is another process: carry the Gettext locale over (role labels)
      LedgerStarter.Locale.put(locale)

      with {:ok, roles} <- Permissions.list_roles(scope),
           labels = Map.new(roles, &{&1.name, &1.label}),
           {:ok, members} <- Companies.list_members(scope),
           {:ok, invites} <- Companies.list_pending_invitations(scope) do
        rows =
          Enum.map(members, fn m ->
            %{
              id: m.membership.id,
              user_id: m.user.id,
              name: m.user.name,
              email: m.user.email,
              role: m.role,
              role_label: m.role_label,
              status: :active
            }
          end) ++
            Enum.map(invites, fn i ->
              %{
                id: i.id,
                user_id: nil,
                name: nil,
                email: i.email,
                role: i.role,
                role_label: Map.get(labels, i.role, i.role),
                status: :pending
              }
            end)

        {:ok, %{team: %{rows: rows, seats: Companies.seats_info(scope)}}}
      else
        _ -> {:error, :unauthorized}
      end
    end)
  end

  defp seats_text(%{used: used, limit: limit}),
    do: gettext("%{used} de %{limit} assentos em uso.", used: used, limit: limit)

  defp send_label(0), do: gettext("Enviar convites")

  defp send_label(n),
    do: ngettext("Enviar %{count} convite", "Enviar %{count} convites", n)
end
