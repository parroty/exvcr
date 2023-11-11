defmodule ExVCR.Adapter.HandlerOptionsTest do
  defmodule MatchRequestsOn do
    use ExVCR.Mock
    use ExUnit.Case, async: false

    @port 34006
    @url "http://localhost:#{@port}/server"

    setup_all do
      HTTPotion.start()
      on_exit fn ->
        HttpServer.stop(@port)
      end
      :ok
    end

    test "specifying match_requests_on: [:query] matches query params" do
      use_cassette "different_query_params_on", match_requests_on: [:query] do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.get("#{@url}?q=string&p=3", []).body =~ ~r/test_response_before/
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

    test "specifying match_requests_on: [:headers] matches header params" do
      use_cassette "different_headers_on", match_requests_on: [:headers] do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.post(@url, [body: "body", headers: ["User-Agent": "My App"]]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method call should NOT be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.post(@url, [body: "body", headers: ["User-Agent": "Other App"]]).body =~ ~r/test_response_after/
        HttpServer.stop(@port)
      end
    end

    test "not specifying match_requests_on: [:headers] ignores headers" do
      use_cassette "different_headers_off" do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")
        assert HTTPotion.post(@url, [body: "p=3", headers: ["User-Agent": "My App"]]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)

        # this method call should be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")
        assert HTTPotion.post(@url, [body: "p=4", headers: ["User-Agent": "Other App"]]).body =~ ~r/test_response_before/
        HttpServer.stop(@port)
      end
    end

    defp always_map(headers) do
      # When a request is first recorded then the request headers are stored
      # as a List, but when it's fetched from storage then they are a Map...
      if(is_list(headers), do: Enum.into(headers, %{}), else: headers)
    end

    test "specifying custom_matchers matches using user-defined functions" do
      matches_special_header = fn response, keys, _recorder_options ->
        recorded_headers = always_map(response.request.headers)
        expected_value = recorded_headers["X-Special-Header"]
        keys[:headers]
        |> Enum.any?(&(match?({"X-Special-Header", ^expected_value}, &1)))
      end
      # This will always return true, but just so we can show you can pass an arbitrary
      # number of functions
      always_true = fn _, _, _ -> true end

      use_cassette "user_defined_matchers_matching",
        custom_matchers: [always_true, matches_special_header] do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")

        assert HTTPotion.post(@url,
                 body: "p=3",
                 headers: ["User-Agent": "My App", "X-Special-Header": "Value One"]
               ).body =~ ~r/test_response_before/

        HttpServer.stop(@port)

        # this method call should be mocked as previous "test_response_before" response
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")

        assert HTTPotion.post(@url,
                 body: "p=4",
                 headers: ["User-Agent": "Other App", "X-Special-Header": "Value One"]
               ).body =~ ~r/test_response_before/

        HttpServer.stop(@port)
      end
    end

    test "specifying custom_matchers does not match user-defined functions" do
      matches_special_header = fn response, keys, _recorder_options ->
        recorded_headers = always_map(response.request.headers)
        expected_value = recorded_headers["X-Special-Header"]
        keys[:headers]
        |> Enum.any?(&(match?({"X-Special-Header", ^expected_value}, &1)))
      end
      # This will always return true, but just so we can show you can pass an arbitrary
      # number of functions
      always_true = fn _, _, _ -> true end

      use_cassette "user_defined_matchers_not_matching",
        custom_matchers: [always_true, matches_special_header] do
        HttpServer.start(path: "/server", port: @port, response: "test_response_before")

        assert HTTPotion.post(@url,
                 body: "p=3",
                 headers: ["User-Agent": "My App", "X-Special-Header": "Value One"]
               ).body =~ ~r/test_response_before/

        HttpServer.stop(@port)

        # this method call NOT should be mocked as the custom header check won't match
        HttpServer.start(path: "/server", port: @port, response: "test_response_after")

        assert HTTPotion.post(@url,
                 body: "p=4",
                 headers: ["User-Agent": "Other App", "X-Special-Header": "Value Two"]
               ).body =~ ~r/test_response_after/

        HttpServer.stop(@port)
      end
    end
  end
end
