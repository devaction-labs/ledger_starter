defmodule LedgerStarterWeb.TenantTest do
  use LedgerStarterWeb.ConnCase, async: true

  import LedgerStarter.AccountsFixtures
  import LedgerStarter.CompaniesFixtures
  import Phoenix.LiveViewTest

  alias LedgerStarterWeb.Tenant

  defp on_host(conn, host), do: %{conn | host: host}

  describe "host classification" do
    test "base host and www are the root; one label below is a tenant" do
      assert Tenant.classify("example.com") == :root
      assert Tenant.classify("www.example.com") == :root
      assert Tenant.classify("orbit.example.com") == {:tenant, "orbit"}
      assert Tenant.classify("ORBIT.Example.com") == {:tenant, "orbit"}
      assert Tenant.classify("a.b.example.com") == :unknown
      # health checks by IP / localhost behave as the root host
      assert Tenant.classify("localhost") == :root
    end

    test "url builders use the base host" do
      company = %LedgerStarter.Companies.Company{subdomain: "orbit"}
      assert Tenant.root_url("/x") == "http://example.com/x"
      assert Tenant.company_url(company, "/painel") == "http://orbit.example.com/painel"
      assert Tenant.company_host(company) == "orbit.example.com"
    end

    test "trusted_url?/1 only accepts the base host and its subdomains" do
      assert Tenant.trusted_url?("http://orbit.example.com/painel")
      assert Tenant.trusted_url?("https://example.com/")
      refute Tenant.trusted_url?("https://evil.com/")
      refute Tenant.trusted_url?("https://example.com.evil.com/")
      refute Tenant.trusted_url?("javascript:alert(1)")
      refute Tenant.trusted_url?(nil)
    end
  end

  describe "tenant resolution (host -> company)" do
    setup %{conn: conn} do
      user = user_fixture()
      company = company_fixture(user, %{subdomain: "orbit"})
      %{conn: log_in_user(conn, user), user: user, company: company}
    end

    test "a member sees the dashboard of the company of the host", %{conn: conn} do
      {:ok, _lv, html} = conn |> on_host("orbit.example.com") |> live(~p"/painel")
      assert html =~ "Orbit" or html =~ "orbit.example.com"
      assert html =~ "orbit.example.com"
    end

    test "an unknown subdomain is a 404", %{conn: conn} do
      conn = conn |> on_host("naoexiste.example.com") |> get(~p"/painel")
      assert html_response(conn, 404)
    end

    test "a non-member gets a 404 (and learns nothing about the company)", %{company: _company} do
      outsider = user_fixture()

      conn =
        build_conn() |> log_in_user(outsider) |> on_host("orbit.example.com") |> get(~p"/painel")

      assert html_response(conn, 404)
    end

    test "tenant pages on the root host are a 404", %{conn: conn} do
      conn = get(conn, ~p"/painel")
      assert html_response(conn, 404)
    end

    test "an anonymous visitor is sent to log in on the root host and returns afterwards" do
      conn = build_conn() |> on_host("orbit.example.com") |> get(~p"/contatos")

      assert redirected_to(conn) == "http://example.com/users/log-in"
      assert get_session(conn, :user_return_to) == "http://orbit.example.com/contatos"
    end

    test "root-only pages on a tenant host redirect to the root host", %{conn: conn} do
      conn = conn |> on_host("orbit.example.com") |> get(~p"/users/log-in")
      assert redirected_to(conn) == "http://example.com/users/log-in"
    end

    test "'/' on a tenant host goes to the dashboard; on the root it is the landing", %{
      conn: conn
    } do
      assert conn |> on_host("orbit.example.com") |> get(~p"/") |> redirected_to() == ~p"/painel"
      assert conn |> get(~p"/") |> html_response(200) =~ "O CRM pronto para virar o seu SaaS"
    end

    test "after login the return URL on the tenant is honoured" do
      user = user_fixture() |> set_password()

      conn =
        build_conn()
        |> init_test_session(%{user_return_to: "http://orbit.example.com/contatos"})
        |> post(~p"/users/log-in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert redirected_to(conn) == "http://orbit.example.com/contatos"
    end

    test "an external return URL is ignored" do
      user = user_fixture() |> set_password()

      conn =
        build_conn()
        |> init_test_session(%{user_return_to: "https://evil.com/steal"})
        |> post(~p"/users/log-in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert redirected_to(conn) == "http://example.com/empresas/nova"
    end
  end

  describe "post-login destination by number of companies" do
    test "0 -> create company, 1 -> its dashboard, many -> chooser" do
      user = user_fixture() |> set_password()
      params = %{"user" => %{"email" => user.email, "password" => valid_user_password()}}

      assert build_conn() |> post(~p"/users/log-in", params) |> redirected_to() ==
               "http://example.com/empresas/nova"

      company_fixture(user, %{subdomain: "primeira"})

      assert build_conn() |> post(~p"/users/log-in", params) |> redirected_to() ==
               "http://primeira.example.com/painel"

      company_fixture(user, %{subdomain: "segunda"})

      assert build_conn() |> post(~p"/users/log-in", params) |> redirected_to() ==
               "http://example.com/workspaces"
    end
  end

  describe "session cookie shared across subdomains" do
    test "the session cookie carries the base-host domain" do
      conn = get(build_conn(), ~p"/")
      assert %{domain: ".example.com"} = conn.resp_cookies["_ledger_starter_key"]
    end

    test "the remember-me cookie too" do
      user = user_fixture() |> set_password()

      conn =
        post(build_conn(), ~p"/users/log-in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert %{domain: ".example.com"} = conn.resp_cookies["_ledger_starter_web_user_remember_me"]
      assert %{domain: ".example.com"} = conn.resp_cookies["_ledger_starter_key"]
    end

    test "a host outside the base domain does not get a mismatching domain" do
      conn = get(%{build_conn() | host: "localhost"}, ~p"/")
      refute Map.get(conn.resp_cookies["_ledger_starter_key"], :domain)
    end

    test "cookie_domain_for/1" do
      assert Tenant.cookie_domain_for("example.com") == ".example.com"
      assert Tenant.cookie_domain_for("orbit.example.com") == ".example.com"
      assert Tenant.cookie_domain_for("evilexample.com") == nil
      assert Tenant.cookie_domain_for("localhost") == nil
    end

    test "a session started on the root host authenticates on the tenant host" do
      user = user_fixture()
      company_fixture(user, %{subdomain: "orbit"})
      token = LedgerStarter.Accounts.generate_user_session_token(user)

      # the same session (cookie) is replayed on the tenant host
      conn =
        build_conn()
        |> init_test_session(%{user_token: token})
        |> on_host("orbit.example.com")
        |> get(~p"/contatos")

      assert html_response(conn, 200) =~ "Contatos"
    end
  end

  describe "health" do
    test "live and ready answer without auth on any host", %{conn: conn} do
      assert conn |> get(~p"/health/live") |> json_response(200) == %{"status" => "ok"}

      assert conn |> on_host("orbit.example.com") |> get(~p"/health/ready") |> json_response(200) ==
               %{"status" => "ok"}
    end
  end
end
