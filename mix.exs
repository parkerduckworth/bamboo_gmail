defmodule BambooGmail.MixProject do
  use Mix.Project

  @source_url "https://github.com/parkerduckworth/bamboo_gmail"

  def project do
    [
      app: :bamboo_gmail,
      version: "0.2.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Bamboo GmailAdapter",
      source_url: @source_url
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
      {:bamboo, "~> 2.1"},
      {:goth, "~> 1.1.0"},
      {:httpoison, "~> 1.6"},
      {:mail, "~> 0.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Gmail adapter for Bamboo"
  end

  defp package do
    [
      maintainers: ["Parker Duckworth"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
