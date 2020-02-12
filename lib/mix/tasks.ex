defmodule Mix.Tasks.Vcr do
  use Mix.Task

  @shortdoc "Operate exvcr cassettes"

  @moduledoc """
  Provides mix tasks for operating cassettes.

  ## Command line options
  * `--dir` - specifies the vcr cassette directory.
  * `--custom` - specifies the custom cassette directory.
  * `-i (--interactive)` - ask for confirmation for each file operation.
  """

  @doc "Entry point for [mix vcr] task"
  def run(args) do
    {options, _, _} = OptionParser.parse(args, aliases: [d: :dir, c: :custom, h: :help], switches: [dir: :string, custom: :string, help: :boolean])
    if options[:help] do
      ExVCR.Task.Util.print_help_message
    else
      ExVCR.Task.Util.parse_basic_options(options) |> ExVCR.Task.Runner.show_vcr_cassettes
    end
  end

  defmodule Delete do
    use Mix.Task

    @doc "Entry point for [mix vcr.delete] task"
    def run(args) do
      {options, files, _} =
        OptionParser.parse(args,
                           switches: [interactive: :boolean, all: :boolean],
                           aliases: [d: :dir, i: :interactive, a: :all])

      pattern = cond do
        options[:all]          -> ~r/.*/
        Enum.count(files) == 1 -> Enum.at(files, 0)
        true                   -> nil
      end

      if pattern do
        ExVCR.Task.Runner.delete_cassettes(
          options[:dir] || ExVCR.Setting.get(:cassette_library_dir),
          pattern, options[:interactive] || false)
      else
        IO.puts "[Invalid Param] Specify substring of cassette file-name to be deleted - `mix vcr.delete [pattern]`, or use `mix vcr.delete --all` for deleting all cassettes."
      end
    end
  end

  defmodule Check do
    @moduledoc """
    Check how the recorded cassettes are used while executing [mix test] task.
    """
    use Mix.Task

    @doc "Entry point for [mix vcr.check] task."
    def run(args) do
      {options, _files, _} = OptionParser.parse(args, aliases: [d: :dir, c: :custom])
      dirs = ExVCR.Task.Util.parse_basic_options(options)
      ExVCR.Checker.start(%ExVCR.Checker.Results{dirs: dirs})

      Mix.env(:test)
      Mix.Task.run("test")
      System.at_exit(fn(_) ->
        ExVCR.Task.Runner.check_cassettes(ExVCR.Checker.get)
      end)
    end
  end

  defmodule Show do
    @moduledoc """
    Show the contents of the cassettes.
    """
    use Mix.Task

    @doc "Entry point for [mix vcr.show] task."
    def run(args) do
      {_options, files, _} = OptionParser.parse(args, aliases: [])
      ExVCR.Task.Show.run(files)
    end
  end
end
