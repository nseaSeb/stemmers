defmodule Stemmers.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/nseaSeb/stemmers"

  def project do
    [
      app: :stemmers,
      version: @version,
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      description:
        "Snowball stemming for Elixir via a Rust NIF (rust-stemmers). " <>
          "Multilingual, French included. Ships precompiled binaries (no Rust toolchain needed).",
      package: package(),
      docs: docs(),
      source_url: @source_url,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler_precompiled, "~> 0.8"},
      # Kept non-optional so the `force_build` fallback works out of the box on
      # unsupported platforms (and for path-dep dev) without the consumer adding it.
      # `rustler` is a tiny pure-Elixir package; it only invokes `cargo` when actually
      # building, so a precompiled install still needs no Rust toolchain.
      {:rustler, "~> 0.38"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      # The checksum file lets consumers verify the precompiled downloads; the Rust
      # sources let them fall back to building when no binary matches their platform.
      files: [
        "lib",
        "native/stemmers/src",
        "native/stemmers/Cargo.toml",
        "native/stemmers/Cargo.lock",
        "checksum-*.exs",
        "mix.exs",
        "README.md",
        "LICENSE",
        ".formatter.exs"
      ]
    ]
  end

  defp docs do
    [
      main: "Stemmers",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
