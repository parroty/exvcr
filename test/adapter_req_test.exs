defmodule ExVCR.Adapter.ReqTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Req

  alias ExVCR.Actor.CurrentRecorder

  @port 34_008

  setup_all do
    HttpServer.start(path: "/server", port: @port, response: "test_response")

    on_exit(fn ->
      HttpServer.stop(@port)
    end)

    :ok
  end

  test "passthrough works when CurrentRecorder has an initial state" do
    if ExVCR.Application.global_mock_enabled?() do
      CurrentRecorder.set(CurrentRecorder.default_state())
    end

    url = "http://localhost:#{@port}/server"
    {:ok, response} = Req.get(url)
    assert response.status == 200
  end

  test "passthrough works after cassette has been used" do
    url = "http://localhost:#{@port}/server"

    use_cassette "req_get_localhost" do
      {:ok, response} = Req.get(url)
      assert response.status == 200
    end

    {:ok, response} = Req.get(url)
    assert response.status == 200
  end

  test "example single request" do
    use_cassette "example_req" do
      {:ok, response} = Req.get("http://example.com")
      assert response.status == 200
      assert Map.new(response.headers)["content-type"] == ["text/html; charset=UTF-8"]
      assert response.body =~ ~r/Example Domain/
    end
  end

  test "example multiple requests" do
    use_cassette "example_req_multiple" do
      {:ok, response} = Req.get("http://example.com")
      assert response.status == 200
      assert response.body =~ ~r/Example Domain/

      {:ok, response} = Req.get("http://example.com/2")
      assert response.status == 404
      assert response.body =~ ~r/Example Domain/
    end
  end

  test "single request with error" do
    use_cassette "error_req" do
      {:error, response} = Req.get("http://invalid_url")
      assert response == %Req.TransportError{reason: :nxdomain}
    end
  end

  test "request with HTTPError" do
    use_cassette "req_httperror", custom: true do
      {:error, response} = Req.get("http://example.com/")

      assert response == %Mint.HTTPError{
               module: Mint.HTTP2,
               reason: :too_many_concurrent_requests
             }
    end
  end

  test "request with generic timeout error" do
    use_cassette "req_generic_timeout_error", custom: true do
      {:error, response} = Req.get("http://example.com/")
      assert response == %{reason: :timeout}
    end
  end

  test "request with generic string error" do
    use_cassette "req_generic_string_error", custom: true do
      {:error, response} = Req.get("http://example.com/", retry: false)
      assert response == %{reason: "some made up error which could happen, in theory"}
    end
  end

  test "request with tuple error" do
    use_cassette "req_tuple_transport_error", custom: true do
      {:error, response} = Req.get("http://example.com/", retry: false)
      assert response == %Req.TransportError{reason: {:bad_alpn_protocol, "h3"}}
    end
  end

  test "post method" do
    use_cassette "req_post" do
      {:ok, response} = Req.post("http://httpbin.org/post", body: "test")
      assert response.status == 200
      assert response.body["data"] == "test"
    end
  end

  test "post method with json body" do
    use_cassette "req_post_map" do
      body = %{
        "name" => "John",
        "age" => 30,
        "city" => "New York",
        "country" => "USA",
        "isMarried" => true,
        "hobbies" => ["reading", "traveling", "swimming"],
        "address" => %{
        "street" => "123 Main St",
        "city" => "Los Angeles",
        "state" => "CA",
        "zip" => "90001"
        },
        "phoneNumbers" => [
          %{
            "type" => "home",
            "number" => "555-555-1234"
          },
          %{
            "type" => "work",
            "number" => "555-555-5678"
          }
        ],
        "favoriteColor" => "blue"
      }

      {:ok, response} = Req.post("http://httpbin.org/post", json: body)
      assert response.status == 200
      assert response.body["json"] == body
    end
  end

  test "put method" do
    use_cassette "req_put" do
      {:ok, response} = Req.put("http://httpbin.org/put", body: "test")
      assert response.status == 200
      assert response.body["data"] == "test"
    end
  end

  test "patch method" do
    use_cassette "req_patch" do
      {:ok, response} = Req.patch("http://httpbin.org/patch", body: "test")
      assert response.status == 200
      assert response.body["data"] == "test"
    end
  end

  test "delete method" do
    use_cassette "req_delete" do
      {:ok, response} = Req.delete("http://httpbin.org/delete")
      assert response.status == 200
    end
  end

  test "get fails with timeout" do
    use_cassette "req_get_timeout" do
      {:error, error} = Req.get("http://example.com", receive_timeout: 1)
      assert error == %Req.TransportError{reason: :timeout}
    end
  end

  test "using recorded cassette, but requesting with different url should return error" do
    use_cassette "example_req_different" do
      {:ok, response} = Req.get("http://example.com")
      assert response.status == 200
      assert response.body =~ ~r/Example Domain/
    end

    use_cassette "example_req_different" do
      assert_raise ExVCR.RequestNotMatchError, ~r/different_from_original/, fn ->
        Req.get("http://example.com/different_from_original")
      end
    end
  end

  test "stub request works for Req" do
    use_cassette :stub, [url: "http://example.com", body: "Stub Response"] do
      {:ok, response} = Req.get("http://example.com")
      assert response.body == "Stub Response"
    end
  end
end
