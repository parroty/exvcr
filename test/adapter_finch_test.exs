defmodule ExVCR.Adapter.FinchTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Finch

  @port 34008

  setup_all do
    HttpServer.start(path: "/server", port: @port, response: "test_response")
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
    {:ok, response} = Finch.build(:get, url) |> Finch.request(ExVCRFinch)
    assert response.status == 200
  end

  test "passthrough works after cassette has been used" do
    url = "http://localhost:#{@port}/server"
    use_cassette "finch_get_localhost" do
      {:ok, response} = Finch.build(:get, url) |> Finch.request(ExVCRFinch)
      assert response.status == 200
    end
    {:ok, response} = Finch.build(:get, url) |> Finch.request(ExVCRFinch)
    assert response.status == 200
  end

  test "example single request" do
    use_cassette "example_finch" do
      {:ok, response} = Finch.build(:get, "http://example.com") |> Finch.request(ExVCRFinch)
      assert response.status == 200
      assert Map.new(response.headers)["content-type"] == "text/html; charset=UTF-8"
      assert response.body =~ ~r/Example Domain/
    end
  end

  test "example multiple requests" do
    use_cassette "example_finch_multiple" do
      {:ok, response} = Finch.build(:get, "http://example.com") |> Finch.request(ExVCRFinch)
      assert response.status == 200
      assert response.body =~ ~r/Example Domain/

      {:ok, response} = Finch.build(:get, "http://example.com/2") |> Finch.request(ExVCRFinch)
      assert response.status == 404
      assert response.body =~ ~r/Example Domain/
    end
  end

  test "single request with error" do
    use_cassette "error_finch" do
      {:error, response} = Finch.build(:get, "http://invalid_url") |> Finch.request(ExVCRFinch)
      assert response == %Mint.TransportError{reason: :nxdomain}
    end
  end

  test "request with HTTPError" do
    use_cassette "finch_httperror", custom: true do
      {:error, response} = Finch.build(:get, "http://example.com/") |> Finch.request(ExVCRFinch)
      assert response == %Mint.HTTPError{module: Mint.HTTP2, reason: :too_many_concurrent_requests}
    end
  end

  test "request with generic timeout error" do
    use_cassette "finch_generic_timeout_error", custom: true do
      {:error, response} = Finch.build(:get, "http://example.com/") |> Finch.request(ExVCRFinch)
      assert response == %{reason: :timeout}
    end
  end

  test "request with generic string error" do
    use_cassette "finch_generic_string_error", custom: true do
      {:error, response} = Finch.build(:get, "http://example.com/") |> Finch.request(ExVCRFinch)
      assert response == %{reason: "some made up error which could happen, in theory"}
    end
  end

  test "request with tuple error" do
    use_cassette "finch_tuple_transport_error", custom: true do
      {:error, response} = Finch.build(:get, "http://example.com/") |> Finch.request(ExVCRFinch)
      assert response == %Mint.TransportError{reason: {:bad_alpn_protocol, "h3"}}
    end
  end

  test "post method" do
    use_cassette "finch_post" do
      assert_response Finch.build(:post, "http://httpbin.org/post", [], "test") |> Finch.request(ExVCRFinch)
    end
  end

  test "put method" do
    use_cassette "finch_put" do
      assert_response Finch.build(:put, "http://httpbin.org/put", [], "test") |> Finch.request(ExVCRFinch, receive_timeout: 10_000)
    end
  end

  test "patch method" do
    use_cassette "finch_patch" do
      assert_response Finch.build(:patch, "http://httpbin.org/patch", [], "test") |> Finch.request(ExVCRFinch)
    end
  end

  test "delete method" do
    use_cassette "finch_delete" do
      assert_response Finch.build(:delete, "http://httpbin.org/delete") |> Finch.request(ExVCRFinch, receive_timeout: 10_000)
    end
  end

  test "get fails with timeout" do
    use_cassette "finch_get_timeout" do
      {:error, error} = Finch.build(:get, "http://example.com") |> Finch.request(ExVCRFinch, receive_timeout: 1)
      assert error == %Mint.TransportError{reason: :timeout}
    end
  end

  test "using recorded cassete, but requesting with different url should return error" do
    use_cassette "example_finch_different" do
      {:ok, response} = Finch.build(:get, "http://example.com") |> Finch.request(ExVCRFinch)
      assert response.status == 200
      assert response.body =~ ~r/Example Domain/
    end

    use_cassette "example_finch_different" do
      assert_raise ExVCR.RequestNotMatchError, ~r/different_from_original/, fn ->
        {:ok, _response} = Finch.build(:get, "http://example.com/different_from_original") |> Finch.request(ExVCRFinch)
      end
    end
  end

  test "stub request works for Finch" do
    use_cassette :stub, [url: "http://example.com/", body: "Stub Response", status_code: 200] do
      {:ok, response} = Finch.build(:get, "http://example.com") |> Finch.request(ExVCRFinch)
      assert response.body =~ ~r/Stub Response/
      assert Map.new(response.headers)["content-type"] == "text/html"
      assert response.status == 200
    end
  end

  test "single request using request!" do
    use_cassette "example_finch" do
      response = Finch.build(:get, "http://example.com") |> Finch.request!(ExVCRFinch)
      assert response.status == 200
      assert Map.new(response.headers)["content-type"] == "text/html; charset=UTF-8"
      assert response.body =~ ~r/Example Domain/
    end
  end

  test "single request with error using request!" do
    use_cassette "error_finch" do
      assert_raise(Mint.TransportError, fn ->
        Finch.build(:get, "http://invalid_url") |> Finch.request!(ExVCRFinch)
      end)
    end
  end

  defp assert_response({:ok, response}, function \\ nil) do
    assert response.status in 200..299
    assert Map.new(response.headers)["connection"] == "keep-alive"
    assert is_binary(response.body)
    unless function == nil, do: function.(response)
  end
end
