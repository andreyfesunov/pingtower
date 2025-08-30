defmodule PingWorkers.MixProject do
  use Mix.Project

  def project do
    [
      app: :ping_workers,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PingWorkers.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "2.7.4"},
      {:jason, "1.4.4"},
      {:uuid, "1.1.8"},
      {:dialyxir, "1.4.6", only: [:dev], runtime: false},
      {:credo, "1.7.12", only: [:dev, :test], runtime: false}
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :underspecs,
        :unknown,
        :unmatched_returns
      ]
    ]
  end
end
