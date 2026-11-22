defmodule LedgerStarterWeb.UserLive.MagicLinkTest do
  use LedgerStarterWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import LedgerStarter.AccountsFixtures
  import Swoosh.TestAssertions

  alias LedgerStarter.{Accounts, Repo}
  alias LedgerStarter.Accounts.UserToken

  test "renders the request form", %{conn: conn} do
    {:ok, _lv, html} = live(conn, ~p"/users/log-in/link")

    assert html =~ "Entrar sem senha"
    assert html =~ "Enviar link mágico"
    assert html =~ "15 minutos"
  end

  # user_fixture/0 itself sends e-mails; drop them before asserting.
  defp drain_emails do
    receive do
      {:email, _} -> drain_emails()
    after
      0 -> :ok
    end
  end

  test "sends the link and shows the sent state", %{conn: conn} do
    user = user_fixture()
    drain_emails()
    {:ok, lv, _html} = live(conn, ~p"/users/log-in/link")

    html =
      lv
      |> form("#magic_link_form", user: %{email: user.email})
      |> render_submit()

    assert html =~ "Confira seu e-mail"
    assert html =~ user.email
    assert_email_sent(to: {nil, user.email}, subject: "Seu link de acesso ao StartKit")
    assert Repo.get_by!(UserToken, user_id: user.id, context: "login")
  end

  test "does not reveal whether the e-mail exists", %{conn: conn} do
    {:ok, lv, _html} = live(conn, ~p"/users/log-in/link")

    html =
      lv
      |> form("#magic_link_form", user: %{email: "nobody@example.com"})
      |> render_submit()

    assert html =~ "Confira seu e-mail"
    assert Repo.aggregate(UserToken, :count) == 0
  end

  test "the e-mail carries a link valid for 15 minutes", %{conn: conn} do
    user = user_fixture()
    drain_emails()
    {:ok, lv, _html} = live(conn, ~p"/users/log-in/link")
    lv |> form("#magic_link_form", user: %{email: user.email}) |> render_submit()

    assert_received {:email, email}
    assert email.text_body =~ "15 minutos"
    assert email.text_body =~ "/users/log-in/"
  end

  describe "magic link token" do
    test "is single use" do
      user = user_fixture()

      token =
        extract_user_token(fn url -> Accounts.deliver_login_instructions(user, url) end)

      assert {:ok, {_user, _}} = Accounts.login_user_by_magic_link(token)
      assert {:error, :not_found} = Accounts.login_user_by_magic_link(token)
    end

    test "expires after 15 minutes" do
      user = user_fixture()
      {encoded, raw} = generate_user_magic_link_token(user)

      assert Accounts.get_user_by_magic_link_token(encoded)

      offset_user_token(raw, -16, :minute)
      refute Accounts.get_user_by_magic_link_token(encoded)
    end

    test "the confirmation page logs the user in", %{conn: conn} do
      user = user_fixture()
      token = extract_user_token(fn url -> Accounts.deliver_login_instructions(user, url) end)

      {:ok, lv, html} = live(conn, ~p"/users/log-in/#{token}")
      assert html =~ "Bem-vindo de volta"

      form = form(lv, "#confirmation_form", user: %{token: token})
      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == "http://example.com/empresas/nova"
      assert get_session(conn, :user_token)
    end

    test "an invalid link goes back to the request page", %{conn: conn} do
      assert {:error, {:live_redirect, %{to: "/users/log-in/link"}}} =
               live(conn, ~p"/users/log-in/invalid-token")
    end
  end
end
