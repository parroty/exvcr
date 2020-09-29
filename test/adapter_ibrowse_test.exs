defmodule ExVCR.Adapter.IBrowseTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  @port 34011

  setup_all do
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    Application.ensure_started(:ibrowse)
    on_exit fn ->
      HttpServer.stop(@port)
    end
    :ok
  end


  test "passthrough works after cassette has been used" do
    url = "http://localhost:#{@port}/server" |> to_char_list()
    use_cassette "ibrowse_get_localhost" do
      {:ok, status_code, _headers, _body} = :ibrowse.send_req(url, [], :get)
      assert status_code == '200'
    end
    {:ok, status_code, _headers, _body} = :ibrowse.send_req(url, [], :get)
    assert status_code == '200'
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
      response = HTTPotion.get("http://example.com", [])
      assert response.body =~ ~r/Example Domain/
      assert response.headers[:"Content-Type"] == "text/html"
      assert response.status_code == 200
    end
  end

  test "httpotion error" do
    use_cassette "httpotion_get_error" do
      assert_raise HTTPotion.HTTPError, fn ->
        HTTPotion.get!("http://invalid_url", [])
      end
    end
  end

  test "post method" do
    use_cassette "httpotion_post" do
      assert_response HTTPotion.post("http://httpbin.org/post", [body: "test"])
    end
  end

  test "put method" do
    use_cassette "httpotion_put" do
      assert_response HTTPotion.put("http://httpbin.org/put", [body: "test", timeout: 10000])
    end
  end

  test "patch method" do
    use_cassette "httpotion_patch" do
      assert_response HTTPotion.patch("http://httpbin.org/patch", [body: "test"])
    end
  end

  test "delete method" do
    use_cassette "httpotion_delete" do
      assert_response HTTPotion.delete("http://httpbin.org/delete", [timeout: 10000])
    end
  end

  test "get fails with timeout" do
    assert_raise HTTPotion.HTTPError, fn ->
      use_cassette "httpotion_get_timeout" do
        assert HTTPotion.get!("http://example.com", [timeout: 1])
      end
    end
  end

  test "get request with basic_auth" do
    use_cassette "httpotion_get_basic_auth" do
      response = HTTPotion.get!("http://example.com", [basic_auth: {"user", "password"}])
      assert response.body =~ ~r/Example Domain/
      assert response.status_code == 200
    end
  end

  test "using recorded cassete, but requesting with different url should return error" do
    use_cassette "example_ibrowse_different" do
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert to_string(body) =~ ~r/Example Domain/
    end

    use_cassette "example_ibrowse_different" do
      assert_raise ExVCR.RequestNotMatchError, ~r/different_from_original/, fn ->
        :ibrowse.send_req('http://example.com/different_from_original', [], :get)
      end
    end
  end

  test "stub request works for ibrowse" do
    use_cassette :stub, [url: 'http://example.com', body: 'Stub Response', status_code: 200] do
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert to_string(body) =~ ~r/Stub Response/
    end
  end

  test "stub request works for HTTPotion" do
    use_cassette :stub, [url: "http://example.com", body: "Stub Response", status_code: 200] do
      response = HTTPotion.get("http://example.com", [])
      assert response.body =~ ~r/Stub Response/
      assert response.headers[:"Content-Type"] == "text/html"
      assert response.status_code == 200
    end
  end

  defp assert_response(response, function \\ nil) do
    assert HTTPotion.Response.success?(response, :extra)
    assert response.headers[:Connection] == "keep-alive"
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
