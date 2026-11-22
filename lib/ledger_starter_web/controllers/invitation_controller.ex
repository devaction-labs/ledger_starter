defmodule LedgerStarterWeb.InvitationController do
  use LedgerStarterWeb, :controller

  alias LedgerStarter.{Accounts.Scope, Companies}
  alias LedgerStarterWeb.Tenant

  @doc """
  Landing of the invitation link. Logged-in with the invited e-mail: joins and
  goes to the company. Otherwise register/log in (the link is kept as the
  return path) and join afterwards.
  """
  def show(conn, %{"token" => token}) do
    case {Companies.get_invitation_by_token(token), conn.assigns.current_scope} do
      {nil, _} ->
        conn
        |> put_flash(:error, "Este convite é inválido ou expirou.")
        |> redirect(to: ~p"/")

      {invitation, %Scope{user: %{} = user}} ->
        case Companies.accept_invitation(token, user) do
          {:ok, company} ->
            conn
            |> put_flash(:info, "Você entrou em #{company.name}.")
            |> redirect(external: Tenant.company_url(company, "/painel"))

          {:error, :email_mismatch} ->
            conn
            |> put_flash(
              :error,
              "Este convite é para #{invitation.email}. Entre com esse e-mail para aceitar."
            )
            |> redirect(to: ~p"/workspaces")

          {:error, _} ->
            conn
            |> put_flash(:error, "Não foi possível aceitar o convite.")
            |> redirect(to: ~p"/workspaces")
        end

      {invitation, _} ->
        conn
        |> put_session(:user_return_to, ~p"/convites/#{token}")
        |> put_flash(:info, "Crie sua conta ou entre para entrar em #{invitation.company.name}.")
        |> redirect(to: ~p"/users/register?#{[email: invitation.email]}")
    end
  end
end
