defmodule ExVCR.Mock do
  @moduledoc """
  Provides macro to record HTTP request/response.
  """

  alias ExVCR.Recorder

  defmacro __using__(opts) do
    adapter = opts[:adapter] || ExVCR.Adapter.IBrowse

    quote do
      import ExVCR.Mock
      :application.start(unquote(adapter).module_name)
      use unquote(adapter)

      def adapter do
        unquote(adapter)
      end

      def setup_all do
        :meck.new(adapter.module_name, [:passthrough])
        :ok
      end

      def teardown_all do
        :meck.unload(adapter.module_name)
        :ok
      end
    end
  end

  @doc """
  Provides macro to mock response based on specified parameters.
  """
  defmacro use_cassette(:stub, options, test) do
    quote do
      stub_fixture = "stub_fixture_#{ExVCR.Util.uniq_id}"
      stub = prepare_stub_record(unquote(options), adapter)
      recorder = Recorder.start([fixture: stub_fixture, stub: stub, adapter: adapter])

      mock_methods(recorder, adapter)

      try do
        unquote(test)
      end
    end
  end

  @doc """
  Provides macro to trigger recording/replaying http interactions.
  """
  defmacro use_cassette(fixture, options, test) do
    quote do
      recorder = Recorder.start(
        unquote(options) ++ [fixture: normalize_fixture(unquote(fixture)), adapter: adapter])

      mock_methods(recorder, adapter)

      try do
        unquote(test)
      after
        Recorder.save(recorder)
      end
    end
  end

  @doc """
  Provides macro to trigger recording/replaying http interactions with default options.
  """
  defmacro use_cassette(fixture, test) do
    quote do
      use_cassette(unquote(fixture), [], unquote(test))
    end
  end

  @doc """
  Mock methods pre-defined for the specified adapter.
  """
  def mock_methods(recorder, adapter) do
    target_methods = adapter.target_methods(recorder)
    module_name    = adapter.module_name

    Enum.each(target_methods, fn({function, callback}) ->
      :meck.expect(module_name, function, callback)
    end)
  end

  @doc """
  Prepare stub record based on specified option parameters.
  """
  def prepare_stub_record(options, adapter) do
    method      = (options[:method] || "get") |> to_string
    url         = (options[:url] || ".+") |> to_string
    body        = (options[:body] || "Hello World") |> to_string

    headers     = options[:headers] || adapter.default_stub_params(:headers)
    status_code = options[:status_code] || adapter.default_stub_params(:status_code)

    record = %{ "request"  => %{"method" => method, "url" => url},
                "response" => %{"body" => body, "headers"  => headers, "status_code" => status_code} }

    [adapter.convert_from_string(record)]
  end

  @doc """
  Normalize fixture name for using as json file names, which removes whitespaces and align case.
  """
  def normalize_fixture(fixture) do
    fixture |> String.replace(~r/\s/, "_") |> String.downcase
  end
end
