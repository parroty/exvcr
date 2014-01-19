defmodule ExVCR.Adapter.IBrowse do
  @moduledoc """
  Provides callback information for ibrowse.
  """
  alias ExVCR.Adapter.IBrowse.Converter

  defmacro __using__(_opts) do
    # do nothing
  end

  @doc """
  Returns list of the mock target methods with function name and callback
  """
  def target_methods(recorder) do
    [ {:send_req, &ExVCR.Recorder.request(recorder, [&1,&2,&3])},
      {:send_req, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4])},
      {:send_req, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4,&5])},
      {:send_req, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4,&5,&6])} ]
  end

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :ibrowse
  end

  @doc """
  Generate key for searching response
  """
  def generate_keys_for_request(request) do
    url    = Enum.fetch!(request, 0)
    method = Enum.fetch!(request, 2)
    [url: url, method: method]
  end

  def hook_response_from_server(response) do
    response |> ExVCR.Filter.replace_sensitive_data
  end

  def hook_response_from_cache(response) do
    response
  end

  @doc """
  Parse string fromat into original request / response format
  """
  def from_string([{"request", request}, {"response", response}]) do
    [ request:  Converter.string_to_request(request),
      response: Converter.string_to_response(response) ]
  end

  @doc """
  Parse request and response parameters into string format.
  """
  def to_string(request, response) do
    [ request:  Converter.request_to_string(request),
      response: Converter.response_to_string(response) ]
  end
end
