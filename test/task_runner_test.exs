defmodule ExVCR.TaskRunnerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  @deletes_path "test/cassettes/for_deletes/"

  test "show vcr cassettes task prints json file summary" do
    result = capture_io(fn ->
      ExVCR.TaskRunner.show_vcr_cassettes("test/cassettes")
    end)

    assert result =~ %r/[File Name]/
    assert result =~ %r/test1.json/
    assert result =~ %r/test2.json/
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
