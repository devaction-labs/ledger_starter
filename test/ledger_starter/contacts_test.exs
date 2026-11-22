defmodule LedgerStarter.ContactsTest do
  use LedgerStarter.DataCase

  alias LedgerStarter.Contacts

  describe "contacts" do
    alias LedgerStarter.Contacts.Contact

    import LedgerStarter.CompaniesFixtures, only: [company_scope_fixture: 0]
    import LedgerStarter.ContactsFixtures

    @invalid_attrs %{name: nil, stage: nil, email: nil, phone: nil, company_name: nil}

    test "list_contacts/1 returns all scoped contacts" do
      scope = company_scope_fixture()
      other_scope = company_scope_fixture()
      contact = contact_fixture(scope)
      other_contact = contact_fixture(other_scope)
      assert Contacts.list_contacts(scope) == [contact]
      assert Contacts.list_contacts(other_scope) == [other_contact]
    end

    test "get_contact!/2 returns the contact with given id" do
      scope = company_scope_fixture()
      contact = contact_fixture(scope)
      other_scope = company_scope_fixture()
      assert Contacts.get_contact!(scope, contact.id) == contact
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(other_scope, contact.id) end
    end

    test "create_contact/2 with valid data creates a contact" do
      valid_attrs = %{
        name: "some name",
        stage: :lead,
        email: "some email",
        phone: "some phone",
        company_name: "some company_name"
      }

      scope = company_scope_fixture()

      assert {:ok, %Contact{} = contact} = Contacts.create_contact(scope, valid_attrs)
      assert contact.name == "some name"
      assert contact.stage == :lead
      assert contact.email == "some email"
      assert contact.phone == "some phone"
      assert contact.company_name == "some company_name"
      assert contact.company_id == scope.company.id
    end

    test "create_contact/2 with invalid data returns error changeset" do
      scope = company_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(scope, @invalid_attrs)
    end

    test "update_contact/3 with valid data updates the contact" do
      scope = company_scope_fixture()
      contact = contact_fixture(scope)

      update_attrs = %{
        name: "some updated name",
        stage: :qualified,
        email: "some updated email",
        phone: "some updated phone",
        company_name: "some updated company_name"
      }

      assert {:ok, %Contact{} = contact} = Contacts.update_contact(scope, contact, update_attrs)
      assert contact.name == "some updated name"
      assert contact.stage == :qualified
      assert contact.email == "some updated email"
      assert contact.phone == "some updated phone"
      assert contact.company_name == "some updated company_name"
    end

    test "update_contact/3 with invalid scope raises" do
      scope = company_scope_fixture()
      other_scope = company_scope_fixture()
      contact = contact_fixture(scope)

      assert_raise MatchError, fn ->
        Contacts.update_contact(other_scope, contact, %{})
      end
    end

    test "update_contact/3 with invalid data returns error changeset" do
      scope = company_scope_fixture()
      contact = contact_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(scope, contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(scope, contact.id)
    end

    test "delete_contact/2 deletes the contact" do
      scope = company_scope_fixture()
      contact = contact_fixture(scope)
      assert {:ok, %Contact{}} = Contacts.delete_contact(scope, contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(scope, contact.id) end
    end

    test "delete_contact/2 with invalid scope raises" do
      scope = company_scope_fixture()
      other_scope = company_scope_fixture()
      contact = contact_fixture(scope)
      assert_raise MatchError, fn -> Contacts.delete_contact(other_scope, contact) end
    end

    test "change_contact/2 returns a contact changeset" do
      scope = company_scope_fixture()
      contact = contact_fixture(scope)
      assert %Ecto.Changeset{} = Contacts.change_contact(scope, contact)
    end
  end
end
