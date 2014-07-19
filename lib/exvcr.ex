defmodule ExVCR do
  @moduledoc """
  Record and replay HTTP interactions library for elixir.
  It's inspired by Ruby's VCR, and trying to provide similar functionalities.
  """

  @doc """
  This method will be called from [mix vcr.check].
  (either run or start depending on elixir version)
  """
  def start(_compile_path, _opts) do
    fn() ->
      check
    end
  end

  defp check do
    ExVCR.Task.Runner.check_cassettes(ExVCR.Checker.get)
  end
end

