defmodule Mix.Tasks.Vcr do
  use Mix.Task
  alias ExVCR.TaskRunner
  @shortdoc "Operate exvcr cassettes"

  @moduledoc """
  Provides mix tasks for operating cassettes.

  ## Command line options

  * `--dir` - specifies the vcr cassette directory
  """

  @switches [:dir]
  def run(args) do
    { options, _, _ } = OptionParser.parse(args, switches: @switches)
    dir = options[:dir] || ExVCR.Setting.get_default_path
    TaskRunner.show_cassettes(dir)
  end

  defmodule Delete do
    use Mix.Task

    def run(args) do
      { options, files, _ } = OptionParser.parse(args, switches: @switches)
      dir = options[:dir] || ExVCR.Setting.get_default_path
      if Enum.count(files) == 1 do
        TaskRunner.delete_cassettes(dir, Enum.first(files))
      else
        IO.puts "invalid parameter is specified for - mix vcr.delete [pattern]"
      end
    end
  end
end

