Code.require_file "../test_helper.exs", __DIR__

defmodule Mix.Tasks.VcrTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "mix vcr" do
    assert capture_io(fn ->
      Mix.Tasks.Vcr.run([])
    end) =~ %r/Showing list of cassettes/
  end
end
