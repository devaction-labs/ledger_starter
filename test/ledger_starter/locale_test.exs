defmodule LedgerStarter.LocaleTest do
  use ExUnit.Case, async: true

  alias LedgerStarter.Locale

  doctest LedgerStarter.Locale

  describe "normalize/1" do
    test "maps language tags to the supported codes" do
      assert Locale.normalize("pt_BR") == "pt_BR"
      assert Locale.normalize("pt-br") == "pt_BR"
      assert Locale.normalize("pt") == "pt_BR"
      assert Locale.normalize("en") == "en"
      assert Locale.normalize("en-US") == "en"
      assert Locale.normalize(" EN ") == "en"
    end

    test "unsupported or missing values are nil" do
      assert Locale.normalize("fr") == nil
      assert Locale.normalize("") == nil
      assert Locale.normalize(nil) == nil
    end
  end

  describe "from_accept_language/1" do
    test "picks the supported language with the highest q" do
      assert Locale.from_accept_language("fr;q=0.9, en;q=0.8, pt-BR;q=0.7") == "en"
      assert Locale.from_accept_language("en-US,en;q=0.9,pt;q=0.95") == "en"
      assert Locale.from_accept_language("pt-BR,pt;q=0.9,en;q=0.8") == "pt_BR"
    end

    test "ignores unsupported languages, wildcards and q=0" do
      assert Locale.from_accept_language("fr, de;q=0.8") == nil
      assert Locale.from_accept_language("*") == nil
      assert Locale.from_accept_language("en;q=0, pt;q=0.1") == "pt_BR"
      assert Locale.from_accept_language(nil) == nil
    end
  end

  test "with_locale/2 sets the Gettext locale only inside the function" do
    Locale.put("pt_BR")

    assert Locale.with_locale("en", fn -> Locale.current() end) == "en"
    assert Locale.current() == "pt_BR"
    assert Locale.with_locale("xx", fn -> Locale.current() end) == "pt_BR"
  end
end
