defmodule ExVCR.Adapter.Hackney do
  @moduledoc """
  Provides adapter methods to mock :hackney methods.
  """
  alias ExVCR.Adapter.Hackney.Store

  defmacro __using__(_opts) do
    quote do
      Store.start
    end
  end

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :hackney
  end

  @doc """
  Returns list of the mock target methods with function name and callback
  """
  def target_methods(recorder) do
    [ {:request, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4,&5])},
      {:body,    &handle_body_request(recorder, [&1])} ]
  end

  @doc """
  Generate key for searching response.
  """
  def generate_keys_for_request(request) do
    url    = Enum.fetch!(request, 1)
    method = Enum.fetch!(request, 0)
    [url: url, method: method]
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the HTTP server.
  """
  def hook_response_from_server(response = {:ok, _status_code, _headers, _client}) do
    response
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the json file cache.
  """
  def hook_response_from_cache(nil), do: nil
  def hook_response_from_cache(ExVCR.Response[body: body] = response) do
    client = make_ref
    Store.set(client, body)
    response.body(client)
  end

  defp handle_body_request(recorder, [client]) do
    if body = Store.get(client) do
      {:ok, body}
    else
      {:ok, body} = :meck.passthrough([client])
      body = ExVCR.Filter.filter_sensitive_data(body)

      client_key_in_string = inspect(client)
      ExVCR.Recorder.update(recorder,
        fn([request: _request, response: response]) ->
          response.body == client_key_in_string
        end,
        fn([request: request, response: response]) ->
          [request: request, response: response.body(body)]
        end
      )
      {:ok, body}
    end
  end

  @doc """
  Parse string fromat into original request / response format
  """
  def from_string([{"request", request}, {"response", response}]) do
    [ request:  ExVCR.Adapter.Hackney.Converter.string_to_request(request),
      response: ExVCR.Adapter.Hackney.Converter.string_to_response(response) ]
  end

  @doc """
  Parse request and response parameters into string format.
  """
  def to_string(request, response) do
    [ request:  ExVCR.Adapter.Hackney.Converter.request_to_string(request),
      response: ExVCR.Adapter.Hackney.Converter.response_to_string(response) ]
  end

end
