defmodule ExVCR.RecorderReqTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Req

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_req"
  @port 34_003
  @url "http://localhost:#{@port}/server"
  @url_with_query "http://localhost:#{@port}/server?password=sample"

  setup_all do
    on_exit(fn ->
      File.rm_rf(@dummy_cassette_dir)
      HttpServer.stop(@port)
      :ok
    end)

    HttpServer.start(path: "/server", port: @port, response: "test_response")
    :ok
  end

  setup do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
  end

  test "forcefully getting response from server by removing json in advance" do
    use_cassette "server1" do
      {:ok, response} = Req.get(@url)
      assert response.body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    use_cassette "server2" do
      {:ok, response} = Req.get(@url)
      assert response.body =~ ~r/test_response/
    end

    use_cassette "server2" do
      {:ok, response} = Req.get(@url)
      assert response.body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server with error" do
    use_cassette "server_error1" do
      {:error, reason} = Req.get("http://invalid_url")
      assert reason == %Req.TransportError{reason: :nxdomain}
    end
  end

  test "forcefully getting response from server using request!" do
    use_cassette "server1" do
      response = Req.get!(@url)
      assert response.body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server with error using request!" do
    use_cassette "server_error2" do
      assert_raise(Req.TransportError, fn ->
        Req.get!("http://invalid_url")
      end)
    end
  end

  test "replace sensitive data in body" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")

    use_cassette "server_sensitive_data_in_body" do
      {:ok, response} = Req.get(@url)
      assert response.body =~ ~r/PLACEHOLDER/
    end

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in query" do
    ExVCR.Config.filter_sensitive_data("password=[a-z]+", "password=***")

    use_cassette "server_sensitive_data_in_query" do
      {:ok, response} = Req.get(@url_with_query)
      assert response.body =~ ~r/test_response/
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
      {:ok, response} =
        Req.get(@url_with_query, headers: [{"X-My-Secret-Token", "my-secret-token"}])

      assert response.body =~ ~r/test_response/
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_header.json")
    assert cassette =~ ~s("X-My-Secret-Token",)
    assert cassette =~ ~s("***")
    refute cassette =~ ~s("my-secret-token")

    ExVCR.Config.filter_request_headers(nil)
  end

  test "replace sensitive data in matching request header" do
    ExVCR.Config.filter_sensitive_data("Basic [a-z]+", "Basic ***")

    use_cassette "sensitive_data_matches_in_request_headers", match_requests_on: [:headers] do
      {:ok, response} =
        Req.get(@url_with_query, headers: [{"Authorization", "Basic credentials"}])

      assert response.body =~ ~r/test_response/
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_matches_in_request_headers.json")
    assert cassette =~ ~s("Authorization")
    assert cassette =~ ~s("Basic ***")

    # Attempt another request should match on filtered header
    use_cassette "sensitive_data_matches_in_request_headers", match_requests_on: [:headers] do
      {:ok, response} =
        Req.get(@url_with_query, headers: [{"Authorization", "Basic credentials"}])

      assert response.body =~ ~r/test_response/
    end

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in request options" do
    ExVCR.Config.filter_request_options("pool_timeout")

    use_cassette "sensitive_data_in_request_options" do
      {:ok, response} =
        Req.get(@url_with_query,
          headers: [{"Authorization", "Basic credentials"}],
          pool_timeout: 5_000
        )

      assert response.body =~ ~r/test_response/
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_options.json")
    assert cassette =~ ~s("pool_timeout",)
    assert cassette =~ ~s("***")
    refute cassette =~ "5000"

    ExVCR.Config.filter_request_options(nil)
  end

  test "filter url param flag removes url params when recording cassettes" do
    ExVCR.Config.filter_url_params(true)

    use_cassette "example_ignore_url_params" do
      {:ok, response} = Req.get("#{@url}?should_not_be_contained")
      assert response.body =~ ~r/test_response/
    end

    json = File.read!("#{__DIR__}/../#{@dummy_cassette_dir}/example_ignore_url_params.json")
    refute String.contains?(json, "should_not_be_contained")
    ExVCR.Config.filter_url_params(false)
  end

  test "remove blacklisted headers" do
    ExVCR.Config.response_headers_blacklist(["date"])

    use_cassette "remove_blacklisted_headers" do
      {:ok, response} = Req.get(@url)

      assert response.headers == [
               {"content-length", "13"},
               {"vary", "accept-encoding"},
               {"cache-control", "max-age=0, private, must-revalidate"},
               {"content-type", "text/plain"}
             ]
    end

    ExVCR.Config.response_headers_blacklist([])
  end
end
