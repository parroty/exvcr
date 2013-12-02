defrecord ExVCR.Checker, dirs: nil, files: []

defmodule ExVCR.RecordChecker do
  @moduledoc """
  Provides data store for checking which cassette files are used.
  It's for [mix vcr.check] task.
  """"

  use ExActor, export: :singleton

  defcall get, state: state, do: state
  defcast set(x), do: new_state(x)
  defcast append(x), state: state, do: new_state(state.files([x|state.files]))
end
