defmodule LedgerStarter.GettextFilesTest do
  @moduledoc """
  The shipped translations are complete: every msgid of the POT files is in both
  `pt_BR` and `en`, with no empty msgstr, and the placeholders match the msgid.
  """
  use ExUnit.Case, async: true

  alias Expo.Message
  alias Expo.PO

  @root Path.expand("../../priv/gettext", __DIR__)
  @domains ~w(default errors)
  @locales ~w(pt_BR en)

  defp messages(path) do
    path |> PO.parse_file!() |> Map.fetch!(:messages)
  end

  defp key(%Message.Singular{msgctxt: ctxt, msgid: id}), do: {ctxt, IO.iodata_to_binary(id)}
  defp key(%Message.Plural{msgctxt: ctxt, msgid: id}), do: {ctxt, IO.iodata_to_binary(id)}

  defp strings(%Message.Singular{msgstr: s}), do: [IO.iodata_to_binary(s)]

  defp strings(%Message.Plural{msgstr: forms}),
    do: forms |> Enum.sort() |> Enum.map(fn {_i, s} -> IO.iodata_to_binary(s) end)

  defp placeholders(string),
    do:
      ~r/%\{(\w+)\}/ |> Regex.scan(string) |> Enum.map(&List.last/1) |> Enum.sort() |> Enum.uniq()

  for locale <- @locales, domain <- @domains do
    describe "#{locale}/#{domain}.po" do
      @describetag locale: locale, domain: domain

      test "has every message of the POT, translated", %{locale: locale, domain: domain} do
        pot = messages(Path.join(@root, "#{domain}.pot"))
        po = messages(Path.join([@root, locale, "LC_MESSAGES", "#{domain}.po"]))
        translations = Map.new(po, &{key(&1), &1})

        assert pot != []

        for message <- pot do
          translated = Map.get(translations, key(message))
          {_, id} = key(message)

          assert translated, "#{locale}/#{domain}.po is missing #{inspect(id)}"

          for string <- strings(translated) do
            assert String.trim(string) != "",
                   "#{locale}/#{domain}.po: empty msgstr for #{inspect(id)}"

            assert placeholders(string) == placeholders(id),
                   "#{locale}/#{domain}.po: placeholders differ for #{inspect(id)}"
          end
        end
      end

      test "has no message that is not in the POT", %{locale: locale, domain: domain} do
        pot_keys = Enum.map(messages(Path.join(@root, "#{domain}.pot")), &key/1)
        po = messages(Path.join([@root, locale, "LC_MESSAGES", "#{domain}.po"]))

        assert Enum.reject(po, &(key(&1) in pot_keys)) == []
      end
    end
  end

  test "English translations are real translations of the Portuguese source" do
    pt =
      Map.new(messages(Path.join([@root, "pt_BR", "LC_MESSAGES", "default.po"])), &{key(&1), &1})

    en = Map.new(messages(Path.join([@root, "en", "LC_MESSAGES", "default.po"])), &{key(&1), &1})

    same =
      for {k, m} <- en, strings(m) == strings(Map.fetch!(pt, k)), do: elem(k, 1)

    # a few strings are identical in both languages (brand names, "Admin", "Status"...)
    assert length(same) < 30, "too many untranslated English strings: #{inspect(same)}"
  end

  test "the translated UI works end to end" do
    Gettext.put_locale(LedgerStarterWeb.Gettext, "en")
    assert Gettext.gettext(LedgerStarterWeb.Gettext, "Entrar") == "Sign in"

    assert Gettext.ngettext(LedgerStarterWeb.Gettext, "%{count} pessoa", "%{count} pessoas", 2) ==
             "2 people"

    Gettext.put_locale(LedgerStarterWeb.Gettext, "pt_BR")
    assert Gettext.gettext(LedgerStarterWeb.Gettext, "Entrar") == "Entrar"

    assert Gettext.ngettext(LedgerStarterWeb.Gettext, "%{count} pessoa", "%{count} pessoas", 0) ==
             "0 pessoas"
  end
end
