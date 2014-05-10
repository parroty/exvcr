defmodule ExVCR.Adapter.Hackney.Converter do
  @moduledoc """
  Provides helpers to mock :hackney methods.
  """

  use ExVCR.Converter

  defp string_to_response(string) do
    response = Enum.traverse(string, fn({x, y}) -> {binary_to_atom(x), y} end)
    struct(ExVCR.Response, response)
  end

  defp request_to_string([method, url, headers, body, options]) do
    %ExVCR.Request{
      url: parse_url(url),
      headers: parse_headers(headers),
      method: to_string(method),
      body: parse_request_body(body),
      options: options
    }
  end

  # Client is already replaced by body through ExVCR.Adapter.Hackney adapter.
  defp response_to_string({:ok, status_code, headers, client}) do
    %ExVCR.Response{
      type: "ok",
      status_code: status_code,
      headers: parse_headers(headers),
      body: inspect client
    }
  end

  defp response_to_string({:error, reason}) do
    %ExVCR.Response{
      type: "error",
      body: atom_to_binary(reason)
    }
  end
end
