defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.1.6",
      elixir: "~> 0.13.3",
      deps: deps(Mix.env),
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
  def deps(:test) do
    deps(:dev)
  end

  def deps(:dev) do
    deps(:prod) ++
      [
        {:ibrowse, github: "cmullaparthi/ibrowse", ref: "866b0ff5aca229f1ef53653eabc8ed1720c13cd6", override: true},
        {:httpotion, github: "myfreeweb/httpotion"},
        {:httpoison, github: "edgurgel/httpoison"},
        {:excoveralls, "~> 0.2.1"},
        {:http_server, github: "parroty/http_server"}
      ]
  end

  def deps(:prod) do
    [
      {:meck, "0.8.1", github: "eproxus/meck"},
      {:exactor, "~> 0.3"},
      {:jsex, "~> 2.0"},
      {:exprintf, "~> 0.1"}
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
