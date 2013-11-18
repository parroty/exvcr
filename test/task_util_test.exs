defmodule ExVCR.TaskUtilTest do
  use ExUnit.Case, async: false

  test "default option" do
    option = ExVCR.TaskUtil.parse_basic_options([])
    assert option == ["fixture/vcr_cassettes", "fixture/custom_cassettes"]
  end

  test "custom option" do
    option = ExVCR.TaskUtil.parse_basic_options([dir: "test1", custom: "test2"])
    assert option == ["test1", "test2"]
  end

  test "base_alias" do
    assert ExVCR.TaskUtil.base_aliases == [d: :dir, c: :custom]
  end
end
