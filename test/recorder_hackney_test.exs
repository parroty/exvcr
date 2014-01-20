defmodule ExVCR.RecorderHackneyTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_hackney"

  setup_all do
    HTTPoison.start
    HttpServer.start(path: "/server", port: 35000, response: "test_response")
    :ok
  end

  setup do
    File.rm_rf(@dummy_cassette_dir)
  end

  test "forcefully getting response from server by removing json in advance" do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    use_cassette "server" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    use_cassette "server" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end

    use_cassette "server" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end
  end

  test "replace sensitive data" do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "sensitive_data" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
  end

  teardown_all do
    File.rm_rf(@dummy_cassette_dir)
  end
end