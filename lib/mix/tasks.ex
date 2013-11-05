defmodule Mix.Tasks.Vcr do
  use Mix.Task
  alias ExVCR.TaskRunner
  @shortdoc "Operate exvcr cassettes"

  @moduledoc """
  Provides mix tasks for operating cassettes.

  ## Command line options
  * `--dir` - specifies the vcr cassette directory.
  * `-i (--interactive) - ask for confirmation for each file operation.
  """

  def run(args) do
    {options, _, _} = OptionParser.parse(args, switches: [:dir])
    TaskRunner.show_vcr_cassettes(options[:dir] || ExVCR.Setting.get_default_vcr_path)
  end

  defmodule Custom do
    use Mix.Task

    def run(args) do
      {options, _, _} = OptionParser.parse(args, switches: [:dir])
      TaskRunner.show_custom_cassettes(options[:dir] || ExVCR.Setting.get_default_custom_path)
    end
  end

  defmodule Delete do
    use Mix.Task

    def run(args) do
      {options, files, _} =
        OptionParser.parse(args, switches: [i: :boolean], aliases: [d: :dir, i: :interactive])

      if Enum.count(files) == 1 do
        TaskRunner.delete_cassettes(
          options[:dir] || ExVCR.Setting.get_default_vcr_path,
          Enum.first(files), options[:interactive] || false)
      else
        IO.puts "invalid parameter is specified for - mix vcr.delete [pattern]"
      end
    end
  end
end

