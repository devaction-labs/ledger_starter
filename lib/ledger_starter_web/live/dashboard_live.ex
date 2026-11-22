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
      crumb={gettext("Início")}
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
            eyebrow={gettext("Olá, %{name}", name: first_name(@current_scope.user))}
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
                {gettext("Convidar o time")}
              </.button>
              <.button
                :if={PermitEx.can?(@current_scope, "contacts:write")}
                navigate={~p"/contatos/novo"}
                variant="outline"
                size="lg"
                icon="plus"
              >
                {gettext("Novo contato")}
              </.button>
            </:actions>
          </.hero_card>

          <div class="grid grid-cols-4 gap-3 max-lg:grid-cols-2">
            <.mini_card
              :if={PermitEx.can?(@current_scope, "contacts:write")}
              surface="card"
              icon="user-plus"
              tone="accent"
              label={gettext("Novo contato")}
              navigate={~p"/contatos/novo"}
            />
            <.mini_card
              :if={PermitEx.can?(@current_scope, "team:write")}
              surface="card"
              icon="users"
              tone="info"
              label={gettext("Convidar pessoas")}
              navigate={~p"/equipe/convidar"}
            />
            <.mini_card
              surface="card"
              icon="kanban"
              tone="success"
              label={gettext("Ver contatos")}
              navigate={~p"/contatos"}
            />
            <.mini_card
              :if={PermitEx.can?(@current_scope, "team:read")}
              surface="card"
              icon="building"
              tone="warning"
              label={gettext("Equipe")}
              navigate={~p"/equipe"}
            />
          </div>

          <div class="grid grid-cols-4 gap-3 max-lg:grid-cols-2" id="metrics">
            <.kpi_card
              id="kpi-total"
              label={gettext("Contatos")}
              value={to_string(data.total)}
              trend="flat"
            >
              <:icon><.icon name="users" /></:icon>
            </.kpi_card>
            <.kpi_card
              id="kpi-lead"
              label={gettext("Leads")}
              value={to_string(data.stages.lead)}
              trend="flat"
            >
              <:icon><.icon name="user-plus" /></:icon>
            </.kpi_card>
            <.kpi_card
              id="kpi-qualified"
              label={gettext("Qualificados")}
              value={to_string(data.stages.qualified)}
              trend="flat"
            >
              <:icon><.icon name="star" /></:icon>
            </.kpi_card>
            <.kpi_card
              id="kpi-customer"
              label={gettext("Clientes")}
              value={to_string(data.stages.customer)}
              trend="flat"
            >
              <:icon><.icon name="check" /></:icon>
            </.kpi_card>
          </div>

          <.card>
            <.card_header>
              <.card_heading>{gettext("Contatos recentes")}</.card_heading>
              <.card_actions>
                <.button navigate={~p"/contatos"} size="sm" variant="ghost">
                  {gettext("Ver todos")}
                </.button>
              </.card_actions>
            </.card_header>
            <.card_body>
              <.table id="recent-contacts" rows={data.recent}>
                <:col :let={c} label={gettext("Nome")}>{c.name}</:col>
                <:col :let={c} label={gettext("Empresa")}>{c.company_name || "—"}</:col>
                <:col :let={c} label={gettext("Etapa")}>
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
     |> assign(page_title: gettext("Início"))
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

  defp hero_title(%{total: 0}), do: gettext("Seu CRM está quase pronto")

  defp hero_title(%{total: n}),
    do: ngettext("%{count} contato no seu funil", "%{count} contatos no seu funil", n)

  defp hero_description(data) do
    case Enum.count(hero_steps(data), &(&1.state != "done")) do
      0 ->
        gettext("Tudo pronto: o time já pode vender pelo StartKit.")

      n ->
        ngettext(
          "Falta %{count} passo para o time vender pelo StartKit.",
          "Faltam %{count} passos para o time vender pelo StartKit.",
          n
        )
    end
  end

  defp hero_steps(data) do
    steps = [
      %{label: gettext("Empresa"), done: true},
      %{label: gettext("Primeiro contato"), done: data.total > 0},
      %{label: gettext("Convidar o time"), done: data.members > 1}
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

  def stage_label(:lead), do: gettext("Lead")
  def stage_label(:qualified), do: gettext("Qualificado")
  def stage_label(:customer), do: gettext("Cliente")
  def stage_label(_), do: "—"

  def stage_color(:lead), do: "info"
  def stage_color(:qualified), do: "warning"
  def stage_color(:customer), do: "success"
  def stage_color(_), do: "neutral"
end
