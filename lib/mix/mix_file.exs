defmodule ExVCR.MixFile do
  use Mix.Project

  def project do
    Keyword.merge(Mix.Project.config, [test_coverage: [tool: ExVCR]])
  end
end