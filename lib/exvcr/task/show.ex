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
      IO.puts json |> ExVCR.JsonAdapter.prettify! |> String.replace(~r/\\n/, "\n")
      display_parsed_body(json)
      IO.puts "\e[32m**************************************\e[m"
    else
      IO.puts "Specified file [#{file}] was not found."
    end
  end

  defp display_parsed_body(json) do
    case extract_body(json) |> JSX.prettify do
      {:ok, body_json } ->
        IO.puts "\n\e[33m[Showing parsed JSON body]\e[m"
        IO.puts body_json
      _ -> nil
    end
  end

  defp extract_body(json) do
    json
    |> JSX.decode!()
    |> List.first()
    |> Enum.into(%{})
    |> get_in(["responce", "body"])
  end
end
