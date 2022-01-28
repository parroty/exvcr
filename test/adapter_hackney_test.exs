defmodule ExVCR.Adapter.HackneyTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @port 15009

  setup_all do
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    {:ok, _} = HTTPoison.start
    on_exit fn ->
      HttpServer.stop(@port)
    end
    :ok
  end

  test "passthrough works when CurrentRecorder has an initial state" do
    if ExVCR.Application.global_mock_enabled?() do
      ExVCR.Actor.CurrentRecorder.default_state()
      |> ExVCR.Actor.CurrentRecorder.set()
    end
    url = "http://localhost:#{@port}/server"
    {:ok, status_code, _headers, _body} = :hackney.request(:get, url, [], [], [with_body: true])
    assert status_code == 200
  end

  test "passthrough works after cassette has been used" do
    url = "http://localhost:#{@port}/server"
    use_cassette "hackney_get_localhost" do
      {:ok, status_code, _headers, _body} = :hackney.request(:get, url, [], [], [with_body: true])
      assert status_code == 200
    end
    {:ok, status_code, _headers, _body} = :hackney.request(:get, url, [], [], [with_body: true])
    assert status_code == 200
  end

  test "hackney request" do
    use_cassette "hackney_get" do
      {:ok, status_code, headers, client} = :hackney.request(:get, "http://www.example.com", [], [], [])
      {:ok, body} = :hackney.body(client)
      assert body =~ ~r/Example Domain/
      assert status_code == 200
      assert List.keyfind(headers, "Content-Type", 0) == {"Content-Type", "text/html"}
    end
  end

  test "hackney head request" do
    use_cassette "hackney_head" do
      {:ok, status_code, headers} = :hackney.request(:head, "http://www.example.com", [], [], [])
      assert status_code == 200
      assert List.keyfind(headers, "Content-Type", 0) == {"Content-Type", "text/html"}
    end
  end

  test "hackney request with gzipped response" do
    use_cassette "hackney_get_gzipped" do
      headers = [{"Accept-Encoding", "gzip, deflate"}]
      {:ok, status_code, headers, client} = :hackney.request(:get, "http://www.example.com", headers, [], [])
      {:ok, body} = :hackney.body(client)

      assert status_code == 200
      assert List.keyfind(headers, "Content-Type", 0) == {"Content-Type", "text/html"}

      assert List.keyfind(headers, "Content-Encoding", 0) == {"Content-Encoding", "gzip"}
      decoded_body = :zlib.gunzip(body)
      assert decoded_body =~ ~r/Example Domain/
    end
  end

  test "hackney request with path_encode_fun option" do
    use_cassette "hackney_path_encode_fun" do
      encode_fun = fn(x) -> :hackney_url.pathencode(x) end
      {:ok, status_code, headers, client} =
        :hackney.request(:get, "http://www.example.com", [], [], [path_encode_fun: encode_fun])
      {:ok, body} = :hackney.body(client)
      assert body =~ ~r/Example Domain/
      assert status_code == 200
      assert List.keyfind(headers, "Content-Type", 0) == {"Content-Type", "text/html"}
    end
  end

  test "hackney request with error" do
    use_cassette "error_hackney" do
      {type, _body} = :hackney.request(:get, "http://invalid_url", [], [], [])
      assert type == :error
    end
  end

  test "hackney body request with invalid reference" do
    use_cassette "hackney_invalid_client" do
      {:ok, _status_code, _headers, client} = :hackney.request(:get, "http://www.example.com", [], [], [])
      :hackney.body(client)
      {ret, _body} = :hackney.body(client)
      assert ret == :error
    end
  end

  test "get request" do
    use_cassette "httpoison_get" do
      response = HTTPoison.get!("http://example.com")
      assert response.body =~ ~r/Example Domain/
      assert response.status_code == 200
      assert List.keyfind(response.headers, "Content-Type", 0) == {"Content-Type", "text/html"}
    end
  end

  test "get request with alternate" do
    use_cassette "httpoison_get_alternate", custom: true do
      assert %HTTPoison.Response{body: "Example Domain 1", status_code: 200} = HTTPoison.get!("http://example.com")
      assert %HTTPoison.Response{body: "Example Domain 2", status_code: 200} = HTTPoison.get!("http://example.com")
    end
  end

  test "get with error" do
    use_cassette "httpoison_get_error" do
      assert_raise HTTPoison.Error, fn ->
        HTTPoison.get!("http://invalid_url", [])
      end
    end
  end

  test "get request with basic_auth" do
    use_cassette "httpoison_get_basic_auth" do
      response = HTTPoison.get!("http://example.com", [], [hackney: [basic_auth: {"user", "password"}]])
      assert response.body =~ ~r/Example Domain/
      assert response.status_code == 200
    end
  end

  test "head request" do
    use_cassette "httpoison_head" do
      response = HTTPoison.head!("http://example.com")
      assert response.body == ""
      assert response.status_code == 200
      assert List.keyfind(response.headers, "Content-Type", 0) == {"Content-Type", "text/html"}
    end
  end

  test "post method" do
    use_cassette "httpoison_post" do
      assert_response HTTPoison.post!("http://httpbin.org/post", "test")
    end
  end

  test "post method with ssl option" do
    use_cassette "httpoison_post_ssl" do
      response = HTTPoison.post!("https://example.com", {:form, []}, [], [ssl: [{:versions, [:'tlsv1.2']}]])
      assert response.body =~ ~r/Example Domain/
      assert response.status_code == 200
    end
  end

  test "post with form-encoded data" do
    use_cassette "httpoison_post_form" do
      HTTPoison.post!("http://httpbin.org/post", {:form, [key: "value"]}, %{"Content-type" => "application/x-www-form-urlencoded"})
    end
  end

  test "post with multipart data" do
    File.mkdir_p("tmp/vcr_tmp")
    File.touch!("tmp/vcr_tmp/dummy_file.txt")
    use_cassette "httpoison_mutipart_post" do
      HTTPoison.post!(
        "https://httpbin.org/post",
        {
          :multipart,
          [
            {
              :file,
              "tmp/vcr_tmp/dummy_file.txt",
              { ["form-data"], [name: "\"photo\"", filename: "\"dummy_file.txt\""] },
              []
            }
          ]
        },
        [],
        [recv_timeout: 30000]
      )
    end
  end

  test "put method" do
    use_cassette "httpoison_put" do
      assert_response HTTPoison.put!("http://httpbin.org/put", "test")
    end
  end

  test "patch method" do
    use_cassette "httpoison_patch" do
      assert_response HTTPoison.patch!("http://httpbin.org/patch", "test")
    end
  end

  test "delete method" do
    use_cassette "httpoison_delete" do
      assert_response HTTPoison.delete!("http://httpbin.org/delete")
    end
  end

  test "stub request works for hackney" do
    use_cassette :stub, [url: "http://www.example.com", body: "Stub Response"] do
      {:ok, status_code, headers, client} = :hackney.request(:get, "http://www.example.com", [], [], [])
      {:ok, body} = :hackney.body(client)
      assert body =~ ~r/Stub Response/
      assert status_code == 200
      assert List.keyfind(headers, "Content-Type", 0) == {"Content-Type", "text/html"}
    end
  end

  test "stub request works for HTTPoison" do
    use_cassette :stub, [url: "http://www.example.com", body: "Stub Response"] do
      response = HTTPoison.get!("http://www.example.com")
      assert response.body =~ ~r/Stub Response/
      assert response.status_code == 200
      assert List.keyfind(response.headers, "Content-Type", 0) == {"Content-Type", "text/html"}
    end
  end

  for option <- [:with_body, {:with_body, true}] do
    @option option

    test "request using `#{inspect option}` option" do
      use_cassette "hackney_with_body" do
        {:ok, status_code, headers, body} = :hackney.request(:get, "http://www.example.com", [], [], [@option])
        assert body =~ ~r/Example Domain/
        assert status_code == 200
        assert List.keyfind(headers, "Content-Type", 0) == {"Content-Type", "text/html"}
      end
    end
  end

  defp assert_response(response, function \\ nil) do
    assert response.status_code == 200
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
