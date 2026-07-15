# stemmers

Snowball stemming for Elixir, backed by the Rust
[`rust-stemmers`](https://github.com/CurrySoftware/rust-stemmers) crate through a
Rustler NIF. Unlike the pure-Elixir `stemmer` package (English only), this supports the
full Snowball language set — **French included** — and is a maintained replacement for
the abandoned `stemex`.

Part of the [search_ash monorepo](../).

```elixir
Stemmers.stem("mangeant", :french)   #=> "mang"
Stemmers.stem("running", :english)   #=> "run"
Stemmers.stem_all(["running", "jumped"], :english)  #=> ["run", "jump"]
Stemmers.supported_languages()       #=> [:arabic, :danish, …, :french, …]
```

## Safety & performance

`rust-stemmers` is safe Rust (no `unsafe`), and Rustler converts any Rust panic into an
Elixir exception, so bad input cannot bring down the BEAM. `stem_all/2` runs on a dirty
CPU scheduler so large batches never stall a normal scheduler thread. Stemming a single
word is a few microseconds — far cheaper than the IPC round-trip a Port would cost.

## Installation

```elixir
def deps do
  [{:stemmers, "~> 0.1"}]
end
```

Precompiled binaries ship for common platforms (Linux gnu/musl and macOS, x86_64 and
aarch64), so **no Rust toolchain is required** to use the library.

A Rust toolchain is only needed to build from source — either on an unsupported
platform, or when you force it:

```sh
STEMMERS_BUILD=1 mix deps.compile stemmers
```

Downloads are verified against a committed checksum file.
