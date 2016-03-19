defmodule ExVCR.Adapter.HandlerOptionsTest do
  defmodule ClearMockAll do
    use ExVCR.Mock, options: [clear_mock: true]
    use ExUnit.Case, async: false

    @port 34003
    @url "http://localhost:#{@port}/server"

    setup_all do
      HTTPotion.start
      :ok
    end

    test "clear_mock option for use ExVCR.Mock works" do
      HttpServer.start(path: "/server", port: @port, response: "test_response1")
      use_cassette "option_clean_all" do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
      HttpServer.stop(@port)
      :timer.sleep(100) # put short sleep.

      # this method should not be mocked (should not return test_response1).
      HttpServer.start(path: "/server", port: @port, response: "test_response2")
      :timer.sleep(100) # put short sleep.
      assert HTTPotion.get(@url, []).body == "test_response2"
      HttpServer.stop(@port)

      use_cassette "option_clean_all" do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
    end
  end

  defmodule ClearMockEach do
    use ExVCR.Mock
    use ExUnit.Case, async: false

    @port 34004
    @url "http://localhost:#{@port}/server"

    setup_all do
      HTTPotion.start
      :ok
    end

    test "clear_mock option for use_cassette works" do
      HttpServer.start(path: "/server", port: @port, response: "test_response1")
      use_cassette "option_clean_each", clear_mock: true do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
      HttpServer.stop(@port)
      :timer.sleep(100) # put short sleep.

      # this method should not be mocked (should not return test_response1).
      HttpServer.start(path: "/server", port: @port, response: "test_response2")
      :timer.sleep(100) # put short sleep.
      assert HTTPotion.get(@url, []).body == "test_response2"
      HttpServer.stop(@port)

      use_cassette "option_clean_each" do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
    end
  end

  defmodule MatchRequestsOn do
    use ExVCR.Mock
    use ExUnit.Case, async: false
    alias ExVCR.Setting
    alias ExVCR.Config

    @port 34006
    @url "http://localhost:#{@port}/server"

    setup_all do
      HTTPotion.start
      :ok
    end

    test "specifying match_requests_on: [:query] matches query params" do
      use_cassette "different_query_params_on", match_requests_on: [:query] do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.get("#{@url}?p=3", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method call should NOT be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.get("#{@url}?p=4", []).body =~ ~r/test_response_after/
        HttpServer.stop(@port)
      end
    end

    test "not specifying match_requests_on: [:query] ignores query params" do
      use_cassette "different_query_params_off" do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.get("#{@url}?p=3", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method call should be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.get("#{@url}?p=4", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)
      end
    end

    test "setting default match_requests_on: [:query]" do
      Config.match_requests_on([:query])

      use_cassette "same_query_params_on" do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.get("#{@url}?p=3", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method call should NOT be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.get("#{@url}?p=3", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)
      end

      Config.match_requests_on(Setting.get_default_match_requests_on)
    end

    test "specifying match_requests_on: [:request_body] matches request_body params" do
      use_cassette "different_request_body_params_on", match_requests_on: [:request_body] do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.post(@url, [body: "p=3"]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method call should NOT be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.post(@url, [body: "p=4"]).body =~ ~r/test_response_after/
        HttpServer.stop(@port)
      end
    end

    test "not specifying match_requests_on: [:request_body] ignores request_body params" do
      use_cassette "different_request_body_params_off" do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.post(@url, [body: "p=3"]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method call should be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.post(@url, [body: "p=4"]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)
      end
    end

    test "setting default match_requests_on: [:request_body]" do
      Config.match_requests_on([:request_body])

      use_cassette "same_request_body_params_on"do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.post(@url, [body: "p=3"]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.post(@url, [body: "p=3"]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)
      end

      Config.match_requests_on(Setting.get_default_match_requests_on)
    end
  end
end
