#!/bin/sh
set -eu
/usr/local/bin/render-config.sh

# Idempotent DB fixes (initdb scripts do not re-run on existing volumes).
php /usr/local/bin/ensure-schema.php || true

# Bind-mounted website tree is often root/host-owned; Apache runs as www-data.
# Cover every path PHP writes at runtime so Permission denied does not 500 pages.
WEBROOT="${APACHE_DOCUMENT_ROOT:-/var/www/html}"

ensure_dir() {
	_dir="$1"
	mkdir -p "$_dir" 2>/dev/null || true
	if [ -d "$_dir" ]; then
		chown www-data:www-data "$_dir" 2>/dev/null || true
		# Prefer group-writable; fall back to world-writable if chown is a no-op on the mount.
		chmod 775 "$_dir" 2>/dev/null || true
		if [ ! -w "$_dir" ]; then
			chmod 777 "$_dir" 2>/dev/null || true
		fi
	fi
}

ensure_file() {
	_file="$1"
	_parent=$(dirname "$_file")
	ensure_dir "$_parent"
	touch "$_file" 2>/dev/null || true
	if [ -f "$_file" ]; then
		chown www-data:www-data "$_file" 2>/dev/null || true
		chmod 664 "$_file" 2>/dev/null || true
		if [ ! -w "$_file" ]; then
			chmod 666 "$_file" 2>/dev/null || true
		fi
	fi
}

# config/serverstatus — online status cache (config-and-functions.php)
# config/config.ini — install / saveconfig_ini
ensure_dir "$WEBROOT/config"
ensure_file "$WEBROOT/config/serverstatus"
ensure_file "$WEBROOT/config/config.ini"

# Page-view counter
ensure_file "$WEBROOT/usercounter.dat"

# headline.php PNG cache
ensure_dir "$WEBROOT/images/head"

# whoisonline.php temp cache
ensure_dir "$WEBROOT/cache"

# Guild logo uploads (guilds.php)
ensure_dir "$WEBROOT/guilds"

# exaBotDefender (optional; require in index.php is commented out)
ensure_dir "$WEBROOT/bdsave"
i=1
while [ "$i" -le 10 ]; do
	ensure_dir "$WEBROOT/bdsave/$i"
	i=$((i + 1))
done
ensure_file "$WEBROOT/bdsave/day.dat"
ensure_file "$WEBROOT/bdsave/locklog.txt"

# php image default CMD is apache2-foreground; keep compatible with overrides
if [ "$#" -eq 0 ]; then
	exec docker-php-entrypoint apache2-foreground
fi
exec docker-php-entrypoint "$@"
