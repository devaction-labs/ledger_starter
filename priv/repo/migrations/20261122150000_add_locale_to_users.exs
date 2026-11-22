defmodule LedgerStarter.Repo.Migrations.AddLocaleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :locale, :string, null: false, default: "pt_BR"
    end
  end
end
