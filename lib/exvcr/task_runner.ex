defmodule ExVCR.TaskRunner do
  @moduledoc """
  Provides task processing logics, which will be invoked by custom mix tasks.
  """
  import ExPrintf
  @print_format "  %-40s %-30s\n"
  @json_file_pattern %r/\.json$/

  @doc """
  Use default cassette_library_dir to execute default task
  """
  def show_cassettes(nil) do
    show_cassettes(ExVCR.Setting.get_default_path)
  end

  @doc """
  Use specified path to execute default task
  """
  def show_cassettes(path) do
    read_cassettes(path) |> print_cassettes
  end

  defp read_cassettes(path) do
    file_names = File.ls!(path) |> Enum.filter(&(&1 =~ @json_file_pattern))
    recorded_times = file_names
                       |> Enum.map(&(read_json(path, &1)))
                       |> Enum.map(&(extract_dates(&1)))
    Enum.zip(file_names, recorded_times)
  end

  defp read_json(path, file_name) do
    Path.expand(file_name, path) |> ExVCR.JSON.read_json_file
  end

  defp extract_dates(json) do
    headers = Enum.first(json)[:response].headers
    case Enum.find(headers, fn(x) -> elem(x, 0) == "Date" end) do
      nil  -> nil
      item -> elem(item, 1)
    end
  end

  defp print_cassettes(items) do
    IO.puts "Showing list of cassettes"
    printf(@print_format, ["[File Name]", "[Last Update]"])
    Enum.each(items, fn({name, date}) -> printf(@print_format, [name, date]) end)
  end
end
