#!/bin/sh
# H7: start as root only long enough to render config + fix ownership, then
# exec TFS as user otserver (uid 1000) so it is PID 1 and never runs as root.
set -eu

/usr/local/bin/render-config.sh

if [ "$#" -gt 0 ]; then
	exec "$@"
fi

# Line-buffer stdout/stderr so docker logs show boot progress live.
run_tfs() {
	exec stdbuf -oL -eL theforgottenserver
}

if [ "$(id -u)" -eq 0 ]; then
	mkdir -p /ot/logs /ot/data/logs
	# Best-effort: bind mounts may refuse chown on some hosts; still try.
	chown -R otserver:otserver /ot/logs /ot/config.lua 2>/dev/null || true
	chown -R otserver:otserver /ot/data 2>/dev/null || true
	# Become otserver without leaving a root parent (signal-friendly PID 1).
	exec setpriv --reuid=otserver --regid=otserver --init-groups -- stdbuf -oL -eL theforgottenserver
fi

run_tfs
