defmodule ExVCR.Application do
  use Application

  def start(_type, _args) do
    for app <- [:hackney, :ibrowse, :httpc], true == Code.ensure_loaded?(app) do
      app
      |> target_methods()
      |> Enum.each(fn {function, callback} ->
        :meck.expect(app, function, callback)
      end)
    end

    children = [ExVCR.Actor.CurrentRecorder]

    Supervisor.start_link(children, strategy: :one_for_one, name: ExVCR.Supervisor)
  end

  defp target_methods(:hackney), do: ExVCR.Adapter.Hackney.target_methods()
  defp target_methods(:ibrowse), do: ExVCR.Adapter.IBrowse.target_methods()
  defp target_methods(:httpc), do: ExVCR.Adapter.Httpc.target_methods()
end
