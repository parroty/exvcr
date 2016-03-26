defmodule ExVCR.Adapter.Hackney do
  @moduledoc """
  Provides adapter methods to mock :hackney methods.
  """

  use ExVCR.Adapter
  alias ExVCR.Adapter.Hackney.Store

  defmacro __using__(_opts) do
    quote do
      Store.start
    end
  end

  defdelegate convert_from_string(string), to: ExVCR.Adapter.Hackney.Converter
  defdelegate convert_to_string(request, response), to: ExVCR.Adapter.Hackney.Converter
  defdelegate parse_request_body(request_body), to: ExVCR.Adapter.Hackney.Converter

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :hackney
  end

  @doc """
  Returns list of the mock target methods with function name and callback.
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
    request_body = Enum.fetch(request, 3) |> parse_request_body

    [url: url, method: method, request_body: request_body]
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the HTTP server.
  """
  def hook_response_from_server(response) do
    apply_filters(response)
  end

  defp apply_filters({:ok, status_code, headers, reference}) do
    filtered_headers = ExVCR.Filter.remove_blacklisted_headers(headers)
    {:ok, status_code, filtered_headers, reference}
  end

  defp apply_filters({:error, reason}) do
    {:error, reason}
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the json file cache.
  """
  def hook_response_from_cache(nil), do: nil
  def hook_response_from_cache(%ExVCR.Response{type: "error"} = response), do: response
  def hook_response_from_cache(%ExVCR.Response{body: body} = response) do
    client          = make_ref
    client_key_atom = client |> inspect |> String.to_atom
    Store.set(client_key_atom, body)
    %{response | body: client}
  end

  defp handle_body_request(recorder, [client]) do
    client_key_atom = client |> inspect |> String.to_atom
    if body = Store.get(client_key_atom) do
      Store.delete(client_key_atom)
      {:ok, body}
    else
      case :meck.passthrough([client]) do
        {:ok, body} ->
          body = ExVCR.Filter.filter_sensitive_data(body)

          client_key_string = inspect(client)
          ExVCR.Recorder.update(recorder,
            fn(%{request: _request, response: response}) ->
              response.body == client_key_string
            end,
            fn(%{request: request, response: response}) ->
              %{request: request, response: %{response | body: body}}
            end
          )
          {:ok, body}
        {ret, body} ->
          {ret, body}
      end
    end
  end

  @doc """
  Default definitions for stub.
  """
  def default_stub_params(:headers), do: %{"Content-Type" => "text/html"}
  def default_stub_params(:status_code), do: 200
end
