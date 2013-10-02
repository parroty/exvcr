defmodule ExVCR.RecorderTest do
  use ExUnit.Case
  import ExVCR.Mock
  alias ExVCR.Recorder

  @tmp_dir "tmp_vcr"

  test "initializes recorder" do
    record = Recorder.start("fixture/tmp", [test: true])
    assert ExVCR.Actor.Fixture.get(record.fixture)     == "fixture/tmp"
    assert ExVCR.Actor.Options.get(record.options)     == [test: true]
    assert ExVCR.Actor.Responses.get(record.responses) == []
  end

  test "getting response from server by removing json in advance" do
    File.rm_rf!(@tmp_dir)
    ExVCR.Config.cassette_library_dir(@tmp_dir)

    use_cassette "server" do
      assert HTTPotion.get("http://httpbin.org", []).body =~ %r/httpbin/
    end

    File.rm_rf!(@tmp_dir)
  end

  test "loading from cache by recording twice" do
    ExVCR.Config.cassette_library_dir(@tmp_dir)

    use_cassette "server" do
      assert HTTPotion.get("http://httpbin.org", []).body =~ %r/httpbin/
    end

    use_cassette "server" do
      assert HTTPotion.get("http://httpbin.org", []).body =~ %r/httpbin/
    end

    File.rm_rf!(@tmp_dir)
  end
end
