defmodule ExVCR.MockLockTest do
  use ExUnit.Case, async: true

  test ":do_request_lock polls until lock is released" do
    caller_pid = self()
    test_pid = self()
    other_caller_pid = "fake_pid"
    state = %{lock_holder: other_caller_pid}

    {:noreply, new_state} =
      ExVCR.MockLock.handle_info({:do_request_lock, caller_pid, test_pid}, state)

    assert_receive {:do_request_lock, ^caller_pid, ^test_pid}

    state2 = %{lock_holder: nil}

    {:noreply, new_state2} =
      ExVCR.MockLock.handle_info({:do_request_lock, caller_pid, test_pid}, state2)

    assert new_state2 == %{lock_holder: caller_pid}
  end

  test "removes lock when calling process goes down" do
    pid = "fake_pid"
    state = %{lock_holder: pid}

    {:noreply, new_state} =
      ExVCR.MockLock.handle_info({:DOWN, "ref", :process, pid, "reason"}, state)

    assert new_state == %{lock_holder: nil}
  end
end
