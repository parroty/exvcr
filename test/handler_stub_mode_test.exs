defmodule ExVCR.Adapter.HandlerStubModeTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock

  setup_all do
    :ok
  end

  test "empty options works with default parameters" do
    use_cassette :stub, [] do
      response = Req.get!("http://localhost")
      assert response.status == 200
      assert get_header(response.headers, "content-type") =~ "text/html"
      assert response.body =~ ~r/Hello World/
    end
  end

  test "specified options should match with return values" do
    use_cassette :stub, url: "http://localhost", body: "NotFound", status_code: 404 do
      response = Req.get!("http://localhost")
      assert response.status == 404
      assert response.body =~ ~r/NotFound/
    end
  end

  test "method name in atom works" do
    use_cassette :stub,
      url: "http://localhost",
      method: :post,
      request_body: "param1=value1&param2=value2" do
      response = Req.post!("http://localhost", form: [param1: "value1", param2: "value2"])
      assert response.status == 200
    end
  end

  test "url matches as regardless of query param order" do
    use_cassette :stub, url: "http://localhost?param1=10&param2=20&param3=30" do
      response = Req.get!("http://localhost?param3=30&param1=10&param2=20")
      assert response.status == 200
      assert response.body =~ ~r/Hello World/
    end
  end

  test "url matches as regex" do
    use_cassette :stub, url: "~r/.+/" do
      response = Req.get!("http://localhost")
      assert response.status == 200
      assert response.body =~ ~r/Hello World/
    end
  end

  test "request_body matches as string" do
    use_cassette :stub,
      url: "http://localhost",
      method: :post,
      request_body: "some-string",
      body: "Hello World" do
      response = Req.post!("http://localhost", body: "some-string")
      assert response.status == 200
      assert response.body =~ ~r/Hello World/
    end
  end

  test "request_body matches as regex" do
    use_cassette :stub,
      url: "http://localhost",
      method: :post,
      request_body: "~r/param1/",
      body: "Hello World" do
      response = Req.post!("http://localhost", body: "param1=value1&param2=value2")
      assert response.status == 200
      assert response.body =~ ~r/Hello World/
    end
  end

  test "request_body mismatches as regex" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub,
        url: "http://localhost",
        method: :post,
        request_body: "~r/param3/",
        body: "Hello World" do
        response = Req.post!("http://localhost", body: "param1=value1&param2=value2")
      end
    end
  end

  test "request_body matches as unordered list of params" do
    use_cassette :stub,
      url: "http://localhost",
      method: :post,
      request_body: "param1=10&param3=30&param2=20",
      body: "Hello World" do
      response = Req.post!("http://localhost", form: [param2: "20", param1: "10", param3: "30"])
      assert response.status == 200
      assert response.body =~ ~r/Hello World/
    end
  end

  test "request_body mismatches as unordered list of params" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub,
        url: "http://localhost",
        method: :post,
        request_body: "param1=10&param3=30&param4=40",
        body: "Hello World" do
        response = Req.post!("http://localhost", form: [param2: "20", param1: "10", param3: "30"])
      end
    end
  end

  test "request_body mismatch should raise error" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub, url: "http://localhost", method: :post, request_body: ~s({"one" => 1}) do
        response = Req.post!("http://localhost")
      end
    end
  end

  test "post request without request_body definition should ignore request body" do
    use_cassette :stub, url: "http://localhost", method: :post, status_code: 500 do
      response = Req.post!("http://localhost", form: [param: "should_be_ignored"])
      assert response.status == 500
    end
  end

  test "url mismatch should raise error" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub, url: "http://localhost" do
        response = Req.get!("http://www.example.com")
      end
    end
  end

  test "method mismatch should raise error" do
    assert_raise ExVCR.InvalidRequestError, fn ->
      use_cassette :stub, url: "http://localhost", method: "post" do
        response = Req.get!("http://localhost")
      end
    end
  end

  defp get_header(headers, key) do
    Enum.find_value(headers, fn {k, [v]} -> if k == key, do: v end)
  end
end
