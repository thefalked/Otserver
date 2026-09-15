#!/bin/sh
set -eu
/usr/local/bin/render-config.sh

# Idempotent DB fixes (initdb scripts do not re-run on existing volumes).
php /usr/local/bin/ensure-schema.php || true

# Bind-mounted paths must stay owned by the *host* deploy user so `git pull` works.
# Never chown www-data on bind mounts (that steals host ownership → Permission denied).
# Make runtime dirs/files writable for Apache (www-data) via mode bits only.
WEBROOT="${APACHE_DOCUMENT_ROOT:-/var/www/html}"

ensure_dir() {
	_dir="$1"
	mkdir -p "$_dir" 2>/dev/null || true
	if [ -d "$_dir" ]; then
		# Prefer group/other write without changing owner.
		chmod 777 "$_dir" 2>/dev/null || chmod 775 "$_dir" 2>/dev/null || true
		if [ ! -w "$_dir" ]; then
			echo "website-entrypoint: $_dir not writable (read-only mount?)" >&2
		fi
	fi
}

ensure_file() {
	_file="$1"
	_parent=$(dirname "$_file")
	ensure_dir "$_parent"
	touch "$_file" 2>/dev/null || true
	if [ -f "$_file" ]; then
		chmod 666 "$_file" 2>/dev/null || chmod 664 "$_file" 2>/dev/null || true
		if [ ! -w "$_file" ]; then
			echo "website-entrypoint: $_file not writable (read-only mount?)" >&2
		fi
	fi
}

# config/serverstatus — online status cache (config-and-functions.php)
# config/config.ini — install / saveconfig_ini
ensure_dir "$WEBROOT/config"
ensure_file "$WEBROOT/config/serverstatus"
ensure_file "$WEBROOT/config/config.ini"

# Page-view counter (under config/ — RW mount; avoids Docker file-bind → dir footgun)
_legacy_counter="$WEBROOT/usercounter.dat"
_counter="$WEBROOT/config/usercounter.dat"
if [ -f "$_legacy_counter" ] && [ ! -f "$_counter" ]; then
	cp -a "$_legacy_counter" "$_counter" 2>/dev/null || true
fi
ensure_file "$_counter"

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
