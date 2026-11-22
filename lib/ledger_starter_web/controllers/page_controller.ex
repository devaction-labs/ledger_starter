defmodule LedgerStarterWeb.PageController do
  use LedgerStarterWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
