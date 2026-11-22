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
            <.theme_switch id="theme" variant="icons" size="sm" />
            <.navbar_user id="me" user={@user_map}>
              <:menu>
                <.navbar_menu_head user={@user_map} />
                <.navbar_menu_item icon="settings" href={Tenant.root_url("/users/settings")}>
                  Minha conta
                </.navbar_menu_item>
                <.navbar_menu_item
                  icon="logout"
                  danger
                  href={Tenant.root_url("/users/log-out")}
                  method="delete"
                >
                  Sair
                </.navbar_menu_item>
              </:menu>
            </.navbar_user>
          </:end>
        </.navbar>
      </:topbar>
      {render_slot(@inner_block)}
      <:aside>
        {render_slot(@aside)}
        <.toaster flash={@flash} />
      </:aside>
    </.shell>
    """
  end

  defp nav(scope) do
    team =
      if PermitEx.can?(scope, "team:read"),
        do: [%{label: "Equipe", icon: "users", navigate: ~p"/equipe"}],
        else: []

    [
      %{group: "Geral", items: [%{label: "Início", icon: "home", navigate: ~p"/painel"}]},
      %{group: "CRM", items: [%{label: "Contatos", icon: "users", navigate: ~p"/contatos"}]}
    ] ++ if(team == [], do: [], else: [%{group: "Workspace", items: team}])
  end

  defp user_map(user, scope) do
    name = user.name || user.email
    role = LedgerStarter.Permissions.role_of(user.id, scope.company.id)

    %{name: name, email: user.email, initials: initials(name), role: role && role_label(role)}
  end

  def role_label("owner"), do: "Dono"
  def role_label("admin"), do: "Admin"
  def role_label("member"), do: "Membro"
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
      label="Trocar de workspace"
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
      <:title>Seus workspaces</:title>
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
        Criar empresa
      </.dropdown_item>
    </.dropdown>
    """
  end
end
