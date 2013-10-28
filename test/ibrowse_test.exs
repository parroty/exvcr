defmodule ExVCR.IBrowseTest do
  use ExUnit.Case, async: false
  alias ExVCR.Mock.IBrowse

  @request ExVCR.Request.new(url: "http://example.com", headers: [{"Accept-Ranges", "bytes"}], method: "get", body: "", options: [])
  test "request_to_string/3" do
    assert IBrowse.request_to_string(['http://example.com', [{'Accept-Ranges', 'bytes'}], :get]) == @request
  end

  test "request_to_string/4" do
    assert IBrowse.request_to_string(['http://example.com', [{'Accept-Ranges', 'bytes'}], :get, []]) == @request
  end

  test "request_to_string/5" do
    assert IBrowse.request_to_string(['http://example.com', [{'Accept-Ranges', 'bytes'}], :get, [], []]) == @request
  end

  test "request_to_string/6" do
    assert IBrowse.request_to_string(['http://example.com', [{'Accept-Ranges', 'bytes'}], :get, [], [], 0]) == @request
  end
end
