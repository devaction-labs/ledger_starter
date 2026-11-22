defmodule LedgerStarterWeb.PageController do
  use LedgerStarterWeb, :controller

  def home(conn, _params) do
    case conn.assigns.host_kind do
      :root ->
        render(conn, :home,
          page_title: gettext("O CRM pronto para virar o seu SaaS"),
          base_host: LedgerStarterWeb.Tenant.base_host()
        )

      _ ->
        redirect(conn, to: ~p"/painel")
    end
  end

  def privacy(conn, _params),
    do: render(conn, :privacy, page_title: gettext("Política de Privacidade"))

  def terms(conn, _params), do: render(conn, :terms, page_title: gettext("Termos de Serviço"))
end
