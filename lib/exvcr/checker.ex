defmodule ExVCR.Checker do
  @moduledoc """
  Provides data store for checking which cassette files are used.
  It's for [mix vcr.check] task.
  """

  use GenServer

  def start(arg) do
    GenServer.start(__MODULE__, arg, name: :singleton)
  end

  def get do
    GenServer.call(:singleton, :get)
  end

  def set(x) do
    GenServer.cast(:singleton, {:set, x})
  end

  def append(x) do
    GenServer.cast(:singleton, {:append, x})
  end

  @doc """
  Increment the counter for cache cassettes hit.
  """
  def add_cache_count(recorder), do: add_count(recorder, :cache)

  @doc """
  Increment the counter for server request hit.
  """
  def add_server_count(recorder), do: add_count(recorder, :server)

  defp add_count(recorder, type) do
    if ExVCR.Checker.get() != [] do
      ExVCR.Checker.append({type, ExVCR.Recorder.get_file_path(recorder)})
    end
  end

  # Callbacks

  @impl true
  def init(arg) do
    {:ok, arg}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:set, x}, _state) do
    {:noreply, x}
  end

  @impl true
  def handle_cast({:append, x}, state) do
    {:noreply, %{state | files: [x | state.files]}}
  end
end
