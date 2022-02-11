defmodule Twitter.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/en30/twitter-elixir"

  def project do
    [
      app: :twitter,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:hackney]
      ],
      name: "Twitter",
      source_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:crypto, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:hackney, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  def docs do
    [
      source_ref: "v:#{@version}",
      main: "Twitter"
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
      maintainers: ["en30"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end