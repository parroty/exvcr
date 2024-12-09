defmodule ExVCR.Adapter.Hackney.Store do
  @moduledoc """
  Provides a datastore for temporary saving client key (Reference) and body relationship.
  """

  @doc """
  Initialize the datastore.
  """
  def start do
    if :ets.info(table()) == :undefined do
      :ets.new(table(), [:set, :public, :named_table])
    end

    :ok
  end

  @doc """
  Returns value (body) from the key (client key).
  """
  def get(key) do
    start()
    :ets.lookup(table(), key)[key]
  end

  @doc """
  Set value (body) with the key (client key).
  """
  def set(key, value) do
    start()
    :ets.insert(table(), {key, value})
    value
  end

  @doc """
  Set key (client key).
  """
  def delete(key) do
    start()
    :ets.delete(table(), key)
  end

  defp table do
    "exvcr_hackney#{inspect(self())}" |> String.to_atom()
  end
end
