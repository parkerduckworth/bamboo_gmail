defmodule BambooGmail.MixProject do
  use Mix.Project

  def project do
    [
      app: :bamboo_gmail,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :bamboo]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bamboo, "~> 1.3"},
      {:goth, "~> 1.1.0"}
    ]
  end
end
