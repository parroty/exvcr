defmodule ExVCR.MockTest do
  use ExUnit.Case
  import ExVCR.Mock

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes", "fixture/custom_cassettes")
    :ok
  end

  test "example single request" do
    use_cassette "example_ibrowse" do
      :ibrowse.start
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert iolist_to_binary(body) =~ %r/Example Domain/
    end
  end

  test "example multiple requests" do
    use_cassette "example_ibrowse_multiple" do
      :ibrowse.start
      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com', [], :get)
      assert status_code == '200'
      assert iolist_to_binary(body) =~ %r/Example Domain/

      {:ok, status_code, _headers, body} = :ibrowse.send_req('http://example.com/2', [], :get)
      assert status_code == '404'
      assert iolist_to_binary(body) =~ %r/Example Domain/
    end
  end

  test "httpotion" do
    use_cassette "example_httpotion" do
      assert HTTPotion.get("http://example.com", []).body =~ %r/Example Domain/
    end
  end

  test "post method" do
    use_cassette "httpotion_post" do
      assert_response HTTPotion.post("http://httpbin.org/post", "test")
    end
  end

  test "put method" do
    use_cassette "httpotion_put" do
      assert_response HTTPotion.put("http://httpbin.org/put", "test")
    end
  end

  test "patch method" do
    use_cassette "httpotion_patch" do
      assert_response HTTPotion.patch("http://httpbin.org/patch", "test")
    end
  end

  test "delete method" do
    use_cassette "httpotion_delete" do
      assert_response HTTPotion.delete("http://httpbin.org/delete")
    end
  end

  test "response mocking with custom response" do
    use_cassette "response_mocking", custom: true do
      assert HTTPotion.get("http://example.com", []).body =~ %r/Custom Response/
    end
  end


  defp assert_response(response, function // nil) do
    assert response.success?(:extra)
    assert response.headers[:Connection] == "keep-alive"
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
