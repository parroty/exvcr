defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.8.12",
      elixir: "~> 1.0",
      deps: deps(),
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:meck, :exactor, :exjsx]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  def deps do
    [
      {:meck, "~> 0.8.3"},
      {:exactor, "~> 2.2"},
      {:exjsx, "~> 4.0"},
      {:ibrowse, "~> 4.2.2", optional: true},
      {:httpotion, "~> 3.0", optional: true},
      {:httpoison, "~> 0.11", optional: true},
      {:excoveralls, "~> 0.7", only: :test},
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
    [ maintainers: ["parroty"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/parroty/exvcr"} ]
  end
end
