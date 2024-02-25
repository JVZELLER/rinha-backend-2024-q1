defmodule RinhaBackend.MixProject do
  use Mix.Project

  def project do
    [
      app: :rinha_backend,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RinhaBackend.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp releases do
    [
      rinha_backend: [
        applications: [runtime_tools: :permanent]
      ]
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Database
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},

      # JSON parser
      {:jason, "~> 1.4.1"},

      # Web Server
      {:plug_cowboy, "~> 2.0"},
      {:bandit, "~> 1.0"}
    ]
  end
end
