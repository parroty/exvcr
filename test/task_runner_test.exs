defmodule ExVCR.TaskRunnerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  @pattern "" <>
  "Showing list of cassettes\n" <>
  "  [File Name]                              [Last Update]                 \n" <>
  "  test1.json                               Mon, 1 Jan 2013 00:00:00 GMT  \n" <>
  "  test2.json                               Mon, 2 Jan 2013 00:00:00 GMT  \n"

  test "show cassette returns json" do
    assert capture_io(fn ->
      ExVCR.TaskRunner.show_cassettes("test/cassettes")
    end) == @pattern
  end
end
