defmodule AutoAlias do
  @moduledoc """
  Documentation for AutoAlias.
  """

  @doc """
  Hello world.

  ## Examples

      iex> AutoAlias.hello()
      :world

  """
  def read(name \\ "lib/sample.ex") do
    {:ok, ast} = Code.string_to_quoted(File.read!(name))

    {_, aliases} =
      Macro.prewalk(
        ast,
        %{substitutions: [], file_name: Path.expand(name)},
        &read_aliases/2
      )

    {_updated, acc} = Macro.prewalk(ast, aliases, &apply_aliases/2)
    acc
  end

  def format(name \\ "lib/sample.ex") do
    %{file_name: f, substitutions: s} = read(name)

    case s do
      [] ->
        IO.puts("No substitutions to perform")

      items ->
        subs = Enum.map(items, fn sub -> "-e#{sub}" end)
        # IO.inspect(subs, label: "sed commands")
        {result, 0} = System.cmd("sed", Enum.concat(subs, [f]))
        IO.inspect(name, label: "name")
        File.write!(name, result, [:write])
    end
  end

  def read_aliases({:defmodule, _, [{:__aliases__, meta, _}, _]} = node, acc) do
    acc =
      case Credo.Code.Module.aliases(node) do
        [] -> acc
        items -> Map.put(acc, meta[:line], Enum.map(items, &alias_path_to_list/1))
      end

    {node, acc}
  end

  def read_aliases(node, acc) do
    {node, acc}
  end

  @spec alias_path_to_list(binary) :: [atom()]
  def alias_path_to_list(alias_path) do
    String.split(alias_path, ".") |> Enum.map(&String.to_atom/1)
  end

  def apply_aliases({:defmodule, _, [{:__aliases__, meta, _}, _]} = module, acc) do
    case Map.get(acc, meta[:line]) do
      nil ->
        {module, acc}

      aliases ->
        {node, {acc, _}} = Macro.prewalk(module, {acc, aliases}, &apply_alias/2)
        {node, acc}
    end
  end

  def apply_aliases(node, acc) do
    {node, acc}
  end

  def apply_alias({:., dot_meta, [{:__aliases__, _, a}, _]} = node, {acc, alias_list}) do
    if a in alias_list do
      full_path = Enum.join(a, ".")
      new_path = List.last(a) |> Atom.to_string()

      acc =
        update_in(acc, [:substitutions], fn l ->
          ["#{dot_meta[:line]}s/#{full_path}/#{new_path}/" | l]
        end)

      {node, {acc, alias_list}}
    else
      {node, {acc, alias_list}}
    end
  end

  def apply_alias({:%, dot_meta, [{:__aliases__, _, a}, _]} = node, {acc, alias_list}) do
    if a in alias_list do
      full_path = Enum.join(a, ".")
      new_path = List.last(a) |> Atom.to_string()

      acc =
        update_in(acc, [:substitutions], fn l ->
          ["#{dot_meta[:line]}s/#{full_path}/#{new_path}/" | l]
        end)

      {node, {acc, alias_list}}
    else
      {node, {acc, alias_list}}
    end
  end

  def apply_alias(node, acc) do
    {node, acc}
  end
end
