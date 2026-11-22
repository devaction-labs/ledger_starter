defmodule LedgerStarterWeb.GoogleAuthController do
  use LedgerStarterWeb, :controller

  alias LedgerStarter.Accounts
  alias LedgerStarter.Auth.Google
  alias LedgerStarterWeb.{Tenant, UserAuth}

  def request(conn, _params) do
    with true <- Google.enabled?(),
         {:ok, %{url: url, session_params: session_params}} <-
           Google.authorize_url(redirect_uri(conn)) do
      conn
      |> put_session(:google_session_params, session_params)
      |> redirect(external: url)
    else
      false ->
        conn
        |> put_flash(:error, "Login com Google não está configurado.")
        |> redirect(to: ~p"/users/log-in")

      {:error, _} ->
        conn
        |> put_flash(:error, "Não foi possível iniciar o login com Google.")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  def callback(conn, params) do
    session_params = get_session(conn, :google_session_params)
    conn = delete_session(conn, :google_session_params)

    with true <- Google.enabled?() and is_map(session_params),
         {:ok, claims} <- Google.callback(redirect_uri(conn), params, session_params),
         {:ok, user} <- Accounts.find_or_create_google_user(claims) do
      conn
      |> put_flash(:info, "Bem-vindo, #{user.name || user.email}!")
      |> UserAuth.log_in_user(user, %{"remember_me" => "true"})
    else
      _ ->
        conn
        |> put_flash(
          :error,
          "Não foi possível entrar com o Google. Tente novamente ou use seu e-mail."
        )
        |> redirect(to: ~p"/users/log-in")
    end
  end

  defp redirect_uri(_conn), do: Tenant.root_url("/auth/google/callback")
end
