defmodule ExVCR.JSON do
  @moduledoc """
  Provides a feature to store/load cassettes in json format.
  """
  def save(file_name, recorder) do
    json = ExVCR.Recorder.get_responses(recorder)
            |> Enum.reverse
            |> JSEX.encode!

    File.write!(file_name, JSEX.prettify!(json))
  end

  def get_file_path(fixture, options) do
    directory = case options[:custom] do
      true  -> ExVCR.Setting.get(:custom_library_dir)
      _     -> ExVCR.Setting.get(:cassette_library_dir)
    end

    "#{directory}/#{fixture}.json"
  end

  def load(fixture, options) do
    file_name = get_file_path(fixture, options)
    case File.exists?(file_name) do
      true -> File.read!(file_name) |> JSEX.decode! |> Enum.map(&json_mapper/1)
      _    -> []
    end
  end

  defp json_mapper([{"request", _request}, {"response", response}]) do
    hash = HashDict.new(response)

    { HashDict.fetch!(hash, "status_code") |> integer_to_list,
      HashDict.fetch!(hash, "headers"),
      HashDict.fetch!(hash, "body") }
  end

  @doc """
  Parse request and response parameters into json file.
  """
  def parse(request, response) do
    [ request:  ExVCR.Mock.IBrowse.parse_request(request),
      response: ExVCR.Mock.IBrowse.parse_response(response) ]
  end
end
