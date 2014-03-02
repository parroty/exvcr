defmodule ExVCR.RecorderBaseTest do
  use ExUnit.Case
  use ExVCR.Mock
  alias ExVCR.Recorder

  test "initializes recorder" do
    record = Recorder.start([test: true, fixture: "fixture/tmp"])
    assert ExVCR.Actor.Options.get(record.options)     == [test: true, fixture: "fixture/tmp"]
    assert ExVCR.Actor.Responses.get(record.responses) == []
  end

  test "test append/pop of recorder" do
    record = Recorder.start([test: true, fixture: "fixture/tmp"])
    Recorder.append(record, "test")
    assert Recorder.pop(record) == "test"
  end
end
