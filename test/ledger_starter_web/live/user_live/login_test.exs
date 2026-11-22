defmodule LedgerStarterWeb.UserLive.LoginTest do
  use LedgerStarterWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import LedgerStarter.AccountsFixtures

  describe "login page" do
    test "renders password login, magic link entry and registration link", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/log-in")

      assert html =~ "Entrar no StartKit"
      assert html =~ "Entrar com link mágico"
      assert html =~ "Criar conta grátis"
      refute html =~ "Continuar com Google"
    end

    test "shows the Google button only when OAuth is configured", %{conn: conn} do
      previous = Application.get_env(:ledger_starter, :google_oauth)

      Application.put_env(:ledger_starter, :google_oauth,
        client_id: "id",
        client_secret: "secret"
      )

      on_exit(fn -> Application.put_env(:ledger_starter, :google_oauth, previous) end)

      {:ok, _lv, html} = live(conn, ~p"/users/log-in")
      assert html =~ "Continuar com Google"
      assert html =~ "/auth/google"
    end
  end

  describe "password login" do
    test "redirects to the login post when submitted", %{conn: conn} do
      user = user_fixture() |> set_password()

      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      form =
        form(lv, "#login_form_password",
          user: %{email: user.email, password: valid_user_password(), remember_me: true}
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == "http://example.com/empresas/nova"
    end

    test "redirects to the login page with a flash error if credentials are invalid", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/users/log-in")

      form =
        form(lv, "#login_form_password",
          user: %{email: "test@email.com", password: "wrong pass 12"}
        )

      render_submit(form, %{user: %{remember_me: true}})

      conn = follow_trigger_action(form, conn)
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "E-mail ou senha inválidos."
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "re-authentication (sudo mode)" do
    setup %{conn: conn} do
      user = user_fixture()
      %{user: user, conn: log_in_user(conn, user)}
    end

    test "redirects a logged-in user to their workspaces", %{conn: conn} do
      assert {:error, {:redirect, %{to: _}}} = live(conn, ~p"/users/register")
    end
  end
end
