defmodule ExVCR.TaskRunner do
  @moduledoc """
  Provides task processing logics, which will be invoked by custom mix tasks.
  """
  import ExPrintf
  @print_format "  %-40s %-30s\n"

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
    load_json(path) |> print_jsons
  end

  defp load_json(path) do
    file_names   = File.ls!(path) |> Enum.filter(&(&1 =~ %r/\.json$/))
    json_records = Enum.map(file_names, &(do_load_json(path, &1)))
    dates        = Enum.map(json_records, fn(record) -> find_date(record) end)
    Enum.zip(file_names, dates)
  end

  defp do_load_json(path, file_name) do
    Path.expand(file_name, path) |> ExVCR.JSON.read_json_file
  end

  defp find_date(record) do
    headers = Enum.first(record)[:response].headers
    case Enum.find(headers, fn(x) -> elem(x, 0) == "Date" end) do
      nil  -> nil
      item -> elem(item, 1)
    end
  end

  defp print_jsons(items) do
    IO.puts "Showing list of cassettes"
    printf(@print_format, ["[File Name]", "[Last Update]"])
    Enum.each(items, fn({name, date}) -> printf(@print_format, [name, date]) end)
  end
end
