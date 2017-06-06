defmodule Html do
  @external_resource tags_path = Path.join([__DIR__, "tags.txt"])
  @tags (for line <- File.stream!(tags_path, [], :line) do
    line |> String.strip |> String.to_atom
  end)

  for t <- @tags do
    defmacro unquote(t)(attrs, do: inner) do
      t = unquote(t)
      quote do
        tag(unquote(t), unquote(attrs), do: unquote(inner))
      end
    end
  end

  defmacro markup(do: block) do
    quote do
      import Kernel, except: [div: 2]
      {:ok, var!(buffer, Html)} = start_buffer([])
      unquote(block)
      result = render(var!(buffer, Html))
      :ok = stop_buffer(var!(buffer, Html))
      result
    end
  end

  def start_buffer(state), do: Agent.start_link(fn -> state end)

  def stop_buffer(buff), do: Agent.stop(buff)

  def put_buffer(buff, content), do: Agent.update(buff, &[content | &1])

  def render(buff), do: Agent.get(buff, &(&1)) |> Enum.reverse |> Enum.join("")

  defmacro tag(name, attrs \\ []) do
    {inner, attrs} = Dict.pop(attrs, :do)
    quote do
      tag(unquote(name), unquote(attrs), do: unquote(inner))
    end
  end
  defmacro tag(name, attrs, do: inner) do
    quote do
      put_buffer var!(buffer, Html), open_tag(unquote_splicing([name, attrs]))
      unquote(inner)
      put_buffer var!(buffer, Html), "</#{unquote(name)}>"
    end
  end

  defmacro text(string) do
    quote do
      put_buffer(var!(buffer, Html), to_string(unquote(string)))
    end
  end

  def open_tag(name, []), do: "<#{name}>"
  def open_tag(name, attrs) do
    attr_html = for {key, val} <- attrs, into: "", do: ~s( #{key}="#{val}")
    "<#{name}#{attr_html}"
  end
end
