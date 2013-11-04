defmodule ExVCR.RecorderTest do
  use ExUnit.Case, async: false
  import ExVCR.Mock
  alias ExVCR.Recorder

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes"
  @dummy_custom_dir   "tmp/vcr_tmp/vcr_custom"

  setup_all do
    :ibrowse.start
    HttpServer.start(path: "/server", port: 4000, response: "test_response")
    :ok
  end

  test "initializes recorder" do
    record = Recorder.start("fixture/tmp", [test: true])
    assert ExVCR.Actor.Fixture.get(record.fixture)     == "fixture/tmp"
    assert ExVCR.Actor.Options.get(record.options)     == [test: true]
    assert ExVCR.Actor.Responses.get(record.responses) == []
  end

  test "forcefully getting response from server by removing json in advance" do
    File.rm(@dummy_cassette_dir <> "/server.json")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)

    use_cassette "server" do
      assert HTTPotion.get("http://localhost:4000/server", []).body =~ %r/test_response/
    end
  end

  test "forcefully getting response from server, then loading from cache by recording twice" do
    File.rm(@dummy_cassette_dir <> "/server.json")
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)

    use_cassette "server" do
      assert HTTPotion.get("http://localhost:4000/server", []).body =~ %r/test_response/
    end

    use_cassette "server" do
      assert HTTPotion.get("http://localhost:4000/server", []).body =~ %r/test_response/
    end
  end
end
