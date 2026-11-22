defmodule LedgerStarterWeb.OnboardingLiveTest do
  use LedgerStarterWeb.ConnCase, async: true

  import LedgerStarter.AccountsFixtures
  import LedgerStarter.CompaniesFixtures
  import Phoenix.LiveViewTest

  alias LedgerStarter.Companies

  setup %{conn: conn} do
    user = user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  describe "create company" do
    test "requires login", %{} do
      assert {:error, {:redirect, %{to: "/users/log-in"}}} =
               live(build_conn(), ~p"/empresas/nova")
    end

    test "suggests the subdomain from the name and previews the URL", %{conn: conn} do
      {:ok, lv, _} = live(conn, ~p"/empresas/nova")

      html = lv |> form("#company_form", company: %{name: "Orbit Cloud Ltda."}) |> render_change()

      assert html =~ ~s(value="orbit-cloud-ltda")
      assert html =~ "orbit-cloud-ltda.example.com"
      assert html =~ "Disponível"
    end

    test "live availability check: taken, reserved and too short", %{conn: conn} do
      company_fixture(nil, %{subdomain: "ocupado"})
      {:ok, lv, _} = live(conn, ~p"/empresas/nova")

      change = fn sub ->
        lv
        |> form("#company_form", company: %{name: "Minha Empresa", subdomain: sub})
        |> render_change(%{"_target" => ["company", "subdomain"]})
      end

      assert change.("ocupado") =~ "já está em uso"
      assert change.("www") =~ "reservado"
      assert change.("ab") =~ "at least 3"
      assert change.("livre") =~ "Disponível"
    end

    test "creates the company and goes to its subdomain dashboard", %{conn: conn, user: user} do
      {:ok, lv, _} = live(conn, ~p"/empresas/nova")

      lv
      |> form("#company_form", company: %{name: "Orbit Cloud", subdomain: "orbit"})
      |> render_submit()

      assert_redirect(lv, "http://orbit.example.com/painel")
      assert [%{subdomain: "orbit"}] = Companies.list_companies_for_user(user)
    end

    test "slugify/1 strips accents and symbols" do
      assert LedgerStarterWeb.CompanyLive.New.slugify("Açaí & Cia!") == "acai-cia"
    end
  end

  describe "workspaces chooser" do
    test "lists the user's companies with role and link to their subdomain", %{
      conn: conn,
      user: user
    } do
      company_fixture(user, %{name: "Orbit Cloud", subdomain: "orbit"})
      other = company_fixture(nil, %{name: "Lumen Studio", subdomain: "lumen"})
      {:ok, _} = Companies.add_member(other, user, "admin")
      _unrelated = company_fixture(nil, %{name: "Secreta", subdomain: "secreta"})

      {:ok, _lv, html} = live(conn, ~p"/workspaces")

      assert html =~ "Escolha o workspace"
      assert html =~ "http://orbit.example.com/painel"
      assert html =~ "http://lumen.example.com/painel"
      assert html =~ "Dono"
      assert html =~ "Admin"
      refute html =~ "Secreta"
      assert html =~ user.email
    end
  end
end
