defmodule ExVCR.Mock do
  @moduledoc """
  Provides macro to record HTTP request/response.
  It only supports :ibrowse HTTP library at the moment.
  """
  alias ExVCR.Recorder

  defmacro __using__(opts) do
    adapter = opts[:adapter] || ExVCR.Adapter.IBrowse

    quote do
      import ExVCR.Mock
      Application.Behaviour.start(unquote(adapter).module_name)
      use unquote(adapter)

      def adapter do
        unquote(adapter)
      end
    end
  end

  @doc """
  Provides macro to trigger recording/replaying http interactions.
  """
  defmacro use_cassette(fixture, options // [], test) do
    quote do
      recorder = Recorder.start(
        unquote(options) ++ [fixture: normalize_fixture(unquote(fixture)), adapter: adapter])

      target_methods = adapter.target_methods(recorder)
      module_name    = adapter.module_name

      :meck.new(module_name, [:passthrough])
      Enum.each(target_methods, fn({function, callback}) ->
        :meck.expect(module_name, function, callback)
      end)

      try do
        unquote(test)
        if Mix.env == :test do
          if :meck.validate(module_name) == false, do: raise ":meck.validate failed"
        end
      after
        :meck.unload(module_name)
        Recorder.save(recorder)
      end
    end
  end

  @doc """
  Normalize fixture name for using as json file names, which removes whitespaces and align case.
  """
  def normalize_fixture(fixture) do
    fixture |> String.replace(%r/\s/, "_") |> String.downcase
  end
end
