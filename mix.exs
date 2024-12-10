defmodule ExVCR.MixProject do
  use Mix.Project

  @source_url "https://github.com/parroty/exvcr"
  @version "0.15.2"

  def project do
    [
      app: :exvcr,
      version: @version,
      source_url: @source_url,
      elixir: "~> 1.3",
      deps: deps(),
      docs: docs(),
      description: description(),
      package: package(),
      compilers: [:yecc, :leex] ++ Mix.compilers(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      applications: [:mimic, :jason, :finch, :req] ++ test_apps(),
      mod: {ExVCR.Application, []}
    ]
  end

  defp test_apps do
    case Mix.env() do
      :test -> [:plug, :bandit]
      _ -> []
    end
  end

  def deps do
    [
      {:mimic, "~> 1.7"},
      {:jason, "~> 1.4"},
      {:finch, "~> 0.18"},
      {:req, "~> 0.5"},
      # {:finch, "~> 0.16", optional: true},
      {:excoveralls, "~> 0.18", only: :test},
      {:styler, "~> 1.2", only: :dev, runtime: false},
      {:bandit, "~> 1.0", only: [:dev, :test]},
      {:plug, "~> 1.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    HTTP request/response recording library for elixir, inspired by VCR.
    """
  end

  defp package do
    [
      maintainers: ["parroty"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/master/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: [
        "CHANGELOG.md",
        "README.md"
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
