defmodule ExVCR.IgnoreUrlsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock

  @port 34_013
  @url "http://localhost:#{@port}/server"
  @ignore_urls [
    ~r/http:\/\/localhost.*/,
    ~r/http:\/\/127\.0\.0\.1.*/
  ]

  setup do
    on_exit(fn ->
      HttpServer.stop(@port)
    end)

    :ok
  end

  test "it does not record url requests when the config has been set" do
    use_cassette "ignore_urls_on", ignore_urls: @ignore_urls do
      HttpServer.start(path: "/server", port: @port, response: "test_response_before")
      assert Req.get!(@url).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
      # this method call should NOT be mocked
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert Req.get!(@url).body =~ ~r/test_response_after/
      HttpServer.stop(@port)
      # this method call should NOT be mocked
      non_localhost_url = "http://127.0.0.1:#{@port}/server"
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert Req.get!(non_localhost_url).body =~ ~r/test_response_after/
      HttpServer.stop(@port)
    end
  end

  test "it records urls requests when the config has not been set" do
    use_cassette "ignore_urls_unset" do
      HttpServer.start(path: "/server", port: @port, response: "test_response_before")
      assert Req.get!(@url).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
      # this method call should be mocked
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert Req.get!(@url).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
      # this method call should NOT be mocked
      non_localhost_url = "http://127.0.0.1:#{@port}/server"
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert Req.get!(non_localhost_url).body =~ ~r/test_response_before/
      HttpServer.stop(@port)
    end
  end

  test "ignore_urls option works with request headers" do
    use_cassette "ignore_urls_with_headers", ignore_urls: @ignore_urls do
      HttpServer.start(path: "/server", port: @port, response: "test_response_after")
      assert Req.get!(@url, headers: [{"user-agent", "ExVCR"}]).body =~ ~r/test_response_after/
      HttpServer.stop(@port)
    end
  end
end
