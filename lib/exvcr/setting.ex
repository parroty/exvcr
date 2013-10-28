defmodule ExVCR.Setting do
  @moduledoc """
  An module to store the configuration settings.
  """
  use ExActor, export: :singleton

  @default_values [cassette_library_dir: "fixture/vcr_cassettes"]

  definit do: HashDict.new(@default_values)
  defcall get, state: state, do: state
  defcast set(x), do: new_state(x)

  def set(key, value) do
    start
    HashDict.put(get, key, value) |> set
  end

  def get(key) do
    start
    HashDict.get(get, key)
  end
end
