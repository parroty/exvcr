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
      IO.puts json |> Jason.Formatter.pretty_print() |> String.replace(~r/\\n/, "\n")
      display_parsed_body(json)
      IO.puts "\e[32m**************************************\e[m"
    else
      IO.puts "Specified file [#{file}] was not found."
    end
  end

  defp display_parsed_body(json) do
    body = extract_body(json) || ""
    output = Jason.Formatter.pretty_print(body)
    IO.puts("\n\e[33m[Showing parsed JSON body]\e[m")
    IO.puts(output)
  end

  defp extract_body(json) do
    json
    |> Jason.decode!()
    |> List.first()
    |> Enum.into(%{})
    |> get_in(["responce", "body"])
  end
end
