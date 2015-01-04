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

      # this method should not be mocked (should not return test_response1).
      HttpServer.start(path: "/server", port: @port, response: "test_response2")
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

      # this method should not be mocked (should not return test_response1).
      HttpServer.start(path: "/server", port: @port, response: "test_response2")
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

    @port 34006
    @url "http://localhost:#{@port}/server"

    setup_all do
      HTTPotion.start
      :ok
    end

    test "Specifying match_requests_on: [:query] matches query params" do
      use_cassette "different_query_params_on", match_requests_on: [:query] do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.get("#{@url}?p=3", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.get("#{@url}?p=4", []).body =~ ~r/test_response_after/
        HttpServer.stop(@port)
      end
    end

    test "Not specifying match_requests_on: [:query] does not match query params" do
      use_cassette "different_query_params_off" do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.get("#{@url}?p=3", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method should be mocked (should return previously recorded test_response1).
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.get("#{@url}?p=4", []).body =~ ~r/test_response_before/
        HttpServer.stop(@port)
      end
    end
  end
end

