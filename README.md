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

The fallback is automatic (no config) when no binary matches your platform. You can also
force a source build on a supported platform:

```sh
STEMMERS_BUILD=1 mix deps.compile stemmers
```

In a Docker build that needs the source path, add Rust to the image, e.g.:

```dockerfile
RUN apk add --no-cache build-base   # Alpine
# then install rustup/cargo, or use a base image that already has Rust
```

> Deploying on Fly.io with the default (Debian-based) Elixir image? You're on the glibc
> row above — nothing to install.
