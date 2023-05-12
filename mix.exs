defmodule ExVCR.Mixfile do
  use Mix.Project

  @source_url "https://github.com/parroty/exvcr"
  @version "0.13.5"

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
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  def application do
    [applications: [:meck, :exactor, :exjsx], mod: {ExVCR.Application, []}]
  end

  def deps do
    [
      {:meck, "~> 0.8"},
      {:exactor, "~> 2.2"},
      {:exjsx, "~> 4.0"},
      {:ibrowse, "4.4.0", optional: true},
      {:httpotion, "~> 3.1", optional: true},
      {:httpoison, "~> 1.0 or ~> 2.0", optional: true},
      {:finch, "~> 0.16", optional: true},
      {:excoveralls, "~> 0.14", only: :test},
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
end
