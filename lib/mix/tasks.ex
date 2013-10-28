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
    { options, _, _ } = OptionParser.parse(args, [@switches])
    TaskRunner.show_cassettes(options[:dir])
  end
end

