defmodule ExVCR.Setting do
  @moduledoc """
  An module to store the configuration settings.
  """
  @ets_table :exvcr_setting
  @default_vcr_path    "fixture/vcr_cassettes"
  @default_custom_path "fixture/custom_cassettes"

  def setup do
    if :ets.info(@ets_table) == :undefined do
      :ets.new(@ets_table, [:set, :public, :named_table])
      :ets.insert(@ets_table, {:cassette_library_dir, @default_path})
    end
  end

  def get(key) do
    setup
    :ets.lookup(@ets_table, key)[key]
  end

  def set(key, value) do
    setup
    :ets.insert(@ets_table, {key, value})
  end

  def get_default_vcr_path, do: @default_vcr_path
  def get_default_custom_path, do: @default_custom_path
end
