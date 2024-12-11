defmodule ExVCR.JSONEncoder do
  @moduledoc """
  Custom JSON encoder implementations for ExVCR.
  """

  defmodule HeaderEncoder do
    @moduledoc false

    def headers_to_map(headers) when is_list(headers) do
      headers
      |> normalize_headers()
      |> Enum.reduce(%{}, fn {k, v}, acc -> 
        Map.put(acc, String.downcase(to_string(k)), to_string(v))
      end)
    end

    def headers_to_map(headers) when is_map(headers) do
      headers
      |> Map.to_list()
      |> normalize_headers()
      |> Enum.reduce(%{}, fn {k, v}, acc -> 
        Map.put(acc, String.downcase(to_string(k)), to_string(v))
      end)
    end

    def headers_to_map(headers), do: headers

    def normalize_headers(headers) do
      Enum.map(headers, fn
        {k, v} -> {k, v}
        [k, v] -> {k, v}
        header when is_tuple(header) -> header
      end)
    end

    def map_to_headers(headers) when is_map(headers) do
      headers
      |> Enum.map(fn {k, v} -> {String.downcase(to_string(k)), to_string(v)} end)
    end
    def map_to_headers(headers), do: headers
  end

  # For encoding tuples to JSON
  defimpl Jason.Encoder, for: Tuple do
    def encode(tuple, opts) do
      tuple
      |> Tuple.to_list()
      |> Jason.Encode.list(opts)
    end
  end

  # For encoding ExVCR.Request
  defimpl Jason.Encoder, for: ExVCR.Request do
    def encode(%{headers: headers} = struct, opts) do
      struct
      |> Map.from_struct()
      |> Map.put(:headers, ExVCR.JSONEncoder.HeaderEncoder.headers_to_map(headers))
      |> Jason.Encode.map(opts)
    end
  end

  # For encoding ExVCR.Response
  defimpl Jason.Encoder, for: ExVCR.Response do
    def encode(%{headers: headers} = struct, opts) do
      struct
      |> Map.from_struct()
      |> Map.put(:headers, ExVCR.JSONEncoder.HeaderEncoder.headers_to_map(headers))
      |> Jason.Encode.map(opts)
    end
  end

  @doc """
  Decode JSON while preserving header structure.
  """
  def decode(json) do
    json
    |> Jason.decode!()
    |> restore_tuples()
  end

  defp restore_tuples(value) when is_map(value) do
    case value do
      %{"request" => request} = map ->
        %{map | "request" => restore_request(request)}
      %{"response" => response} = map ->
        %{map | "response" => restore_response(response)}
      _ ->
        Map.new(value, fn {k, v} -> {k, restore_tuples(v)} end)
    end
  end

  defp restore_tuples(value) when is_list(value) do
    Enum.map(value, &restore_tuples/1)
  end

  defp restore_tuples(value), do: value

  defp restore_request(%{"headers" => headers} = request) when is_map(headers) do
    %{request | "headers" => HeaderEncoder.map_to_headers(headers)}
  end
  defp restore_request(request), do: request

  defp restore_response(%{"headers" => headers} = response) when is_map(headers) do
    %{response | "headers" => HeaderEncoder.map_to_headers(headers)}
  end
  defp restore_response(response), do: response
end
