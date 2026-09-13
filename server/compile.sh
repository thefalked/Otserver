#!/usr/bin/env bash
# Optional: compile TFS 0.4 and copy the binary to server/theforgottenserver.
# docker compose build otserver compiles inside the image for the target arch;
# you do not need this file on the VPS.
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
