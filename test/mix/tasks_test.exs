Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.VcrTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @dummy_path "tmp/vcr_tmp/"
  @dummy_file "dummy.json"

  test "mix vcr" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.run([])
    end) =~ %r/Showing list of cassettes/
  end

  test "mix vcr.delete" do
    File.touch!(@dummy_path <> @dummy_file)
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Delete.run(["--dir", @dummy_path, @dummy_file])
    end) =~ %r/Deleted dummy.json./
    assert(File.exists?(@dummy_path <> @dummy_file) == false)
  end

  test "mix vcr.delete with invalid file" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Delete.run(["--dir", @dummy_path])
    end) =~ %r/invalid parameter is specified/
  end
end
