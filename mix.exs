defmodule ExBlas.MixProject do
  use Mix.Project

  @app :exblas
  @version "0.3.10"
  @source_url "https://github.com/elcritch/exblas"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.7",
      description: description(),
      package: package(),
      source_url: @source_url,
      compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"],
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      build_embedded: true,
      deps: deps(),
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  def application, do: []

  defp description do
    "OpenBlas build for Nerves"
  end

  defp package do
    %{
      files: [
        "lib",
        "src/*.[ch]",
        "src/*.sh",
        "mix.exs",
        "README.md",
        "PORTING.md",
        "LICENSE",
        "CHANGELOG.md",
        "Makefile"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    }
  end

  defp deps() do
    [
      {:ex_doc, "~> 0.22", only: :docs, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "PORTING.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

end
