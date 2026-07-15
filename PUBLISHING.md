# Publishing `stemmers` to Hex

Everything in the repo is prepared. These are the steps that need **your** GitHub /
Hex authentication — run them yourself (in Claude Code, prefix with `!` so the output
comes back into the session, e.g. `! gh auth status`).

Prerequisites: `gh` logged in (`gh auth login`) and a Hex account
(`mix hex.user register` / `mix hex.user auth`).

## 1. Create the public repo and push

```sh
cd stemmers
gh repo create nseaSeb/stemmers --public --source=. --remote=origin --push
```

(The `base_url` in `mix.exs` already points at `github.com/nseaSeb/stemmers`.)

## 2. Dry-run the build matrix BEFORE tagging  ← do not skip

The workflow uploads build artifacts on every run but only creates a GitHub Release on
a tag. So trigger it manually first to confirm all six targets (incl. the musl /
aarch64 cross-builds) compile, **without** burning the version:

```sh
gh workflow run "Build precompiled NIFs"
gh run watch   # wait for the 6 jobs to go green
```

If a job fails, fix it and re-dispatch. Only proceed once all six are green.

## 3. Tag the release → Actions builds + uploads the binaries

```sh
git tag v0.1.0
git push origin v0.1.0
```

This runs the workflow again and, because it's a tag, attaches the precompiled
`.so`/tarballs to a `v0.1.0` GitHub Release.

## 4. Generate and commit the checksum file

Consumers verify downloads against this file — it **must** be in the published package
(it's already in the `files` list; `mix hex.build` currently refuses to build until it
exists, which is the reminder).

```sh
mix rustler_precompiled.download Stemmers.Native --all --print
git add checksum-Elixir.Stemmers.Native.exs
git commit -m "Add precompiled checksums for v0.1.0"
git push
```

## 5. Publish to Hex

```sh
mix hex.build      # should now succeed (checksum present) — review the file list
mix hex.publish    # pushes the package + docs to hexdocs.pm
```

Done — `{:stemmers, "~> 0.1"}` now works for anyone, no Rust toolchain required.

---

## Note on `search_core` / `search_ash`

Those two repos are committed with `{:stemmers, path: "../stemmers"}`, so they build
locally (sibling folders) but a **standalone clone will not build** until you flip that
dependency to the published `{:stemmers, "~> 0.1"}`. That switch happens when you
publish them (phase 3), after the global-search work stabilises — it is not a mistake
in the current state.

## If a build ever comes from source unexpectedly

`lib/stemmers/native.ex` forces a source build when `STEMMERS_BUILD=1` **or** when the
checksum file is absent. If a consumer reports an unexpected Rust build, check that the
checksum file shipped in the package.
