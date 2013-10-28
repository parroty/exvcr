defmodule ExVCR.JSON do
  @moduledoc """
  Provides a feature to store/load cassettes in json format.
  """
  def save(file_name, responses) do
    json = responses |> Enum.reverse |> JSEX.encode!
    File.write!(file_name, JSEX.prettify!(json))
  end

  def get_file_path(fixture, options) do
    directory = case options[:custom] do
      true  -> ExVCR.Setting.get(:custom_library_dir)
      _     -> ExVCR.Setting.get(:cassette_library_dir)
    end
    "#{directory}/#{fixture}.json"
  end

  @doc """
  Loads the JSON files based on the fixture name and options.
  For options, this method just refers to the :custom attribute
  is set or not.
  """
  def load(fixture, options) do
    file_name = get_file_path(fixture, options)
    custom_option = options[:custom]

    case File.exists?(file_name) do
      true -> read_json_file(file_name)
      false when custom_option ->
        raise ExVCR.FileNotFoundError.new(message: "cassette file \"#{file_name}\" not found")
      false -> []
    end
  end

  @doc """
  Reads and parse the json file located at the specified file_name.
  """
  def read_json_file(file_name) do
    File.read!(file_name) |> JSEX.decode! |> Enum.map(&from_string/1)
  end

  @doc """
  Parse string fromat into original request / response format
  """
  def from_string([{"request", request}, {"response", response}]) do
    [ request:  ExVCR.Mock.IBrowse.string_to_request(request),
      response: ExVCR.Mock.IBrowse.string_to_response(response) ]
  end

  @doc """
  Parse request and response parameters into string format.
  """
  def to_string(request, response) do
    [ request:  ExVCR.Mock.IBrowse.request_to_string(request),
      response: ExVCR.Mock.IBrowse.response_to_string(response) ]
  end
end
