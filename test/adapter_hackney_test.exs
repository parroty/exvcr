defmodule ExVCR.Adapter.HackneyTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    {:ok, _} = HTTPoison.start
    :ok
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

  test "post method" do
    use_cassette "httpoison_post" do
      assert_response HTTPoison.post!("http://httpbin.org/post", "test")
    end
  end

  test "post with form-encoded data" do
    use_cassette "httpoison_post_form" do
      HTTPoison.post!("http://httpbin.org/post", {:form, [key: "value"]}, %{"Content-type" => "application/x-www-form-urlencoded"})
    end
  end

  test "post with multipart data" do
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

  defp assert_response(response, function \\ nil) do
    assert response.status_code == 200
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
