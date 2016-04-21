defmodule ExVCR.Util do
  @moduledoc """
  Provides utility functions.
  """

  @doc """
  Returns uniq_id string based on current timestamp (ex. 1407237617115869)
  """
  def uniq_id do
    :os.timestamp |> Tuple.to_list |> Enum.join("")
  end

  @doc """
  Takes a keyword lists and returns them as strings.
  """

  def stringify_keys(list) do
    list |> Enum.map(fn {key, value} -> {to_string(key), to_string(value)} end)
  end
end
