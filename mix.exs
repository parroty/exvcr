defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.0.1",
      elixir: "~> 0.10.3-dev",
      deps: deps(Mix.env)
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
        {:httpotion, github: "myfreeweb/httpotion"},
        {:excoveralls, github: "parroty/excoveralls"}
      ]
  end

  def deps(:prod) do
    [
      {:meck, github: "eproxus/meck"},
      {:exactor, github: "sasa1977/exactor"},
      {:jsex, github: "talentdeficit/jsex"}
    ]
  end
end
