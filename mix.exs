defmodule Tw.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/en30/tw"

  def project do
    [
      app: :tw,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:jason, :hackney, :ex_unit]
      ],
      name: "Tw",
      source_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:crypto, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2", optional: true},
      {:hackney, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  def docs do
    [
      source_ref: "v:#{@version}",
      main: "Tw"
    ]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end

  defp package do
    [
      description: "Twitter API client for elixir.",
      maintainers: ["en30"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
