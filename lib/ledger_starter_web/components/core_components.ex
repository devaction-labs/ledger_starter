defmodule LedgerStarterWeb.CoreComponents do
  @moduledoc """
  Small app-level helpers. All visual components come from `LedgerUI`
  (`use LedgerUI` in `LedgerStarterWeb.html_helpers/0`); this module only keeps
  the Gettext error translation used by form fields.
  """

  @doc "Translates an error message using gettext."
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(LedgerStarterWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(LedgerStarterWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc "Translates the errors for a field from a keyword list of errors."
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
