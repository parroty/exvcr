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

  def get_file_name(fixture, options) do
    dir = case options[:custom] do
      true  -> ExVCR.Setting.get(:custom_library_dir)
      _     -> ExVCR.Setting.get(:cassette_library_dir)
    end

    "#{dir}/#{fixture}.json"
  end

  def load(file_name) do
    json = File.read!(file_name) |> JSEX.decode!

    Enum.map(json, fn(x) ->
      [{"request", _request}, {"response", response}] = x

      h = HashDict.new(response)
      {
        HashDict.fetch!(h, "status_code") |> integer_to_list,
        HashDict.fetch!(h, "headers"),
        HashDict.fetch!(h, "body")
      }
    end)
  end

  @doc """
  Parse request and response parameters into json file.
  """
  def parse(request, response) do
    [
      request:  ExVCR.Mock.IBrowse.parse_request(request),
      response: ExVCR.Mock.IBrowse.parse_response(response)
    ]
  end
end
