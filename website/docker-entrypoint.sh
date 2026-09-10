#!/bin/sh
set -eu
/usr/local/bin/render-config.sh
exec docker-php-entrypoint apache2-foreground "$@"
