defmodule LedgerStarterWeb.CoreComponents do
  @moduledoc """
  Small app-level helpers. All visual components come from `LedgerUI`
  (`use LedgerUI` in `LedgerStarterWeb.html_helpers/0`); this module only keeps
  the Gettext error translation used by form fields.
  """
  use Phoenix.Component
  use Gettext, backend: LedgerStarterWeb.Gettext
  import LedgerUI.Components.Navbar, only: [navbar_lang: 1]

  @doc """
  The PT / EN language switcher (the kit's `navbar_lang`). The links go through
  `LedgerStarterWeb.LocaleController`, which sets the cookie, saves the choice on
  the logged-in user and comes back to the page (`to`, or the referer).
  """
  attr :to, :string, default: nil, doc: "path to come back to (defaults to the referer)"
  attr :class, :any, default: nil

  def locale_switcher(assigns) do
    assigns =
      assign(assigns, :current, if(LedgerStarter.Locale.current() == "en", do: "EN", else: "PT"))

    ~H"""
    <.navbar_lang
      id="locale-switcher"
      label={gettext("Idioma")}
      current={@current}
      class={@class}
      locales={[
        %{code: "PT", label: "Português", href: switch_path("pt_BR", @to)},
        %{code: "EN", label: "English", href: switch_path("en", @to)}
      ]}
    />
    """
  end

  defp switch_path(locale, nil), do: "/idioma/#{locale}"
  defp switch_path(locale, to), do: "/idioma/#{locale}?" <> URI.encode_query(%{"to" => to})

  @doc "Translates an error message using gettext."
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(LedgerStarterWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LedgerStarterWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates every error of a changeset into the current locale (errors domain).
  The kit's inputs print the messages as they are, so forms are built from
  `translate_changeset(changeset)`.
  """
  def translate_changeset(%Ecto.Changeset{} = changeset) do
    errors =
      Enum.map(changeset.errors, fn {field, {msg, opts}} ->
        {field, {translate_error({msg, opts}), opts}}
      end)

    %{changeset | errors: errors}
  end

  @doc "`to_form/2` of a changeset with its errors translated."
  def translated_form(changeset, opts \\ []),
    do: changeset |> translate_changeset() |> to_form(opts)

  @doc "Translates the errors for a field from a keyword list of errors."
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
