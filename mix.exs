defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exvcr,
      version: "0.11.1",
      elixir: "~> 1.3",
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:meck, :exactor | if(Code.ensure_loaded?(JSX), do: [:exjsx], else: [])]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  def deps do
    [
      {:meck, "~> 0.8"},
      {:exactor, "~> 2.2"},
      {:exjsx, "~> 4.0", optional: true, test: true},
      {:jason, "~> 1.1", optional: true, test: true},
      {:ibrowse, "~> 4.4", optional: true},
      {:httpotion, "~> 3.1", optional: true},
      {:httpoison, "~> 1.0", optional: true},
      {:excoveralls, "~> 0.8", only: :test},
      {:http_server, github: "parroty/http_server", only: [:dev, :test]},
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
      links: %{"GitHub" => "https://github.com/parroty/exvcr"}
    ]
  end
end
