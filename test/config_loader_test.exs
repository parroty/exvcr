defmodule ExVCR.ConfigLoaderTest do
  use ExUnit.Case, async: false

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes"
  @dummy_custom_dir   "tmp/vcr_tmp/vcr_custom"

  setup_all do
    File.rm_rf!(@dummy_cassette_dir)
    :ok
  end

  setup do
    on_exit fn ->
      File.rm_rf!(@dummy_cassette_dir)
      :ok
    end
    :ok
  end

  test "loading default setting" do
    # Set dummy values
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir, @dummy_custom_dir)
    ExVCR.Config.filter_sensitive_data("test_before1", "test_after1")
    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.response_headers_blacklist(["Content-Type", "Accept"])

    # Load default values (defined in config/config.exs)
    ExVCR.ConfigLoader.load_defaults

    # Verify against default values
    assert ExVCR.Setting.get(:cassette_library_dir) == "fixture/vcr_cassettes"
    assert ExVCR.Setting.get(:custom_library_dir) == "fixture/custom_cassettes"
    assert ExVCR.Setting.get(:filter_url_params) == false
    assert ExVCR.Setting.get(:response_headers_blacklist) == []
  end
end