defmodule ExVCR.Actor do
  @moduledoc """
  Provides data store for values used by ExVCR.Recorder.
  """

  defmodule Responses do
    @moduledoc """
    Stores request/response for the recorder.
    """

    use GenServer

    def start(arg) do
      GenServer.start(__MODULE__, arg)
    end

    def append(pid, x) do
      GenServer.cast(pid, {:append, x})
    end

    def set(pid, x) do
      GenServer.cast(pid, {:set, x})
    end

    def get(pid) do
      GenServer.call(pid, :get)
    end

    def update(pid, finder, updater) do
      GenServer.call(pid, {:update, finder, updater})
    end

    def pop(pid) do
      GenServer.call(pid, :pop)
    end

    # Callbacks

    @impl true
    def init(arg) do
      {:ok, arg}
    end

    @impl true
    def handle_cast({:append, x}, state) do
      {:noreply, [x|state]}
    end

    @impl true
    def handle_cast({:set, x}, _state) do
      {:noreply, x}
    end

    @impl true
    def handle_call(:get, _from, state) do
      {:reply, state, state}
    end

    @impl true
    def handle_call({:update, finder, updater}, _from, state) do
      new_state = Enum.map(state, fn(record) ->
        if finder.(record) do
          updater.(record)
        else
          record
        end
      end)
      {:reply, new_state, new_state}
    end

    @impl true
    def handle_call(:pop, _from, state) do
      case state do
        [] -> {:reply, state, state}
        [head | tail] -> {:reply, head, tail}
      end
    end
  end

  defmodule Options do
    @moduledoc """
    Stores option parameters for the recorder.
    """

    use GenServer

    def start(arg) do
      GenServer.start(__MODULE__, arg)
    end

    def set(pid, x) do
      GenServer.cast(pid, {:set, x})
    end

    def get(pid) do
      GenServer.call(pid, :get)
    end

    # Callbacks

    @impl true
    def init(arg) do
      {:ok, arg}
    end

    @impl true
    def handle_cast({:set, x}, _state) do
      {:noreply, x}
    end

    @impl true
    def handle_call(:get, _from, state) do
      {:reply, state, state}
    end
  end

  defmodule CurrentRecorder do
    @moduledoc """
    Stores current recorder to be able to fetch it inside of the mocked version of the adapter.
    """

    use GenServer

    def start_link(_) do
      GenServer.start_link(__MODULE__, default_state(), name: __MODULE__)
    end

    def set(x) do
      GenServer.cast(__MODULE__, {:set, x})
    end

    def get do
      GenServer.call(__MODULE__, :get)
    end

    def default_state(), do: nil

    # Callbacks

    @impl true
    def init(state) do
      {:ok, state}
    end

    @impl true
    def handle_cast({:set, x}, _state) do
      {:noreply, x}
    end

    @impl true
    def handle_call(:get, _from, state) do
      {:reply, state, state}
    end
  end
end
