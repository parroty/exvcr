defmodule ExVCR.Adapter.IBrowse.Converter do
  @moduledoc """
  Provides helpers to mock :ibrowse methods.
  """

  use ExVCR.Converter

  defp string_to_response(string) do
    response = Enum.map(string, fn({x, y}) -> {String.to_atom(x), y} end)
    response = struct(ExVCR.Response, response)

    response =
      if response.status_code do
        %{response | status_code: Integer.to_char_list(response.status_code)}
      else
        response
      end

    response =
      if response.type == "error" do
        body = string_to_error_reason(response.body)
        %{response | body: body}
      else
        response
      end

    response =
      if is_map(response.headers) do
        headers = response.headers
                  |> Map.to_list
                  |> Enum.map(fn({k,v}) -> {to_char_list(k), to_char_list(v)} end)
        %{response | headers: headers}
      else
        response
      end

    response
  end

  defp string_to_error_reason([reason, details]), do: { String.to_atom(reason), binary_to_tuple(details) }
  defp string_to_error_reason([reason]), do: String.to_atom(reason)

  defp request_to_string([url, headers, method]), do: request_to_string([url, headers, method, [], []])
  defp request_to_string([url, headers, method, body]), do: request_to_string([url, headers, method, body, []])
  defp request_to_string([url, headers, method, body, options]), do: request_to_string([url, headers, method, body, options, 5000])
  defp request_to_string([url, headers, method, body, options, _timeout]) do
    %ExVCR.Request{
      url: parse_url(url),
      headers: parse_headers(headers),
      method: Atom.to_string(method),
      body: parse_request_body(body),
      options: parse_options(sanitize_options(options))
    }
  end

  # If option value is tuple, make it as list, for encoding as json.
  defp sanitize_options(options) do
    Enum.map(options, fn({key, value}) ->
      if is_tuple(value) do
        {key, Tuple.to_list(value)}
      else
        {key, value}
      end
    end)
  end

  defp response_to_string({:ok, status_code, headers, body}) do
    %ExVCR.Response{
      type: "ok",
      status_code: List.to_integer(status_code),
      headers: parse_headers(headers),
      body: to_string(body)
    }
  end

  defp response_to_string({:error, reason}) do
    %ExVCR.Response{
      type: "error",
      body: error_reason_to_string(reason)
    }
  end

  defp error_reason_to_string({reason, details}), do: [Atom.to_string(reason), tuple_to_binary(details)]
  defp error_reason_to_string(reason), do: [Atom.to_string(reason)]

  defp tuple_to_binary(tuple) do
    Enum.map(Tuple.to_list(tuple), fn(x) ->
      if is_atom(x), do: Atom.to_string(x), else: x
    end)
  end

  defp binary_to_tuple(list) do
    Enum.map(list, fn(x) ->
      if is_binary(x), do: String.to_atom(x), else: x
    end) |> List.to_tuple
  end
end
