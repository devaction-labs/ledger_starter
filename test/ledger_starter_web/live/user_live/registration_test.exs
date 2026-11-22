defmodule LedgerStarterWeb.UserLive.RegistrationTest do
  use LedgerStarterWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import LedgerStarter.AccountsFixtures

  alias LedgerStarter.Accounts

  describe "Registration page" do
    test "renders the form with the strength meter and terms", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Crie sua conta"
      assert html =~ "Seu nome"
      assert html =~ "Forte: 12+"
      assert html =~ "Li e aceito os Termos"
      refute html =~ "Cadastrar com Google"
    end

    test "redirects authenticated users away", %{conn: conn} do
      result = conn |> log_in_user(user_fixture()) |> live(~p"/users/register")

      assert {:error, {:redirect, %{to: _}}} = result
    end

    test "prefills the e-mail from an invitation link", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register?email=paula%40example.com")
      assert html =~ "paula@example.com"
    end

    test "validates the form and shows the strength", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      html =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"name" => "", "email" => "with spaces", "password" => "abc"})

      assert html =~ "must have the @ sign and no spaces"
      assert html =~ "should be at least 12 character(s)"
    end
  end

  describe "register user" do
    test "creates the account and signs in with the password", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")
      email = unique_user_email()

      form =
        form(lv, "#registration_form",
          user: %{
            name: "Alex Nogueira",
            email: email,
            password: valid_user_password(),
            terms: "true"
          }
        )

      render_submit(form)

      user = Accounts.get_user_by_email(email)
      assert user.name == "Alex Nogueira"
      assert is_nil(user.confirmed_at)

      # the trigger-action form posts to the password login
      conn = follow_trigger_action(form(lv, "#login_after_register"), conn)
      assert redirected_to(conn) == "http://example.com/empresas/nova"
    end

    test "requires accepting the terms", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      html =
        lv
        |> form("#registration_form",
          user: %{
            name: "Alex",
            email: unique_user_email(),
            password: valid_user_password(),
            terms: "false"
          }
        )
        |> render_submit()

      assert html =~ "aceite os termos para continuar"
    end

    test "renders errors for duplicated e-mail", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")
      user = user_fixture(%{email: "test@email.com"})

      html =
        lv
        |> form("#registration_form",
          user: %{
            name: "Alex",
            email: user.email,
            password: valid_user_password(),
            terms: "true"
          }
        )
        |> render_submit()

      assert html =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "links to the login page", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element("main a, a", "Entrar")
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log-in")

      assert login_html =~ "Entrar no StartKit"
    end
  end
end
