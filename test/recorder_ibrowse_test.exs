defmodule ExVCR.RecorderIBrowseTest do
  use ExUnit.Case
  use ExVCR.Mock

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_ibrowse"

  setup_all do
    :ibrowse.start
    HttpServer.start(path: "/server", port: 34000, response: "test_response")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    :ok
  end

  test "forcefully getting response from server by removing json in advance" do
    use_cassette "server1" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    use_cassette "server2" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ ~r/test_response/
    end

    use_cassette "server2" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ ~r/test_response/
    end
  end

  test "forcefully getting response from server with error" do
    use_cassette "server_error" do
      assert_raise HTTPotion.HTTPError, fn ->
        HTTPotion.get("http://invalid_url", [])
      end
    end
  end

  test "replace sensitive data" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "server_sensitive_data" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ ~r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
  end


  test "filter url param flag removes url params when recording cassettes" do
    ExVCR.Config.filter_url_params(true)
    use_cassette "example_ignore_url_params" do
      assert HTTPotion.get("http://localhost:34000/server?should_not_be_contained", []).body =~ ~r/test_response/
    end
    json = File.read!("#{__DIR__}/../#{@dummy_cassette_dir}/example_ignore_url_params.json")
    refute String.contains?(json, "should_not_be_contained")
    ExVCR.Config.filter_url_params(false)
  end

  teardown_all do
    File.rm_rf(@dummy_cassette_dir)
    :ok
  end
end
