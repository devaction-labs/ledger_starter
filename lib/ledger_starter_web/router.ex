defmodule LedgerStarterWeb.Router do
  use LedgerStarterWeb, :router

  import LedgerStarterWeb.UserAuth
  import LedgerStarterWeb.Plugs.Tenant

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_host
    plug :fetch_live_flash
    plug :put_root_layout, html: {LedgerStarterWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  # Root host: landing, auth, create company, choose workspace.
  pipeline :root_host do
    plug :require_root_host
  end

  # Tenant host (<subdomain>.<base_host>): loads the company, requires a member.
  pipeline :tenant do
    plug :require_tenant
  end

  scope "/health", LedgerStarterWeb do
    get "/live", HealthController, :live
    get "/ready", HealthController, :ready
  end

  # "/" is the landing on the root host and a redirect to the dashboard on a tenant host.
  scope "/", LedgerStarterWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:ledger_starter, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LedgerStarterWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Tenant routes (on <subdomain>.<base_host>)

  scope "/", LedgerStarterWeb do
    pipe_through [:browser, :tenant]

    live_session :tenant,
      on_mount: [{LedgerStarterWeb.UserAuth, :require_company}],
      session: {LedgerStarterWeb.Plugs.Tenant, :live_session, []} do
      live "/painel", DashboardLive, :index
      live "/contatos", ContactLive.Index, :index
      live "/contatos/novo", ContactLive.Index, :new
      live "/contatos/:id/editar", ContactLive.Index, :edit
      live "/equipe", TeamLive, :index
      live "/equipe/convidar", TeamLive, :invite
    end
  end

  ## Authentication routes (root host)

  scope "/", LedgerStarterWeb do
    pipe_through [:browser, :root_host, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LedgerStarterWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
      live "/empresas/nova", CompanyLive.New, :new
      live "/workspaces", WorkspaceLive.Index, :index
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", LedgerStarterWeb do
    pipe_through [:browser, :root_host]

    live_session :current_user,
      on_mount: [{LedgerStarterWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/link", UserLive.MagicLink, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete

    get "/auth/google", GoogleAuthController, :request
    get "/auth/google/callback", GoogleAuthController, :callback
    get "/convites/:token", InvitationController, :show
  end
end
