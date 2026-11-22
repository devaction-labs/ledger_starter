defmodule LedgerStarterWeb.InvitationControllerTest do
  use LedgerStarterWeb.ConnCase, async: true

  import LedgerStarter.AccountsFixtures
  import LedgerStarter.CompaniesFixtures

  alias LedgerStarter.{Companies, Permissions}

  setup do
    owner = company_scope_fixture()
    %{owner: owner, company: owner.company}
  end

  defp flush_emails do
    receive do
      {:email, _} -> flush_emails()
    after
      0 -> :ok
    end
  end

  defp invite(owner, email, role \\ "member") do
    flush_emails()

    {:ok, %{sent: [_]}} =
      Companies.invite_people(owner, email, role, &"http://example.com/convites/#{&1}")

    assert_received {:email, %{to: [{_, ^email}]} = msg}
    [_, token] = Regex.run(~r{/convites/([A-Za-z0-9_-]+)}, msg.text_body)
    token
  end

  test "the e-mail links to the accept page", %{owner: owner} do
    token = invite(owner, "novo@example.com")
    assert is_binary(token) and byte_size(token) > 20
  end

  test "logged in with the invited e-mail: joins and lands on the company", %{
    conn: conn,
    owner: owner,
    company: company
  } do
    invitee = user_fixture()
    token = invite(owner, invitee.email, "admin")

    conn = conn |> log_in_user(invitee) |> get(~p"/convites/#{token}")

    assert redirected_to(conn) == "http://#{company.subdomain}.example.com/painel"
    assert Companies.member?(invitee, company)
    assert Permissions.role_of(invitee.id, company.id) == "admin"
  end

  test "logged in with another e-mail: refused, not joined", %{
    conn: conn,
    owner: owner,
    company: company
  } do
    token = invite(owner, "convidado@example.com")
    stranger = user_fixture()

    conn = conn |> log_in_user(stranger) |> get(~p"/convites/#{token}")

    assert redirected_to(conn) == ~p"/workspaces"
    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "convidado@example.com"
    refute Companies.member?(stranger, company)
  end

  test "anonymous: goes to register with the e-mail prefilled and joins after logging in", %{
    conn: conn,
    owner: owner,
    company: company
  } do
    token = invite(owner, "paula@example.com")

    conn = get(conn, ~p"/convites/#{token}")
    assert redirected_to(conn) == "/users/register?email=paula%40example.com"
    assert get_session(conn, :user_return_to) == "/convites/#{token}"

    # she registers (password) and logs in; the return path brings her back to the link
    {:ok, user} =
      LedgerStarter.Accounts.register_user(valid_user_attributes(email: "paula@example.com"))

    conn =
      conn
      |> recycle()
      |> post(~p"/users/log-in", %{
        "user" => %{"email" => user.email, "password" => valid_user_password()}
      })

    assert redirected_to(conn) == "/convites/#{token}"

    conn = conn |> recycle() |> get(~p"/convites/#{token}")
    assert redirected_to(conn) == "http://#{company.subdomain}.example.com/painel"
    assert Companies.member?(user, company)
  end

  test "an invalid token redirects home with an error", %{conn: conn} do
    conn = get(conn, ~p"/convites/invalido")
    assert redirected_to(conn) == ~p"/"
    assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "inválido"
  end

  test "a used invitation cannot be reused", %{conn: conn, owner: owner} do
    invitee = user_fixture()
    token = invite(owner, invitee.email)

    conn = conn |> log_in_user(invitee) |> get(~p"/convites/#{token}")
    assert redirected_to(conn) =~ "/painel"

    conn = build_conn() |> log_in_user(invitee) |> get(~p"/convites/#{token}")
    assert redirected_to(conn) == ~p"/"
  end
end
