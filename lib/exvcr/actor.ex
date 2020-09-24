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

    defcall update(finder, updater), state: state do
      state = Enum.map(state, fn(record) ->
        if finder.(record) do
          updater.(record)
        else
          record
        end
      end)
      set_and_reply(state, state)
    end

    defcall pop(), state: state do
      case state do
        [] -> reply(state)
        [head | tail] -> set_and_reply(tail, head)
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

  defmodule CurrentRecorder do
    @moduledoc """
    Stores current recorder to be able to fetch it inside of mocked versio of adapter.
    """

    use ExActor.GenServer, export: __MODULE__

    defstart(start_link(arg), do: initial_state(arg))

    defcast(set(x), do: new_state(x))
    defcall(get, state: state, do: reply(state))
  end
end
