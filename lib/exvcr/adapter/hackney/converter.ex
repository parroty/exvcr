defmodule ExVCR.Adapter.Hackney.Converter do
  @moduledoc """
  Provides helpers to mock :hackney methods
  """

  def string_to_request(string) do
    Enum.map(string, fn({x,y}) -> {binary_to_atom(x),y} end) |> ExVCR.Request.new
  end

  def string_to_response(string) do
    Enum.map(string, fn({x, y}) -> {binary_to_atom(x), y} end) |> ExVCR.Response.new
  end

  def request_to_string([method, url, headers, body, options]) do
    ExVCR.Request.new(
      url: iolist_to_binary(url),
      headers: parse_headers(headers),
      method: atom_to_binary(method),
      body: iolist_to_binary(body),
      options: options
    )
  end

  # Client is already replaced by body through ExVCR.Adapter.Hackney adapter.
  def response_to_string({:ok, status_code, headers, client}) do
    ExVCR.Response.new(
      status_code: status_code,
      headers: parse_headers(headers),
      body: inspect client
    )
  end

  defp parse_headers(headers) do
    do_parse_headers(headers, [])
  end

  defp do_parse_headers([], acc), do: Enum.reverse(acc)
  defp do_parse_headers([{key,value}|tail], acc) do
    do_parse_headers(tail, [{iolist_to_binary(key), iolist_to_binary(value)}|acc])
  end
end