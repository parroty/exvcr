defmodule ExVCR.MixFile do
  use Mix.Project

  def project do
    Keyword.merge(Mix.project, [test_coverage: [tool: ExVCR]])
  end
end