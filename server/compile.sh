#!/usr/bin/env bash
# Compile TFS 0.4 for arm64 and amd64 into server/.
# Runtime entrypoint picks the matching binary via uname -m.
# docker compose build otserver only packages these files (no on-host make).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/server"
IMAGE_BASE="${OTSERVER_BUILDER_IMAGE:-otserver-builder}"

if [[ ! -d "$ROOT/src" ]]; then
	echo "error: sources not found at $ROOT/src" >&2
	exit 1
fi

build_one() {
	local platform="$1"
	local suffix="$2"
	local image="${IMAGE_BASE}:${suffix}"
	local out="${OUT_DIR}/theforgottenserver-${suffix}"

	echo "Building TFS (${platform}) ..."
	docker build \
		--platform "$platform" \
		--target builder \
		-f "$ROOT/server/Dockerfile" \
		-t "$image" \
		"$ROOT"

	local cid
	cid="$(docker create --platform "$platform" "$image")"
	docker cp "$cid:/src/theforgottenserver" "$out"
	docker rm -f "$cid" >/dev/null
	chmod +x "$out"
	file "$out"
	ls -lh "$out"
	echo "Saved: $out"
}

build_one linux/arm64 arm64
build_one linux/amd64 amd64

echo "Done. Entrypoint selects theforgottenserver-\$(uname -m) at start."
