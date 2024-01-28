defmodule ExVCR.IExTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO
  require ExVCR.IEx

  @port 34005

  setup_all do
    :ibrowse.start()
    HttpServer.start(path: "/server", port: @port, response: "test_response")
    on_exit fn ->
      HttpServer.stop(@port)
    end
    :ok
  end

  test "print request/response" do
    assert capture_io(fn ->
      ExVCR.IEx.print do
        :ibrowse.send_req('http://localhost:34005/server', [], :get)
      end
    end) =~ ~r/\"body\": \"test_response\"/
  end
end
