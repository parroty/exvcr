defmodule ExVCR.Adapter.IBrowse.Converter do
  @moduledoc """
  Provides helpers to mock :ibrowse methods
  """

  @doc """
  Parse string fromat into original request / response format
  """
  def convert_from_string(request, response) do
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
    response = Enum.map(string, fn({x, y}) -> {binary_to_atom(x), y} end) |> ExVCR.Response.new
    response.update(status_code: integer_to_list(response.status_code))
  end

  defp request_to_string([url, headers, method]), do: request_to_string([url, headers, method, [], []])
  defp request_to_string([url, headers, method, body]), do: request_to_string([url, headers, method, body, []])
  defp request_to_string([url, headers, method, body, options]), do: request_to_string([url, headers, method, body, options, 5000])
  defp request_to_string([url, headers, method, body, options, _timeout]) do
    ExVCR.Request.new(
      url: iolist_to_binary(url),
      headers: parse_headers(headers),
      method: atom_to_binary(method),
      body: iolist_to_binary(body),
      options: options
    )
  end

  defp response_to_string({:ok, status_code, headers, body}) do
    ExVCR.Response.new(
      status_code: list_to_integer(status_code),
      headers: parse_headers(headers),
      body: iolist_to_binary(body)
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