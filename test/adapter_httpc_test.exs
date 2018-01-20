defmodule ExVCR.Adapter.HttpcTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup_all do
    Application.ensure_started(:inets)
    :ok
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
