defmodule ExVCR.Converter do
  @moduledoc """
  Provides helpers for adapter converters.
  """

  defmacro __using__(_) do
    quote do
      @doc """
      Parse string format into original request / response tuples.
      """
      def convert_from_string(%{"request" => request, "response" => response}) do
        %{ request:  string_to_request(request), response: string_to_response(response) }
      end
      defoverridable [convert_from_string: 1]

      @doc """
      Parse request and response tuples into string format.
      """
      def convert_to_string(request, response) do
        %{ request:  request_to_string(request), response: response_to_string(response) }
      end
      defoverridable [convert_to_string: 2]

      defp string_to_request(string) do
        request = Enum.map(string, fn({x,y}) -> {binary_to_atom(x),y} end) |> Enum.into(%{})
        struct(ExVCR.Request, request)
      end
      defoverridable [string_to_request: 1]

      defp string_to_response(string), do: raise ExVCR.ImplementationMissingError
      defoverridable [string_to_response: 1]

      defp request_to_string(request), do: raise ExVCR.ImplementationMissingError
      defoverridable [request_to_string: 1]

      defp response_to_string(response), do: raise ExVCR.ImplementationMissingError
      defoverridable [response_to_string: 1]

      defp parse_headers(headers) do
        do_parse_headers(headers, [])
      end
      defoverridable [parse_headers: 1]

      defp do_parse_headers([], acc), do: Enum.reverse(acc)
      defp do_parse_headers([{key,value}|tail], acc) do
        replaced_value = to_string(value) |> ExVCR.Filter.filter_sensitive_data
        do_parse_headers(tail, [{to_string(key), replaced_value}|acc])
      end
      defoverridable [do_parse_headers: 2]

      defp parse_url(url) do
        to_string(url) |> ExVCR.Filter.filter_url_params
      end
      defoverridable [parse_url: 1]

      defp parse_request_body(body) do
        to_string(body) |> ExVCR.Filter.filter_sensitive_data
      end
      defoverridable [parse_request_body: 1]

      defp parse_keyword_list(params) do
        Enum.map(params, fn({k,v}) -> {k,to_string(v)} end)
      end
      defoverridable [parse_keyword_list: 1]
    end
  end
end
