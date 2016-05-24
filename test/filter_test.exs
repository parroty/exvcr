defmodule ExVCR.FilterTest do
  use ExUnit.Case, async: false

  test "filter_sensitive_data" do
    ExVCR.Config.filter_sensitive_data("<PASSWORD>.+</PASSWORD>", "PLACEHOLDER")
    ExVCR.Config.filter_sensitive_data("secret", "PLACEHOLDER")

    content = "<PASSWORD>foo</PASSWORD><content>I have a secret</content>"

    assert ExVCR.Filter.filter_sensitive_data(content) ==
      "PLACEHOLDER<content>I have a PLACEHOLDER</content>"

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "filter_url_params" do
    url = "https://example.com/api?test1=foo&test2=bar"

    ExVCR.Config.filter_url_params(true)
    ExVCR.Config.filter_sensitive_data("example.com", "example.org")
    ExVCR.Config.filter_sensitive_data("foo", "PLACEHOLDER")

    assert ExVCR.Filter.filter_url_params(url) == "https://example.org/api"

    ExVCR.Config.filter_url_params(false)

    assert ExVCR.Filter.filter_url_params(url) ==
      "https://example.org/api?test1=PLACEHOLDER&test2=bar"

    ExVCR.Config.filter_sensitive_data(nil)
  end

  test "strip_query_params" do
    url = "https://example.com/api?test1=foo&test2=bar"
    assert ExVCR.Filter.strip_query_params(url) == "https://example.com/api"

    url = "https://example.com?test1=foo&test2=bar"
    assert ExVCR.Filter.strip_query_params(url) == "https://example.com"
  end

  test "remove_blacklisted_headers" do
    assert ExVCR.Filter.remove_blacklisted_headers([]) == []

    ExVCR.Config.response_headers_blacklist(["X-Filter1", "X-Filter2"])
    headers = [{"X-Filter1", "1"}, {"x-filter2", "2"}, {"X-NoFilter", "3"}]
    filtered_headers = ExVCR.Filter.remove_blacklisted_headers(headers)
    assert filtered_headers == [{"X-NoFilter", "3"}]

    ExVCR.Config.response_headers_blacklist([])
  end
end
