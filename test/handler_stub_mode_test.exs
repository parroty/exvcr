defmodule ExVCR.Adapter.HandlerStubModeTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  setup_all do
    Application.ensure_started(:ibrowse)
    :ok
  end

  test "empty options works with default parameters" do
    use_cassette :stub, [] do
      {:ok, status_code, headers, body} = :ibrowse.send_req(~c"http://localhost", [], :get)
      assert status_code == ~c"200"
      assert List.keyfind(headers, ~c"Content-Type", 0) == {~c"Content-Type", ~c"text/html"}
      assert to_string(body) =~ ~r/Hello World/
    end
  end

  test "specified options should match with return values" do
    use_cassette :stub, url: ~c"http://localhost", body: ~c"NotFound", status_code: 404 do
      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://localhost", [], :get)
      assert status_code == ~c"404"
      assert to_string(body) =~ ~r/NotFound/
    end
  end

  test "method name in atom works" do
    use_cassette :stub,
      url: ~c"http://localhost",
      method: :post,
      request_body: ~c"param1=value1&param2=value2" do
      {:ok, status_code, _headers, _body} =
        :ibrowse.send_req(~c"http://localhost", [], :post, ~c"param1=value1&param2=value2")

      assert status_code == ~c"200"
    end
  end

  test "url matches as regardless of query param order" do
    use_cassette :stub, url: "http://localhost?param1=10&param2=20&param3=30" do
      {:ok, status_code, _headers, body} =
        :ibrowse.send_req(~c"http://localhost?param3=30&param1=10&param2=20", [], :get)

      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Hello World/
    end
  end

  test "url matches as regex" do
    use_cassette :stub, url: "~r/.+/" do
      {:ok, status_code, _headers, body} = :ibrowse.send_req(~c"http://localhost", [], :get)
      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Hello World/
    end
  end

  test "request_body matches as string" do
    use_cassette :stub,
      url: ~c"http://localhost",
      method: :post,
      request_body: "some-string",
      body: "Hello World" do
      {:ok, status_code, _headers, body} =
        :ibrowse.send_req(~c"http://localhost", [], :post, ~c"some-string")

      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Hello World/
    end
  end

  test "request_body matches as regex" do
    use_cassette :stub,
      url: ~c"http://localhost",
      method: :post,
      request_body: "~r/param1/",
      body: "Hello World" do
      {:ok, status_code, _headers, body} =
        :ibrowse.send_req(~c"http://localhost", [], :post, ~c"param1=value1&param2=value2")

      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Hello World/
    end
  end

  test "request_body mismatches as regex" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub,
        url: ~c"http://localhost",
        method: :post,
        request_body: "~r/param3/",
        body: "Hello World" do
        {:ok, _status_code, _headers, _body} =
          :ibrowse.send_req(~c"http://localhost", [], :post, ~c"param1=value1&param2=value2")
      end
    end
  end

  test "request_body matches as unordered list of params" do
    use_cassette :stub,
      url: ~c"http://localhost",
      method: :post,
      request_body: "param1=10&param3=30&param2=20",
      body: "Hello World" do
      {:ok, status_code, _headers, body} =
        :ibrowse.send_req(~c"http://localhost", [], :post, ~c"param2=20&param1=10&param3=30")

      assert status_code == ~c"200"
      assert to_string(body) =~ ~r/Hello World/
    end
  end

  test "request_body mismatches as unordered list of params" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub,
        url: ~c"http://localhost",
        method: :post,
        request_body: "param1=10&param3=30&param4=40",
        body: "Hello World" do
        {:ok, _status_code, _headers, _body} =
          :ibrowse.send_req(~c"http://localhost", [], :post, ~c"param2=20&param1=10&param3=30")
      end
    end
  end

  test "request_body mismatch should raise error" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub, url: ~c"http://localhost", method: :post, request_body: ~c'{"one" => 1}' do
        {:ok, _status_code, _headers, _body} = :ibrowse.send_req(~c"http://localhost", [], :post)
      end
    end
  end

  test "post request without request_body definition should ignore request body" do
    use_cassette :stub, url: ~c"http://localhost", method: :post, status_code: 500 do
      {:ok, status_code, _headers, _body} =
        :ibrowse.send_req(~c"http://localhost", [], :post, ~c"param=should_be_ignored")

      assert status_code == ~c"500"
    end
  end

  test "url mismatch should raise error" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub, url: ~c"http://localhost" do
        {:ok, _status_code, _headers, _body} =
          :ibrowse.send_req(~c"http://www.example.com", [], :get)
      end
    end
  end

  test "method mismatch should raise error" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub, url: ~c"http://localhost", method: "post" do
        {:ok, _status_code, _headers, _body} = :ibrowse.send_req(~c"http://localhost", [], :get)
      end
    end
  end
end
