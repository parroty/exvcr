defmodule ExVCR.Adapter.IBrowse do
  @moduledoc """
  Provides adapter methods to mock :ibrowse methods.
  """

  use ExVCR.Adapter

  defmacro __using__(_opts) do
    # do nothing
  end

  defdelegate convert_from_string(string), to: ExVCR.Adapter.IBrowse.Converter
  defdelegate convert_to_string(request, response), to: ExVCR.Adapter.IBrowse.Converter

  @doc """
  Returns the name of the mock target module.
  """
  def module_name do
    :ibrowse
  end

  @doc """
  Returns list of the mock target methods with function name and callback.
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
    replaced_body = to_string(body) |> ExVCR.Filter.filter_sensitive_data
    {:ok, status_code, headers, replaced_body}
  end

  defp filter_sensitive_data({:error, reason}) do
    {:error, reason}
  end

  @doc """
  Default definitions for stub.
  """
  def default_stub_params(:headers), do: %{"Content-Type" => "text/html"}
  def default_stub_params(:status_code), do: 200
end
