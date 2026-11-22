defmodule LedgerStarterWeb.LocaleController do
  @moduledoc """
  The language switcher target: `GET /idioma/:locale?to=/path`. Sets the `locale`
  cookie (shared across subdomains), saves the choice on the logged-in user and
  goes back to a local path.
  """
  use LedgerStarterWeb, :controller

  alias LedgerStarter.{Accounts, Locale}
  alias LedgerStarterWeb.Plugs.Locale, as: LocalePlug

  def update(conn, %{"locale" => locale} = params) do
    case Locale.normalize(locale) do
      nil ->
        redirect(conn, to: target(conn, params))

      locale ->
        case conn.assigns.current_scope do
          %{user: %{} = user} -> Accounts.update_user_locale(user, locale)
          _ -> :ok
        end

        conn
        |> LocalePlug.put_locale_cookie(locale)
        |> put_session(:locale, locale)
        |> redirect(to: target(conn, params))
    end
  end

  # `to`, else the path of a same-host referer, else "/".
  defp target(conn, params) do
    case params["to"] do
      nil -> referer_path(conn)
      to -> safe_path(to)
    end
  end

  defp referer_path(conn) do
    with [referer | _] <- get_req_header(conn, "referer"),
         %URI{host: host, path: path, query: query} when host == conn.host and is_binary(path) <-
           URI.parse(referer) do
      safe_path(if query, do: path <> "?" <> query, else: path)
    else
      _ -> "/"
    end
  end

  # Only local paths ("/x", not "//host" nor "/\\host").
  defp safe_path("/" <> rest = path) do
    if String.starts_with?(rest, ["/", "\\"]), do: "/", else: path
  end

  defp safe_path(_), do: "/"
end
