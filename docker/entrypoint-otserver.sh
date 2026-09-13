#!/bin/sh
set -eu
/usr/local/bin/render-config.sh
if [ "$#" -eq 0 ]; then
	# Line-buffer stdout/stderr so docker logs show boot progress live.
	exec stdbuf -oL -eL theforgottenserver
fi
exec "$@"
