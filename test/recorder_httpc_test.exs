defmodule ExVCR.RecorderHttpcTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_httpc"

  setup_all do
    :inets.start
    HttpServer.start(path: "/server", port: 36000, response: "test_response")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    :ok
  end

  test "forcefully getting response from server by removing json in advance" do
    use_cassette "server1" do
      {:ok, {_, _, body}} = :httpc.request('http://localhost:36000/server')
      assert body =~ %r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    use_cassette "server2" do
      {:ok, {_, _, body}} = :httpc.request('http://localhost:36000/server')
      assert body =~ %r/test_response/
    end

    use_cassette "server2" do
      {:ok, {_, _, body}} = :httpc.request('http://localhost:36000/server')
      assert body =~ %r/test_response/
    end
  end

  test "replace sensitive data" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "server_sensitive_data" do
      assert HTTPotion.get("http://localhost:36000/server", []).body =~ %r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
  end

  teardown_all do
    File.rm_rf(@dummy_cassette_dir)
    :ok
  end
end
