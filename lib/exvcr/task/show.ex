defmodule ExVCR.Task.Show do
  @moduledoc """
  Handles [mix vcr.show] task execution.
  """

  @doc """
  Displays the contents of cassettes.
  This method will called by the mix task.
  """
  def run(files, options) do
    Enum.each(files, &(print_file(&1, options)))
  end

  defp print_file(file, options) do
    IO.puts "\e[32mShowing #{file}\e[m"
    IO.puts "\e[32m**************************************\e[m"
    json = File.read!(file)
    IO.puts json |> JSEX.prettify! |> String.replace(~r/\\n/, "\n")
    if options[:json] do
      IO.puts "\n\e[32mShowing response body\e[m"
      case extract_body(json) |> JSEX.prettify do
        {:ok, body_json } -> IO.puts body_json
        {:error, _} -> IO.puts "Parsing response body failed."
      end
    end
    IO.puts "\e[32m**************************************\e[m"
  end

  defp extract_body(json) do
    response = JSEX.decode!(json) |> List.first |> HashDict.new |> HashDict.fetch!("response")
    response |> HashDict.new |> HashDict.fetch!("body")
  end
end
