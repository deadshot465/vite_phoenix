defmodule VitePhoenix.MixProject do
  use Mix.Project

  @version "0.1.3"
  @source_url "https://github.com/deadshot465/vite_phoenix"

  def project do
    [
      app: :vite_phoenix,
      version: @version,
      elixir: "~> 1.10",
      deps: deps(),
      description: description(),
      package: package(),
      docs: [
        source_url: @source_url,
        extras: [
          "README.md",
          "CHANGELOG.md": [filename: "changelog", title: "Change Log"]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {VitePhoenix, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    "An experimental light-weight module to help with integrating Vite into your Phoenix project and watching for any code change in Vite's side."
  end

  defp package do
    [
      name: "vite_phoenix",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
      CHANGELOG*),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "vite" => "https://vitejs.dev/"
      }
    ]
  end
end
