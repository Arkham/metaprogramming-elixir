defmodule Assertion do
  defmodule AssertionError do
    defexception message: "an assertion error has occurred"
  end

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run, do: Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
  defmacro assert(value) do
    quote bind_quoted: [value: value] do
      Assertion.Test.assert(value)
    end
  end

  defmacro assert_received(message) do
    quote bind_quoted: [message: message] do
      Assertion.Test.assert_received(message)
    end
  end

  defmacro assert_raise(error_type, fun) do
    quote bind_quoted: [error_type: error_type, fun: fun] do
      Assertion.Test.assert_raise(error_type, fun)
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    Enum.each tests, fn {test_func, description} ->
      case apply(module, test_func, []) do
        :ok             -> IO.write "."
        {:fail, reason} -> IO.puts """

          =================================================
          FAILURE: #{description}
          =================================================
          #{reason}
          """
      end
    end
  end

  def assert(true), do: :ok
  def assert(value) do
    {:fail, """
      Expected: true
      but returned: #{inspect value}
      """
    }
  end
  def assert(:==, lhs, rhs) when lhs == rhs, do: :ok
  def assert(:==, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be equal to: #{rhs}
      """
    }
  end
  def assert(:<, lhs, rhs) when lhs < rhs, do: :ok
  def assert(:<, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be less than: #{rhs}
      """
    }
  end
  def assert(:<=, lhs, rhs) when lhs <= rhs, do: :ok
  def assert(:<=, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be less or equal than: #{rhs}
      """
    }
  end
  def assert(:>, lhs, rhs) when lhs > rhs, do: :ok
  def assert(:>, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be greater than: #{rhs}
      """
    }
  end
  def assert(:>=, lhs, rhs) when lhs >= rhs, do: :ok
  def assert(:>=, lhs, rhs) do
    {:fail, """
      Expected: #{lhs}
      to be greater or equal than: #{rhs}
      """
    }
  end

  def assert_received(message) do
    receive do
      ^message -> :ok
    after
      0 -> {:fail, """
        Expected: process #{inspect self()}
        to have received message #{inspect message}
      """
      }
    end
  end

  def assert_raise(error_type, fun) do
    try do
      fun.()

    rescue
      error ->
        name = error.__struct__

        cond do
          name == error_type ->
            :ok
          true ->
            reraise Assertion.AssertionError,
              [message: "Expected function to raise error #{inspect error_type}"]
        end
    else
      _ ->
        {:fail, """
          Expected function to raise error #{inspect error_type}
          """}
    end
  end
end
