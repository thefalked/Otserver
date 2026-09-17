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

run_tfs() {
	exec stdbuf -oL -eL theforgottenserver
}

if [ "$(id -u)" -eq 0 ]; then
	mkdir -p /ot/logs /ot/data/logs
	# Named volume /ot/logs. safe to own as otserver.
	chown -R otserver:otserver /ot/logs 2>/dev/null || true
	chown otserver:otserver /ot/config.lua 2>/dev/null || true
	# Bind-mounted data: mode only (keep host uid for git).
	chmod -R a+rwX /ot/data/logs /ot/data/world 2>/dev/null || true
	exec setpriv --reuid=otserver --regid=otserver --init-groups -- stdbuf -oL -eL theforgottenserver
fi

run_tfs
