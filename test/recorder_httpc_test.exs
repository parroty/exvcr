defmodule ExVCR.RecorderHttpcTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_httpc"
  @port 34001
  @url 'http://localhost:#{@port}/server'
  @url_with_query 'http://localhost:#{@port}/server?password=sample'

  setup_all do
    on_exit fn ->
      File.rm_rf(@dummy_cassette_dir)
      HttpServer.stop(@port)
      :ok
    end

    Application.ensure_started(:inets)
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    :ok
  end

  setup do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
  end

  test "forcefully getting response from server by removing json in advance" do
    use_cassette "server1" do
      {:ok, {_, _, body}} = :httpc.request(@url)
      assert body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    use_cassette "server2" do
      {:ok, {_, _, body}} = :httpc.request(@url)
      assert body =~ ~r/test_response/
    end

    use_cassette "server2" do
      {:ok, {_, _, body}} = :httpc.request(@url)
      assert body =~ ~r/test_response/
    end
  end

  test "replace sensitive data in body" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "server_sensitive_data_in_body" do
      {:ok, {_, _, body}} = :httpc.request(@url)
      assert body =~ ~r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "replace sensitive data in query " do
    ExVCR.Config.filter_sensitive_data("password=[a-z]+", "password=***")
    use_cassette "server_sensitive_data_in_query" do
      {:ok, {_, _, body}} = :httpc.request(@url_with_query)
      assert body =~ ~r/test_response/
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
      {:ok, {_, _, body}} = :httpc.request(:get, {@url_with_query, [{'X-My-Secret-Token', 'my-secret-token'}]}, [], [])
      assert body == "test_response"
    end

    # The recorded cassette should contain replaced data.
    cassette = File.read!("#{@dummy_cassette_dir}/sensitive_data_in_request_header.json")
    assert cassette =~ "\"X-My-Secret-Token\": \"***\""
    refute cassette =~  "\"X-My-Secret-Token\": \"my-secret-token\""

    ExVCR.Config.filter_request_headers(nil)
  end
  test "filter url param flag removes url params when recording cassettes" do
    ExVCR.Config.filter_url_params(true)
    use_cassette "example_ignore_url_params" do
      {:ok, {_, _, body}} = :httpc.request('#{@url}?should_not_be_contained')
      assert body =~ ~r/test_response/
    end
    json = File.read!("#{__DIR__}/../#{@dummy_cassette_dir}/example_ignore_url_params.json")
    refute String.contains?(json, "should_not_be_contained")
    ExVCR.Config.filter_url_params(false)
  end

  test "remove blacklisted headers" do
    ExVCR.Config.response_headers_blacklist(["Date"])
    use_cassette "remove_blacklisted_headers" do
      {:ok, {_, headers, _}} = :httpc.request(@url)
      assert headers == [{'server', 'Cowboy'}, {'content-length', '13'}]
    end
    ExVCR.Config.response_headers_blacklist([])
  end
end
