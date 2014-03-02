defmodule ExVCR.Adapter.Hackney.Converter do
  @moduledoc """
  Provides helpers to mock :hackney methods.
  """

  @doc """
  Parse string fromat into original request / response format.
  """
  def convert_from_string([{"request", request}, {"response", response}]) do
    [ request:  string_to_request(request), response: string_to_response(response) ]
  end

  @doc """
  Parse request and response parameters into string format.
  """
  def convert_to_string(request, response) do
    [ request:  request_to_string(request), response: response_to_string(response) ]
  end

  defp string_to_request(string) do
    Enum.map(string, fn({x,y}) -> {binary_to_atom(x),y} end) |> ExVCR.Request.new
  end

  defp string_to_response(string) do
    Enum.map(string, fn({x, y}) -> {binary_to_atom(x), y} end) |> ExVCR.Response.new
  end

  defp request_to_string([method, url, headers, body, options]) do
    ExVCR.Request.new(
      url: to_string(url),
      headers: parse_headers(headers),
      method: to_string(method),
      body: to_string(body),
      options: options
    )
  end

  # Client is already replaced by body through ExVCR.Adapter.Hackney adapter.
  defp response_to_string({:ok, status_code, headers, client}) do
    ExVCR.Response.new(
      type: "ok",
      status_code: status_code,
      headers: parse_headers(headers),
      body: inspect client
    )
  end

  defp response_to_string({:error, reason}) do
    ExVCR.Response.new(
      type: "error",
      body: atom_to_binary(reason)
    )
  end

  defp parse_headers(headers) do
    do_parse_headers(headers, [])
  end

  defp do_parse_headers([], acc), do: Enum.reverse(acc)
  defp do_parse_headers([{key,value}|tail], acc) do
    do_parse_headers(tail, [{to_string(key), to_string(value)}|acc])
  end
end