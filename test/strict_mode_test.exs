defmodule ExVCR.StrictModeTest do
  use ExVCR.Mock
  use ExUnit.Case, async: false

  @dummy_cassette_dir "tmp/vcr_tmp/vcr_cassettes_strict_mode"
  @port 34007
  @url "http://localhost:#{@port}/server"
  @http_server_opts [path: "/server", port: @port, response: "test_response"]

  setup_all do
    File.rm_rf(@dummy_cassette_dir)

    on_exit fn ->
      File.rm_rf(@dummy_cassette_dir)
      HttpServer.stop(@port)
      :ok
    end

    HTTPotion.start
    HttpServer.start(@http_server_opts)
    :ok
  end

  setup do
    ExVCR.Config.cassette_library_dir(@dummy_cassette_dir)
  end

  test "it makes HTTP calls if not set" do
    use_cassette "strict_mode_off", strict_mode: false do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end
  end

  test "it throws an error when set and no cassette recorded" do
    use_cassette "strict_mode_on", strict_mode: true do
      try do
       HTTPotion.get(@url, []).body =~ ~r/test_response/
       assert(false, "Shouldn't get here")
      catch
        "A matching cassette was not found" <> _ -> :ok
        _ -> assert(false, "Encountered unexpected `throw`")
      end
    end
  end

  test "it uses a cassette if it exists" do
    use_cassette "strict_mode_cassette", strict_mode: false do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end

    use_cassette "strict_mode_cassette", strict_mode: true do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end
  end

  test "it does not uses a cassette when override the defaut config" do
    ExVCR.Setting.set(:strict_mode, true)

    use_cassette "strict_mode_cassette", strict_mode: false do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end

    use_cassette "strict_mode_cassette" do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end

    use_cassette "strict_mode_cassette", strict_mode: true do
      assert HTTPotion.get(@url, []).body =~ ~r/test_response/
    end

    ExVCR.Setting.set(:strict_mode, false)
  end
end
