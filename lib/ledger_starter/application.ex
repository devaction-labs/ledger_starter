defmodule LedgerStarter.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LedgerStarterWeb.Telemetry,
      LedgerStarter.Repo,
      {DNSCluster, query: Application.get_env(:ledger_starter, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LedgerStarter.PubSub},
      # Start a worker by calling: LedgerStarter.Worker.start_link(arg)
      # {LedgerStarter.Worker, arg},
      # Start to serve requests, typically the last entry
      LedgerStarterWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LedgerStarter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LedgerStarterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
