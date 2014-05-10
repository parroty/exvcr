defmodule ExVCR.Adapter.Httpc.Converter do
  @moduledoc """
  Provides helpers to mock :httpc methods.
  """

  use ExVCR.Converter

  defp string_to_response(string) do
    response = Enum.traverse(string, fn({x, y}) -> {binary_to_atom(x), y} end)
    response = struct(ExVCR.Response, response)

    if response.status_code do
      response = %{response | status_code: list_to_tuple(response.status_code)}
    end

    if response.type == "error" do
      response = %{response | body: {binary_to_atom(response.body), []}}
    end

    response
  end

  defp request_to_string([url]) do
    request_to_string([:get, {url, [], [], []}, [], []])
  end
  defp request_to_string([method, {url, headers}, http_options, options]) do
    request_to_string([method, {url, headers, [], []}, http_options, options])
  end

  # TODO: need to handle content_type
  defp request_to_string([method, {url, headers, _content_type, body}, http_options, options]) do
    %ExVCR.Request{
      url: parse_url(url),
      headers: parse_headers(headers),
      method: to_string(method),
      body: parse_request_body(body),
      options: [httpc_options: parse_keyword_list(options), http_options: parse_keyword_list(http_options)]
    }
  end

  defp response_to_string({:ok, {{http_version, status_code, reason_phrase}, headers, body}}) do
    %ExVCR.Response{
      type: "ok",
      status_code: [to_string(http_version), status_code, to_string(reason_phrase)],
      headers: parse_headers(headers),
      body: to_string(body)
    }
  end

  defp response_to_string({:error, {reason, _detail}}) do
    %ExVCR.Response{
      type: "error",
      body: atom_to_binary(reason)
    }
  end
end
