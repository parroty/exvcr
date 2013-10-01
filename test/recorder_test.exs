defmodule ExVCR.RecorderTest do
  use ExUnit.Case
  alias ExVCR.Recorder
  alias ExVCR.Record

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "initializes recorder" do
    record = Recorder.start("fixture/tmp", [test: true])
    assert ExVCR.Actor.Fixture.get(record.fixture)     == "fixture/tmp"
    assert ExVCR.Actor.Options.get(record.options)     == [test: true]
    assert ExVCR.Actor.Responses.get(record.responses) == []
  end

end
