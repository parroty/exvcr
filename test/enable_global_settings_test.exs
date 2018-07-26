defmodule ExVCR.EnableGlobalSettingsTest do
  use ExVCR.Mock
  use ExUnit.Case, async: false

  test "settings are normally per-process" do
    original_value = ExVCR.Setting.get(:custom_library_dir)

    ExVCR.Setting.set(:custom_library_dir, "global_setting_test")

    setting_from_task = Task.async(fn -> ExVCR.Setting.get(:custom_library_dir) end)

    assert Task.await(setting_from_task) == original_value
    assert ExVCR.Setting.get(:custom_library_dir) == "global_setting_test"
  end

  test "settings are shared globally among processes" do
    original_setting = Application.get_env(:exvcr, :enable_global_settings)

    Application.put_env(:exvcr, :enable_global_settings, true)

    ExVCR.Setting.set(:custom_library_dir, "global_setting_test")

    setting_from_task = Task.async(fn -> ExVCR.Setting.get(:custom_library_dir) end)

    assert Task.await(setting_from_task) == "global_setting_test"

    Application.put_env(:exvcr, :enable_global_settings, original_setting)
  end
end
