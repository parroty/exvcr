defmodule ExVCR.Adapter.HandlerCustomModeTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  test "query param match succeeds with custom mode" do
    use_cassette "response_mocking_with_param", custom: true do
      HTTPotion.get("http://example.com?another_param=456&auth_token=123abc", []).body =~ ~r/Custom Response/
    end
  end

  test "custom with valid response" do
    use_cassette "response_mocking", custom: true do
      assert HTTPotion.get("http://example.com", []).body =~ ~r/Custom Response/
    end
  end

  test "custom response with regexp url" do
    use_cassette "response_mocking_regex", custom: true do
      HTTPotion.get("http://example.com/something/abc", []).body =~ ~r/Custom Response/
    end
  end

  test "custom without valid response throws error" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette "response_mocking", custom: true do
        HTTPotion.get("http://invalidurl.example.com/invalid", [])
      end
    end
  end

  test "custom without valid response file throws error" do
    assert_raise ExVCR.FileNotFoundError, fn ->
      use_cassette "invalid_file_response", custom: true do
        HTTPotion.get("http://example.com", [])
      end
    end
  end

  test "match method succeeds" do
    use_cassette "method_mocking", custom: true do
      HTTPotion.post("http://example.com", []).body =~ ~r/Custom Response/
    end
  end

  test "match method fails" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette "method_mocking", custom: true do
        HTTPotion.put("http://example.com", []).body =~ ~r/Custom Response/
      end
    end
  end
end
