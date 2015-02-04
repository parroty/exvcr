defmodule ExVCR.Adapter.HandlerCustomModeTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock

  test "query param match succeeds with custom mode" do
    use_cassette "response_mocking_with_param", custom: true do
      HTTPotion.get("http://example.com?auth_token=123abc", []).body =~ ~r/Custom Response/
    end
  end
end