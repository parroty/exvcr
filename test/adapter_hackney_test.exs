defmodule ExVCR.Adapter.HackneyTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "hackney request" do
    use_cassette "hackney_get" do
      {:ok, _status_code, _headers, client} = :hackney.request(:get, "http://www.example.com", [], [], [])
      {:ok, body} = :hackney.body(client)
      assert body =~ %r/Example Domain/
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
      assert HTTPoison.get("http://example.com").body =~ %r/Example Domain/
    end
  end

  test "get with error" do
    use_cassette "httpoison_get_error" do
      assert_raise HTTPoison.HTTPError, fn ->
        HTTPoison.get("http://invalid_url", [])
      end
    end
  end

  test "post method" do
    use_cassette "httpoison_post" do
      assert_response HTTPoison.post("http://httpbin.org/post", "test")
    end
  end

  test "put method" do
    use_cassette "httpoison_put" do
      assert_response HTTPoison.put("http://httpbin.org/put", "test")
    end
  end

  test "patch method" do
    use_cassette "httpoison_patch" do
      assert_response HTTPoison.patch("http://httpbin.org/patch", "test")
    end
  end

  test "delete method" do
    use_cassette "httpoison_delete" do
      assert_response HTTPoison.delete("http://httpbin.org/delete")
    end
  end

  defp assert_response(response, function \\ nil) do
    assert response.status_code == 200
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
