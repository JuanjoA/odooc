defmodule Odooc.MixProject do
  use Mix.Project

  def project do
    [
      app: :odooc,
      version: "0.2.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      # mod: {Odooc.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:jason, ">= 1.0.0"},
      {:ex_doc, "~> 0.21", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp description() do
    "Elixir module for interacting with the Odoo JSON-RPC API. It defines methods for logging in, search, read (including pagination), create, update, delete records, and executing methods."
  end

  defp package() do
    [
      maintainers: ["Juanjo Algaz"],
      name: "odooc",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/JuanjoA/odooc"},
      description: description(),
      source_url: "https://github.com/elixir-ecto/postgrex"
    ]
  end

end
