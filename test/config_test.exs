defmodule ExVCR.ConfigTest do
  use ExUnit.Case

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes"
  @dummy_custom_dir   "tmp/vcr_tmp/vcr_custom"

  setup do
    File.rm_rf!(@dummy_cassette_dir)
    :ok
  end

  test "setting up cassette library dir" do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
    assert ExVCR.Setting.get(:cassette_library_dir) == @dummy_cassette_dir
    assert ExVCR.Setting.get(:custom_library_dir)   == nil
  end

  test "setting up cassette and custom library dir" do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir, @dummy_custom_dir)
    assert ExVCR.Setting.get(:cassette_library_dir) == @dummy_cassette_dir
    assert ExVCR.Setting.get(:custom_library_dir)   == @dummy_custom_dir
  end

  teardown do
    File.rm_rf!(@dummy_cassette_dir)
    :ok
  end

end
