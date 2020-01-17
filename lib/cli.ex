defmodule AutoAlias.CLI do
  @moduledoc """
  synopsis:
  Autoalias runs in just one mode right now.

  usage:
  auto_alias [options] file_path

  options:
  --write=false Overwrite the specified file_path if true. If false, print the modified file to stdout.

  """
  def main([]) do
    IO.puts(@moduledoc)
  end

  def main(args) do
    {opts, [path], _errors} =
      OptionParser.parse(args, aliases: [w: :write], strict: [write: :boolean])

    write = Keyword.get(opts, :write)
    AutoAlias.format(path, write)
  end
end
