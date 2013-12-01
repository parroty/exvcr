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
    {options, _, _} = OptionParser.parse(args, aliases: ExVCR.Task.Util.base_aliases)
    ExVCR.Task.Util.parse_basic_options(options) |> ExVCR.Task.Runner.show_vcr_cassettes
  end

  defmodule Delete do
    use Mix.Task

    @doc "Entry point for [mix vcr.delete] task"
    def run(args) do
      {options, files, _} =
        OptionParser.parse(args,
                           switches: [i: :boolean, a: :boolean],
                           aliases: [d: :dir, i: :interactive, a: :all])

      pattern = cond do
        options[:all]          -> %r/.*/
        Enum.count(files) == 1 -> Enum.first(files)
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
      {options, files, _} = OptionParser.parse(args, aliases: ExVCR.Task.Util.base_aliases)
      dirs = ExVCR.Task.Util.parse_basic_options(options)
      ExVCR.RecordChecker.start(ExVCR.Checker.new(dirs: dirs))

      Mix.env(:test)
      Code.load_file(Path.join([Path.dirname(__FILE__), "mix_file.exs"]))
      Mix.Task.run("test", files ++ ["--cover"])
    end
  end
end
