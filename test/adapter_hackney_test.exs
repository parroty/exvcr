defmodule ExVCR.Adapter.HackneyTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    HTTPoison.start
  end

  test "hackney get request" do
    use_cassette "hackney_get" do
      :hackney.start
      {:ok, status_code, headers, client} = :hackney.request(:get, "http://www.example.com", [], [], [])
      {:ok, body} = :hackney.body(client)
      assert body =~ %r/Example Domain/
    end
  end

  test "get request" do
    use_cassette "httpoison_get" do
      assert HTTPoison.get("http://example.com").body =~ %r/Example Domain/
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

  defp assert_response(response, function // nil) do
    assert response.status_code == 200
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
