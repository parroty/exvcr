defmodule ExVCR.Adapter.HttpcTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup_all do
    Application.ensure_started(:inets)
    :ok
  end

  test "example httpc request/1" do
    use_cassette "example_httpc_request_1" do
      {:ok, result} = :httpc.request('http://example.com')
      {{_http_version, _status_code = 200, _reason_phrase}, _headers, body} = result
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "example httpc request/4" do
    use_cassette "example_httpc_request_4" do
      {:ok, {{_, 200, _reason_phrase}, _headers, body}} = :httpc.request(:get, {'http://example.com', ''}, '', '')
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "example httpc request error" do
    use_cassette "example_httpc_request_error" do
      {:error, {reason, _detail}} = :httpc.request('http://invalidurl')
      assert reason == :failed_connect
    end
  end
end
