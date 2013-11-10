defmodule ExVCR.TaskRunnerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  @show_cassettes_result "" <>
  "Showing list of cassettes in [test/cassettes]\n" <>
  "  [File Name]                              [Last Update]                 \n" <>
  "  test1.json                               Mon, 1 Jan 2013 00:00:00 GMT  \n" <>
  "  test2.json                               Mon, 2 Jan 2013 00:00:00 GMT  \n"

  @deletes_path "test/cassettes/for_deletes/"

  test "show vcr cassettes task prints json file summary" do
    assert capture_io(fn ->
      ExVCR.TaskRunner.show_vcr_cassettes("test/cassettes")
    end) == @show_cassettes_result
  end

  test "delete cassettes task deletes json files" do
    File.mkdir_p!(@deletes_path)
    File.touch(@deletes_path <> "test1.json")
    File.touch(@deletes_path <> "test2.json")

    assert capture_io(fn ->
      ExVCR.TaskRunner.delete_cassettes(@deletes_path, "test1")
    end) == "Deleted test1.json.\n"

    File.rm(@deletes_path <> "test1.json")
    File.rm(@deletes_path <> "test2.json")
  end
end
