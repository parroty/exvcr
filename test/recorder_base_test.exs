defmodule ExVCR.RecorderBaseTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  alias ExVCR.Recorder

  test "initializes recorder" do
    record = Recorder.start(test: true, fixture: "fixture/tmp")
    assert ExVCR.Actor.Options.get(record.options) == [test: true, fixture: "fixture/tmp"]
    assert ExVCR.Actor.Responses.get(record.responses) == []
  end

  test "test append/pop of recorder" do
    record = Recorder.start(test: true, fixture: "fixture/tmp")
    Recorder.append(record, "test")
    assert Recorder.pop(record) == "test"
  end

  test "return values from the block" do
    value =
      use_cassette "return_value_from_block" do
        1
      end

    assert value == 1
  end

  test "return values from the block with stub mode" do
    value =
      use_cassette :stub, [] do
        1
      end

    assert value == 1
  end
end
