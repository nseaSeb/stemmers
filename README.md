# stemmers

Snowball stemming for Elixir, backed by the Rust
[`rust-stemmers`](https://github.com/CurrySoftware/rust-stemmers) crate through a
Rustler NIF. Supports the full Snowball language set — **French included** — at roughly
0.5µs/word.

Part of the [search_ash monorepo](../), where it is kept as a standalone package.

> **Which stemmer should you use?**
> For most work, prefer [`text_stemmer`](https://hex.pm/packages/text_stemmer): it
> compiles the same canonical Snowball algorithms to pure Elixir, covers more languages
> (33 vs 18), produces **identical output**, and needs no native toolchain or
> precompiled binary. `search_core` uses it.
>
> Reach for `stemmers` when throughput actually matters — it is ~20x faster per word,
> which shows up when bulk-indexing large corpora and nowhere else.

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

### No Rust needed on these platforms (precompiled)

Precompiled binaries ship for the platforms below, so **no Rust/cargo toolchain is
required** — `mix deps.get` just downloads the matching binary (verified against a
committed checksum file):

| Platform | Targets |
| --- | --- |
| Linux (glibc — Debian/Ubuntu, **Fly.io's default image**, …) | `x86_64`, `aarch64` |
| macOS | `x86_64` (Intel), `aarch64` (Apple Silicon) |

### Everywhere else: builds from source (Rust required)

On any other platform there is no prebuilt binary, so the NIF is compiled from the Rust
source at install time — which requires a **Rust toolchain** (`rustup`/`cargo`). This
currently includes:

- **Alpine / musl** (e.g. an `*-alpine` Docker image) — precompiled musl support is
  planned for a later release;
- **Windows**, and any other target not listed above.

On such a platform, build from source by setting the env var (a Rust toolchain must be
present):

```sh
STEMMERS_BUILD=1 mix deps.compile stemmers
```

The same env var forces a source build on a supported platform if you ever need it.

In a Docker build that needs the source path, add Rust to the image, e.g.:

```dockerfile
RUN apk add --no-cache build-base   # Alpine
# then install rustup/cargo, or use a base image that already has Rust
```

> Deploying on Fly.io with the default (Debian-based) Elixir image? You're on the glibc
> row above — nothing to install.
