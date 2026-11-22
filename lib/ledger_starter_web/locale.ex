defmodule LedgerStarterWeb.Locale do
  @moduledoc """
  LiveView side of the locale: an `on_mount` hook that sets the Gettext locale of
  the LiveView process and assigns `:locale` and `:locale_ui`.

  Order: user preference > `?locale=` > the locale the plug stored in the session
  (cookie / `Accept-Language`) > `pt_BR`. It must run after the `UserAuth` hook
  that assigns `current_scope`.

      live_session :x, on_mount: [{LedgerStarterWeb.UserAuth, :mount_current_scope}, LedgerStarterWeb.Locale]

  It also calls `LedgerUI.put_locale/1` so the kit components render in the same
  language in the connected process.
  """
  import Phoenix.Component, only: [assign: 2]

  alias LedgerStarter.Locale

  def on_mount(:default, params, session, socket) do
    locale =
      user_locale(socket) ||
        Locale.normalize(params["locale"]) ||
        Locale.normalize(session["locale"]) ||
        Locale.default()

    Locale.put(locale)
    LedgerUI.put_locale(Locale.ui(locale))
    {:cont, assign(socket, locale: locale, locale_ui: Locale.ui(locale))}
  end

  defp user_locale(socket) do
    case socket.assigns[:current_scope] do
      %{user: %{locale: locale}} when is_binary(locale) -> Locale.normalize(locale)
      _ -> nil
    end
  end
end
