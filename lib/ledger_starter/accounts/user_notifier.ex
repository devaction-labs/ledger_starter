defmodule LedgerStarter.Accounts.UserNotifier do
  @moduledoc "Account e-mails (pt-BR)."

  alias LedgerStarter.Accounts.User
  alias LedgerStarter.Mailer

  defp deliver(email) do
    with {:ok, _metadata} <- Mailer.deliver(email), do: {:ok, email}
  end

  def deliver_update_email_instructions(user, url) do
    Mailer.build(
      user.email,
      "Confirme a alteração do seu e-mail",
      "Confirme seu novo e-mail",
      [
        "Use o botão abaixo para confirmar a alteração do e-mail da sua conta.",
        "Se você não pediu isso, ignore esta mensagem."
      ],
      {"Confirmar e-mail", url}
    )
    |> deliver()
  end

  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    Mailer.build(
      user.email,
      "Seu link de acesso ao StartKit",
      "Entrar no StartKit",
      [
        "Clique no botão para entrar. O link vale por 15 minutos e só pode ser usado uma vez.",
        "Se você não pediu este e-mail, ignore-o."
      ],
      {"Entrar agora", url}
    )
    |> deliver()
  end

  defp deliver_confirmation_instructions(user, url) do
    Mailer.build(
      user.email,
      "Confirme sua conta no StartKit",
      "Confirme sua conta",
      [
        "Bem-vindo ao StartKit! Confirme seu e-mail e entre usando o botão abaixo. O link vale por 15 minutos.",
        "Se você não criou uma conta, ignore esta mensagem."
      ],
      {"Confirmar e entrar", url}
    )
    |> deliver()
  end
end
