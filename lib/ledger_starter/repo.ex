defmodule LedgerStarter.Repo do
  use Ecto.Repo,
    otp_app: :ledger_starter,
    adapter: Ecto.Adapters.Postgres
end
