defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.5.2",
      elixir: "~> 1.0",
      deps: deps,
      description: description,
      package: package,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:http_server] ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  def deps do
    [
      {:meck, "~> 0.8.2"},
      {:exactor, "~> 2.1"},
      {:exjsx, "~> 3.2"},
      {:ibrowse, github: "cmullaparthi/ibrowse", optional: true},
      {:httpotion, "~> 2.1", optional: true},
      {:httpoison, "~> 0.7", optional: true},
      {:excoveralls, "~> 0.3", only: :test},
      {:http_server, github: "parroty/http_server", only: [:dev, :test]}
    ]
  end

  defp description do
    """
    HTTP request/response recording library for elixir, inspired by VCR.
    """
  end

  defp package do
    [ contributors: ["parroty"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/parroty/exvcr"} ]
  end
end
