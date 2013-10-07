defmodule ExVCR.HandlerTest do
  use ExUnit.Case
  alias ExVCR.Recorder
  alias ExVCR.Handler

  test "test append/pop" do
    record = Recorder.start("fixture/tmp", [test: true])
    Handler.append(record, "test")
    assert Handler.pop(record) == "test"
  end
end
