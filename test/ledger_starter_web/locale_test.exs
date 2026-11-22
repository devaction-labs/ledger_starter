defmodule LedgerStarterWeb.LocaleTest do
  use LedgerStarterWeb.ConnCase, async: true

  import LedgerStarter.AccountsFixtures
  import LedgerStarter.CompaniesFixtures
  import Phoenix.LiveViewTest

  alias LedgerStarter.Accounts

  @login "/users/log-in"

  defp login_title(html) do
    cond do
      html =~ "Entrar no StartKit" -> :pt_BR
      html =~ "Sign in to StartKit" -> :en
    end
  end

  defp html_lang(html), do: Regex.run(~r/<html[^>]* lang="([^"]+)"/, html) |> List.last()

  describe "resolution order" do
    test "defaults to pt_BR", %{conn: conn} do
      html = conn |> get(@login) |> html_response(200)

      assert login_title(html) == :pt_BR
      assert html_lang(html) == "pt-BR"
    end

    test "Accept-Language is used when there is nothing else", %{conn: conn} do
      html =
        conn
        |> put_req_header("accept-language", "en-US,en;q=0.9")
        |> get(@login)
        |> html_response(200)

      assert login_title(html) == :en
      assert html_lang(html) == "en"
    end

    test "an unsupported Accept-Language falls back to pt_BR", %{conn: conn} do
      html = conn |> put_req_header("accept-language", "fr") |> get(@login) |> html_response(200)
      assert login_title(html) == :pt_BR
    end

    test "the cookie wins over Accept-Language", %{conn: conn} do
      html =
        conn
        |> put_req_header("accept-language", "en")
        |> put_req_cookie("locale", "pt_BR")
        |> get(@login)
        |> html_response(200)

      assert login_title(html) == :pt_BR
    end

    test "?locale= wins over the cookie and sets the cookie", %{conn: conn} do
      conn = conn |> put_req_cookie("locale", "pt_BR") |> get(@login <> "?locale=en")

      assert login_title(html_response(conn, 200)) == :en
      assert conn.resp_cookies["locale"].value == "en"
    end

    test "an invalid ?locale= is ignored and writes no cookie", %{conn: conn} do
      conn = get(conn, @login <> "?locale=klingon")

      assert login_title(html_response(conn, 200)) == :pt_BR
      refute Map.has_key?(conn.resp_cookies, "locale")
    end

    test "the user preference wins over ?locale=, the cookie and Accept-Language", %{conn: conn} do
      user = user_fixture()
      {:ok, user} = Accounts.update_user_locale(user, "en")

      conn =
        conn
        |> log_in_user(user)
        |> put_req_cookie("locale", "pt_BR")
        |> put_req_header("accept-language", "pt-BR")

      html = conn |> get(~p"/") |> html_response(200)
      assert html =~ "Open workspace"
      assert html_lang(html) == "en"

      html = conn |> get(~p"/?locale=pt_BR") |> html_response(200)
      assert html =~ "Open workspace"
    end
  end

  describe "LiveView" do
    test "renders English with ?locale=en", %{conn: conn} do
      {:ok, lv, html} = live(conn, @login <> "?locale=en")

      assert login_title(html) == :en
      assert html =~ "Sign in with a magic link"
      assert login_title(render(lv)) == :en
    end

    test "keeps the language of the cookie after the socket connects", %{conn: conn} do
      {:ok, lv, _html} = conn |> put_req_cookie("locale", "en") |> live("/users/register")

      html = render(lv)
      assert html =~ "Create your account"
      assert html =~ "Work email"
      refute html =~ "Crie sua conta"
    end

    test "form errors are translated to the current language", %{conn: conn} do
      {:ok, lv, _} = live(conn, "/users/register?locale=pt_BR")

      html =
        lv
        |> form("#registration_form", user: %{name: "", email: "x", password: "123"})
        |> render_change()

      assert html =~ "não pode ficar em branco" or html =~ "informe seu nome"
      assert html =~ "deve ter o @ e não pode ter espaços"
    end

    test "a tenant page follows the user preference", %{conn: conn} do
      user = user_fixture()
      company = company_fixture(user)
      {:ok, _} = Accounts.update_user_locale(user, "en")
      user = Accounts.get_user!(user.id)

      conn = conn |> log_in_user(user) |> Map.put(:host, "#{company.subdomain}.example.com")

      {:ok, lv, html} = live(conn, ~p"/painel")
      assert html =~ "Home"
      html = render_async(lv)
      assert html =~ "Recent contacts"
      assert html =~ "Customers"

      {:ok, lv, _} = live(conn, ~p"/equipe/papeis")
      html = render_async(lv)
      assert html =~ "Roles and permissions"
      assert html =~ "Owner"
      assert html =~ "Permission matrix"
      assert html =~ "Contacts and companies"
    end

    test "the account settings change the language", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)

      {:ok, lv, _} = live(conn, ~p"/users/settings")

      assert {:error, {:redirect, %{to: to}}} =
               lv |> element("#locale_form") |> render_change(%{"user" => %{"locale" => "en"}})

      assert to =~ "/idioma/en"
      assert to =~ "settings"
    end
  end

  describe "switcher (GET /idioma/:locale)" do
    test "sets the cookie and goes back to the referer", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "http://www.example.com/users/register")
        |> Map.put(:host, "www.example.com")
        |> get(~p"/idioma/en")

      assert redirected_to(conn) == "/users/register"
      assert conn.resp_cookies["locale"].value == "en"
    end

    test "the cookie uses the shared cookie domain on the base host", %{conn: conn} do
      conn = get(conn, ~p"/idioma/en")
      assert conn.resp_cookies["locale"].value == "en"
      assert conn.resp_cookies["locale"].max_age > 0
    end

    test "uses `to` and refuses non-local targets", %{conn: conn} do
      assert conn |> get(~p"/idioma/en?to=/termos") |> redirected_to() == "/termos"
      assert conn |> get("/idioma/en?to=//evil.example") |> redirected_to() == "/"
      assert conn |> get("/idioma/en?to=https://evil.example") |> redirected_to() == "/"
      assert conn |> get("/idioma/en") |> redirected_to() == "/"
    end

    test "an unsupported locale changes nothing", %{conn: conn} do
      conn = get(conn, "/idioma/xx")

      assert redirected_to(conn) == "/"
      refute Map.has_key?(conn.resp_cookies, "locale")
    end

    test "saves the preference on the logged-in user", %{conn: conn} do
      user = user_fixture()
      assert user.locale == "pt_BR"

      conn = conn |> log_in_user(user) |> get(~p"/idioma/en")

      assert conn.resp_cookies["locale"].value == "en"
      assert Accounts.get_user!(user.id).locale == "en"
    end

    test "the page renders the switcher", %{conn: conn} do
      html = conn |> get(~p"/") |> html_response(200)

      assert html =~ ~s(href="/idioma/pt_BR")
      assert html =~ ~s(href="/idioma/en")
    end
  end

  describe "registration" do
    test "stores the language of the visitor on the user", %{conn: conn} do
      {:ok, lv, _} = live(conn, "/users/register?locale=en")

      attrs = valid_user_attributes()

      lv
      |> form("#registration_form",
        user: %{name: attrs.name, email: attrs.email, password: attrs.password, terms: "true"}
      )
      |> render_submit()

      assert Accounts.get_user_by_email(attrs.email).locale == "en"
    end
  end
end
