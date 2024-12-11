defmodule ExVCR.IEx do
  @moduledoc """
  Provides helper functions for IEx.
  """

  alias ExVCR.Recorder

  @doc """
  Provides helper for monitoring http request/response in cassette json format.
  """
  defmacro print(options \\ [], test) do
    adapter = options[:adapter] || ExVCR.Adapter.Req
    method_name = :"ExVCR.IEx.Sample#{ExVCR.Util.uniq_id()}"
    IO.inspect(1)

    quote do
      defmodule unquote(method_name) do
        use ExVCR.Mock, adapter: unquote(adapter)

        def run do
          recorder = Recorder.start(unquote(options) ++ [fixture: "", adapter: unquote(adapter)])

          try do
            ExVCR.Mock.mock_methods(recorder, unquote(adapter))
            unquote(test)
          after
            ExVCR.MockLock.release_lock()

            recorder
            |> Recorder.get()
            |> Jason.encode!(pretty: true)
            |> IO.puts()
          end

          :ok
        end
      end

      unquote(method_name).run()
    end

    IO.inspect(3)
  end

  IO.inspect(4)
end
