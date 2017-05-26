defmodule Mime do
  @external_resource mimes_path = Path.join(__DIR__, "mimes.txt")

  for line <- File.stream!(mimes_path, [], :line) do
    [type, rest] =
      line
      |> String.split("\t")
      |> Enum.map(&String.strip/1)
    extensions = String.split(rest, ~r/,\s?/)

    def exts_for_type(unquote(type)), do: unquote(extensions)
    def type_for_ext(ext) when ext in unquote(extensions), do: unquote(type)
  end

  def exts_for_type(_type), do: []
  def type_for_ext(_ext), do: nil
  def valid_type?(type), do: exts_for_type(type) |> Enum.any?

  defmacro __using__(additional) do
    additional_ast = for {type, extensions} <- additional do
      type = to_string(type)
      quote do
        def exts_for_type(unquote(type)), do: unquote(extensions)
        def type_for_ext(ext) when ext in unquote(extensions), do: unquote(type)
      end
    end

    quote do
      unquote(additional_ast)
      defdelegate exts_for_type(type), to: Mime
      defdelegate type_for_ext(ext), to: Mime
    end
  end
end
