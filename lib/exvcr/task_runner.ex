defmodule ExVCR.TaskRunner do
  @moduledoc """
  Provides task processing logics, which will be invoked by custom mix tasks.
  """
  import ExPrintf
  @print_format "  %-40s %-30s\n"
  @json_file_pattern %r/\.json$/

  @doc """
  Use specified path to show the list of vcr cassettes.
  """
  def show_vcr_cassettes(path) do
    read_cassettes(path) |> print_cassettes(path)
  end

  @doc """
  Use specified path to delete cassettes.
  """
  def delete_cassettes(path, file_patterns, is_interactive // false) do
    path |> find_json_files
         |> Enum.filter(&(&1 =~ file_patterns))
         |> Enum.each(&(delete_and_print_name(path, &1, is_interactive)))
  end

  @doc """
  Check and show which cassettes are used by the test execution.
  """
  def check_cassettes(record) do
    count_hash = create_count_hash(record.files)
    Enum.each(record.dirs, fn(dir) ->
      cassettes = read_cassettes(dir)
      print_check_cassettes(cassettes, dir, count_hash)
      IO.puts ""
    end)
  end

  defp create_count_hash(files) do
    do_create_count_hash(files, HashDict.new)
  end

  defp do_create_count_hash([], acc), do: acc
  defp do_create_count_hash([head|tail], acc) do
    file = Path.basename(head)
    count = HashDict.get(acc, file, 0)
    hash  = HashDict.put(acc, file, count + 1)
    do_create_count_hash(tail, hash)
  end

  defp print_check_cassettes(items, path, counts_hash) do
    IO.puts "Showing hit counts of cassettes in [#{path}]"
    printf(@print_format, ["[File Name]", "[Hit Counts]"])
    Enum.each(items, fn({name, _date}) ->
      printf("  %-40s %-30d\n", [name, HashDict.get(counts_hash, name, 0)])
    end)
  end

  defp delete_and_print_name(path, file_name, true) do
    line = IO.gets("delete #{file_name}? ")
    if String.upcase(line) == "Y\n" do
      delete_and_print_name(path, file_name, false)
    end
  end

  defp delete_and_print_name(path, file_name, false) do
    case Path.expand(file_name, path) |> File.rm do
      :ok    -> IO.puts "Deleted #{file_name}."
      :error -> IO.puts "Failed to delete #{file_name}"
    end
  end

  defp read_cassettes(path) do
    file_names = find_json_files(path)
    date_times = Enum.map(file_names, &(extract_last_modified_time(path, &1)))
    Enum.zip(file_names, date_times)
  end

  defp find_json_files(path) do
    File.ls!(path) |> Enum.filter(&(&1 =~ @json_file_pattern))
                   |> Enum.sort
  end

  defp extract_last_modified_time(path, file_name) do
    {{year, month, day}, {hour, min, sec}} = File.stat!(Path.join(path, file_name)).mtime
    sprintf("%04d/%02d/%02d %02d:%02d:%02d", [year, month, day, hour, min, sec])
  end

  # Temporaily comments out (will be used to extract other json contents later)
  # defp extract_response_time(file_names) do
  #   file_names |> Enum.map(&(read_json(path, &1)))
  #              |> Enum.map(&(extract_dates(&1)))
  # end

  # defp read_json(path, file_name) do
  #   Path.expand(file_name, path) |> ExVCR.JSON.read_json_file
  # end

  # defp extract_dates(json) do
  #   headers = Enum.first(json)[:response].headers
  #   case Enum.find(headers, fn(x) -> elem(x, 0) == "Date" end) do
  #     nil  -> ""
  #     item -> elem(item, 1)
  #   end
  # end

  defp print_cassettes(items, path) do
    IO.puts "Showing list of cassettes in [#{path}]"
    printf(@print_format, ["[File Name]", "[Last Update]"])
    Enum.each(items, fn({name, date}) -> printf(@print_format, [name, date]) end)
  end
end
