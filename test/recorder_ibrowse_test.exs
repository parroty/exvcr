defmodule ExVCR.RecorderIBrowseTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_ibrowse"
  @port 34000
  @url "http://localhost:#{@port}/server"
  @url_with_query "http://localhost:#{@port}/server?password=sample"

  setup_all do
    on_exit fn ->
      File.rm_rf(@dummy_cassette_dir)
      HttpServer.stop(@port)
      :ok
    end

    Application.ensure_started(:ibrowse)
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    :ok
  end

  setup do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
  end

  test "forcefully getting response from server by removing json in advance" do
    use_cassette "server1" do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    use_cassette "server2" do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end

    use_cassette "server2" do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server with error" do
    use_cassette "server_error" do
      response = HTTPotion.get!(@url)
      assert response.status_code == 200
      assert String.valid?(response.body)
    end
  end

  test "replace sensitive data in body" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "server_sensitive_data_in_body" do
      assert HTTPotion.get(@url, []).body =~ ~r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in query" do
    ExVCR.Config.filter_sensitive_data("password=[a-z]+", "password=***")
    use_cassette "server_sensitive_data_in_query" do
      assert HTTPotion.get(@url_with_query, []).body =~ ~r/test_response/
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/server_sensitive_data_in_query.json")
    assert cassette =~ "password=***"
    refute cassette =~ "password=sample"

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in request header" do
    ExVCR.Config.filter_request_headers("X-My-Secret-Token")
    use_cassette "sensitive_data_in_request_header" do
      assert HTTPotion.get(@url_with_query, [headers: ["X-My-Secret-Token": "my-secret-token"]]).body =~ ~r/test_response/
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_header.json")
    assert cassette =~ "\"X-My-Secret-Token\": \"***\""
    refute cassette =~  "\"X-My-Secret-Token\": \"my-secret-token\""

    ExVCR.Config.filter_request_headers(nil)
  end

  test "replace sensitive data in matching request header" do
    ExVCR.Config.filter_sensitive_data("Basic [a-z]+", "Basic ***")

    use_cassette "sensitive_data_matches_in_request_headers", match_requests_on: [:headers] do
      assert HTTPotion.get(@url_with_query, [headers: ["Authorization": "Basic credentials"]]).body =~ ~r/test_response/
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_matches_in_request_headers.json")
    assert cassette =~ "\"Authorization\": \"Basic ***\""

    # Attempt another request should match on filtered header
    use_cassette "sensitive_data_matches_in_request_headers", match_requests_on: [:headers] do
      assert HTTPotion.get(@url_with_query, [headers: ["Authorization": "Basic credentials"]]).body =~ ~r/test_response/
    end

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in request options" do
    ExVCR.Config.filter_request_options("basic_auth")
    use_cassette "sensitive_data_in_request_options" do
      assert HTTPotion.get(@url_with_query, [basic_auth: {"username", "password"}]).body =~ ~r/test_response/
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_options.json")
    assert cassette =~ "\"basic_auth\": \"***\""
    refute cassette =~  "\"basic_auth\": {\"username\", \"password\"}"

    ExVCR.Config.filter_request_options(nil)
  end

  test "filter url param flag removes url params when recording cassettes" do
    ExVCR.Config.filter_url_params(true)
    use_cassette "example_ignore_url_params" do
      assert HTTPotion.get("#{@url}?should_not_be_contained", []).body =~ ~r/test_response/
    end
    json = File.read!("#{__DIR__}/../#{@dummy_cassette_dir}/example_ignore_url_params.json")
    refute String.contains?(json, "should_not_be_contained")
    ExVCR.Config.filter_url_params(false)
  end

  test "remove blacklisted headers" do
    ExVCR.Config.response_headers_blacklist(["date"])
    use_cassette "remove_blacklisted_headers" do
      assert HTTPotion.get(@url, []).headers == %HTTPotion.Headers{
        hdrs: %{"content-length" => "13", "server" => "Cowboy"}
      }
    end
    ExVCR.Config.response_headers_blacklist([])
  end
end
