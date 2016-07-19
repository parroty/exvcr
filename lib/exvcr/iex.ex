defmodule ExVCR.IEx do
  @moduledoc """
  Provides helper functions for IEx.
  """

  alias ExVCR.Recorder

  @doc """
  Provides helper for monitoring http request/response in cassette json format.
  """
  defmacro print(options \\ [], test) do
    adapter = options[:adapter] || ExVCR.Adapter.IBrowse
    method_name = :"ExVCR.IEx.Sample#{ExVCR.Util.uniq_id}"

    quote do
      defmodule unquote(method_name) do
        use ExVCR.Mock, adapter: unquote(adapter)

        def run do
          recorder = Recorder.start(
            unquote(options) ++ [fixture: "", adapter: unquote(adapter)])

          target_methods = adapter_method().target_methods(recorder)
          module_name    = adapter_method().module_name

          Enum.each(target_methods, fn({function, callback}) ->
            :meck.expect(module_name, function, callback)
          end)

          try do
            unquote(test)
          after
            Recorder.get(recorder)
            |> JSX.encode!
            |> JSX.prettify!
            |> IO.puts
          end
          :ok
        end
      end
      unquote(method_name).run()
    end
  end
end
