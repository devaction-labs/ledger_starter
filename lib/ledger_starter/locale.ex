defmodule LedgerStarter.Locale do
  @moduledoc """
  The languages of the app (`pt_BR`, the default, and `en`) and the helpers to
  normalize, negotiate and apply them.

  Resolution order for a request (see `LedgerStarterWeb.Plugs.Locale`):
  user preference > `?locale=` > `locale` cookie > `Accept-Language` > `pt_BR`.
  """

  @locales ["pt_BR", "en"]
  @default "pt_BR"
  @backend LedgerStarterWeb.Gettext

  def locales, do: @locales
  def default, do: @default

  @doc "True when `locale` is exactly one of the supported codes."
  def supported?(locale), do: locale in @locales

  @doc """
  Normalizes a language tag to a supported code, or `nil`.

      iex> LedgerStarter.Locale.normalize("pt-br")
      "pt_BR"
      iex> LedgerStarter.Locale.normalize("en-US")
      "en"
      iex> LedgerStarter.Locale.normalize("fr")
      nil
  """
  def normalize(locale) when is_binary(locale) do
    case locale |> String.trim() |> String.downcase() |> String.replace("_", "-") do
      "pt" <> _ -> "pt_BR"
      "en" <> _ -> "en"
      _ -> nil
    end
  end

  def normalize(_), do: nil

  @doc """
  The first supported language of an `Accept-Language` header value (by q-value), or `nil`.
  """
  def from_accept_language(header) when is_binary(header) do
    header
    |> String.split(",", trim: true)
    |> Enum.map(&parse_range/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(fn {_tag, q} -> q end, :desc)
    |> Enum.find_value(fn {tag, _q} -> normalize(tag) end)
  end

  def from_accept_language(_), do: nil

  defp parse_range(range) do
    [tag | params] = range |> String.trim() |> String.split(";")
    tag = String.trim(tag)

    q =
      Enum.find_value(params, 1.0, fn p ->
        case p |> String.trim() |> String.split("=") do
          ["q", v] -> parse_q(v)
          _ -> nil
        end
      end)

    if tag in ["", "*"] or q <= 0, do: nil, else: {tag, q}
  end

  defp parse_q(v) do
    case Float.parse(v) do
      {q, _} -> q
      :error -> 0.0
    end
  end

  @doc "The Gettext locale of the current process."
  def current, do: Gettext.get_locale(@backend)

  @doc "Sets the Gettext locale of the current process (unsupported values fall back to the default)."
  def put(locale) do
    locale = if supported?(locale), do: locale, else: @default
    Gettext.put_locale(@backend, locale)
    locale
  end

  @doc "Runs `fun` with the Gettext locale set to `locale` (e-mails in the recipient's language)."
  def with_locale(locale, fun) do
    locale = if supported?(locale), do: locale, else: @default
    Gettext.with_locale(@backend, locale, fun)
  end

  @doc "Value for `<html lang>`: `pt-BR` or `en`."
  def html_lang("pt_BR"), do: "pt-BR"
  def html_lang(locale), do: locale

  @doc "The Ledger UI locale for a code (the kit takes `pt_BR` and `en`)."
  def ui(locale) when locale in @locales, do: locale
  def ui(_), do: @default
end
