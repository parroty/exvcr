defmodule ExVCR.SettingTest do
  use ExUnit.Case

  test "default vcr path" do
    assert ExVCR.Setting.get(:cassette_library_dir) == "fixture/vcr_cassettes"
  end

  test "default custom path" do
    assert ExVCR.Setting.get(:custom_library_dir) == "fixture/custom_cassettes"
  end

  test "set cassette_library_dir" do
    ExVCR.Setting.set(:cassette_library_dir, "dummy")
    assert ExVCR.Setting.get(:cassette_library_dir) == "dummy"
  end
end
