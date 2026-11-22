defmodule LedgerStarterWeb.TeamLive do
  use LedgerStarterWeb, :live_view

  alias LedgerStarter.Companies
  alias LedgerStarter.Accounts.Scope
  alias LedgerStarterWeb.{Layouts, Tenant}

  @roles [
    {"admin", "Admin", "Gerencia contatos e convida pessoas."},
    {"member", "Membro", "Cria e edita contatos."}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      companies={@companies}
      current={~p"/equipe"}
      crumb="Equipe"
    >
      <.async_result :let={team} assign={@team}>
        <:loading>
          <div class="px-7 py-6"><.skeleton class="h-40 w-full" /></div>
        </:loading>
        <.page_header title="Equipe" description={seats_text(team.seats)}>
          <:actions>
            <.button
              :if={PermitEx.can?(@current_scope, "team:invite")}
              id="invite-people"
              navigate={~p"/equipe/convidar"}
              icon="user-plus"
            >
              Convidar pessoas
            </.button>
          </:actions>
        </.page_header>

        <div class="px-7 pb-8">
          <.card_table id="team" rows={team.rows} row_id={& &1.id}>
            <:col :let={row} label="Pessoa">
              <span class="flex items-center gap-2.5">
                <.avatar initials={Layouts.initials(row.name || row.email)} size="34" />
                <span class="flex flex-col leading-tight">
                  <span class="font-medium">{row.name || row.email}</span>
                  <span class="text-[12.5px] text-muted">{row.email}</span>
                </span>
              </span>
            </:col>
            <:col :let={row} label="Papel">
              <.badge color={if row.role == "owner", do: "primary", else: "neutral"}>
                {Layouts.role_label(row.role)}
              </.badge>
            </:col>
            <:col :let={row} label="Status" role="status">
              <span class={row.status == :pending && "text-muted"}>
                {if row.status == :pending, do: "Convite enviado", else: "Ativo"}
              </span>
            </:col>
            <:action :let={row}>
              <.dropdown
                :if={menu?(@current_scope, row)}
                id={"team-menu-#{row.id}"}
                trigger_style="ghost"
                part="action-menu"
                row_mark
                label="Ações"
                placement="bottom-end"
              >
                <%= if row.status == :active do %>
                  <.dropdown_item
                    :for={{value, label, _} <- roles()}
                    :if={PermitEx.can?(@current_scope, "team:manage") and row.role != "owner"}
                    selected={row.role == value}
                    phx-click="set_role"
                    phx-value-user-id={row.user_id}
                    phx-value-role={value}
                  >
                    Tornar {label}
                  </.dropdown_item>
                <% else %>
                  <.dropdown_item danger phx-click="revoke" phx-value-id={row.id}>
                    <:icon><.icon name="trash" /></:icon>
                    Cancelar convite
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
              <h3>Convidar pessoas</h3>
              <p>Eles recebem um link para entrar em {Tenant.company_host(@current_company)}.</p>
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
              label="E-mails"
              placeholder="paula@empresa.com.br, joao@empresa.com.br"
              help="Separe por vírgula."
              phx-debounce="200"
            />
            <div class="flex flex-col gap-1.5">
              <span class="text-[13px] font-medium">Papel</span>
              <.radio_group
                field={@form[:role]}
                variant="card"
                options={
                  for {value, label, description} <- roles(),
                      do: %{label: label, value: value, description: description}
                }
              />
            </div>
            <.alert color={if @seats_after > @seats.limit, do: "warning", else: "info"}>
              Você está usando {@seats.used} de {@seats.limit} assentos.
              <%= if @seats_after > @seats.limit do %>
                Estes convites passam do limite.
              <% end %>
            </.alert>
          </.form>
          <:footer>
            <.button type="button" variant="outline" phx-click="close_drawer">Cancelar</.button>
            <.button type="submit" form="invite-form" phx-disable-with="Enviando...">
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

    if PermitEx.can?(scope, "team:read") do
      {:ok,
       socket
       |> assign(
         page_title: "Equipe",
         seats: Companies.seats_info(scope),
         email_count: 0,
         seats_after: 0
       )
       |> assign(form: invite_form(%{"role" => "member"}))
       |> assign_new(:companies, fn -> Companies.list_companies_for_user(scope.user) end)
       |> load_team()}
    else
      {:ok,
       socket
       |> put_flash(:error, "Você não tem permissão para ver a equipe.")
       |> push_navigate(to: ~p"/painel")}
    end
  end

  @impl true
  def handle_params(_params, _uri, %{assigns: %{live_action: :invite}} = socket) do
    if PermitEx.can?(socket.assigns.current_scope, "team:invite") do
      {:noreply, assign(socket, seats: Companies.seats_info(socket.assigns.current_scope))}
    else
      {:noreply,
       socket
       |> put_flash(:error, "Você não tem permissão para convidar.")
       |> push_patch(to: ~p"/equipe")}
    end
  end

  def handle_params(_params, _uri, socket), do: {:noreply, socket}

  defp roles, do: @roles

  defp menu?(scope, %{status: :pending}), do: PermitEx.can?(scope, "team:invite")
  defp menu?(scope, %{role: role}), do: role != "owner" and PermitEx.can?(scope, "team:manage")

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
        msg =
          "#{length(sent)} #{if length(sent) == 1, do: "convite enviado", else: "convites enviados"}" <>
            if(skipped == [], do: ".", else: " (#{length(skipped)} já na equipe ou inválido).")

        {:noreply,
         socket
         |> put_flash(:info, msg)
         |> assign(email_count: 0, form: invite_form(%{"role" => "member"}))
         |> load_team()
         |> push_patch(to: ~p"/equipe")}

      {:error, :unauthorized} ->
        {:noreply, put_flash(socket, :error, "Você não tem permissão para convidar.")}

      {:error, :no_emails} ->
        {:noreply, put_flash(socket, :error, "Informe ao menos um e-mail.")}

      {:error, :seats_exceeded} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "Limite de assentos atingido. Remova convites ou aumente o plano."
         )}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Não foi possível enviar os convites.")}
    end
  end

  def handle_event("revoke", %{"id" => id}, socket) do
    case Companies.revoke_invitation(socket.assigns.current_scope, id) do
      :ok ->
        {:noreply, socket |> put_toast("Convite cancelado.", color: "success") |> load_team()}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Não foi possível cancelar o convite.")}
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
         |> put_toast("Papel atualizado.", color: "success")
         |> load_team()}

      {:error, :last_owner} ->
        {:noreply, put_flash(socket, :error, "O workspace precisa de ao menos um dono.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Você não tem permissão para alterar papéis.")}
    end
  end

  defp load_team(socket) do
    scope = socket.assigns.current_scope

    assign_async(socket, :team, fn ->
      with {:ok, members} <- Companies.list_members(scope),
           {:ok, invites} <- Companies.list_pending_invitations(scope) do
        rows =
          Enum.map(members, fn m ->
            %{
              id: m.membership.id,
              user_id: m.user.id,
              name: m.user.name,
              email: m.user.email,
              role: m.role,
              status: :active
            }
          end) ++
            Enum.map(invites, fn i ->
              %{id: i.id, user_id: nil, name: nil, email: i.email, role: i.role, status: :pending}
            end)

        {:ok, %{team: %{rows: rows, seats: Companies.seats_info(scope)}}}
      else
        _ -> {:error, :unauthorized}
      end
    end)
  end

  defp seats_text(%{used: used, limit: limit}), do: "#{used} de #{limit} assentos em uso."

  defp send_label(0), do: "Enviar convites"
  defp send_label(1), do: "Enviar 1 convite"
  defp send_label(n), do: "Enviar #{n} convites"
end
