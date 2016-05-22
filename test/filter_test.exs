defmodule ExVCR.FilterTest do
  use ExUnit.Case, async: false

  test "remove_blacklisted_headers with empty headers" do
    assert ExVCR.Filter.remove_blacklisted_headers([]) == []
  end

  test "remove_blacklisted_headers with supplied headers" do
    ExVCR.Config.response_headers_blacklist(["X-Filter1", "X-Filter2"])
    headers = [{"X-Filter1", "1"}, {"x-filter2", "2"}, {"X-NoFilter", "3"}]
    filtered_headers = ExVCR.Filter.remove_blacklisted_headers(headers)
    assert filtered_headers == [{"X-NoFilter", "3"}]
  end
end
