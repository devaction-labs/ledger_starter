defmodule LedgerStarterWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use LedgerStarterWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  alias LedgerStarterWeb.Tenant

  @doc """
  The tenant app frame: the `shell` with the sidebar (workspace switcher on top),
  a top bar with breadcrumbs, theme switch and the user menu.
  """
  attr :flash, :map, default: %{}
  attr :current_scope, :map, required: true
  attr :companies, :list, default: []
  attr :current, :string, required: true, doc: "the current path, to mark the menu item"
  attr :crumb, :string, required: true
  slot :inner_block, required: true
  slot :aside

  def app(assigns) do
    scope = assigns.current_scope
    company = scope.company
    user = scope.user

    assigns =
      assigns
      |> assign(:company, company)
      |> assign(:user_map, user_map(user, scope))
      |> assign(:nav, nav(scope))

    ~H"""
    <.shell
      id="shell"
      full
      format="sections"
      nav={@nav}
      current={@current}
      brand={%{name: @company.name}}
      user={@user_map}
      footer="none"
    >
      <:brand_mark>
        <.workspace_switcher company={@company} companies={@companies} />
      </:brand_mark>
      <:topbar>
        <.navbar>
          <.navbar_crumbs items={[%{label: @company.name}, %{label: @crumb}]} />
          <:end>
            <.locale_switcher />
            <.theme_switch
              id="theme"
              size="sm"
              label={gettext("Tema")}
              light_label={gettext("Claro")}
              dark_label={gettext("Escuro")}
              system_label={gettext("Sistema")}
            />
            <.navbar_user id="me" user={@user_map}>
              <:menu>
                <.navbar_menu_head user={@user_map} />
                <.navbar_menu_item icon="settings" href={Tenant.root_url("/users/settings")}>
                  {gettext("Minha conta")}
                </.navbar_menu_item>
                <.navbar_menu_item
                  icon="logout"
                  danger
                  href={Tenant.root_url("/users/log-out")}
                  method="delete"
                >
                  {gettext("Sair")}
                </.navbar_menu_item>
              </:menu>
            </.navbar_user>
          </:end>
        </.navbar>
      </:topbar>
      {render_slot(@inner_block)}
      <:aside>
        {render_slot(@aside)}
        <.toaster flash={@flash} close_label={gettext("Fechar")} />
      </:aside>
    </.shell>
    """
  end

  defp nav(scope) do
    team =
      if PermitEx.can?(scope, "team:read"),
        do: [%{label: gettext("Equipe"), icon: "users", navigate: ~p"/equipe"}],
        else: []

    [
      %{
        group: gettext("Geral"),
        items: [%{label: gettext("Início"), icon: "home", navigate: ~p"/painel"}]
      },
      %{
        group: gettext("CRM"),
        items: [%{label: gettext("Contatos"), icon: "users", navigate: ~p"/contatos"}]
      }
    ] ++ if(team == [], do: [], else: [%{group: gettext("Workspace"), items: team}])
  end

  defp user_map(user, scope) do
    name = user.name || user.email
    role = scope.roles |> List.first() |> then(&(&1 && LedgerStarter.Permissions.label(&1)))

    %{name: name, email: user.email, initials: initials(name), role: role}
  end

  @doc "Display name of a role template (custom roles show their own name)."
  def role_label("owner"), do: gettext("Dono")
  def role_label("admin"), do: gettext("Admin")
  def role_label("sales"), do: gettext("Vendas")
  def role_label("viewer"), do: gettext("Leitura")
  def role_label(other), do: other

  def initials(name) when is_binary(name) do
    name
    |> String.split(~r/[\s@.]+/, trim: true)
    |> Enum.take(2)
    |> Enum.map_join(&String.first/1)
    |> String.upcase()
  end

  def initials(_), do: "?"

  attr :company, :map, required: true
  attr :companies, :list, required: true

  @doc "Workspace switcher: the company on top of the sidebar, a dropdown with the user's companies."
  def workspace_switcher(assigns) do
    ~H"""
    <.dropdown
      id="workspace-switcher"
      placement="bottom-start"
      trigger_style="ghost"
      toggle_class="w-full justify-start"
      menu_style="min-width:240px"
      label={gettext("Trocar de workspace")}
    >
      <:trigger>
        <span class="flex items-center gap-2.5 text-left">
          <.avatar initials={initials(@company.name)} shape="squircle" />
          <span class="flex min-w-0 flex-col">
            <b class="truncate text-[14px] font-semibold text-ink">{@company.name}</b>
            <span class="truncate text-[12px] text-muted">{Tenant.company_host(@company)}</span>
          </span>
          <.icon name="updown" size="md" class="text-muted" />
        </span>
      </:trigger>
      <:title>{gettext("Seus workspaces")}</:title>
      <.dropdown_item
        :for={c <- @companies}
        href={Tenant.company_url(c, "/painel")}
        selected={c.id == @company.id}
        description={Tenant.company_host(c)}
        two_line
      >
        {c.name}
      </.dropdown_item>
      <.dropdown_separator />
      <.dropdown_item href={Tenant.root_url("/empresas/nova")}>
        <:icon><.icon name="plus" /></:icon>
        {gettext("Criar empresa")}
      </.dropdown_item>
    </.dropdown>
    """
  end
end
