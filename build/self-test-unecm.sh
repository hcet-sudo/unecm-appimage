#!/usr/bin/env bash
# Self-test for the unecm AppImage:
#   encode the test image with the (CI-built) ecm encoder,
#   decode it back with the unecm AppImage, require bit-identical output.
# Usage: self-test-unecm.sh <unecm-appimage-path> <ecm-encoder-path>
set -euo pipefail

UNECM_APP="$(readlink -f "$1")"
ECM_BIN="$(readlink -f "$2")"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
cd "$T"

# EMU_PREFIX (optional): see self-test-chdman.sh — prefix every AppImage
# invocation (e.g. an emulated baseline x86-64-v1 CPU via qemu-user).
run() { APPIMAGE_EXTRACT_AND_RUN=1 ${EMU_PREFIX:-} "$UNECM_APP" "$@"; }

echo "--- banner ---"
run 2>&1 | head -3 || true

echo "--- generate test image ---"
python3 "$REPO_DIR/build/make-testbin.py" test.bin

echo "--- encode with ecm ---"
"$ECM_BIN" test.bin test.bin.ecm
ls -la test.bin test.bin.ecm

echo "--- decode with unecm AppImage ---"
run test.bin.ecm test.out.bin

if cmp test.bin test.out.bin; then
  echo "UNECM ROUNDTRIP: OK (bit-perfect)"
else
  echo "UNECM ROUNDTRIP: FAILED" >&2
  exit 1
fi

echo "UNECM SELF-TEST PASSED"
