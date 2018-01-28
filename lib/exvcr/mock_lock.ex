defmodule ExVCR.MockLock do
  use ExActor.GenServer, export: :mock_lock
  @ten_milliseconds 10

  defstart start() do
    initial_state(%{lock_holder: nil})
  end

  def ensure_started do
    unless Process.whereis(:mock_lock) do
      __MODULE__.start
    end
  end

  defcast request_lock(caller_pid, test_pid) do
    Process.send(self(), {:do_request_lock, caller_pid, test_pid}, [])
    noreply()
  end

  defhandleinfo {:do_request_lock, caller_pid, test_pid}, state: state do
    if Map.get(state, :lock_holder) do
      Process.send_after(self(), {:do_request_lock, caller_pid, test_pid}, @ten_milliseconds)
      noreply()
    else
      Process.monitor(test_pid)
      Process.send(caller_pid, :lock_granted, [])

      state
      |> Map.put(:lock_holder, caller_pid)
      |> new_state
    end
  end

  defhandleinfo {:DOWN, _ref, :process, pid, _}, state: state do
    if state.lock_holder == pid do
      state
      |> Map.put(:lock_holder, nil)
      |> new_state
    else
      noreply()
    end
  end

  defcall release_lock(), state: state do
    state
    |> Map.put(:lock_holder, nil)
    |> set_and_reply(:ok)
  end
end
