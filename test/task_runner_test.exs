defmodule ExVCR.TaskRunnerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  @deletes_path "test/cassettes/for_deletes/"

  test "show vcr cassettes task prints json file summary" do
    result = capture_io(fn ->
      ExVCR.Task.Runner.show_vcr_cassettes(["test/cassettes"])
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
      ExVCR.Task.Runner.delete_cassettes(@deletes_path, "test1")
    end) == "Deleted test1.json.\n"

    File.rm(@deletes_path <> "test1.json")
    File.rm(@deletes_path <> "test2.json")
  end

  test "check vcr cassettes task prints json file summary" do
    result = capture_io(fn ->
      record = ExVCR.Checker.new(dirs: ["test/cassettes"], files: ["test1.json", "test2.json", "test1.json"])
      ExVCR.Task.Runner.check_cassettes(record)
    end)

    assert result =~ %r/Showing hit counts of cassettes in/
    assert result =~ %r/test1.json\s+2\s+\n/
    assert result =~ %r/test2.json\s+1\s+\n/
  end
end
