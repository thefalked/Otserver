#!/bin/sh
set -eu
/usr/local/bin/render-config.sh
# php image default CMD is apache2-foreground; keep compatible with overrides
if [ "$#" -eq 0 ]; then
	exec docker-php-entrypoint apache2-foreground
fi
exec docker-php-entrypoint "$@"
