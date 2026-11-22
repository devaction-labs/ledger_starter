defmodule LedgerStarter.Companies.InvitationNotifier do
  @moduledoc """
  Invitation e-mail, sent in the inviter's language (`inviter.locale`; the invitee
  has no account yet, so no preference of their own). Falls back to `pt_BR`.
  """
  use Gettext, backend: LedgerStarterWeb.Gettext

  alias LedgerStarter.{Locale, Mailer}

  def deliver(invitation, company, inviter, url) do
    Locale.with_locale(inviter && inviter.locale, fn ->
      who = (inviter && (inviter.name || inviter.email)) || gettext("Alguém")

      invitation.email
      |> Mailer.build(
        gettext("%{who} convidou você para %{company} no StartKit",
          who: who,
          company: company.name
        ),
        gettext("Você foi convidado para %{company}", company: company.name),
        [
          gettext("%{who} convidou você para entrar no workspace %{company}.",
            who: who,
            company: company.name
          ),
          gettext("O convite vale por 7 dias. Entre com o e-mail %{email} para aceitar.",
            email: invitation.email
          )
        ],
        {gettext("Aceitar convite"), url}
      )
      |> Mailer.deliver()
    end)
  end
end
