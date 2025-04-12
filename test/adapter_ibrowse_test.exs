defmodule ExVCR.Adapter.IBrowseTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  @port 34011

  setup_all do
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    Application.ensure_started(:ibrowse)

    on_exit(fn ->
      HttpServer.stop(@port)
    end)

    :ok
  end

  test "passthrough works when CurrentRecorder has an initial state" do
    if ExVCR.Application.global_mock_enabled?() do
      ExVCR.Actor.CurrentRecorder.default_state()
      |> ExVCR.Actor.CurrentRecorder.set()
    end

    url = "http://localhost:#{@port}/server" |> to_charlist()
    {:ok, status_code, _headers, _body} = :ibrowse.send_req(url, [], :get)
    assert status_code == ~c"200"
  end

  test "passthrough works after cassette has been used" do
    url = "http://localhost:#{@port}/server" |> to_charlist()

    use_cassette "ibrowse_get_localhost" do
      {:ok, status_code, _headers, _body} = :ibrowse.send_req(url, [], :get)
      assert status_code == ~c"200"
    end

    {:ok, status_code, _headers, _body} = :ibrowse.send_req(url, [], :get)
    assert status_code == ~c"200"
  end

  test "example single request" do
    use_cassette "example_ibrowse" do
      {:ok, status_code, headers, body} = :ibrowse.send_req(~c"http://example.com", [], :get)
      assert status_code == ~c"200"
      assert List.keyfind(headers, ~c"Content-Type", 0) == {~c"Content-Type", ~c"text/html"}
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "example multiple requests" do
    use_cassette "example_ibrowse_multiple" do
      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://example.com", [], :get)
      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Example Domain/

      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://example.com/2", [], :get)
      assert status_code == ~c"404"
      assert to_string(body) =~ ~r/Example Domain/
    end
  end

  test "single request with error" do
    use_cassette "error_ibrowse" do
      response = :ibrowse.send_req(~c"http://invalid_url", [], :get)
      assert response == {:error, {:conn_failed, {:error, :nxdomain}}}
    end
  end

  test "using recorded cassette, but requesting with different url should return error" do
    use_cassette "example_ibrowse_different" do
      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://example.com", [], :get)
      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Example Domain/
    end

    use_cassette "example_ibrowse_different" do
      assert_raise ExVCR.RequestNotMatchError, ~r/different_from_original/, fn ->
        :ibrowse.send_req(~c"http://example.com/different_from_original", [], :get)
      end
    end
  end

  test "stub request works for ibrowse" do
    use_cassette :stub, url: ~c"http://example.com", body: ~c"Stub Response", status_code: 200 do
      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://example.com", [], :get)
      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Stub Response/
    end
  end

  test "stub multiple requests works for ibrowse" do
    stubs = [
      [url: "http://example.com/1", body: "Stub Response 1", status_code: 200],
      [url: "http://example.com/2", body: "Stub Response 2", status_code: 404]
    ]

    use_cassette :stub, stubs do
      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://example.com/1", [], :get)
      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Stub Response 1/

      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://example.com/2", [], :get)
      assert status_code == ~c"404"
      assert to_string(body) =~ ~r/Stub Response 2/
    end
  end
end
