defmodule ExVCR.JSONEncoder do
  @moduledoc """
  Custom JSON encoder implementations for ExVCR.
  """

  # For encoding tuples to JSON
  defimpl Jason.Encoder, for: Tuple do
    def encode(tuple, opts) do
      case tuple do
        # Special case for header tuples to preserve them
        {key, value} when is_binary(key) and is_binary(value) ->
          Jason.Encode.map(%{"__tuple__" => [key, value]}, opts)

        # All other tuples convert to plain lists
        _ ->
          tuple
          |> Tuple.to_list()
          |> Jason.Encode.list(opts)
      end
    end
  end

  @doc """
  Decode JSON while preserving header tuples.
  """
  def decode(json) do
    json
    |> Jason.decode!()
    |> restore_tuples()
  end

  defp restore_tuples(value) when is_map(value) do
    case value do
      %{"__tuple__" => [key, value]} when is_binary(key) and is_binary(value) ->
        {key, value}

      _ ->
        Map.new(value, fn {k, v} -> {k, restore_tuples(v)} end)
    end
  end

  defp restore_tuples(value) when is_list(value) do
    Enum.map(value, &restore_tuples/1)
  end

  defp restore_tuples(value), do: value
end
