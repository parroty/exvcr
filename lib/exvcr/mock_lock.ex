defmodule ExVCR.MockLock do
  use GenServer
  @ten_milliseconds 10

  def start() do
    GenServer.start(__MODULE__, %{lock_holder: nil}, name: :mock_lock)
  end

  def ensure_started do
    unless Process.whereis(:mock_lock) do
      __MODULE__.start()
    end
  end

  def request_lock(caller_pid, test_pid) do
    GenServer.cast(:mock_lock, {:request_lock, caller_pid, test_pid})
  end

  def release_lock() do
    GenServer.call(:mock_lock, :release_lock)
  end

  # Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:request_lock, caller_pid, test_pid}, state) do
    Process.send(self(), {:do_request_lock, caller_pid, test_pid}, [])
    {:noreply, state}
  end

  @impl true
  def handle_info({:do_request_lock, caller_pid, test_pid}, state) do
    if Map.get(state, :lock_holder) do
      Process.send_after(self(), {:do_request_lock, caller_pid, test_pid}, @ten_milliseconds)
      {:noreply, state}
    else
      Process.monitor(test_pid)
      Process.send(caller_pid, :lock_granted, [])
      {:noreply, Map.put(state, :lock_holder, caller_pid)}
    end
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _}, state) do
    if state.lock_holder == pid do
      {:noreply, Map.put(state, :lock_holder, nil)}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call(:release_lock, _from, state) do
    {:reply, :ok, Map.put(state, :lock_holder, nil)}
  end
end
