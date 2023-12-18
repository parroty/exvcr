defmodule ExVCR.Task.Util do
  @moduledoc """
  Provides task related utilities.
  """

  @doc """
  Parse basic option parameters, which are commonly used by multiple mix tasks.
  """
  def parse_basic_options(options) do
    [ options[:dir]    || ExVCR.Setting.get(:cassette_library_dir),
      options[:custom] || ExVCR.Setting.get(:custom_library_dir) ]
  end

  @doc """
  Method for printing help message.
  """
  def print_help_message do
    IO.puts """
Usage: mix vcr [options]
  Used to display the list of cassettes

  -h (--help)         Show helps for vcr mix tasks
  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory

Usage: mix vcr.delete [options] [cassette-file-names]
  Used to delete cassettes

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory
  -i (--interactive)  Request confirmation before attempting to delete
  -a (--all)          Delete all the files by ignoring specified [filenames]

Usage: mix vcr.check [options] [test-files]
  Used to check cassette use on test execution

  -d (--dir)          Specify vcr cassettes directory
  -c (--custom)       Specify custom cassettes directory

Usage: mix vcr.show [cassette-file-names]
  Used to show cassette contents

"""
  end
end
