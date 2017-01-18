defmodule ExVCR.Setting do
  @moduledoc """
  An module to store the configuration settings.
  """

  @ets_table :exvcr_setting


  def get(key) do
    setup()
    :ets.lookup(@ets_table, key)[key]
  end

  def set(key, value) do
    setup()
    :ets.insert(@ets_table, {key, value})
  end

  def append(key, value) do
    set(key, [value | ExVCR.Setting.get(key)])
  end

  defp setup do
    if :ets.info(@ets_table) == :undefined do
      :ets.new(@ets_table, [:set, :public, :named_table])
      ExVCR.ConfigLoader.load_defaults
    end
  end
end
