defmodule ExVCR.RecorderIBrowseTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock
  alias ExVCR.Recorder

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_ibrowse"
  @dummy_custom_dir   "tmp/vcr_tmp/vcr_custom_ibrowse"

  setup_all do
    :ibrowse.start
    HttpServer.start(path: "/server", port: 34000, response: "test_response")
    :ok
  end

  test "initializes recorder" do
    record = Recorder.start([test: true, fixture: "fixture/tmp"])
    assert ExVCR.Actor.Options.get(record.options)     == [test: true, fixture: "fixture/tmp"]
    assert ExVCR.Actor.Responses.get(record.responses) == []
  end

  test "forcefully getting response from server by removing json in advance" do
    File.rm(@dummy_cassette_dir <> "/server.json")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)

    use_cassette "server" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ %r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    File.rm(@dummy_cassette_dir <> "/server.json")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)

    use_cassette "server" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ %r/test_response/
    end

    use_cassette "server" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ %r/test_response/
    end
  end

  test "replace sensitive data" do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    ExVCR.Config.filter_sensitive_data("test_response", "PLACEHOLDER")
    use_cassette "sensitive_data" do
      assert HTTPotion.get("http://localhost:34000/server", []).body =~ %r/PLACEHOLDER/
    end
    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "test append/pop" do
    record = Recorder.start([test: true, fixture: "fixture/tmp"])
    Recorder.append(record, "test")
    assert Recorder.pop(record) == "test"
  end
end
