defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.0.1",
      elixir: "~> 0.10.3-dev",
      deps: deps(Mix.env),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application
  def application do
    []
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
        {:excoveralls, github: "parroty/excoveralls"}
      ]
  end

  def deps(:prod) do
    [
      {:meck, "0.8.1", [github: "eproxus/meck", tag: "0.8.1"]},
      {:exactor, github: "sasa1977/exactor"},
      {:jsex, github: "talentdeficit/jsex"},
      {:exprintf, github: "parroty/exprintf"}
    ]
  end
end
