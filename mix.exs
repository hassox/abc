defmodule Abc.MixProject do
  use Mix.Project

  def project do
    [
      app: :abc,
      version: "0.1.0",
      elixir: "~> 1.7",
      license: "MIT",
      description: "Message Broadcaster (GenStage + Swarm)",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end