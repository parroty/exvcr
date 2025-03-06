defmodule ExVCR.IgnoreLocalhostTest do
  use ExVCR.Mock
  use ExUnit.Case, async: false

  @port 34012
  @url "http://localhost:#{@port}/server"

  setup_all do
    HTTPotion.start()

    on_exit(fn ->
      HttpServer.stop(@port)
    end)

    :ok
  end

  test "it does not record localhost requests when the config has been set" do
    use_cassette "ignore_localhost_on", ignore_localhost: true do
      HttpServer.start(path: "/server", port: @port, response: "test_response_before")
      assert HTTPotion.get(@url, []).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
      # this method call should NOT be mocked
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert HTTPotion.get(@url, []).body =~ ~r/test_response_after/
      HttpServer.stop(@port)
    end
  end

  test "it records localhost requests when the config has not been set" do
    use_cassette "ignore_localhost_unset" do
      HttpServer.start(path: "/server", port: @port, response: "test_response_before")
      assert HTTPotion.get(@url, []).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
      # this method call should be mocked
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert HTTPotion.get(@url, []).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
    end
  end

  test "ignore_localhost option works with request headers" do
    use_cassette "ignore_localhost_with_headers", ignore_localhost: true do
      non_localhost_url = "http://127.0.0.1:#{@port}/server"
      HttpServer.start(path: "/server", port: @port, response: "test_response_before")
      assert HTTPotion.get(non_localhost_url, headers: ["User-Agent": "ExVCR"]).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
      # this method call should be mocked
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert HTTPotion.get(non_localhost_url, headers: ["User-Agent": "ExVCR"]).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
    end
  end

  test "it records localhost requests when overrides the config setting" do
    ExVCR.Setting.set(:ignore_localhost, true)

    use_cassette "ignore_localhost_unset", ignore_localhost: false do
      HttpServer.start(path: "/server", port: @port, response: "test_response_before")
      assert HTTPotion.get(@url, []).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
      # this method call should be mocked
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert HTTPotion.get(@url, []).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
    end

    ExVCR.Setting.set(:strict_mode, false)
  end
end
