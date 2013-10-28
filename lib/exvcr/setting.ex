defmodule ExVCR.Setting do
  @moduledoc """
  An module to store the configuration settings.
  """
  use ExActor, export: :singleton

  @default_path "fixture/vcr_cassettes"

  definit do: HashDict.new([cassette_library_dir: @default_path])
  defcall get, state: state, do: state
  defcast set(x), do: new_state(x)

  def get_default_path, do: @default_path

  def set(key, value) do
    start
    HashDict.put(get, key, value) |> set
  end

  def get(key) do
    start
    HashDict.get(get, key)
  end
end
