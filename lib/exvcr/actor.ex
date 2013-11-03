defmodule ExVCR.Actor do
  @moduledoc """
  Provides data store for values used by ExVCR.Recorder
  """
  defmodule Responses do
    use ExActor

    defcast append(x), state: state, do: new_state([x|state])
    defcast set(x), do: new_state(x)
    defcall get, state: state, do: state

    def pop(x) do
      case get(x) do
        [] -> []
        [head|tail] ->
          set(x, tail)
          head
      end
    end
  end

  defmodule Fixture do
    use ExActor

    defcast set(x), do: new_state(x)
    defcall get, state: state, do: state
  end

  defmodule Options do
    use ExActor

    defcast set(x), do: new_state(x)
    defcall get, state: state, do: state
  end
end
