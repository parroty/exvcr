defmodule ExVCR.JSON do
  @moduledoc """
  Provides a feature to store/load cassettes in json format.
  """

  @doc """
  Save responses into the json file.
  """
  def save(file_name, recordings) do
    gunzipped_recordings = recordings
    |> Enum.map(&gunzip_recording/1)
    json = gunzipped_recordings |> Enum.reverse |> JSX.encode!
    unless File.exists?(path = Path.dirname(file_name)), do: File.mkdir_p(path)
    File.write!(file_name, JSX.prettify!(json))
  end

  defp gunzip_recording(recording) do
    %{request: request, response: response} = recording

    encoding_header = List.keyfind(response.headers, "Content-Encoding", 0)

    case encoding_header do
      {"Content-Encoding", "gzip"} ->
        decoded_body = :zlib.gunzip(response.body)
        decoded_response = %{ response | body: decoded_body }
        %{request: request, response: decoded_response}
      _ -> recording
    end
  end

  @doc """
  Loads the JSON files based on the fixture name and options.
  For options, this method just refers to the :custom attribute is set or not.
  """
  def load(file_name, custom_mode, adapter) do
    case { File.exists?(file_name), custom_mode } do
      { true, _ } -> read_json_file(file_name) |> Enum.map(&adapter.convert_from_string/1)
      { false, true } -> raise %ExVCR.FileNotFoundError{message: "cassette file \"#{file_name}\" not found"}
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
    |> Enum.map(&gzip_recording/1)
  end

  defp gzip_recording(recording) do
    %{"request" => request, "response" => response} = recording

    # add guards for empty things

    case response["headers"]["Content-Encoding"] do
      "gzip" ->
        encoded_body = :zlib.gzip(response["body"])
        encoded_response = %{ response | "body" => encoded_body }
        %{"request" => request, "response" => encoded_response}
      _ -> recording
    end
  end
end
