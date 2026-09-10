#!/bin/sh
set -eu
/usr/local/bin/render-config.sh

# Bind-mounted website tree is often root-owned on the host; Apache runs as www-data.
# Ensure runtime cache files are writable so status/counter updates do not 500.
WEBROOT="${APACHE_DOCUMENT_ROOT:-/var/www/html}"
if [ -d "$WEBROOT/config" ]; then
	touch "$WEBROOT/config/serverstatus" "$WEBROOT/usercounter.dat" 2>/dev/null || true
	chown www-data:www-data "$WEBROOT/config/serverstatus" "$WEBROOT/usercounter.dat" 2>/dev/null || true
	chmod 664 "$WEBROOT/config/serverstatus" "$WEBROOT/usercounter.dat" 2>/dev/null || true
fi

# php image default CMD is apache2-foreground; keep compatible with overrides
if [ "$#" -eq 0 ]; then
	exec docker-php-entrypoint apache2-foreground
fi
exec docker-php-entrypoint "$@"
