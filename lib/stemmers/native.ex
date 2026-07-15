defmodule Stemmers.Native do
  @moduledoc false
  # Thin NIF binding. Do not call directly — use `Stemmers`, which validates the
  # language and gives a clean error before crossing into the NIF.
  #
  # Distributed as a precompiled binary via RustlerPrecompiled: consumers on a
  # supported platform need no Rust toolchain. Falls back to building from source
  # (requires Rust) when forced via STEMMERS_BUILD, or before a release exists /
  # on an unsupported platform (no committed checksum file yet).
  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :stemmers,
    crate: "stemmers",
    base_url: "https://github.com/nseaSeb/stemmers/releases/download/v#{version}",
    version: version,
    force_build:
      System.get_env("STEMMERS_BUILD") in ["1", "true"] or
        not File.exists?(Path.join(__DIR__, "../../checksum-Elixir.Stemmers.Native.exs"))

  # These clauses only run if the NIF fails to load.
  def stem(_word, _lang), do: :erlang.nif_error(:nif_not_loaded)
  def stem_all(_words, _lang), do: :erlang.nif_error(:nif_not_loaded)
end
