defmodule ExVCR.RecorderBaseTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock
  alias ExVCR.Recorder

  test "test append/pop of recorder" do
    record = Recorder.start([test: true, fixture: "fixture/tmp"])
    Recorder.append(record, "test")
    assert Recorder.pop(record) == "test"
  end
end
