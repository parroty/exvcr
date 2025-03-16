defmodule ExVCR.Setting do
  @moduledoc """
  An module to store the configuration settings.
  """

  def get(key) do
    setup()
    :ets.lookup(table(), key)[key]
  end

  def set(key, value) do
    setup()
    :ets.insert(table(), {key, value})
  end

  def append(key, value) do
    case __MODULE__.get(key) do
      [_ | _] = values -> __MODULE__.set(key, [value | values])
      _ -> __MODULE__.set(key, [value])
    end
  end

  defp setup do
    if :ets.info(table()) == :undefined do
      :ets.new(table(), [:set, :public, :named_table])
      ExVCR.ConfigLoader.load_defaults()
    end
  end

  defp table do
    if Application.get_env(:exvcr, :enable_global_settings) do
      :exvcr_setting
    else
      :"exvcr_setting#{inspect(self())}"
    end
  end
end
