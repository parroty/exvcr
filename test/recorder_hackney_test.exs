defmodule ExVCR.RecorderHackneyTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_hackney"

  setup_all do
    HTTPoison.start
    HttpServer.start(path: "/server", port: 35000, response: "test_response")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    :ok
  end

  test "forcefully getting response from server by removing json in advance" do
    use_cassette "server1" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    use_cassette "server2" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end
    use_cassette "server2" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end
  end

  test "forcefully getting response from server with error" do
    use_cassette "server_error" do
      assert_raise HTTPoison.HTTPError, fn ->
        HTTPoison.get("http://invalid_url", [])
      end
    end
  end

  test "replace sensitive data" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "sensitive_data" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
  end

  teardown_all do
    File.rm_rf(@dummy_cassette_dir)
    :ok
  end
end
