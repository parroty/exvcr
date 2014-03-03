defmodule ExVCR.Converter do
  @moduledoc """
  Provides helpers for adapter converters
  """

  defmacro __using__(_) do
    quote do
      @doc """
      Parse string fromat into original request / response format.
      """
      def convert_from_string([{"request", request}, {"response", response}]) do
        [ request:  string_to_request(request), response: string_to_response(response) ]
      end
      defoverridable [convert_from_string: 1]

      @doc """
      Parse request and response parameters into string format.
      """
      def convert_to_string(request, response) do
        [ request:  request_to_string(request), response: response_to_string(response) ]
      end
      defoverridable [convert_to_string: 2]

      defp string_to_request(string) do
        Enum.map(string, fn({x,y}) -> {binary_to_atom(x),y} end) |> ExVCR.Request.new
      end
      defoverridable [string_to_request: 1]

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
    end

  end
end
