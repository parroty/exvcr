defmodule ExVCR.IgnoreLocalhostTest do
  use ExVCR.Mock
  use ExUnit.Case, async: false

  @port 34006
  @url "http://localhost:#{@port}/server"

  setup_all do
    HTTPotion.start
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
end
