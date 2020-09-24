defmodule ExVCR.Adapter.Httpc do
  @moduledoc """
  Provides adapter methods to mock :httpc methods.
  """

  use ExVCR.Adapter
  alias ExVCR.Util

  defmacro __using__(_opts) do
    # do nothing
  end

  defdelegate convert_from_string(string), to: ExVCR.Adapter.Httpc.Converter
  defdelegate convert_to_string(request, response), to: ExVCR.Adapter.Httpc.Converter
  defdelegate parse_request_body(request_body), to: ExVCR.Adapter.Httpc.Converter

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :httpc
  end

  @doc """
  Returns list of the mock target methods with function name and callback.
    TODO:
      {:request, &ExVCR.Recorder.request(recorder, [&1,&2])}
      {:request, &ExVCR.Recorder.request(recorder, [&1,&2,&3,&4,&5])}
  """
  def target_methods() do
    [ {:request, &ExVCR.Recorder.request([&1])},
      {:request, &ExVCR.Recorder.request([&1,&2,&3,&4])} ]
  end

  @doc """
  Generate key for searching response.
  """
  def generate_keys_for_request(request) do
    case request do
      [method, {url, headers} | _] ->
        [url: url, method: method, request_body: nil, headers: Util.stringify_keys(headers)]
      [method, {url, headers, _, body} | _] ->
        [url: url, method: method, request_body: body, headers: Util.stringify_keys(headers)]
      [url | _] ->
        [url: url, method: :get, request_body: nil, headers: []]
    end
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the HTTP server.
  """
  def hook_response_from_server(response) do
    apply_filters(response)
  end

  defp apply_filters({:ok, {status_code, headers, body}}) do
    replaced_body = to_string(body) |> ExVCR.Filter.filter_sensitive_data
    filtered_headers = ExVCR.Filter.remove_blacklisted_headers(headers)
    {:ok, {status_code, filtered_headers, replaced_body}}
  end

  defp apply_filters({:error, reason}) do
    {:error, reason}
  end

  @doc """
  Returns the response from the ExVCR.Reponse record.
  """
  def get_response_value_from_cache(response) do
    if response.type == "error" do
      {:error, response.body}
    else
      {:ok, {response.status_code, response.headers, response.body}}
    end
  end

  @doc """
  Default definitions for stub.
  """
  def default_stub_params(:headers), do: %{"content-type" => "text/html"}
  def default_stub_params(:status_code), do: ["HTTP/1.1", 200, "OK"]
end
