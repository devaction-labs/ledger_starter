defmodule LedgerStarter.Repo.Migrations.MigrateRolesToPermissionMatrix do
  @moduledoc """
  Moves existing companies to the roles of the "Papéis e permissões" matrix.

  * `member` -> `sales` ("Vendas"): the closest role (it created and edited
    contacts). The PermitEx role row is renamed in place, so everyone who was a
    member keeps their assignment; pending invitations for `member` become `sales`.
  * `owner`, `admin`, `sales` and the new `viewer` ("Leitura") are re-cloned into
    every company with the new permission set (`LedgerStarter.Permissions.sync_catalog!/0`),
    `owner` and `admin` locked; permissions that left the catalog
    (`contacts:create|update`, `team:invite|manage`, `company:manage`) are deleted.
  * Note for admins: Admin now holds `team:write` (it used to lack `team:manage`),
    so it can edit roles and invite.

  Runs without a DDL transaction so the rename is committed before the catalog
  sync reads it through the repo.
  """
  use Ecto.Migration

  @disable_ddl_transaction true

  def up do
    execute("ALTER TABLE invitations ALTER COLUMN role SET DEFAULT 'sales'")
    flush()

    LedgerStarter.Permissions.migrate_legacy_member_role!()
    LedgerStarter.Permissions.sync_catalog!()
  end

  def down do
    execute("ALTER TABLE invitations ALTER COLUMN role SET DEFAULT 'member'")
    execute("UPDATE invitations SET role = 'member' WHERE role IN ('sales', 'viewer')")
    # Custom roles and the new permission set are not rewound; `sales` goes back to its old name.
    execute(
      "UPDATE permit_ex_roles SET name = 'member', description = 'Membro' WHERE name = 'sales'"
    )
  end
end
