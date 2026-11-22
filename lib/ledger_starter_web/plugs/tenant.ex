defmodule LedgerStarterWeb.Plugs.Tenant do
  @moduledoc """
  Host-based tenancy plugs.

    * `fetch_host/2` classifies the request host and assigns `:host_kind`
      (`:root | {:tenant, subdomain} | :unknown`).
    * `require_root_host/2` — root-only routes; on a tenant host redirects to the root host.
    * `require_tenant/2` — loads `:current_company` and requires an authenticated
      member; unknown subdomain or non-member is a 404, anonymous goes to login.
  """
  import Plug.Conn
  import Phoenix.Controller
  use Gettext, backend: LedgerStarterWeb.Gettext

  alias LedgerStarter.Accounts.Scope
  alias LedgerStarter.Companies
  alias LedgerStarterWeb.Tenant

  def fetch_host(conn, _opts), do: assign(conn, :host_kind, Tenant.classify(conn.host))

  def require_root_host(conn, _opts) do
    case conn.assigns.host_kind do
      :root ->
        conn

      _ ->
        conn
        |> redirect(external: Tenant.root_url(conn.request_path))
        |> halt()
    end
  end

  def require_tenant(conn, _opts) do
    with {:tenant, sub} <- conn.assigns.host_kind,
         %Companies.Company{} = company <- Companies.get_company_by_subdomain(sub) do
      authorize_member(conn, company)
    else
      _ -> not_found(conn)
    end
  end

  defp authorize_member(conn, company) do
    case conn.assigns[:current_scope] do
      %Scope{user: %{} = user} = scope ->
        if Companies.member?(user, company) do
          conn
          |> assign(:current_scope, Scope.put_company(scope, company))
          |> assign(:current_company, company)
        else
          not_found(conn)
        end

      _ ->
        conn
        |> put_session(:user_return_to, Tenant.company_url(company, current_path(conn)))
        |> put_flash(:error, gettext("Entre para acessar este workspace."))
        |> redirect(external: Tenant.root_url("/users/log-in"))
        |> halt()
    end
  end

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> put_view(html: LedgerStarterWeb.ErrorHTML)
    |> render(:"404")
    |> halt()
  end

  @doc "Session map passed to tenant LiveViews (`live_session ..., session: {M, :f, []}`)."
  def live_session(conn), do: %{"company_id" => conn.assigns.current_company.id}
end
