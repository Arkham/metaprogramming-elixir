defmodule Setter do
  defmacro bind_name(string) do
    quote do
      # name = unquote(string)
      var!(name) = unquote(string)
    end
  end
end
