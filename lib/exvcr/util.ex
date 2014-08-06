defmodule ExVCR.Util do
  @moduledoc """
  Provides utility functions.
  """

  @doc """
  Returns uniq_id string based on current timestamp (ex. 1407237617115869)
  """
  def uniq_id do
    :erlang.now |> Tuple.to_list |> Enum.join("")
  end
end
