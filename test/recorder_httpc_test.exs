defmodule ExVCR.RecorderHttpcTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_httpc"
  @port 34001
  @url 'http://localhost:#{@port}/server'

  setup_all do
    on_exit fn ->
      File.rm_rf(@dummy_cassette_dir)
      :ok
    end

    :inets.start
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    :ok
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

  test "replace sensitive data" do
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "server_sensitive_data" do
      {:ok, {_, _, body}} = :httpc.request(@url)
      assert body =~ ~r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
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

end
