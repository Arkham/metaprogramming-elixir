Code.require_file("assertion.ex", __DIR__)
Code.require_file("translator.ex", __DIR__)

defmodule TranslatorTest do
  use Assertion

  defmodule Example do
    use Translator

    locale "en",
      foo: "bar",
      flash: [
        hello: "Hello %{first} %{last}!",
        bye: "Bye, %{name}!"
      ],
      users: [
        title: "Users"
      ]

    locale "fr",
      flash: [
        hello: "Salut %{first} %{last}!",
        bye: "Au revoir, %{name}!"
      ],
      users: [
        title: "Utilisateurs"
      ]
  end

  test "t/3 works for root level translations" do
    assert Example.t("en", "foo") == "bar"
  end

  test "t/3 walks through all levels" do
    assert Example.t("en", "users.title") == "Users"
  end

  test "t/3 allows multiple locales to be registered" do
    assert Example.t("en", "users.title") == "Users"
    assert Example.t("fr", "users.title") == "Utilisateurs"
  end

  test "t/3 interpolates bindings" do
    assert Example.t("en", "flash.hello", first: "Ju", last: "Liu") ==
      "Hello Ju Liu!"
  end

  test "t/3 raises errors when binding is not provided" do
    assert_raise KeyError, fn -> Example.t("en", "flash.hello", first: "Ju") end
  end

  test "t/3 returns {:error, :no_translation} when it's not available" do
    assert Example.t("fr", "foo") == {:error, :no_translation}
  end

  test "t/3 converts values to strings before interpolating" do
    assert Example.t("en", "flash.hello", first: 1, last: 2) == "Hello 1 2!"
  end

  test "compile/1 generates catch all t/3 functions" do
    assert Translator.compile([]) |> Macro.to_string == String.strip ~S"""
    (
      def(t(locale, path, bindings \\ []))
      []
      def(t(_locale, _path, _bindings)) do
        {:error, :no_translation}
      end
    )
    """
  end

  test "compile/1 generates t/3 functions for each local" do
    locales = [{"en", [foo: "bar", bar: "%{baz}"]}]
    assert Translator.compile(locales) |> Macro.to_string == String.strip ~S"""
    (
      def(t(locale, path, bindings \\ []))
      [[def(t("en", "foo", bindings)) do
        "" <> "bar"
      end, def(t("en", "bar", bindings)) do
        (("" <> "") <> to_string(Keyword.fetch!(bindings, :baz))) <> ""
      end]]
      def(t(_locale, _path, _bindings)) do
        {:error, :no_translation}
      end
    )
    """
  end
end

TranslatorTest.run
