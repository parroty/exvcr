defmodule ExVCR.Mixfile do
  use Mix.Project

  def project do
    [ app: :exvcr,
      version: "0.8.0",
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
    [ applications: [:http_server] ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  def deps do
    [
      {:meck, "~> 0.8.3"},
      {:exactor, "~> 2.2"},
      {:exjsx, "~> 3.2"},
      {:ibrowse, "~> 4.2.2", optional: true},
      {:httpotion, "~> 3.0", optional: true},
      {:httpoison, "~> 0.8", optional: true},
      {:excoveralls, "~> 0.4", only: :test},
      {:http_server, github: "parroty/http_server", only: [:dev, :test]}
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
