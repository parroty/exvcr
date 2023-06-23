defmodule ExVCR.RecorderHackneyTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_hackney"
  @port 34002
  @url "http://localhost:#{@port}/server"
  @url_with_query "http://localhost:#{@port}/server?password=sample"

  setup_all do
    File.rm_rf(@dummy_cassette_dir)

    on_exit(fn ->
      File.rm_rf(@dummy_cassette_dir)
      HttpServer.stop(@port)
      :ok
    end)

    HTTPoison.start()
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    :ok
  end

  setup do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
  end

  test "forcefully getting response from server by removing json in advance" do
    use_cassette "server1" do
      assert HTTPoison.get!(@url, []).body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    use_cassette "server2" do
      assert HTTPoison.get!(@url, []).body =~ ~r/test_response/
    end

    use_cassette "server2" do
      assert HTTPoison.get!(@url, []).body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server with error" do
    use_cassette "server_error" do
      assert_raise HTTPoison.Error, fn ->
        HTTPoison.get!("http://invalid_url", [])
      end
    end
  end

  test "replace sensitive data in body" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")

    use_cassette "sensitive_data_in_body" do
      assert HTTPoison.get!(@url, []).body =~ ~r/PLACEHOLDER/
    end

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in query" do
    ExVCR.Config.filter_sensitive_data("password=[a-z]+", "password=***")

    use_cassette "sensitive_data_in_query" do
      body = HTTPoison.get!(@url_with_query, []).body
      assert body == "test_response"
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_query.json")
    assert cassette =~ "password=***"
    refute cassette =~ "password=sample"

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in request header" do
    ExVCR.Config.filter_request_headers("X-My-Secret-Token")

    use_cassette "sensitive_data_in_request_header" do
      body = HTTPoison.get!(@url, "X-My-Secret-Token": "my-secret-token").body
      assert body == "test_response"
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_header.json")
    assert cassette =~ "\"X-My-Secret-Token\": \"***\""
    refute cassette =~ "\"X-My-Secret-Token\": \"my-secret-token\""

    ExVCR.Config.filter_request_headers(nil)
  end

  test "replace sensitive data in matching request header" do
    ExVCR.Config.filter_sensitive_data("Basic [a-z]+", "Basic ***")

    use_cassette "sensitive_data_matches_in_request_headers", match_requests_on: [:headers] do
      body = HTTPoison.get!(@url, [{"Authorization", "Basic credentials"}]).body
      assert body == "test_response"
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_matches_in_request_headers.json")
    assert cassette =~ "\"Authorization\": \"Basic ***\""

    # Attempt another request should match on filtered header
    use_cassette "sensitive_data_matches_in_request_headers", match_requests_on: [:headers] do
      body = HTTPoison.get!(@url, [{"Authorization", "Basic credentials"}]).body
      assert body == "test_response"
    end

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in request options" do
    ExVCR.Config.filter_request_options("basic_auth")

    use_cassette "sensitive_data_in_request_options" do
      body = HTTPoison.get!(@url, [], hackney: [basic_auth: {"username", "password"}]).body
      assert body == "test_response"
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_options.json")
    assert cassette =~ "\"basic_auth\": \"***\""
    refute cassette =~ "\"basic_auth\": {\"username\", \"password\"}"

    ExVCR.Config.filter_request_options(nil)
  end

  test "filter url param flag removes url params when recording cassettes" do
    ExVCR.Config.filter_url_params(true)

    use_cassette "example_ignore_url_params" do
      assert HTTPoison.get!("#{@url}?should_not_be_contained", []).body =~ ~r/test_response/
    end

    json = File.read!("#{__DIR__}/../#{@dummy_cassette_dir}/example_ignore_url_params.json")
    refute String.contains?(json, "should_not_be_contained")
    ExVCR.Config.filter_url_params(false)
  end

  test "remove blacklisted headers" do
    use_cassette "original_headers" do
      assert List.keyfind(HTTPoison.get!(@url, []).headers, "server", 0) != nil
    end

    ExVCR.Config.response_headers_blacklist(["Connection"])

    use_cassette "remove_blacklisted_headers" do
      assert List.keyfind(HTTPoison.get!(@url, []).headers, "connection", 0) == nil
    end

    ExVCR.Config.response_headers_blacklist([])
  end

  @tag :wip
  test "hackney request with ssl options" do
    use_cassette "record_hackney_with_ssl_options" do
      host = @url |> URI.parse() |> Map.get(:host) |> to_charlist()
      options = :hackney_connection.ssl_opts(host, [])
      {:ok, status_code, _headers, _ref} = :hackney.request(:post, @url, [], [], options)
      assert status_code == 200
    end
  end

  test "HTTPoison with ssl options" do
    use_cassette "record_hackney_with_ssl_options" do
      response =
        HTTPoison.post!("https://example.com", {:form, []}, [], ssl: [{:versions, [:"tlsv1.2"]}])

      assert response.status_code == 200
    end
  end

  for option <- [:with_body, {:with_body, true}] do
    @option option

    test "request using `#{inspect(option)}` option records and replays the same thing" do
      recorded_body = use_cassette_with_hackney(@option)
      assert recorded_body =~ ~r/test_response/
      replayed_body = use_cassette_with_hackney(@option)
      assert replayed_body == recorded_body
    end
  end

  defp use_cassette_with_hackney(option) do
    use_cassette "record_hackney_with_body_#{inspect(option)}" do
      {:ok, status_code, _headers, body} = :hackney.request(:get, @url, [], [], [option])
      assert status_code == 200
      body
    end
  end
end
