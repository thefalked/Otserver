#!/bin/sh
# Render config.lua from config.lua.template using env vars.
# Docker: CONFIG_TEMPLATE=/ot/config.lua.template CONFIG_OUT=/ot/config.lua
# Host:   ./docker/render-config.sh  (writes server/config.lua)
set -eu

if [ -n "${CONFIG_TEMPLATE:-}" ]; then
	TEMPLATE="$CONFIG_TEMPLATE"
	OUT="${CONFIG_OUT:-/ot/config.lua}"
elif [ -f /ot/config.lua.template ]; then
	TEMPLATE=/ot/config.lua.template
	OUT="${CONFIG_OUT:-/ot/config.lua}"
else
	ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
	TEMPLATE="${CONFIG_TEMPLATE:-$ROOT/server/config.lua.template}"
	OUT="${CONFIG_OUT:-$ROOT/server/config.lua}"
fi

: "${MYSQL_HOST:=mysql}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_USER:=ot}"
: "${MYSQL_PASSWORD:=otserver}"
: "${MYSQL_DATABASE:=ot}"
: "${OT_IP:=127.0.0.1}"

export MYSQL_HOST MYSQL_PORT MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE OT_IP

if ! command -v envsubst >/dev/null 2>&1; then
	echo "render-config: envsubst not found (install gettext / gettext-base)" >&2
	exit 1
fi

if [ ! -f "$TEMPLATE" ]; then
	echo "render-config: template not found: $TEMPLATE" >&2
	exit 1
fi

umask 077
envsubst '$MYSQL_HOST $MYSQL_PORT $MYSQL_USER $MYSQL_PASSWORD $MYSQL_DATABASE $OT_IP' \
	< "$TEMPLATE" > "$OUT"

echo "render-config: wrote $OUT"
