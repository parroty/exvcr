defmodule ExVCR.Adapter.IBrowseTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock

  setup_all do
    Application.ensure_started(:ibrowse)
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "example single request" do
    use_cassette "example_ibrowse" do
      {:ok, status_code, headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert List.keyfind(headers, 'Content-Type', 0) == {'Content-Type', 'text/html'}
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "example multiple requests" do
    use_cassette "example_ibrowse_multiple" do
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert to_string(body) =~ ~r/Example Domain/

      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com/2', [], :get)
      assert status_code == '404'
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "single request with error" do
    use_cassette "error_ibrowse" do
      response = :ibrowse.send_req('http://invalid_url', [], :get)
      assert response == {:error, {:conn_failed, {:error, :nxdomain}}}
    end
  end

  test "httpotion" do
    use_cassette "example_httpotion" do
      HTTPotion.start
      response = HTTPotion.get("http://example.com", [])
      assert response.body =~ ~r/Example Domain/
      assert response.headers[:"Content-Type"] == "text/html"
    end
  end

  test "httpotion error" do
    use_cassette "httpotion_get_error" do
      assert_raise HTTPotion.HTTPError, fn ->
        HTTPotion.get("http://invalid_url", [])
      end
    end
  end

  test "post method" do
    use_cassette "httpotion_post" do
      assert_response HTTPotion.post("http://httpbin.org/post", "test")
    end
  end

  test "put method" do
    use_cassette "httpotion_put" do
      assert_response HTTPotion.put("http://httpbin.org/put", "test", [timeout: 10000])
    end
  end

  test "patch method" do
    use_cassette "httpotion_patch" do
      assert_response HTTPotion.patch("http://httpbin.org/patch", "test")
    end
  end

  test "delete method" do
    use_cassette "httpotion_delete" do
      assert_response HTTPotion.delete("http://httpbin.org/delete", [], [timeout: 10000])
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
      HTTPotion.post("http://example.com", "").body =~ ~r/Custom Response/
    end
  end

  test "match method fails" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette "method_mocking", custom: true do
        HTTPotion.put("http://example.com", "").body =~ ~r/Custom Response/
      end
    end
  end

  test "get fails with timeout" do
    assert_raise HTTPotion.HTTPError, fn ->
      use_cassette "httpotion_get_timeout" do
        assert HTTPotion.get("http://example.com", [], [timeout: 1])
      end
    end
  end

  test "using recorded cassete, but requesting with different url should return error" do
    use_cassette "example_ibrowse_different" do
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert to_string(body) =~ ~r/Example Domain/
    end

    use_cassette "example_ibrowse_different" do
      assert_raise ExVCR.RequestNotMatchError, fn ->
        :ibrowse.send_req('http://example.com/different_from_original', [], :get)
      end
    end
  end

  defp assert_response(response, function \\ nil) do
    assert HTTPotion.Response.success?(response, :extra)
    assert response.headers[:Connection] == "keep-alive"
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
