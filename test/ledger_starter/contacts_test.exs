defmodule LedgerStarter.ContactsTest do
  use LedgerStarter.DataCase, async: true

  import LedgerStarter.CompaniesFixtures
  import LedgerStarter.ContactsFixtures

  alias LedgerStarter.Contacts
  alias LedgerStarter.Contacts.Contact

  describe "tenant scoping" do
    test "a company never sees another company's contacts" do
      scope = company_scope_fixture()
      other = company_scope_fixture()
      mine = contact_fixture(scope, %{name: "Minha"})
      theirs = contact_fixture(other, %{name: "Deles"})

      assert [%{id: id}] = Contacts.list_contacts(scope)
      assert id == mine.id
      assert [%{id: other_id}] = Contacts.list_contacts(other)
      assert other_id == theirs.id
    end

    test "get_contact!/2 raises for a contact of another company" do
      scope = company_scope_fixture()
      other = company_scope_fixture()
      contact = contact_fixture(scope)

      assert Contacts.get_contact!(scope, contact.id).id == contact.id
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(other, contact.id) end
    end

    test "update/delete refuse a contact of another company" do
      scope = company_scope_fixture()
      other = company_scope_fixture()
      contact = contact_fixture(scope)

      assert_raise MatchError, fn -> Contacts.update_contact(other, contact, %{name: "x"}) end
      assert_raise MatchError, fn -> Contacts.delete_contact(other, contact) end
      assert Contacts.get_contact!(scope, contact.id).name == contact.name
    end

    test "company_id and owner come from the scope, never from the params" do
      scope = company_scope_fixture()
      other = company_scope_fixture()

      {:ok, contact} =
        Contacts.create_contact(scope, %{
          name: "Ana",
          email: "ana@example.com",
          stage: :lead,
          company_id: other.company.id,
          owner_id: other.user.id
        })

      assert contact.company_id == scope.company.id
      assert contact.owner_id == scope.user.id
    end

    test "count_by_stage/1 counts only the company's contacts" do
      scope = company_scope_fixture()
      other = company_scope_fixture()
      contact_fixture(scope, %{stage: :lead})
      contact_fixture(scope, %{stage: :customer})
      contact_fixture(other, %{stage: :customer})

      assert Contacts.count_by_stage(scope) == %{lead: 1, qualified: 0, customer: 1}
    end

    test "each company is notified only of its own changes" do
      scope = company_scope_fixture()
      other = company_scope_fixture()
      Contacts.subscribe_contacts(scope)

      contact_fixture(other)
      refute_receive {:created, _}

      contact = contact_fixture(scope)
      assert_receive {:created, %Contact{id: id}}
      assert id == contact.id
    end
  end

  describe "create/update/delete" do
    test "requires name, e-mail and stage" do
      scope = company_scope_fixture()
      assert {:error, changeset} = Contacts.create_contact(scope, %{})
      assert %{name: _, email: _, stage: _} = errors_on(changeset)
    end

    test "update_contact/3 and delete_contact/2" do
      scope = company_scope_fixture()
      contact = contact_fixture(scope)

      assert {:ok, %Contact{name: "Novo nome"}} =
               Contacts.update_contact(scope, contact, %{name: "Novo nome"})

      assert {:ok, _} = Contacts.delete_contact(scope, contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(scope, contact.id) end
    end
  end

  describe "authorization (PermitEx, per company)" do
    test "a member can create and update but not delete" do
      owner = company_scope_fixture()
      {_user, member} = member_fixture(owner.company, "member")

      assert {:ok, contact} =
               Contacts.create_contact(member, %{name: "A", email: "a@example.com", stage: :lead})

      assert {:ok, _} = Contacts.update_contact(member, contact, %{name: "B"})
      assert {:error, :unauthorized} = Contacts.delete_contact(member, contact)
    end

    test "an admin can delete" do
      owner = company_scope_fixture()
      {_user, admin} = member_fixture(owner.company, "admin")
      contact = contact_fixture(owner)

      assert {:ok, _} = Contacts.delete_contact(admin, contact)
    end

    test "permissions of one company do not apply in another" do
      owner = company_scope_fixture()
      other = company_scope_fixture()
      # the owner of `owner.company` is just a stranger in `other.company`
      stranger = company_scope_fixture(owner.user, other.company)

      assert {:error, :unauthorized} =
               Contacts.create_contact(stranger, %{
                 name: "A",
                 email: "a@example.com",
                 stage: :lead
               })
    end
  end
end
