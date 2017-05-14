defmodule Inspector do
  defmacro get_ast(expression) do
    quote do
      var!(expression)
    end
  end
end
