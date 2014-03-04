defmodule ExVCR.Adapter.IBrowse.Converter do
  @moduledoc """
  Provides helpers to mock :ibrowse methods.
  """

  use ExVCR.Converter

  defp string_to_response(string) do
    response = Enum.map(string, fn({x, y}) -> {binary_to_atom(x), y} end) |> ExVCR.Response.new

    if response.status_code do
      response = response.update(status_code: integer_to_list(response.status_code))
    end

    if response.type == "error" do
      response = response.update(string_to_error_reason(response.body))
    end

    response
  end

  defp string_to_error_reason([reason, details]), do: [body: { binary_to_atom(reason), binary_to_tuple(details) }]
  defp string_to_error_reason([reason]), do: [body: binary_to_atom(reason)]

  defp request_to_string([url, headers, method]), do: request_to_string([url, headers, method, [], []])
  defp request_to_string([url, headers, method, body]), do: request_to_string([url, headers, method, body, []])
  defp request_to_string([url, headers, method, body, options]), do: request_to_string([url, headers, method, body, options, 5000])
  defp request_to_string([url, headers, method, body, options, _timeout]) do
    ExVCR.Request.new(
      url: parse_url(url),
      headers: parse_headers(headers),
      method: atom_to_binary(method),
      body: parse_request_body(body),
      options: options
    )
  end

  defp response_to_string({:ok, status_code, headers, body}) do
    ExVCR.Response.new(
      type: "ok",
      status_code: list_to_integer(status_code),
      headers: parse_headers(headers),
      body: to_string(body)
    )
  end

  defp response_to_string({:error, reason}) do
    ExVCR.Response.new(
      type: "error",
      body: error_reason_to_string(reason)
    )
  end

  defp error_reason_to_string({reason, details}), do: [atom_to_binary(reason), tuple_to_binary(details)]
  defp error_reason_to_string(reason), do: [atom_to_binary(reason)]

  defp tuple_to_binary(tuple) do
    Enum.map(tuple_to_list(tuple), fn(x) ->
      if is_atom(x), do: atom_to_binary(x), else: x
    end)
  end

  defp binary_to_tuple(list) do
    Enum.map(list, fn(x) ->
      if is_binary(x), do: binary_to_atom(x), else: x
    end) |> list_to_tuple
  end
end
