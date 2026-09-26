# AGENTS.md

## What this repo is

Custom [bootc](https://github.com/bootc-dev/bootc) OCI image (Universal Blue `image-template` fork): `Containerfile` derives from `ghcr.io/ublue-os/bluefin-dx:latest`, `build_files/build.sh` installs Traditional Chinese input methods/fonts and GNOME schema overrides, result publishes to `ghcr.io/errchh/bluefin-bubbletea`.

There is no application code and no test suite. The only verification is the GitHub Actions build (`just check` + `podman build`), so check CI after pushing: `gh run list` / `gh run watch`.

## Layout (what actually matters)

- `Containerfile` — build entrypoint. A `scratch AS ctx` stage copies `build_files/` and `system_files/`, then `/ctx/build.sh` runs inside the base image. Ends with `bootc container lint`.
- `build_files/build.sh` — all `dnf5 install` calls, GSettings schema override, `systemctl enable`. First line copies `/ctx/system_files/.` to `/`.
- `system_files/` — declarative overlay copied verbatim into the image (`etc/`, `usr/`, currently empty). Prefer dropping config files here over adding `RUN` steps to the `Containerfile`.
- `image-template.env` — single source of truth for `IMAGE_NAME`, `REPO_ORGANIZATION`, `DEFAULT_TAG`, `BIB_IMAGE`, ArtifactHub metadata. The `Justfile` loads it via `set dotenv-filename`/`dotenv-load`; every recipe reads these vars.
- `Justfile` — all local and CI commands.
- `.github/workflows/build.yml` — container build, rechunk, tag, push, sign. `.github/workflows/build-disk.yml` — qcow2/ISO via bootc-image-builder (manual dispatch).
- `disk_config/` — bootc-image-builder configs (`disk.toml` for qcow2/raw, `iso-gnome.toml`/`iso-kde.toml` for ISOs).

## Commands

```bash
just check          # Justfile format check (first CI step; needs `just` on PATH, not an absolute path)
just lint           # shellcheck over all *.sh (only build_files/build.sh today)
just format         # shfmt --write over all *.sh
just build          # podman build; optional args: just build <image> <tag>
just ostree-rechunk # layer rechunk used by CI; `just rechunk` (chunkah) is the experimental alternative
just build-qcow2 | build-iso | build-raw   # disk images; run-vm-* / spawn-vm to boot them
```

Order that matters: `just check` → `just lint` → push. Nothing else to run locally.

Local prerequisites: `just`, `podman`, `jq`, plus `shellcheck`/`shfmt` for lint/format (see README). They are not guaranteed to be installed on this machine — when they are missing, rely on CI rather than hand-verifying.

## CI behavior (build.yml)

- Triggers: push to `main` (ignores `README.md`-only changes), PRs to `main`, daily cron 10:05 UTC, manual dispatch.
- PRs build but never push or sign — those steps are gated on "not a pull request" **and** "on the default branch". Direct pushes to `main` publish.
- GHCR names are lowercased before use; image name in CI comes from `just image_name` (i.e. `image-template.env`).
- Publishing requires the `SIGNING_SECRET` GitHub secret: a **passwordless** cosign private key (`COSIGN_PASSWORD="" cosign generate-key-pair`). `cosign.pub` in the repo root must match it, or the sign step fails. Never commit `cosign.key` (gitignored).
- Action versions are digest-pinned and maintained by Renovate + Dependabot; don't unpin or re-pin them by hand.

## Gotchas

- `disk_config/iso.toml` does not exist — only `iso-gnome.toml` and `iso-kde.toml`. `just build-iso`/`rebuild-iso`/`run-vm-iso` and the `anaconda-iso` path in `build-disk.yml` reference the missing file, and `build-disk.yml`'s PR path filter does too. ISO builds fail until that path is reconciled.
- The ISO kickstarts in `disk_config/iso-*.toml` still hardcode `bootc switch ... ghcr.io/ublue-os/image-template:latest` (the upstream template image), so an installed system would rebase away from this image.
- `build-disk.yml` sets `IMAGE_NAME` from the GitHub repo name "keep in sync" with `image-template.env`; renaming one without the other breaks disk builds.
- `just build` and `just generate-build-tags` only add git-SHA labels/tags when `git status -s` is empty. A dirty tree silently produces fewer labels/tags — not a bug.
- `just check` is sensitive to the local `just` version: CI (via `extractions/setup-just`) passes with current `just` (1.58.0), while older binaries (e.g. 1.42.4) fail wanting `set dotenv-load := true`. If only that diff appears, upgrade `just` — do not edit the `Justfile` to satisfy an old binary.
- `bootc container lint` emits known non-fatal warnings about leftovers in `/run/dnf` and `/var/lib/dnf/...`; the build still succeeds.
- `README.md` is mostly inherited upstream template docs and is partially stale (e.g. it references `disk_config/iso.toml`). Trust the `Justfile` and workflows over the README.
