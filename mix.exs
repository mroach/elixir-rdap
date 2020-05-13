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
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.3"},
      {:inet_cidr, "~> 1.0"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
