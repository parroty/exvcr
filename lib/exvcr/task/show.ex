defmodule ExVCR.Task.Show do
  @moduledoc """
  Handles [mix vcr.show] task execution.
  """

  @doc """
  Displays the contents of cassettes.
  This method will called by the mix task.
  """
  def run(files) do
    Enum.each(files, &print_file/1)
  end

  defp print_file(file) do
    if File.exists?(file) do
      IO.puts "\e[32mShowing #{file}\e[m"
      IO.puts "\e[32m**************************************\e[m"
      json = File.read!(file)
      IO.puts json |> JSEX.prettify! |> String.replace(~r/\\n/, "\n")
      display_parsed_body(json)
      IO.puts "\e[32m**************************************\e[m"
    else
      IO.puts "Specified file [#{file}] was not found."
    end
  end

  defp display_parsed_body(json) do
    case extract_body(json) |> JSEX.prettify do
      {:ok, body_json } ->
        IO.puts "\n\e[33m[Showing parsed JSON body]\e[m"
        IO.puts body_json
      _ -> nil
    end
  end

  defp extract_body(json) do
    response = JSEX.decode!(json) |> List.first |> Enum.into(HashDict.new) |> fetch_value("response")
    Enum.into(response, HashDict.new) |> fetch_value("body")
  end

  defp fetch_value(dict, key) do
    case HashDict.fetch(dict, key) do
      {:ok, value} -> value
      _ -> []
    end
  end
end
