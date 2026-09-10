#!/bin/sh
set -eu
/usr/local/bin/render-config.sh
if [ "$#" -eq 0 ]; then
	exec theforgottenserver
fi
exec "$@"
