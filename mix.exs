defmodule RDAP.MixProject do
  use Mix.Project

  def project do
    [
      app: :rdap,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {RDAP, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:inet_cidr, "~> 1.0.0"},
      {:credo, "~> 1.4.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 0.9", only: :dev, runtime: false},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
