defmodule LedgerStarterWeb.Plugs.Session do
  @moduledoc """
  `Plug.Session` with a runtime `domain`, so one cookie works on the root host
  and on every `<tenant>.<base_host>` (`config :ledger_starter, :session_cookie_domain`).
  """
  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    opts =
      case LedgerStarterWeb.Tenant.cookie_domain_for(conn.host) do
        nil -> opts
        domain -> Keyword.put(opts, :domain, domain)
      end

    Plug.Session.call(conn, Plug.Session.init(opts))
  end
end
