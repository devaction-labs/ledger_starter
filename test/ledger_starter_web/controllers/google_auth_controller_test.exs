defmodule LedgerStarterWeb.GoogleAuthControllerTest do
  # Not async: it flips global application env (Google config + Assent stub).
  use LedgerStarterWeb.ConnCase, async: false

  import LedgerStarter.AccountsFixtures

  alias LedgerStarter.{Accounts, Repo}
  alias LedgerStarter.Auth.GoogleStub

  setup do
    prev = Application.get_env(:ledger_starter, :google_oauth)
    Application.put_env(:ledger_starter, :google_oauth, client_id: "id", client_secret: "secret")
    Application.put_env(:ledger_starter, :google_adapter, GoogleStub)

    on_exit(fn ->
      Application.put_env(:ledger_starter, :google_oauth, prev)
      Application.delete_env(:ledger_starter, :google_adapter)
    end)

    :ok
  end

  defp claims(overrides \\ %{}) do
    Map.merge(
      %{
        "sub" => "google-uid-#{System.unique_integer([:positive])}",
        "email" => unique_user_email(),
        "email_verified" => true,
        "name" => "Maria Google"
      },
      overrides
    )
  end

  defp start_flow(conn) do
    conn = get(conn, ~p"/auth/google")
    assert redirected_to(conn) =~ "https://accounts.google.test/auth"
    assert redirected_to(conn) =~ URI.encode_www_form("http://example.com/auth/google/callback")
    conn
  end

  test "request is refused when Google is not configured", %{conn: conn} do
    Application.put_env(:ledger_starter, :google_oauth, client_id: nil, client_secret: nil)
    conn = get(conn, ~p"/auth/google")
    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "callback creates a confirmed user and stores google_uid", %{conn: conn} do
    c = claims()
    GoogleStub.set_claims(c)

    conn =
      conn
      |> start_flow()
      |> recycle()
      |> get(~p"/auth/google/callback", %{"code" => "abc", "state" => "state-123"})

    user = Accounts.get_user_by_email(c["email"])
    assert user.google_uid == c["sub"]
    assert user.name == "Maria Google"
    assert user.confirmed_at
    assert get_session(conn, :user_token)
    # no company yet
    assert redirected_to(conn) == "http://example.com/empresas/nova"
  end

  test "callback links an existing user by verified e-mail", %{conn: conn} do
    existing = user_fixture()
    c = claims(%{"email" => existing.email})
    GoogleStub.set_claims(c)

    conn = conn |> start_flow() |> recycle() |> get(~p"/auth/google/callback", %{"code" => "abc"})

    assert get_session(conn, :user_token)
    assert Accounts.get_user!(existing.id).google_uid == c["sub"]
    assert Repo.aggregate(LedgerStarter.Accounts.User, :count) == 1
  end

  test "linking an unconfirmed account discards its unverified password", %{conn: conn} do
    unconfirmed = unconfirmed_user_fixture()
    assert unconfirmed.hashed_password
    GoogleStub.set_claims(claims(%{"email" => unconfirmed.email}))

    conn |> start_flow() |> recycle() |> get(~p"/auth/google/callback", %{"code" => "abc"})

    user = Accounts.get_user!(unconfirmed.id)
    assert user.confirmed_at
    assert is_nil(user.hashed_password)
  end

  test "an unverified Google e-mail is refused", %{conn: conn} do
    c = claims(%{"email_verified" => false})
    GoogleStub.set_claims(c)

    conn = conn |> start_flow() |> recycle() |> get(~p"/auth/google/callback", %{"code" => "abc"})

    refute get_session(conn, :user_token)
    assert redirected_to(conn) == ~p"/users/log-in"
    refute Accounts.get_user_by_email(c["email"])
  end

  test "an OAuth error from Google redirects back to login", %{conn: conn} do
    conn =
      conn
      |> start_flow()
      |> recycle()
      |> get(~p"/auth/google/callback", %{"error" => "access_denied"})

    refute get_session(conn, :user_token)
    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "callback without a started flow (no session state) is refused", %{conn: conn} do
    GoogleStub.set_claims(claims())
    conn = get(conn, ~p"/auth/google/callback", %{"code" => "abc"})
    refute get_session(conn, :user_token)
    assert redirected_to(conn) == ~p"/users/log-in"
  end
end
