defmodule ExVCR.Mock do
  @moduledoc """
  Provides macro to record HTTP request/response.
  """

  alias ExVCR.Recorder

  defmacro __using__(opts) do
    adapter = opts[:adapter] || ExVCR.Adapter.IBrowse
    options = opts[:options]

    quote do
      import ExVCR.Mock
      :application.start(unquote(adapter).module_name())
      use unquote(adapter)

      def adapter_method() do
        unquote(adapter)
      end

      def options_method() do
        unquote(options)
      end
    end
  end

  @doc """
  Provides macro to trigger recording/replaying http interactions.

  ## Options

  - `:match_requests_on` A list of request properties to match on when
    finding a matching response. Valid values include `:query`, `:headers`,
    and `:request_body`

  """
  defmacro use_cassette(:stub, options, test) do
    quote do
      stub_fixture = "stub_fixture_#{ExVCR.Util.uniq_id()}"
      stub = prepare_stub_record(unquote(options), adapter_method())
      recorder = Recorder.start([fixture: stub_fixture, stub: stub, adapter: adapter_method()])

      try do
        mock_methods(recorder, adapter_method())
        [do: return_value] = unquote(test)
        return_value
      after
        module_name = adapter_method().module_name()
        unload(module_name)
        ExVCR.MockLock.release_lock()
      end
    end
  end

  defmacro use_cassette(fixture, options, test) do
    quote do
      recorder = start_cassette(unquote(fixture), unquote(options))

      try do
        [do: return_value] = unquote(test)
        return_value
      after
        stop_cassette(recorder)
      end
    end
  end

  defmacro use_cassette(fixture, test) do
    quote do
      use_cassette(unquote(fixture), [], unquote(test))
    end
  end

  defmacro start_cassette(fixture, options) when fixture != :stub do
    quote do
      recorder =
        Recorder.start(
          unquote(options) ++
            [fixture: normalize_fixture(unquote(fixture)), adapter: adapter_method()]
        )

      mock_methods(recorder, adapter_method())
      recorder
    end
  end

  defmacro stop_cassette(recorder) do
    quote do
      recorder_result = Recorder.save(unquote(recorder))

      module_name = adapter_method().module_name()
      unload(module_name)
      ExVCR.MockLock.release_lock()

      recorder_result
    end
  end

  @doc false
  defp load(adapter, recorder) do
    if ExVCR.Application.global_mock_enabled?() do
      ExVCR.Actor.CurrentRecorder.set(recorder)
    else
      module_name    = adapter.module_name()
      target_methods = adapter.target_methods(recorder)
      Enum.each(target_methods, fn({function, callback}) ->
        :meck.expect(module_name, function, callback)
      end)
    end
  end

  @doc false
  def unload(module_name) do
    if ExVCR.Application.global_mock_enabled?() do
      ExVCR.Actor.CurrentRecorder.default_state()
      |> ExVCR.Actor.CurrentRecorder.set()
    else
      :meck.unload(module_name)
    end
  end

  @doc """
  Mock methods pre-defined for the specified adapter.
  """
  def mock_methods(recorder, adapter) do
    parent_pid = self()
    Task.async(fn ->
      ExVCR.MockLock.ensure_started()
      ExVCR.MockLock.request_lock(self(), parent_pid)
      receive do
        :lock_granted ->
          load(adapter, recorder)
      end
    end)
    |> Task.await(:infinity)
  end

  @doc """
  Prepare stub record based on specified option parameters.
  """
  def prepare_stub_record(options, adapter) do
    method        = (options[:method] || "get") |> to_string
    url           = (options[:url] || "~r/.+/") |> to_string
    body          = (options[:body] || "Hello World") |> to_string
    # REVIEW: would be great to have "~r/.+/" as default request_body
    request_body  = (options[:request_body] || "") |> to_string

    headers     = options[:headers] || adapter.default_stub_params(:headers)
    status_code = options[:status_code] || adapter.default_stub_params(:status_code)

    record = %{ "request"  => %{"method" => method, "url" => url, "request_body" => request_body},
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
