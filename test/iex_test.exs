defmodule ExVCR.IExTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  require ExVCR.IEx

  setup_all do
    :ibrowse.start
    HttpServer.start(path: "/server", port: 37000, response: "test_response")
    :ok
  end

  test "print request/response" do
    assert capture_io(fn ->
      ExVCR.IEx.print do
        :ibrowse.send_req('http://localhost:37000/server', [], :get)
      end
    end) =~ ~r/\"body\": \"test_response\"/
  end
end
