defmodule LedgerStarter.PermissionsTest do
  use LedgerStarter.DataCase, async: true

  import LedgerStarter.CompaniesFixtures

  alias LedgerStarter.Permissions

  setup do
    owner = company_scope_fixture()
    %{owner: owner, company: owner.company}
  end

  test "no permission name has exactly 16 bytes (PermitEx would read it as a UUID)" do
    for name <- Permissions.permission_names(), do: refute(byte_size(name) == 16, name)
    for name <- Permissions.role_names(), do: refute(byte_size(name) == 16, name)
    assert Enum.all?(Permissions.permission_names(), &String.contains?(&1, ":"))
  end

  test "roles of a company: Dono and Admin locked, with member counts", %{owner: owner} do
    member_fixture(owner.company, "sales")
    member_fixture(owner.company, "sales")

    assert {:ok, roles} = Permissions.list_roles(owner)
    assert Enum.map(roles, & &1.label) == ["Dono", "Admin", "Vendas", "Leitura"]
    assert Enum.map(roles, & &1.locked) == [true, true, false, false]
    assert Enum.map(roles, & &1.members) == [1, 0, 2, 0]
    assert hd(roles).permissions == MapSet.new(Permissions.permission_names())
  end

  test "the matrix levels of the templates match the board", %{owner: owner} do
    {:ok, roles} = Permissions.list_roles(owner)
    by_name = Map.new(roles, &{&1.name, &1})
    groups = Map.new(Permissions.groups(), &{&1.key, &1})
    level = fn role, g -> Permissions.level(groups[g], by_name[role].permissions) end

    assert level.("owner", "contacts") == :all
    assert level.("owner", "company") == :all
    assert level.("admin", "billing") == :view
    assert level.("admin", "company") == :none
    assert level.("sales", "contacts") == {:scope, "Do time"}
    assert level.("sales", "deals") == {:scope, "Só os seus"}
    assert level.("sales", "tasks") == {:scope, "Só os seus"}
    assert level.("sales", "reports") == {:scope, "Do time"}
    assert level.("sales", "data") == :none
    assert level.("sales", "team") == :none
    assert level.("viewer", "contacts") == :view
    assert level.("viewer", "tasks") == :none
  end

  test "setup_company! is idempotent and keeps edited roles", %{owner: owner, company: company} do
    assert {:ok, _} =
             Permissions.update_role(owner, "sales", %{
               "permissions" => ["contacts:read"]
             })

    {_, scope} = member_fixture(company, "sales")
    assert PermitEx.can?(scope, "contacts:read")
    refute PermitEx.can?(scope, "contacts:write")
  end

  describe "update_role/3" do
    test "changes the effective permissions of everyone holding the role", %{
      owner: owner,
      company: company
    } do
      {_, sales} = member_fixture(company, "sales")
      assert PermitEx.can?(sales, "contacts:write")
      refute PermitEx.can?(sales, "contacts:delete")

      params = %{
        "contacts" => %{
          "read" => "true",
          "write" => "false",
          "delete" => "true",
          "scope" => "all"
        }
      }

      assert {:ok, role} =
               Permissions.update_role(owner, "sales", %{
                 "label" => "Vendas Sul",
                 "permissions" => Permissions.permissions_from_params(params)
               })

      assert role.label == "Vendas Sul"
      assert role.permissions == MapSet.new(["contacts:read", "contacts:delete", "contacts:all"])

      reloaded = LedgerStarter.Accounts.Scope.reload(sales)
      refute PermitEx.can?(reloaded, "contacts:write")
      assert PermitEx.can?(reloaded, "contacts:delete")
    end

    test "a group without Ver keeps nothing", _ do
      params = %{"contacts" => %{"read" => "false", "write" => "true", "scope" => "all"}}
      assert Permissions.permissions_from_params(params) == []
    end

    test "Dono and Admin are locked, even for the owner", %{owner: owner} do
      assert {:error, :role_locked} =
               Permissions.update_role(owner, "owner", %{"permissions" => []})

      assert {:error, :role_locked} = Permissions.update_role(owner, "admin", %{"label" => "X"})
      assert {:ok, [%{permissions: perms} | _]} = Permissions.list_roles(owner)
      assert MapSet.member?(perms, "team:write")
    end

    test "needs team:write", %{company: company} do
      {_, sales} = member_fixture(company, "sales")
      {_, viewer} = member_fixture(company, "viewer")
      assert {:error, :unauthorized} = Permissions.update_role(sales, "viewer", %{})
      assert {:error, :unauthorized} = Permissions.update_role(viewer, "viewer", %{})
    end

    test "nobody grants what they do not hold", %{owner: owner, company: company} do
      {_, admin} = member_fixture(company, "admin")

      assert {:error, :escalation} =
               Permissions.update_role(admin, "viewer", %{
                 "permissions" => ["contacts:read", "billing:write"]
               })

      assert {:ok, _} =
               Permissions.update_role(admin, "viewer", %{"permissions" => ["billing:read"]})

      assert {:ok, _} =
               Permissions.update_role(owner, "viewer", %{"permissions" => ["billing:write"]})
    end

    test "rejects blank names and unknown roles", %{owner: owner} do
      assert {:error, :blank_label} = Permissions.update_role(owner, "sales", %{"label" => "  "})
      assert {:error, :not_found} = Permissions.update_role(owner, "nope", %{})
    end
  end

  describe "create_role/2" do
    test "creates a custom role scoped to the company", %{owner: owner} do
      other = company_scope_fixture()

      assert {:ok, role} =
               Permissions.create_role(owner, %{
                 "label" => "Atendimento Rápido",
                 "permissions" => ["contacts:read", "tasks:read"]
               })

      assert role.name == "atendimento_rapido"
      assert role.custom
      assert role.label == "Atendimento Rápido"
      assert {:ok, roles} = Permissions.list_roles(other)
      refute Enum.any?(roles, &(&1.name == "atendimento_rapido"))

      {_, scope} = member_fixture(owner.company, role.name)
      assert PermitEx.can?(scope, "tasks:read")
      refute PermitEx.can?(scope, "tasks:write")

      assert {:ok, %{name: "atendimento_rapido_2"}} =
               Permissions.create_role(owner, %{
                 "label" => "Atendimento Rápido",
                 "permissions" => []
               })
    end

    test "never creates a 16-byte role name", %{owner: owner} do
      assert {:ok, %{name: name}} =
               Permissions.create_role(owner, %{
                 "label" => "abcdefghijklmnop",
                 "permissions" => []
               })

      refute byte_size(name) == 16
    end
  end

  describe "data migration of legacy roles" do
    test "member becomes sales keeping assignments; templates are re-synced; custom roles stay",
         %{owner: owner, company: company} do
      alias LedgerStarter.Repo

      # Rebuild the pre-matrix state: a `member` role with the old permission names.
      {user, _scope} = member_fixture(company, "sales")
      custom = role_fixture(owner, "Custom", ["contacts:read"])

      Repo.query!(
        "UPDATE permit_ex_roles SET name = 'member', description = 'Membro' WHERE name = 'sales' AND context_id = $1",
        [Ecto.UUID.dump!(company.id)]
      )

      {:ok, _} = PermitEx.upsert_permission("contacts:create", %{}, repo: Repo)
      member = PermitEx.get_role_by_name("member", company.id, repo: Repo)

      {:ok, _} =
        PermitEx.sync_role_permissions(member, ["contacts:create"], repo: Repo, force?: true)

      Repo.query!(
        "UPDATE permit_ex_roles SET name = 'member', description = 'Membro' WHERE name = 'sales' AND context_id IS NULL"
      )

      assert Permissions.role_of(user.id, company.id) == "member"

      Permissions.migrate_legacy_member_role!()
      Permissions.sync_catalog!()

      assert Permissions.role_of(user.id, company.id) == "sales"
      assert Permissions.role_label_of(user.id, company.id) == "Vendas"
      scope = company_scope_fixture(user, company)
      assert PermitEx.can?(scope, "contacts:write")
      assert PermitEx.can?(scope, "contacts:team")
      refute PermitEx.can?(scope, "contacts:create")
      assert PermitEx.get_permission_by_name("contacts:create", repo: Repo) == nil

      assert {:ok, roles} = Permissions.list_roles(owner)
      assert Enum.map(roles, & &1.label) == ["Dono", "Admin", "Vendas", "Leitura", "Custom"]

      assert Enum.find(roles, &(&1.name == custom.name)).permissions ==
               MapSet.new(["contacts:read"])

      assert Enum.take(roles, 2) |> Enum.all?(& &1.locked)
    end
  end
end
