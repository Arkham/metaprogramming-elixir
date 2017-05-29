Code.require_file("mime.ex", __DIR__)
Code.require_file("assertion.ex", __DIR__)

defmodule MimeTest do
  use Assertion

  defmodule Example do
    use Mime, "text/elixir": [".exs", ".ex"],
      "text/ruby": [".rb"]
  end

  test "it find extension for type" do
    assert MimeTest.Example.exts_for_type("text/html") == [".html"]
  end

  test "it find type for extension" do
    assert MimeTest.Example.type_for_ext(".html") == "text/html"
  end
end

MimeTest.run
