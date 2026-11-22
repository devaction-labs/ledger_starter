defmodule LedgerStarter.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :email, :string
      add :phone, :string
      add :company_name, :string
      add :stage, :string
      add :owner_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:contacts, [:company_id])

    create index(:contacts, [:owner_id])
  end
end
