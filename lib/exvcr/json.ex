defmodule ExVCR.JSON do
  @moduledoc """
  Provides a feature to store/load cassettes in json format.
  """

  @doc """
  Save responses into the json file.
  """
  def save(file_name, recordings) do
    json = recordings
    |> Enum.map(&encode_binary_data/1)
    |> Enum.reverse()
    |> JSX.encode!()
    |> JSX.prettify!()

    unless File.exists?(path = Path.dirname(file_name)), do: File.mkdir_p!(path)
    File.write!(file_name, json)
  end

  defp encode_binary_data(recording = %{request: _, response: %ExVCR.Response{body: nil}}), do: recording

  defp encode_binary_data(recording = %{response: response}) do
    case String.valid?(response.body) do
      true -> recording
      false ->
        body = response.body
        |> :erlang.term_to_binary()
        |> Base.encode64()
        %{ recording | response: %{ body: body, binary: true } }
    end
  end

  @doc """
  Loads the JSON files based on the fixture name and options.
  For options, this method just refers to the :custom attribute is set or not.
  """
  def load(file_name, custom_mode, adapter) do
    case { File.exists?(file_name), custom_mode } do
      { true, _ } -> read_json_file(file_name) |> Enum.map(&adapter.convert_from_string/1)
      { false, true } -> raise ExVCR.FileNotFoundError, message: "cassette file \"#{file_name}\" not found"
      { false, _ } -> []
    end
  end

  @doc """
  Reads and parse the json file located at the specified file_name.
  """
  def read_json_file(file_name) do
    file = File.read!(file_name)
    recordings = JSX.decode!(file)

    recordings
    |> Enum.map(&load_binary_data/1)
  end

  defp load_binary_data(%{"body" => body, "binary" => true} = recording) do
    body
    |> Base.decode64!()
    |> :erlang.binary_to_term()
    %{ recording | "body" => body }
  end

  defp load_binary_data(recording), do: recording
end
