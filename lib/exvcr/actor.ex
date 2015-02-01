defmodule ExVCR.Actor do
  @moduledoc """
  Provides data store for values used by ExVCR.Recorder.
  """

  defmodule Responses do
    @moduledoc """
    Stores request/response for the recorder.
    """

    use ExActor.GenServer

    defstart start(arg), do: initial_state(arg)

    defcast append(x), state: state, do: new_state([x|state])
    defcast set(x), do: new_state(x)
    defcall get, state: state, do: reply(state)

    def pop(x) do
      case ExVCR.Actor.Responses.get(x) do
        [] -> []
        [head|tail] ->
          set(x, tail)
          head
      end
    end
  end

  defmodule Options do
    @moduledoc """
    Stores option parameters for the recorder.
    """

    use ExActor.GenServer

    defstart start(arg), do: initial_state(arg)

    defcast set(x), do: new_state(x)
    defcall get, state: state, do: reply(state)
  end
end
