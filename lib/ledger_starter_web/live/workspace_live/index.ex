defmodule LedgerStarterWeb.WorkspaceLive.Index do
  @moduledoc "Choose a workspace (the user's companies, each linking to its subdomain)."
  use LedgerStarterWeb, :live_view

  import LedgerStarterWeb.AuthComponents

  alias LedgerStarter.{Companies, Permissions}
  alias LedgerStarterWeb.Tenant

  @impl true
  def render(assigns) do
    ~H"""
    <.auth_screen flash={@flash} id="workspaces" footer_right={gettext("Ajuda")}>
      <:chip
        icon="users"
        title={gettext("Um login, várias empresas")}
        subtitle={gettext("troque sem sair")}
        top="64px"
        left="56px"
      />

      <h1>{gettext("Escolha o workspace")}</h1>
      <p class="sub">
        {ngettext(
          "Você está em %{count} empresa com %{email}.",
          "Você está em %{count} empresas com %{email}.",
          length(@companies),
          email: @email
        )}
      </p>
      <div class="flex flex-col gap-2.5" id="workspace-list">
        <.mini_card
          :for={{company, role} <- @companies}
          id={"workspace-#{company.subdomain}"}
          surface="card"
          icon="building"
          label={company.name}
          href={Tenant.company_url(company, "/painel")}
        >
          {Tenant.company_host(company)} · {role}
        </.mini_card>
      </div>
      <.or_divider label={gettext("ou")} />
      <.button navigate={~p"/empresas/nova"} icon="plus" class="w-full" size="lg" variant="outline">
        {gettext("Criar uma nova empresa")}
      </.button>
      <p class="text-center text-[13.5px] text-muted">
        {gettext("Não é você?")}
        <.link href={~p"/users/log-out"} method="delete">{gettext("Sair")}</.link>
      </p>
    </.auth_screen>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user

    companies =
      for c <- Companies.list_companies_for_user(user),
          do: {c, Permissions.role_label_of(user.id, c.id)}

    {:ok,
     assign(socket,
       page_title: gettext("Escolher workspace"),
       companies: companies,
       email: user.email
     )}
  end
end
