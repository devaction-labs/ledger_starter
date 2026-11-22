defmodule LedgerStarter.Companies.InvitationNotifier do
  @moduledoc "Invitation e-mail (pt-BR)."

  alias LedgerStarter.Mailer

  def deliver(invitation, company, inviter, url) do
    who = (inviter && (inviter.name || inviter.email)) || "Alguém"

    invitation.email
    |> Mailer.build(
      "#{who} convidou você para #{company.name} no StartKit",
      "Você foi convidado para #{company.name}",
      [
        "#{who} convidou você para entrar no workspace #{company.name}.",
        "O convite vale por 7 dias. Entre com o e-mail #{invitation.email} para aceitar."
      ],
      {"Aceitar convite", url}
    )
    |> Mailer.deliver()
  end
end
