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
      IO.puts("\e[32mShowing #{file}\e[m")
      IO.puts("\e[32m**************************************\e[m")
      json = File.read!(file)

      json
      |> Jason.decode!()
      |> Jason.encode!(pretty: true)
      |> String.replace(~r/\\n/, "\n")
      |> IO.inspect()

      display_parsed_body(json)
      IO.puts("\e[32m**************************************\e[m")
    else
      IO.puts("Specified file [#{file}] was not found.")
    end
  end

  defp display_parsed_body(json) do
    case json |> extract_body() |> Jason.decode!() |> Jason.encode!(pretty: true) do
      {:ok, body_json} ->
        IO.puts("\n\e[33m[Showing parsed JSON body]\e[m")
        IO.puts(body_json)

      _ ->
        nil
    end
  end

  defp extract_body(json) do
    json
    |> Jason.decode!()
    |> List.first()
    |> Map.new()
    |> get_in(["response", "body"])
  end
end
