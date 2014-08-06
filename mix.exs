defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.3.0",
      elixir: "~> 0.14.2",
      deps: deps,
      description: description,
      package: package,
      test_coverage: [tool: ExCoveralls]
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
      {:meck, "0.8.2", github: "eproxus/meck"},
      {:exactor, "~> 0.3"},
      {:jsex, "~> 2.0"},
      {:ibrowse, github: "cmullaparthi/ibrowse", optional: true},
      {:httpotion, "~> 0.2", optional: true},
      {:httpoison, github: "edgurgel/httpoison", optional: true},
      {:excoveralls, "~> 0.3", only: :dev},
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
      links: [ { "GitHub", "https://github.com/parroty/exvcr" } ] ]
  end
end
