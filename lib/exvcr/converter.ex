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
        %{request: string_to_request(request), response: string_to_response(response)}
      end

      defoverridable convert_from_string: 1

      @doc """
      Parse request and response tuples into string format.
      """
      def convert_to_string(request, response) do
        %{request: request_to_string(request), response: response_to_string(response)}
      end

      defoverridable convert_to_string: 2

      def string_to_request(string) do
        request = Enum.map(string, fn {x, y} -> {String.to_atom(x), y} end) |> Enum.into(%{})
        struct(ExVCR.Request, request)
      end

      defoverridable string_to_request: 1

      def string_to_response(string), do: raise(ExVCR.ImplementationMissingError)
      defoverridable string_to_response: 1

      def request_to_string(request), do: raise(ExVCR.ImplementationMissingError)
      defoverridable request_to_string: 1

      def response_to_string(response), do: raise(ExVCR.ImplementationMissingError)
      defoverridable response_to_string: 1

      def parse_headers(headers) do
        do_parse_headers(headers, [])
      end

      defoverridable parse_headers: 1

      def do_parse_headers([], acc) do
        Enum.reverse(acc) |> Enum.uniq_by(fn {key, value} -> key end)
      end

      def do_parse_headers([{key, value} | tail], acc) do
        replaced_value = to_string(value) |> ExVCR.Filter.filter_sensitive_data()

        replaced_value =
          ExVCR.Filter.filter_request_header(to_string(key), to_string(replaced_value))

        do_parse_headers(tail, [{to_string(key), replaced_value} | acc])
      end

      defoverridable do_parse_headers: 2

      def parse_options(options) do
        do_parse_options(options, [])
      end

      defoverridable parse_options: 1

      def do_parse_options([], acc) do
        Enum.reverse(acc) |> Enum.uniq_by(fn {key, value} -> key end)
      end

      def do_parse_options([{key, value} | tail], acc) when is_function(value) do
        do_parse_options(tail, acc)
      end

      def do_parse_options([{key, value} | tail], acc) do
        replaced_value = atom_to_string(value) |> ExVCR.Filter.filter_sensitive_data()

        replaced_value =
          ExVCR.Filter.filter_request_option(to_string(key), atom_to_string(replaced_value))

        do_parse_options(tail, [{to_string(key), replaced_value} | acc])
      end

      defoverridable do_parse_options: 2

      def parse_url(url) do
        to_string(url) |> ExVCR.Filter.filter_url_params()
      end

      defoverridable parse_url: 1

      def parse_keyword_list(params) do
        Enum.map(params, fn {k, v} -> {k, to_string(v)} end)
      end

      defoverridable parse_keyword_list: 1

      def parse_request_body(:error), do: ""

      def parse_request_body({:ok, body}) do
        parse_request_body(body)
      end

      def parse_request_body(body) do
        body_string =
          try do
            to_string(body)
          rescue
            _e in Protocol.UndefinedError -> inspect(body)
          end

        ExVCR.Filter.filter_sensitive_data(body_string)
      end

      defoverridable parse_request_body: 1

      defp atom_to_string(atom) do
        if is_atom(atom) do
          to_string(atom)
        else
          atom
        end
      end
    end
  end
end
