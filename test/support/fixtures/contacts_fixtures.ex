defmodule LedgerStarter.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LedgerStarter.Contacts` context.
  """

  @doc """
  Generate a contact.
  """
  def contact_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        company_name: "some company_name",
        email: "contato@example.com",
        name: "some name",
        phone: "some phone",
        stage: :lead
      })

    {:ok, contact} = LedgerStarter.Contacts.create_contact(scope, attrs)
    contact
  end
end
