defmodule LedgerStarterWeb.DashboardLive do
  use LedgerStarterWeb, :live_view

  alias LedgerStarter.{Companies, Contacts}
  alias LedgerStarterWeb.Layouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_scope}
      companies={@companies}
      current={~p"/painel"}
      crumb="Início"
    >
      <.async_result :let={data} assign={@data}>
        <:loading>
          <div class="flex flex-col gap-5 px-7 py-6">
            <.skeleton class="h-48 w-full" />
          </div>
        </:loading>
        <div class="flex flex-col gap-5 px-7 py-6">
          <.hero_card
            id="dashboard-hero"
            eyebrow={"Olá, #{first_name(@current_scope.user)}"}
            title={hero_title(data)}
            description={hero_description(data)}
            steps={hero_steps(data)}
          >
            <:actions>
              <.button
                :if={PermitEx.can?(@current_scope, "team:write")}
                navigate={~p"/equipe/convidar"}
                color="mono"
                size="lg"
                icon="user-plus"
              >
                Convidar o time
              </.button>
              <.button
                :if={PermitEx.can?(@current_scope, "contacts:write")}
                navigate={~p"/contatos/novo"}
                variant="outline"
                size="lg"
                icon="plus"
              >
                Novo contato
              </.button>
            </:actions>
          </.hero_card>

          <div class="grid grid-cols-4 gap-3 max-lg:grid-cols-2">
            <.mini_card
              :if={PermitEx.can?(@current_scope, "contacts:write")}
              surface="card"
              icon="user-plus"
              tone="accent"
              label="Novo contato"
              navigate={~p"/contatos/novo"}
            />
            <.mini_card
              :if={PermitEx.can?(@current_scope, "team:write")}
              surface="card"
              icon="users"
              tone="info"
              label="Convidar pessoas"
              navigate={~p"/equipe/convidar"}
            />
            <.mini_card
              surface="card"
              icon="kanban"
              tone="success"
              label="Ver contatos"
              navigate={~p"/contatos"}
            />
            <.mini_card
              :if={PermitEx.can?(@current_scope, "team:read")}
              surface="card"
              icon="building"
              tone="warning"
              label="Equipe"
              navigate={~p"/equipe"}
            />
          </div>

          <div class="grid grid-cols-4 gap-3 max-lg:grid-cols-2" id="metrics">
            <.kpi_card id="kpi-total" label="Contatos" value={to_string(data.total)} trend="flat">
              <:icon><.icon name="users" /></:icon>
            </.kpi_card>
            <.kpi_card id="kpi-lead" label="Leads" value={to_string(data.stages.lead)} trend="flat">
              <:icon><.icon name="user-plus" /></:icon>
            </.kpi_card>
            <.kpi_card
              id="kpi-qualified"
              label="Qualificados"
              value={to_string(data.stages.qualified)}
              trend="flat"
            >
              <:icon><.icon name="star" /></:icon>
            </.kpi_card>
            <.kpi_card
              id="kpi-customer"
              label="Clientes"
              value={to_string(data.stages.customer)}
              trend="flat"
            >
              <:icon><.icon name="check" /></:icon>
            </.kpi_card>
          </div>

          <.card>
            <.card_header>
              <.card_heading>Contatos recentes</.card_heading>
              <.card_actions>
                <.button navigate={~p"/contatos"} size="sm" variant="ghost">Ver todos</.button>
              </.card_actions>
            </.card_header>
            <.card_body>
              <.table id="recent-contacts" rows={data.recent}>
                <:col :let={c} label="Nome">{c.name}</:col>
                <:col :let={c} label="Empresa">{c.company_name || "—"}</:col>
                <:col :let={c} label="Etapa">
                  <.badge color={stage_color(c.stage)} dot>{stage_label(c.stage)}</.badge>
                </:col>
              </.table>
            </.card_body>
          </.card>
        </div>
      </.async_result>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    {:ok,
     socket
     |> assign(page_title: "Início")
     |> assign_new(:companies, fn -> Companies.list_companies_for_user(scope.user) end)
     |> assign_async(:data, fn -> {:ok, %{data: load(scope)}} end)}
  end

  defp load(scope) do
    stages = Contacts.count_by_stage(scope)
    recent = scope |> Contacts.list_contacts() |> Enum.take(5)

    %{
      members: Companies.count_members(scope.company),
      stages: stages,
      total: Enum.sum(Map.values(stages)),
      recent: recent
    }
  end

  defp first_name(user),
    do: (user.name || user.email) |> String.split(~r/[\s@]/, parts: 2) |> hd()

  defp hero_title(%{total: 0}), do: "Seu CRM está quase pronto"

  defp hero_title(%{total: n}),
    do: "#{n} #{if n == 1, do: "contato", else: "contatos"} no seu funil"

  defp hero_description(data) do
    case Enum.count(hero_steps(data), &(&1.state != "done")) do
      0 ->
        "Tudo pronto: o time já pode vender pelo StartKit."

      n ->
        "Faltam #{n} #{if n == 1, do: "passo", else: "passos"} para o time vender pelo StartKit."
    end
  end

  defp hero_steps(data) do
    steps = [
      %{label: "Empresa", done: true},
      %{label: "Primeiro contato", done: data.total > 0},
      %{label: "Convidar o time", done: data.members > 1}
    ]

    {steps, _} =
      Enum.map_reduce(steps, false, fn s, found_current ->
        cond do
          s.done -> {%{label: s.label, state: "done"}, found_current}
          found_current -> {%{label: s.label, state: "todo"}, true}
          true -> {%{label: s.label, state: "current"}, true}
        end
      end)

    steps
  end

  def stage_label(:lead), do: "Lead"
  def stage_label(:qualified), do: "Qualificado"
  def stage_label(:customer), do: "Cliente"
  def stage_label(_), do: "—"

  def stage_color(:lead), do: "info"
  def stage_color(:qualified), do: "warning"
  def stage_color(:customer), do: "success"
  def stage_color(_), do: "neutral"
end
