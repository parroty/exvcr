defmodule ExVCR.Adapter.Hackney.Store do
  def start do
    if :ets.info(:exvcr_hackney) == :undefined do
      :ets.new(:exvcr_hackney, [:set, :public, :named_table])
    end
    :ok
  end

  def get(key) do
    start
    :ets.lookup(:exvcr_hackney, key)[key]
  end

  def set(key, value) do
    start
    :ets.insert(:exvcr_hackney, {key, value})
    value
  end
end
