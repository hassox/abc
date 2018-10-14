defmodule Abc.MixProject do
  use Mix.Project

  def project do
    [
      app: :abc,
      version: "0.1.0",
      elixir: "~> 1.7",
      description: description(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ABC.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_stage, "~>0.14"},
      {:swarm, "~>3.3"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description do
    "Event Broadcaster (GenStage + Swarm)"
  end

  defp package do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/hassox/abc"}
    ]
  end
end
