defmodule ExVCR.Adapter.IBrowse do
  @moduledoc """
  Provides adapter methods to mock :ibrowse methods.
  """
  defmacro __using__(_opts) do
    # do nothing
  end

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :ibrowse
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
  Generate key for searching response.
  """
  def generate_keys_for_request(request) do
    url    = Enum.fetch!(request, 0)
    method = Enum.fetch!(request, 2)
    [url: url, method: method]
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the HTTP server.
  """
  def hook_response_from_server(response) do
    filter_sensitive_data(response)
  end

  defp filter_sensitive_data({:ok, status_code, headers, body}) do
    replaced_body = body |> iolist_to_binary |> ExVCR.Filter.filter_sensitive_data
    {:ok, status_code, headers, replaced_body}
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the json file cache.
  """
  def hook_response_from_cache(response) do
    response
  end

  @doc """
  Parse string fromat into original request / response format
  """
  def from_string([{"request", request}, {"response", response}]) do
    [ request:  ExVCR.Adapter.IBrowse.Converter.string_to_request(request),
      response: ExVCR.Adapter.IBrowse.Converter.string_to_response(response) ]
  end

  @doc """
  Parse request and response parameters into string format.
  """
  def to_string(request, response) do
    [ request:  ExVCR.Adapter.IBrowse.Converter.request_to_string(request),
      response: ExVCR.Adapter.IBrowse.Converter.response_to_string(response) ]
  end
end
