defmodule ExVCR.Mock do
  @moduledoc """
  Provides macro to record HTTP request/response.
  """

  alias ExVCR.Actor.CurrentRecorder
  alias ExVCR.Recorder

  defmacro __using__(opts) do
    adapter = opts[:adapter] || ExVCR.Adapter.Finch
    options = opts[:options]

    quote do
      use unquote(Mimic)
      use unquote(adapter)

      import ExVCR.Mock

      Mimic.copy(unquote(adapter).module_name())
      :application.start(unquote(adapter).module_name())

      def adapter_method do
        unquote(adapter)
      end

      def options_method do
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
      stub = prepare_stub_records(unquote(options), adapter_method())
      recorder = Recorder.start(fixture: stub_fixture, stub: stub, adapter: adapter_method())

      try do
        mock_methods(recorder, adapter_method())
        [do: return_value] = unquote(test)
        return_value
      after
        module_name = adapter_method().module_name()
        unload(module_name)
        Mimic.verify!()
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
      CurrentRecorder.set(recorder)
    else
      module_name = adapter.module_name()
      target_methods = adapter.target_methods(recorder)

      Enum.each(target_methods, fn {function, callback} ->
        Mimic.stub(module_name, function, callback)
      end)
    end
  end

  @doc false
  def unload(module_name) do
    if ExVCR.Application.global_mock_enabled?() do
      CurrentRecorder.set(CurrentRecorder.default_state())
    end
  end

  @doc """
  Mock methods pre-defined for the specified adapter.
  """
  def mock_methods(recorder, adapter) do
    load(adapter, recorder)
    parent_pid = self()

    fn ->
      ExVCR.MockLock.ensure_started()
      ExVCR.MockLock.request_lock(self(), parent_pid)

      receive do
        :lock_granted ->
          load(adapter, recorder)
      end
    end
    |> Task.async()
    |> Task.await(:infinity)
  end

  @doc """
  Prepare stub records
  """
  def prepare_stub_records(options, adapter) do
    if Keyword.keyword?(options) do
      prepare_stub_record(options, adapter)
    else
      Enum.flat_map(options, &prepare_stub_record(&1, adapter))
    end
  end

  @doc """
  Prepare stub record based on specified option parameters.
  """
  def prepare_stub_record(options, adapter) do
    method = to_string(options[:method] || "get")
    url = to_string(options[:url] || "~r/.+/")
    body = to_string(options[:body] || "Hello World")
    # REVIEW: would be great to have "~r/.+/" as default request_body
    request_body = to_string(options[:request_body] || "")

    headers = options[:headers] || adapter.default_stub_params(:headers)
    status_code = options[:status_code] || adapter.default_stub_params(:status_code)

    record = %{
      "request" => %{"method" => method, "url" => url, "request_body" => request_body},
      "response" => %{"body" => body, "headers" => headers, "status_code" => status_code}
    }

    [adapter.convert_from_string(record)]
  end

  @doc """
  Normalize fixture name for using as json file names, which removes whitespaces and align case.
  """
  def normalize_fixture(fixture) do
    fixture |> String.replace(~r/\s/, "_") |> String.downcase()
  end
end
