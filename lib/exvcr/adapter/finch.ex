defmodule ExVCR.Adapter.Finch do
  @moduledoc """
  Provides adapter methods to mock Finch methods.
  """

  use ExVCR.Adapter

  alias ExVCR.Util

  defmacro __using__(_opts) do
    # do nothing
  end

  defdelegate convert_from_string(string), to: ExVCR.Adapter.Finch.Converter
  defdelegate convert_to_string(request, response), to: ExVCR.Adapter.Finch.Converter
  defdelegate parse_request_body(request_body), to: ExVCR.Adapter.Finch.Converter

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    Finch
  end

  @doc """
  Returns list of the mock target methods with function name and callback.
  Implementation for global mock.
  """
  def target_methods() do
    [
      {:request, &ExVCR.Recorder.request([&1,&2])},
      {:request, &ExVCR.Recorder.request([&1,&2,&3])}
    ]
  end

  @doc """
  Returns list of the mock target methods with function name and callback.
  """
  def target_methods(recorder) do
    [
      {:request, &ExVCR.Recorder.request(recorder, [&1,&2])},
      {:request, &ExVCR.Recorder.request(recorder, [&1,&2,&3])}
    ]
  end

  @doc """
  Generate key for searching response.
  """
  def generate_keys_for_request(request) do
    req = Enum.fetch!(request, 0)
    url = Util.build_url(req.scheme, req.host, req.path, req.port, req.query)

    [url: url, method: String.downcase(req.method), request_body: req.body, headers: req.headers]
  end

  @doc """
  Callback from ExVCR.Handler when response is retrieved from the HTTP server.
  """
  def hook_response_from_server(response) do
    apply_filters(response)
  end

  @doc """
  Callback from ExVCR.Handler to get the response content tuple from the ExVCR.Reponse record.
  """
  def get_response_value_from_cache(response) do
    if response.type == "error" do
      {:error, response.body}
    else
      finch_response = %Finch.Response{
        status: response.status_code,
        headers: response.headers,
        body: response.body
      }

      {:ok, finch_response}
    end
  end

  defp apply_filters({:ok, %Finch.Response{} = response}) do
    replaced_body = to_string(response.body) |> ExVCR.Filter.filter_sensitive_data
    filtered_headers = ExVCR.Filter.remove_blacklisted_headers(response.headers)
    filtered_response = Map.put(response, :body, replaced_body)
    |> Map.put(:headers, filtered_headers)
    {:ok, filtered_response}
  end

  defp apply_filters({:error, reason}), do: {:error, reason}

  @doc """
  Default definitions for stub.
  """
  def default_stub_params(:headers), do: %{"content-type" => "text/html"}
  def default_stub_params(:status_code), do: 200
end
