defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.1.1",
      elixir: ">= 0.13.1",
      deps: deps(Mix.env),
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
        {:excoveralls, github: "parroty/excoveralls"},
        {:http_server, github: "parroty/http_server"}
      ]
  end

  def deps(:prod) do
    [
      {:meck, "0.8.1", github: "eproxus/meck"},
      {:exactor, github: "sasa1977/exactor"},
      {:jsex, "~> 2.0", override: true},
      {:exprintf, github: "parroty/exprintf"}
    ]
  end
end
