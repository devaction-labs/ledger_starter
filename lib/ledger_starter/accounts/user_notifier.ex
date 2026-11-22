defmodule LedgerStarter.Accounts.UserNotifier do
  @moduledoc "Account e-mails, sent in the recipient's language (`user.locale`)."
  use Gettext, backend: LedgerStarterWeb.Gettext

  alias LedgerStarter.Accounts.User
  alias LedgerStarter.{Locale, Mailer}

  defp deliver(email) do
    with {:ok, _metadata} <- Mailer.deliver(email), do: {:ok, email}
  end

  def deliver_update_email_instructions(user, url) do
    Locale.with_locale(user.locale, fn ->
      Mailer.build(
        user.email,
        gettext("Confirme a alteração do seu e-mail"),
        gettext("Confirme seu novo e-mail"),
        [
          gettext("Use o botão abaixo para confirmar a alteração do e-mail da sua conta."),
          gettext("Se você não pediu isso, ignore esta mensagem.")
        ],
        {gettext("Confirmar e-mail"), url}
      )
      |> deliver()
    end)
  end

  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    Locale.with_locale(user.locale, fn ->
      Mailer.build(
        user.email,
        gettext("Seu link de acesso ao StartKit"),
        gettext("Entrar no StartKit"),
        [
          gettext(
            "Clique no botão para entrar. O link vale por 15 minutos e só pode ser usado uma vez."
          ),
          gettext("Se você não pediu este e-mail, ignore-o.")
        ],
        {gettext("Entrar agora"), url}
      )
      |> deliver()
    end)
  end

  defp deliver_confirmation_instructions(user, url) do
    Locale.with_locale(user.locale, fn ->
      Mailer.build(
        user.email,
        gettext("Confirme sua conta no StartKit"),
        gettext("Confirme sua conta"),
        [
          gettext(
            "Bem-vindo ao StartKit! Confirme seu e-mail e entre usando o botão abaixo. O link vale por 15 minutos."
          ),
          gettext("Se você não criou uma conta, ignore esta mensagem.")
        ],
        {gettext("Confirmar e entrar"), url}
      )
      |> deliver()
    end)
  end
end
