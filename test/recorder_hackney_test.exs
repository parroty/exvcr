defmodule ExVCR.RecorderHackneyTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_hackney"
  @port 34002
  @url "http://localhost:#{@port}/server"

  setup_all do
    on_exit fn ->
      File.rm_rf(@dummy_cassette_dir)
      HttpServer.stop(@port)
      :ok
    end

    HTTPoison.start
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    :ok
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

  test "replace sensitive data" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "sensitive_data" do
      assert HTTPoison.get!(@url, []).body =~ ~r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
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
      assert Map.has_key?(HTTPoison.get!(@url, []).headers, "connection") == true
    end

    ExVCR.Config.response_headers_blacklist(["Connection"])
    use_cassette "remove_blacklisted_headers" do
      assert Map.has_key?(HTTPoison.get!(@url, []).headers, "connection") == false
    end
    
    ExVCR.Config.response_headers_blacklist([])
  end
end
