defmodule ExVCR.ConfigLoaderTest do
  use ExUnit.Case, async: true

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

  test "loading default setting from config.exs" do
    # Set dummy values
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir, @dummy_custom_dir)
    ExVCR.Config.filter_sensitive_data("test_before1", "test_after1")
    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.response_headers_blacklist(["Content-Type", "Accept"])

    # Load default values (defined in config/config.exs)
    ExVCR.ConfigLoader.load_defaults()

    # Verify against default values
    assert ExVCR.Setting.get(:cassette_library_dir) == "fixture/vcr_cassettes"
    assert ExVCR.Setting.get(:custom_library_dir) == "fixture/custom_cassettes"
    assert ExVCR.Setting.get(:filter_url_params) == false
    assert ExVCR.Setting.get(:response_headers_blacklist) == []
  end

  test "loading default setting from empty values" do
    # Backup current env values
    vcr_cassette_library_dir    = Application.get_env(:exvcr, :vcr_cassette_library_dir)
    custom_cassette_library_dir = Application.get_env(:exvcr, :custom_cassette_library_dir)
    filter_sensitive_data       = Application.get_env(:exvcr, :filter_sensitive_data)
    response_headers_blacklist  = Application.get_env(:exvcr, :response_headers_blacklist)

    # Remove env values
    Application.delete_env(:exvcr, :vcr_cassette_library_dir)
    Application.delete_env(:exvcr, :custom_cassette_library_dir)
    Application.delete_env(:exvcr, :filter_sensitive_data)
    Application.delete_env(:exvcr, :response_headers_blacklist)

    # Load default values
    ExVCR.ConfigLoader.load_defaults()

    # Verify against default values
    assert ExVCR.Setting.get(:cassette_library_dir) == "fixture/vcr_cassettes"
    assert ExVCR.Setting.get(:custom_library_dir) == "fixture/custom_cassettes"
    assert ExVCR.Setting.get(:filter_url_params) == false
    assert ExVCR.Setting.get(:response_headers_blacklist) == []

    # Restore env values
    Application.put_env(:exvcr, :vcr_cassette_library_dir, vcr_cassette_library_dir)
    Application.put_env(:exvcr, :custom_cassette_library_dir, custom_cassette_library_dir)
    Application.get_env(:exvcr, :filter_sensitive_data, filter_sensitive_data)
    Application.get_env(:exvcr, :response_headers_blacklist, response_headers_blacklist)
  end
end
