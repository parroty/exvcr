defmodule ExVCR.RecorderHackneyTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_hackney"
  @dummy_custom_dir   "tmp/vcr_tmp/vcr_custom_hackney"

  setup_all do
    HTTPoison.start
    HttpServer.start(path: "/server", port: 35000, response: "test_response")
    :ok
  end

  test "forcefully getting response from server by removing json in advance" do
    File.rm(@dummy_cassette_dir <> "/server.json")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)

    use_cassette "server" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    File.rm(@dummy_cassette_dir <> "/server.json")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)

    use_cassette "server" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end

    use_cassette "server" do
      assert HTTPoison.get("http://localhost:35000/server", []).body =~ %r/test_response/
    end
  end
end