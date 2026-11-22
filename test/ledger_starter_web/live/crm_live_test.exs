defmodule LedgerStarterWeb.CrmLiveTest do
  use LedgerStarterWeb.ConnCase, async: true

  import LedgerStarter.CompaniesFixtures
  import LedgerStarter.ContactsFixtures
  import Phoenix.LiveViewTest

  alias LedgerStarter.{Companies, Contacts}

  defp on_host(conn, company), do: %{conn | host: "#{company.subdomain}.example.com"}

  defp login_as(conn, company, role) do
    {user, scope} = member_fixture(company, role)
    {log_in_user(conn, user) |> on_host(company), user, scope}
  end

  setup do
    owner = company_scope_fixture()
    %{owner: owner, company: owner.company}
  end

  describe "dashboard" do
    test "shows the company's own metrics only", %{conn: conn, owner: owner, company: company} do
      contact_fixture(owner, %{stage: :customer, name: "Cliente Meu"})
      other = company_scope_fixture()
      contact_fixture(other, %{stage: :customer, name: "Cliente Alheio"})

      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/painel")
      html = render_async(lv)

      assert html =~ "Cliente Meu"
      refute html =~ "Cliente Alheio"
      assert html =~ company.name
    end
  end

  describe "contacts" do
    test "lists only this company's contacts (scoping)", %{
      conn: conn,
      owner: owner,
      company: company
    } do
      contact_fixture(owner, %{name: "Joana Prado"})
      other = company_scope_fixture()
      contact_fixture(other, %{name: "Intrusa Alheia"})

      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/contatos")
      html = render_async(lv)

      assert html =~ "Joana Prado"
      refute html =~ "Intrusa Alheia"
      assert html =~ "1 contato no workspace"
    end

    test "Novo contato modal creates a contact in the current company", %{
      conn: conn,
      owner: owner,
      company: company
    } do
      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/contatos")
      render_async(lv)

      html = lv |> element("#new-contact") |> render_click()
      assert_patch(lv, ~p"/contatos/novo")
      assert html =~ "Novo contato"
      assert has_element?(lv, "#contact-modal")

      # the segmented control sets the hidden stage input in the browser
      render_hook(lv, "save", %{
        "contact" => %{
          "name" => "Joana Prado",
          "email" => "joana@bompreco.com.br",
          "stage" => "customer"
        }
      })

      assert_patch(lv, ~p"/contatos")
      assert [contact] = Contacts.list_contacts(owner)
      assert contact.name == "Joana Prado"
      assert contact.stage == :customer
      assert contact.company_id == company.id
      assert contact.owner_id == owner.user.id
    end

    test "validates the modal form", %{conn: conn, owner: owner, company: company} do
      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/contatos/novo")

      html =
        lv |> form("#contact-modal", contact: %{name: "", email: "no"}) |> render_change()

      assert html =~ "can&#39;t be blank" or html =~ "can't be blank"
      assert html =~ "e-mail inválido"
    end

    test "edits and deletes", %{conn: conn, owner: owner, company: company} do
      contact = contact_fixture(owner, %{name: "Antes"})
      conn = conn |> log_in_user(owner.user) |> on_host(company)

      {:ok, lv, _} = live(conn, ~p"/contatos/#{contact.id}/editar")
      lv |> form("#contact-modal", contact: %{name: "Depois"}) |> render_submit()
      assert Contacts.get_contact!(owner, contact.id).name == "Depois"

      {:ok, lv, _} = live(conn, ~p"/contatos")
      render_async(lv)
      render_click(lv, "delete", %{"id" => contact.id})
      assert Contacts.list_contacts(owner) == []
    end

    test "cannot edit or delete a contact of another company", %{
      conn: conn,
      owner: owner,
      company: company
    } do
      other = company_scope_fixture()
      foreign = contact_fixture(other, %{name: "Alheio"})
      conn = conn |> log_in_user(owner.user) |> on_host(company)

      assert {:error, {:live_redirect, %{to: "/contatos"}}} =
               live(conn, ~p"/contatos/#{foreign.id}/editar")

      {:ok, lv, _} = live(conn, ~p"/contatos")
      render_async(lv)
      assert render_click(lv, "delete", %{"id" => foreign.id}) =~ "Contatos"
      assert Contacts.get_contact!(other, foreign.id)
    end

    test "a member sees the button but cannot delete", %{
      conn: conn,
      owner: owner,
      company: company
    } do
      contact = contact_fixture(owner)
      {conn, _user, _scope} = login_as(conn, company, "member")

      {:ok, lv, _} = live(conn, ~p"/contatos")
      html = render_async(lv)

      assert html =~ "Novo contato"
      refute html =~ "Excluir"
      render_click(lv, "delete", %{"id" => contact.id})
      assert Contacts.get_contact!(owner, contact.id)
    end

    test "changes by another member show up live", %{conn: conn, owner: owner, company: company} do
      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/contatos")
      render_async(lv)

      contact_fixture(owner, %{name: "Chegou Agora"})
      assert render_async(lv) =~ "Chegou Agora"
    end
  end

  describe "team" do
    test "lists members with roles and pending invitations of this company only", %{
      conn: conn,
      owner: owner,
      company: company
    } do
      {_u, _s} = member_fixture(company, "admin")
      other = company_scope_fixture()

      {:ok, _} =
        Companies.invite_people(owner, "pendente@example.com", "member", &"http://x/#{&1}")

      {:ok, _} = Companies.invite_people(other, "alheio@example.com", "member", &"http://x/#{&1}")

      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/equipe")
      html = render_async(lv)

      assert html =~ owner.user.email
      assert html =~ "Dono"
      assert html =~ "Admin"
      assert html =~ "pendente@example.com"
      assert html =~ "Convite enviado"
      refute html =~ "alheio@example.com"
      assert html =~ "3 de 10 assentos"
    end

    test "the invite drawer sends invitations", %{conn: conn, owner: owner, company: company} do
      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/equipe/convidar")

      assert has_element?(lv, "#invite-drawer")

      html =
        lv
        |> form("#invite-form",
          invite: %{emails: "paula@example.com, joao@example.com", role: "admin"}
        )
        |> render_change()

      assert html =~ "Enviar 2 convites"

      lv
      |> form("#invite-form",
        invite: %{emails: "paula@example.com, joao@example.com", role: "admin"}
      )
      |> render_submit()

      assert_patch(lv, ~p"/equipe")
      assert {:ok, invitations} = Companies.list_pending_invitations(owner)

      assert Enum.sort(Enum.map(invitations, & &1.email)) == [
               "joao@example.com",
               "paula@example.com"
             ]

      assert Enum.all?(invitations, &(&1.role == "admin"))
    end

    test "a member sees the team but not the invite button and cannot open the drawer", %{
      conn: conn,
      company: company
    } do
      {conn, _user, _scope} = login_as(conn, company, "member")

      {:ok, lv, _} = live(conn, ~p"/equipe")
      html = render_async(lv)
      refute html =~ "Convidar pessoas"

      assert {:error, {:live_redirect, %{to: "/equipe"}}} = live(conn, ~p"/equipe/convidar")
    end

    test "a member cannot invite by forging the event", %{conn: conn, company: company} do
      {conn, _user, scope} = login_as(conn, company, "member")
      {:ok, lv, _} = live(conn, ~p"/equipe")
      render_async(lv)

      render_hook(lv, "invite", %{"invite" => %{"emails" => "x@example.com", "role" => "member"}})

      assert {:ok, []} =
               Companies.list_pending_invitations(%{
                 scope
                 | permissions: MapSet.new(["team:read"])
               })
    end

    test "owner changes a member's role; admin cannot", %{
      conn: conn,
      owner: owner,
      company: company
    } do
      {member, _} = member_fixture(company, "member")
      {admin_conn, _admin, _} = login_as(build_conn(), company, "admin")

      {:ok, lv, _} = live(admin_conn, ~p"/equipe")
      render_async(lv)
      render_click(lv, "set_role", %{"user-id" => member.id, "role" => "admin"})
      assert LedgerStarter.Permissions.role_of(member.id, company.id) == "member"

      conn = conn |> log_in_user(owner.user) |> on_host(company)
      {:ok, lv, _} = live(conn, ~p"/equipe")
      render_async(lv)
      render_click(lv, "set_role", %{"user-id" => member.id, "role" => "admin"})
      assert LedgerStarter.Permissions.role_of(member.id, company.id) == "admin"
    end
  end

  describe "workspace switcher" do
    test "lists the user's companies linking to their subdomains", %{
      conn: conn,
      owner: owner,
      company: company
    } do
      second = company_fixture(owner.user, %{name: "Segunda Empresa", subdomain: "segunda"})
      conn = conn |> log_in_user(owner.user) |> on_host(company)

      {:ok, lv, _} = live(conn, ~p"/painel")
      html = render_async(lv)

      assert html =~ "workspace-switcher"
      assert html =~ "http://segunda.example.com/painel"
      assert html =~ "http://#{company.subdomain}.example.com/painel"
      assert html =~ second.name
    end
  end
end
