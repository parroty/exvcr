defmodule ExVCR.Task.Util do
  @moduledoc """
  Provides task related utilities
  """

  def parse_basic_options(options) do
    [ options[:dir] || ExVCR.Setting.get_default_vcr_path,
      options[:custom] || ExVCR.Setting.get_default_custom_path ]
  end

  def print_help_message do
    IO.puts """
Usage: mix vcr [options]
  Used to display the list of cassettes

  -h (--help)         Show helps for vcr mix tasks
  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory

Usage: mix vcr.delete [options] [cassete-file-names]
  Used to delete cassettes

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory
  -i (--interactive)  Request confirmation before attempting to delete
  -a (--all)          Delete all the files by ignoring specified [filenames]

Usage: mix vcr.check [options] [test-files]
  Used to check cassette use on test execution

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory
"""
  end
end
