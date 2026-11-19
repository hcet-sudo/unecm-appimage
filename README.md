# unecm — unofficial static AppImage

[![Build and release](https://github.com/hcet-sudo/unecm-appimage/actions/workflows/release.yml/badge.svg)](https://github.com/hcet-sudo/unecm-appimage/actions/workflows/release.yml)

Unofficial, **fully static** AppImage of `unecm` — Neill Corlett's decoder
for ECM (Error Code Modeler) CD-image files — for x86_64 Linux. Static means
no glibc or library requirements whatsoever — it runs on any distribution,
however old or new, including minimal containers and distros without FUSE.

The ECM sources (v1.0, GPL v2+) are vendored in `external/` — ECM has been
frozen for two decades, so there is nothing to track upstream. Companion
repo: [chdman-appimage](https://github.com/hcet-sudo/chdman-appimage) (compresses
the decoded image to `.chd`).

## Install

### With am / appman

```
am -e https://github.com/hcet-sudo/unecm-appimage unecm unecm
```

### Direct download (stable URL)

```
curl -LO https://github.com/hcet-sudo/unecm-appimage/releases/latest/download/unecm-x86_64.AppImage
chmod +x unecm-x86_64.AppImage
```

Without FUSE, run `./unecm-x86_64.AppImage --appimage-extract-and-run ...`.

## Usage

```
./unecm-x86_64.AppImage game.bin.ecm              # writes game.bin
./unecm-x86_64.AppImage game.bin.ecm out.bin      # explicit output name
```

Then compress the result to a `.chd` with
[chdman](https://github.com/hcet-sudo/chdman-appimage):

```
./chdman-x86_64.AppImage createcd -i game.cue -o game.chd
```

## How releases work (pkgforge-style)

The GitHub Actions workflow (`.github/workflows/release.yml`) runs on every
push that touches the build or sources, and on demand (**Actions → Build and
release → Run workflow**):

1. Compiles `unecm` statically from the vendored sources.
2. **Self-tests it** — generates a valid MODE1/2352 CD image, encodes it
   with the `ecm` encoder (built in CI from the same source, not shipped),
   decodes it back with the AppImage, and requires bit-identical results.
3. **ISA-gates it** — the release only publishes if the same bit-perfect
   self-test also passes under `qemu` emulating a **baseline x86-64-v1**
   CPU, so the AppImage runs on every x86_64 CPU, however old.
4. Publishes a release tagged `<ver>@<date>_<epoch>` with the stable asset
   name `unecm-x86_64.AppImage`, so `releases/latest/download/...` always
   points at the newest build.

## Building locally

```
gcc -O2 -Wall -s -static -o unecm external/unecm.c
bash build/build-unecm.sh                     # also packages the AppImage
bash build/self-test-unecm.sh dist/unecm-x86_64.AppImage dist/ecm
```

## Publishing your fork

1. Replace `hcet-sudo` with your GitHub username in this README:
   `grep -rl hcet-sudo . | xargs sed -i 's/hcet-sudo/yourname/g'`.
2. Push the repo to GitHub (terminal or the web UI's "Upload files" flow —
   the workflows invoke scripts via `bash`, so missing execute bits on
   web-uploaded files don't matter).
3. Repo Settings → Actions → General → Workflow permissions → **Read and
   write** (the release job needs write access to publish releases).
4. Test with Actions → "Build and release" → Run workflow.

To make plain `am -i unecm` work for everyone, submit an installation
script to the [AM database](https://github.com/ivan-hc/AM): run
`am -t unecm`, choose the GitHub option, then open a PR adding the
generated script to `programs/x86_64/` and its name to the `x86_64-apps`
list. (As of Nov 2026 there is no unecm entry in the AM database — you
would be the first.)

## License

- ECM sources by Neill Corlett are **GNU GPL v2 or later** (header text in
  `external/ecm.c` / `external/unecm.c`).
- Build scripts and icons in this repo: GPL-2.0-or-later, same license.
