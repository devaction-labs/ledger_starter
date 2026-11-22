defmodule LedgerStarterWeb.HealthController do
  use LedgerStarterWeb, :controller

  @doc "Liveness: the VM is up and serving."
  def live(conn, _params), do: json(conn, %{status: "ok"})

  @doc "Readiness: the database answers."
  def ready(conn, _params) do
    case Ecto.Adapters.SQL.query(LedgerStarter.Repo, "SELECT 1", []) do
      {:ok, _} ->
        json(conn, %{status: "ok"})

      _ ->
        conn |> put_status(:service_unavailable) |> json(%{status: "unavailable"})
    end
  end
end
