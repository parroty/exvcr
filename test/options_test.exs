defmodule ExVCR.Adapter.OptionsTest do
  defmodule All do
    use ExVCR.Mock, options: [clear_mock: true]
    use ExUnit.Case, async: false

    @port 34003
    @url "http://localhost:#{@port}/server"

    setup_all do
      HTTPotion.start
      :ok
    end

    test "clear_mock option for use ExVCR.Mock works" do
      HttpServer.start(path: "/server", port: @port, response: "test_response1")
      use_cassette "option_clean_all" do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
      HttpServer.stop(@port)

      # this method should not be mocked (should not return test_response1).
      HttpServer.start(path: "/server", port: @port, response: "test_response2")
      assert HTTPotion.get(@url, []).body == "test_response2"
      HttpServer.stop(@port)

      use_cassette "option_clean_all" do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
    end
  end

  defmodule Each do
    use ExVCR.Mock
    use ExUnit.Case, async: false

    @port 34004
    @url "http://localhost:#{@port}/server"

    setup_all do
      HTTPotion.start
      :ok
    end

    test "clear_mock option for use_cassette works" do
      HttpServer.start(path: "/server", port: @port, response: "test_response1")
      use_cassette "option_clean_each", clear_mock: true do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
      HttpServer.stop(@port)

      # this method should not be mocked (should not return test_response1).
      HttpServer.start(path: "/server", port: @port, response: "test_response2")
      assert HTTPotion.get(@url, []).body == "test_response2"
      HttpServer.stop(@port)

      use_cassette "option_clean_each" do
        assert HTTPotion.get(@url, []).body == "test_response1"
      end
    end
  end

end

