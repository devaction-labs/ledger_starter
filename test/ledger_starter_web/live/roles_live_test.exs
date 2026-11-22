defmodule LedgerStarterWeb.RolesLiveTest do
  use LedgerStarterWeb.ConnCase, async: true

  import LedgerStarter.CompaniesFixtures
  import Phoenix.LiveViewTest

  alias LedgerStarter.Permissions

  defp on_host(conn, company), do: %{conn | host: "#{company.subdomain}.example.com"}

  defp login_as(conn, company, role) do
    {user, scope} = member_fixture(company, role)
    {log_in_user(conn, user) |> on_host(company), user, scope}
  end

  setup %{conn: conn} do
    owner = company_scope_fixture()
    company = owner.company

    %{
      owner: owner,
      company: company,
      owner_conn: conn |> log_in_user(owner.user) |> on_host(company)
    }
  end

  describe "matrix" do
    test "shows the roles, member counts and the levels of each group", %{
      owner_conn: conn,
      company: company
    } do
      member_fixture(company, "sales")
      member_fixture(company, "sales")

      {:ok, lv, _} = live(conn, ~p"/equipe/papeis")
      html = render_async(lv)

      for text <-
            ~w(Dono Admin Vendas Leitura) ++
              [
                "Matriz de permissões",
                "Contatos e empresas",
                "Negócios e funil",
                "Importar e exportar",
                "Excluir o workspace",
                "Vendas e Leitura são editáveis",
                "2 pessoas · CRM do time",
                "1 pessoa · acesso total",
                "Do time",
                "Só os seus",
                "Tudo"
              ] do
        assert html =~ text, text
      end

      # Dono and Admin are locked: no link to their drawer; Vendas has one.
      refute has_element?(lv, ~s(#role-card-owner[href^="/equipe/papeis/"]))
      assert has_element?(lv, ~s(#role-card-sales[href="/equipe/papeis/sales/editar"]))
      assert has_element?(lv, "#new-role")
    end

    test "is read-only without team:write", %{company: company, owner: owner} do
      role = role_fixture(owner, "Só equipe", ["team:read"])
      {conn, _, _} = login_as(build_conn(), company, role.name)

      {:ok, lv, _} = live(conn, ~p"/equipe/papeis")
      html = render_async(lv)

      assert html =~ "Matriz de permissões"
      refute has_element?(lv, "#new-role")
      refute has_element?(lv, ~s(#role-card-sales[href^="/equipe/papeis/"]))

      # the drawer routes bounce back to the matrix
      for path <- [~p"/equipe/papeis/sales/editar", ~p"/equipe/papeis/novo"] do
        {:ok, lv, _} = live(conn, path)
        refute has_element?(lv, "#role-drawer")
        assert render(lv) =~ "Você não tem permissão para editar papéis."
      end
    end

    test "a role without team:read gets the 403 page", %{company: company} do
      {conn, _, _} = login_as(build_conn(), company, "sales")

      assert {:error, {:live_redirect, %{to: "/sem-permissao?pagina=papeis"}}} =
               live(conn, ~p"/equipe/papeis")
    end
  end

  describe "edit drawer" do
    test "saving changes the effective permissions", %{
      owner_conn: conn,
      company: company
    } do
      {_, sales} = member_fixture(company, "sales")
      refute PermitEx.can?(sales, "contacts:delete")

      {:ok, lv, _} = live(conn, ~p"/equipe/papeis/sales/editar")
      render_async(lv)
      assert has_element?(lv, "#role-drawer")
      assert render(lv) =~ "Editar papel · Vendas"
      assert render(lv) =~ "1 pessoa usa este papel"

      lv
      |> form("#role-form",
        role: %{
          label: "Vendas Sul",
          contacts: %{read: "true", write: "true", delete: "true"}
        }
      )
      |> render_submit(%{role: %{contacts: %{scope: "all"}}})

      assert_patch(lv, ~p"/equipe/papeis")
      html = render_async(lv)
      assert html =~ "Vendas Sul"

      reloaded = LedgerStarter.Accounts.Scope.reload(sales)
      assert PermitEx.can?(reloaded, "contacts:delete")
      assert PermitEx.can?(reloaded, "contacts:all")
    end

    test "creates a custom role", %{owner_conn: conn, owner: owner} do
      {:ok, lv, _} = live(conn, ~p"/equipe/papeis/novo")
      assert render(lv) =~ "Novo papel"

      lv
      |> form("#role-form", role: %{label: "Financeiro", billing: %{read: "true"}})
      |> render_submit()

      assert_patch(lv, ~p"/equipe/papeis")

      assert {:ok, %{permissions: perms, custom: true}} =
               Permissions.get_role(owner, "financeiro")

      assert perms == MapSet.new(["billing:read"])
      assert render_async(lv) =~ "Financeiro"
    end

    test "Dono and Admin cannot be edited", %{owner_conn: conn} do
      for role <- ~w(owner admin) do
        {:ok, lv, _} = live(conn, ~p"/equipe/papeis/#{role}/editar")
        refute has_element?(lv, "#role-drawer")
        assert render(lv) =~ "Dono e Admin não podem ser editados."
      end
    end

    test "forged save without team:write changes nothing", %{company: company, owner: owner} do
      role = role_fixture(owner, "Só equipe", ["team:read"])
      {conn, _, _} = login_as(build_conn(), company, role.name)
      {:ok, lv, _} = live(conn, ~p"/equipe/papeis")
      render_async(lv)

      render_hook(lv, "save", %{"role" => %{"label" => "Hack", "contacts" => %{"read" => "true"}}})

      assert {:ok, %{label: "Vendas"}} = Permissions.get_role(owner, "sales")
    end

    test "a role change applies on the next click of someone already on the page", %{
      owner: owner,
      company: company
    } do
      role = role_fixture(owner, "Equipe total", ["team:read", "team:write", "contacts:read"])
      {conn, user, _} = login_as(build_conn(), company, role.name)
      {:ok, lv, _} = live(conn, ~p"/equipe")
      render_async(lv)
      assert render(lv) =~ "Convidar pessoas"

      {:ok, _} = Permissions.update_role(owner, role.name, %{"permissions" => ["team:read"]})

      render_hook(lv, "invite", %{"invite" => %{"emails" => "x@example.com", "role" => "sales"}})

      scope =
        LedgerStarter.Accounts.Scope.for_user(user)
        |> LedgerStarter.Accounts.Scope.put_company(company)

      assert {:ok, []} = LedgerStarter.Companies.list_pending_invitations(scope)
    end
  end

  describe "403 page" do
    test "names the page, the role and who can release access", %{company: company, owner: owner} do
      {conn, _, _} = login_as(build_conn(), company, "sales")
      {:ok, lv, html} = live(conn, ~p"/sem-permissao?pagina=equipe")

      assert html =~ "403"
      assert html =~ "Você não tem acesso à Equipe"
      assert html =~ "Seu papel é Vendas"
      assert html =~ "Peça a um Admin ou ao dono"
      assert has_element?(lv, "#granters", owner.user.name || owner.user.email)
      assert has_element?(lv, ~s(#back-to-dashboard[href="/painel"]))
    end

    test "contacts require contacts:read", %{company: company, owner: owner} do
      {conn, _, _} = login_as(build_conn(), company, "sales")
      assert {:ok, _, _} = live(conn, ~p"/contatos")

      role = role_fixture(owner, "Só equipe", ["team:read"])
      {conn, _, _} = login_as(build_conn(), company, role.name)

      assert {:error, {:live_redirect, %{to: "/sem-permissao?pagina=contatos"}}} =
               live(conn, ~p"/contatos")
    end

    test "an unknown page still renders a generic 403", %{company: company} do
      {conn, _, _} = login_as(build_conn(), company, "viewer")
      {:ok, _lv, html} = live(conn, ~p"/sem-permissao?pagina=whatever")
      assert html =~ "Você não tem acesso a esta página"
    end
  end
end
