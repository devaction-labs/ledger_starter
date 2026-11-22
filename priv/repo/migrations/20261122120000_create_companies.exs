defmodule LedgerStarter.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
      add :google_uid, :string
    end

    create unique_index(:users, [:google_uid], where: "google_uid IS NOT NULL")

    create table(:companies, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :subdomain, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:companies, [:subdomain])

    create table(:memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:memberships, [:user_id, :company_id])
    create index(:memberships, [:company_id])

    create table(:invitations, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :company_id, references(:companies, type: :binary_id, on_delete: :delete_all),
        null: false

      add :invited_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :email, :citext, null: false
      add :role, :string, null: false, default: "member"
      add :token_hash, :binary, null: false
      add :expires_at, :utc_datetime, null: false
      add :accepted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:invitations, [:token_hash])
    create index(:invitations, [:company_id])
    create index(:invitations, [:email])
  end
end
