defmodule Mix.Tasks.Vcr do
  use Mix.Task

  @shortdoc "Operate exvcr cassettes"

  @moduledoc """
  Provides mix tasks for operating cassettes.

  ## Command line options
  * `--dir` - specifies the vcr cassette directory.
  * `--custom` - specifies the custom cassette directory.
  * `-i (--interactive) - ask for confirmation for each file operation.
  """

  @doc "Entry point for [mix vcr] task"
  def run(args) do
    {options, _, _} = OptionParser.parse(args, aliases: [d: :dir, c: :custom, h: :help])
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
          options[:dir] || ExVCR.Setting.get_default_vcr_path,
          pattern, options[:interactive] || false)
      else
        IO.puts "invalid parameter is specified for - mix vcr.delete [pattern]"
      end
    end
  end

  defmodule Check do
    use Mix.Task

    @doc "Entry point for [mix vcr.check] task"
    def run(args) do
      {options, files, _} = OptionParser.parse(args, aliases: [d: :dir, c: :custom])
      dirs = ExVCR.Task.Util.parse_basic_options(options)
      ExVCR.Checker.start(ExVCR.Checker.Results.new(dirs: dirs))

      Mix.env(:test)
      Code.load_file(Path.join([Path.dirname(__ENV__.file), "mix_file.exs"]))
      Mix.Task.run("test", files ++ ["--cover"])
    end
  end
end
