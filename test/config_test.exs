defmodule ExVCR.ConfigTest do
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

  test "add filter sensitive data" do
    ExVCR.Config.filter_sensitive_data(nil)
    ExVCR.Config.filter_sensitive_data("test_before1", "test_after1")
    ExVCR.Config.filter_sensitive_data("test_before2", "test_after2")
    assert ExVCR.Setting.get(:filter_sensitive_data) ==
      [{"test_before2", "test_after2"},{"test_before1", "test_after1"}]

    ExVCR.Config.filter_sensitive_data(nil)
    assert ExVCR.Setting.get(:filter_sensitive_data) == []
  end

  test "add filter_url_params" do
    ExVCR.Config.filter_url_params(true)
    assert ExVCR.Setting.get(:filter_url_params) == true
  end

  test "add response headers blacklist" do
    ExVCR.Config.response_headers_blacklist(["Content-Type", "Accept"])
    assert ExVCR.Setting.get(:response_headers_blacklist) == ["content-type", "accept"]

    ExVCR.Config.response_headers_blacklist([])
    assert ExVCR.Setting.get(:response_headers_blacklist) == []
  end
end
