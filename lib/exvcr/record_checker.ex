defrecord ExVCR.Checker, dir: nil, files: []

defmodule ExVCR.RecordChecker do
  use ExActor, export: :singleton

  defcall get, state: state, do: state
  defcast set(x), do: new_state(x)
  defcast append(x), state: state, do: new_state(state.files([x|state.files]))
end
