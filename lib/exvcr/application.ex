defmodule ExVCR.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children =
      if global_mock_enabled?() do
        globally_mock_adapters()
        [ExVCR.Actor.CurrentRecorder]
      else
        []
      end

    Supervisor.start_link(children, strategy: :one_for_one, name: ExVCR.Supervisor)
  end

  defp globally_mock_adapters do
    for app <- [Finch], true == Code.ensure_loaded?(app) do
      app
      |> target_methods()
      |> Enum.each(fn {function, callback} ->
        Mimic.stub(app, function, callback)
      end)
    end
  end

  defp target_methods(Finch), do: ExVCR.Adapter.Finch.target_methods()

  def global_mock_enabled? do
    Application.get_env(:exvcr, :global_mock, false)
  end
end
