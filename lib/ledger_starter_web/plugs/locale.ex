defmodule LedgerStarterWeb.Plugs.Locale do
  @moduledoc """
  Resolves the request locale and applies it.

  Order: user preference > `?locale=` > `locale` cookie > `Accept-Language` > `pt_BR`.

  Sets the Gettext locale of the request process, assigns `:locale` and
  `:locale_ui` (the Ledger UI locale) and stores the result in the session so
  LiveViews (see `LedgerStarterWeb.Locale.on_mount/4`) render in the same language.
  A valid `?locale=` also writes the cookie, so the choice sticks.

  The cookie is shared across tenant subdomains like the session cookie
  (`LedgerStarterWeb.Tenant.cookie_domain_for/1`).

  TODO: when the kit releases `LedgerUI.put_locale/1`, call it here (and in the
  LiveView hook) instead of passing `locale={@locale_ui}` to each component.
  """
  import Plug.Conn

  alias LedgerStarter.Locale
  alias LedgerStarterWeb.Tenant

  @cookie "locale"
  @max_age 60 * 60 * 24 * 365

  def cookie_name, do: @cookie

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_cookies(conn)
    param = Locale.normalize(conn.params["locale"] || conn.query_params["locale"])

    locale =
      user_locale(conn) ||
        param ||
        cookie_locale(conn) ||
        accept_language(conn) ||
        Locale.default()

    Locale.put(locale)

    conn
    |> maybe_write_cookie(param)
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
    |> assign(:locale_ui, Locale.ui(locale))
  end

  @doc "Writes the locale cookie (shared with the subdomains)."
  def put_locale_cookie(conn, locale) do
    opts = [max_age: @max_age, same_site: "Lax", http_only: false]

    opts =
      case Tenant.cookie_domain_for(conn.host) do
        nil -> opts
        domain -> Keyword.put(opts, :domain, domain)
      end

    put_resp_cookie(conn, @cookie, locale, opts)
  end

  defp maybe_write_cookie(conn, nil), do: conn
  defp maybe_write_cookie(conn, param), do: put_locale_cookie(conn, param)

  defp user_locale(conn) do
    case conn.assigns[:current_scope] do
      %{user: %{locale: locale}} when is_binary(locale) -> Locale.normalize(locale)
      _ -> nil
    end
  end

  defp cookie_locale(conn), do: Locale.normalize(conn.cookies[@cookie])

  defp accept_language(conn) do
    conn |> get_req_header("accept-language") |> List.first() |> Locale.from_accept_language()
  end
end
