#!/usr/bin/env bash
# Build the unecm AppImage (static) from the vendored Neill Corlett ECM sources.
# Also builds the "ecm" encoder binary (used by the self-test; not shipped).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$REPO_DIR/dist"
mkdir -p "$DIST"

CC="${CC:-gcc}"
ECM_VER="1.0"   # per the banner in unecm.c / ecm.c ("format v1.0")

# Force baseline x86-64: GitHub's ubuntu-latest image now defaults to the
# amd64v3 variant, whose gcc compiles with -march=x86-64-v3 — the resulting
# binary dies with SIGILL on older CPUs. Appending LAST makes the flag win.
SHIMDIR="$DIST/cc-shim"
mkdir -p "$SHIMDIR"
for c in gcc g++ cc c++; do
  if command -v "$c" >/dev/null 2>&1; then
    printf '#!/bin/sh\nexec %s "$@" -march=x86-64 -mtune=generic\n' \
      "$(command -v "$c")" > "$SHIMDIR/$c"
    chmod +x "$SHIMDIR/$c"
  fi
done
export PATH="$SHIMDIR:$PATH"

echo "[unecm] compiling (static)"
"$CC" -O2 -Wall -s -static \
  -o "$DIST/unecm" "$REPO_DIR/external/unecm.c"
"$CC" -O2 -Wall -s -static \
  -o "$DIST/ecm" "$REPO_DIR/external/ecm.c"

file "$DIST/unecm"

echo "[unecm] packaging AppImage"
# Invoked via `bash` (see build-chdman.sh): GitHub's web editor stores files
# mode 0644, so direct execution would die with exit 126 "Permission denied".
APP_VERSION="$ECM_VER" bash "$REPO_DIR/build/package-appimage.sh" \
  unecm "$DIST/unecm" \
  "Decode ECM (Error Code Modeler) CD image files" \
  "https://www.neillcorlett.com/ecm/" \
  "unecm-x86_64.AppImage"

echo "$ECM_VER" > "$DIST/unecm.version"
echo "[unecm] done (v$ECM_VER)"
