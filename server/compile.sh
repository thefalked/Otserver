#!/usr/bin/env bash
# Compile TFS 0.4 once and save the Linux binary next to data/mods (replaces Baiak-Map.exe).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/src"
OUT="$ROOT/server/theforgottenserver"
IMAGE="${OTSERVER_BUILDER_IMAGE:-otserver-builder:local}"

if [[ ! -d "$SRC" ]]; then
	echo "error: sources not found at $SRC" >&2
	exit 1
fi

echo "Building TFS from $SRC ..."
docker build --target builder -t "$IMAGE" "$SRC"

cid="$(docker create "$IMAGE")"
cleanup() { docker rm -f "$cid" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker cp "$cid:/src/theforgottenserver" "$OUT"
chmod +x "$OUT"
file "$OUT"
ls -lh "$OUT"
echo "Saved: $OUT"
