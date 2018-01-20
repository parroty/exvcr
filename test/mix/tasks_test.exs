Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.VcrTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  @dummy_path "tmp/vcr_tmp/"
  @dummy_file1 "dummy1.json"
  @dummy_file2 "dummy2.json"
  @dummy_file_show "dummy_show.json"

  setup_all do
    File.mkdir_p!(@dummy_path)
    :ok
  end

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
  end

  test "mix vcr" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.run([])
    end) =~ ~r/Showing list of cassettes/
  end

  test "mix vcr -h" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.run(["-h"])
    end) =~ "Usage: mix vcr [options]"
  end

  test "mix vcr.delete" do
    File.touch!(@dummy_path <> @dummy_file1)
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Delete.run(["--dir", @dummy_path, @dummy_file1])
    end) =~ ~r/Deleted dummy1.json./
    assert(File.exists?(@dummy_path <> @dummy_file1) == false)
  end

  test "mix vcr.delete with --interactive option" do
    File.touch!(@dummy_path <> @dummy_file1)
    assert capture_io("y\n", fn ->
      Mix.Tasks.Vcr.Delete.run(["-i", "--dir", @dummy_path, @dummy_file1])
    end) =~ ~r/delete dummy1.json?/
    assert(File.exists?(@dummy_path <> @dummy_file1) == false)
  end

  test "mix vcr.delete with --all option" do
    File.touch!(@dummy_path <> @dummy_file1)
    File.touch!(@dummy_path <> @dummy_file2)

    assert capture_io("y\n", fn ->
      Mix.Tasks.Vcr.Delete.run(["-a", "--dir", @dummy_path, @dummy_file1])
    end) =~ ~r/Deleted dummy1.json./

    assert(File.exists?(@dummy_path <> @dummy_file1) == false)
    assert(File.exists?(@dummy_path <> @dummy_file2) == false)
  end

  test "mix vcr.delete with invalid file" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Delete.run(["--dir", @dummy_path])
    end) =~ ~r/[Invalid Param]/
  end

  test "mix vcr.show displays json content" do
    File.write(@dummy_path <> @dummy_file_show, "[{\"request\": \"a\"},{\"response\": {\"body\": \"dummy_body\"}}]")
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Show.run([@dummy_path <> @dummy_file_show])
    end) =~ ~r/dummy_body/
  end

  test "mix vcr.show displays shows error if file is not found" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.Show.run(["invalid_file_name"])
    end) =~ ~r/\[invalid_file_name\] was not found/
  end
end
