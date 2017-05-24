defmodule ByHand do
  defmacro evaluate_this() do
    expr = {:==, [context: Elixir, import: Kernel], [6,6]}
    quote do
      unquote(expr)
    end
  end
end
