defmodule ExVCR.SettingTest do
  use ExUnit.Case, async: false

  setup_all do
    cassette_library_dir = ExVCR.Setting.get(:cassette_library_dir)
    custom_library_dir   = ExVCR.Setting.get(:custom_library_dir)

    on_exit(fn ->
      ExVCR.Setting.set(:cassette_library_dir, cassette_library_dir)
      ExVCR.Setting.set(:custom_library_dir, custom_library_dir)
      :ok
    end)
    :ok
  end

  test "set custom_library_dir" do
    ExVCR.Setting.set(:custom_library_dir, "custom_dummy")
    assert ExVCR.Setting.get(:custom_library_dir) == "custom_dummy"
  end

  test "set cassette_library_dir" do
    ExVCR.Setting.set(:cassette_library_dir, "cassette_dummy")
    assert ExVCR.Setting.get(:cassette_library_dir) == "cassette_dummy"
  end
end
