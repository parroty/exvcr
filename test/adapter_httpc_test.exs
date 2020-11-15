defmodule ExVCR.Adapter.HttpcTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  @port 34010

  setup_all do
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    Application.ensure_started(:inets)
    on_exit fn ->
      HttpServer.stop(@port)
    end
    :ok
  end

  test "passthrough works when CurrentRecorder has an initial state" do
    if ExVCR.Application.global_mock_enabled?() do
      ExVCR.Actor.CurrentRecorder.default_state()
      |> ExVCR.Actor.CurrentRecorder.set()
    end
    url = "http://localhost:#{@port}/server" |> to_charlist()
    {:ok, result} = :httpc.request(url)
    {{_http_version, status_code, _reason_phrase}, _headers, _body} = result
    assert status_code == 200
  end

  test "passthrough works after cassette has been used" do
    url = "http://localhost:#{@port}/server" |> to_charlist()
    use_cassette "httpc_get_localhost" do
      {:ok, result} = :httpc.request(url)
      {{_http_version, status_code, _reason_phrase}, _headers, _body} = result
      assert status_code == 200
    end
    {:ok, result} = :httpc.request(url)
    {{_http_version, status_code, _reason_phrase}, _headers, _body} = result
    assert status_code == 200
  end

  test "example httpc request/1" do
    use_cassette "example_httpc_request_1" do
      {:ok, result} = :httpc.request('http://example.com')
      {{http_version, _status_code = 200, reason_phrase}, headers, body} = result
      assert to_string(body) =~ ~r/Example Domain/
      assert http_version == 'HTTP/1.1'
      assert reason_phrase == 'OK'
      assert List.keyfind(headers, 'content-type', 0) == {'content-type', 'text/html'}
    end
  end

  test "example httpc request/4" do
    use_cassette "example_httpc_request_4" do
      {:ok, {{_, 200, _reason_phrase}, _headers, body}} = :httpc.request(:get, {'http://example.com', ''}, '', '')
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "example httpc request/4 with additional options" do
    use_cassette "example_httpc_request_4_additional_options" do
      {:ok, {{_, 200, _reason_phrase}, _headers, body}} = :httpc.request(
        :get,
        {'http://example.com', [{'Content-Type', 'text/html'}]},
        [connect_timeout: 3000, timeout: 5000],
        body_format: :binary)
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "example httpc request error" do
    use_cassette "example_httpc_request_error" do
      {:error, {reason, _detail}} = :httpc.request('http://invalidurl')
      assert reason == :failed_connect
    end
  end

  test "stub request works" do
    use_cassette :stub, [url: 'http://example.com', body: 'Stub Response'] do
      {:ok, result} = :httpc.request('http://example.com')
      {{_http_version, _status_code = 200, _reason_phrase}, headers, body} = result
      assert to_string(body) =~ ~r/Stub Response/
      assert List.keyfind(headers, 'content-type', 0) == {'content-type', 'text/html'}
    end
  end
end
