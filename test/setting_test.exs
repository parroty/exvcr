defmodule ExVCR.SettingTest do
  use ExUnit.Case, async: true

  setup_all do
    cassette_library_dir = ExVCR.Setting.get(:cassette_library_dir)
    custom_library_dir = ExVCR.Setting.get(:custom_library_dir)

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

  test "set response_headers_blacklist" do
    ExVCR.Setting.set(:response_headers_blacklist, ["Content-Type", "Accept"])
    assert ExVCR.Setting.get(:response_headers_blacklist) == ["Content-Type", "Accept"]
  end

  test "set ignore_urls" do
    ExVCR.Setting.set(:ignore_urls, ["example.com"])
    assert ExVCR.Setting.get(:ignore_urls) == ["example.com"]
  end

  test "append ignore_urls when there are no existing values" do
    ExVCR.Setting.append(:ignore_urls, "example.com")
    assert ExVCR.Setting.get(:ignore_urls) == ["example.com"]
  end

  test "append ignore_urls when there are existing values" do
    ExVCR.Setting.set(:ignore_urls, [~r/example.com/])
    ExVCR.Setting.append(:ignore_urls, ~r/example2.com/)
    assert ExVCR.Setting.get(:ignore_urls) == [~r/example2.com/, ~r/example.com/]
  end
end
