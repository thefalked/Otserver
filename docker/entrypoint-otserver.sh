#!/bin/sh
# H7: start as root only long enough to render config + fix *volume* ownership, then
# exec TFS as user otserver (uid 1000) so it is PID 1 and never runs as root.
#
# Do not chown bind-mounted ./server/data. that steals host ownership and breaks git pull.
# Host script scripts/fix-repo-ownership.sh keeps data deploy-owned + writable.
set -eu

/usr/local/bin/render-config.sh

if [ "$#" -gt 0 ]; then
	exec "$@"
fi

# Host bind mounts (preferred) or binaries baked into the image.
tfs_binary() {
	arch="$(uname -m)"
	case "$arch" in
		aarch64 | arm64) suffix=arm64 ;;
		x86_64 | amd64) suffix=amd64 ;;
		*)
			echo "error: unsupported arch: $arch" >&2
			exit 1
			;;
	esac
	for candidate in \
		"/ot/theforgottenserver-${suffix}" \
		"/usr/local/bin/theforgottenserver-${suffix}"; do
		# Docker creates a directory when a bind-mount source is missing.
		if [ -f "$candidate" ] && [ -x "$candidate" ]; then
			printf '%s' "$candidate"
			return 0
		fi
	done
	echo "error: missing theforgottenserver-${suffix} (run ./server/compile.sh)" >&2
	exit 1
}

TFS_BIN="$(tfs_binary)"

if [ "$(id -u)" -eq 0 ]; then
	mkdir -p /ot/logs /ot/data/logs
	# Named volume /ot/logs. safe to own as otserver.
	chown -R otserver:otserver /ot/logs 2>/dev/null || true
	chown otserver:otserver /ot/config.lua 2>/dev/null || true
	# Bind-mounted data: mode only (keep host uid for git).
	chmod -R a+rwX /ot/data/logs /ot/data/world 2>/dev/null || true
	exec setpriv --reuid=otserver --regid=otserver --init-groups -- stdbuf -oL -eL "$TFS_BIN"
fi

exec stdbuf -oL -eL "$TFS_BIN"
