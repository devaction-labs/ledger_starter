defmodule LedgerStarter.I18nEmailsTest do
  use LedgerStarter.DataCase, async: true

  import LedgerStarter.AccountsFixtures
  import LedgerStarter.CompaniesFixtures

  alias LedgerStarter.{Accounts, Companies, Locale}

  defp english(user) do
    {:ok, user} = Accounts.update_user_locale(user, "en")
    user
  end

  describe "account e-mails are sent in the recipient's language" do
    test "confirmation (unconfirmed user) in English" do
      user = english(unconfirmed_user_fixture())

      {:ok, email} = Accounts.deliver_login_instructions(user, &"http://example.com/l/1/#{&1}")

      assert email.subject == "Confirm your StartKit account"
      assert email.text_body =~ "Welcome to StartKit!"
      assert email.text_body =~ "http://example.com/l/1/"
      assert email.html_body =~ "Confirm your account"
      assert email.html_body =~ "Or copy this link: http://example.com/l/1"
    end

    test "magic link in English" do
      user = english(user_fixture())

      {:ok, email} = Accounts.deliver_login_instructions(user, &"http://example.com/l/2/#{&1}")

      assert email.subject == "Your StartKit sign-in link"
      assert email.text_body =~ "Click the button to sign in."
    end

    test "e-mail change in English" do
      user = english(user_fixture())

      {:ok, email} =
        Accounts.deliver_user_update_email_instructions(user, user.email, fn token ->
          "http://example.com/c/#{token}"
        end)

      assert email.subject == "Confirm your email change"
      assert email.text_body =~ "Confirm email:"
    end

    test "pt_BR users keep receiving Portuguese" do
      user = user_fixture()
      assert user.locale == "pt_BR"

      {:ok, email} = Accounts.deliver_login_instructions(user, &"http://example.com/l/3/#{&1}")

      assert email.subject == "Seu link de acesso ao StartKit"
      assert email.html_body =~ "Ou copie este link: http://example.com/l/3"
    end

    test "the sending process keeps its own locale" do
      Locale.put("pt_BR")
      user = english(user_fixture())

      {:ok, _} = Accounts.deliver_login_instructions(user, &"http://example.com/l/4/#{&1}")

      assert Locale.current() == "pt_BR"
    end
  end

  describe "invitations use the inviter's language" do
    test "English inviter" do
      owner = company_scope_fixture()
      {:ok, _} = Accounts.update_user_locale(owner.user, "en")
      owner = %{owner | user: Accounts.get_user!(owner.user.id)}

      assert {:ok, %{sent: [_]}} =
               Companies.invite_people(
                 owner,
                 "new@example.com",
                 "sales",
                 &"http://example.com/c/#{&1}"
               )

      assert_received_email("new@example.com", fn email ->
        assert email.subject =~ "invited you to #{owner.company.name} on StartKit"
        assert email.text_body =~ "The invitation is valid for 7 days."
        assert email.text_body =~ "Accept invitation:"
      end)
    end

    test "Portuguese inviter" do
      owner = company_scope_fixture()

      assert {:ok, %{sent: [_]}} =
               Companies.invite_people(
                 owner,
                 "novo@example.com",
                 "sales",
                 &"http://example.com/c/#{&1}"
               )

      assert_received_email("novo@example.com", fn email ->
        assert email.subject =~ "convidou você para #{owner.company.name} no StartKit"
        assert email.text_body =~ "Aceitar convite:"
      end)
    end
  end

  # The test mailer adapter sends the e-mail to the calling process.
  defp assert_received_email(to, fun) do
    assert_received {:email, %{to: [{_, ^to}]} = email}
    fun.(email)
  end
end
