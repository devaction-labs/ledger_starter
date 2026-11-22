defmodule LedgerStarter.Release do
  @moduledoc """
  Tasks run from the release (no Mix): `bin/ledger_starter eval "LedgerStarter.Release.migrate()"`.
  """
  @app :ledger_starter

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  @doc "Optional: loads the demo workspace (Orbit Cloud) in an empty environment."
  def seed_demo do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(LedgerStarter.Repo, fn _repo ->
        Code.eval_file(Application.app_dir(@app, "priv/repo/seeds.exs"))
      end)
  end

  defp repos, do: Application.fetch_env!(@app, :ecto_repos)

  defp load_app do
    Application.ensure_all_started(:ssl)
    Application.load(@app)
  end
end
