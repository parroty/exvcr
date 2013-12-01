defmodule ExVCR.TaskUtilTest do
  use ExUnit.Case, async: false

  test "default option" do
    option = ExVCR.Task.Util.parse_basic_options([])
    assert option == ["fixture/vcr_cassettes", "fixture/custom_cassettes"]
  end

  test "custom option" do
    option = ExVCR.Task.Util.parse_basic_options([dir: "test1", custom: "test2"])
    assert option == ["test1", "test2"]
  end
end
