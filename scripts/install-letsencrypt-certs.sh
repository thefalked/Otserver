#!/usr/bin/env bash
# Copy a Let's Encrypt live cert into the nginx bind-mount and reload nginx.
#
# Why copy instead of mounting /etc/letsencrypt: the container only sees
# docker/nginx/certs. Host symlinks into /etc/letsencrypt would be dangling
# inside the container. Hawser (VPS overlay) mounts the same dir for TLS.
#
# Certbot calls this as a deploy hook with RENEWED_LINEAGE set. You can also
# run it by hand after `certbot certonly`.
#
# Reload (not restart) so existing HTTP/HTTPS connections drain; game TCP
# streams through nginx are only dropped if that worker is recycled, which
# is still far cheaper than bouncing the OT process. If reload fails (e.g.
# old nginx.conf that required otserver DNS at load time), fall back to a
# container restart so the new pems are still picked up.
# Hawser does not hot-reload certs — restart it when present so renewals apply.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CERT_DIR="${REPO_ROOT}/docker/nginx/certs"
CONTAINER="${NGINX_CONTAINER:-otserver-nginx}"
HAWSER_CONTAINER="${HAWSER_CONTAINER:-otserver-hawser}"

if [ -n "${RENEWED_LINEAGE:-}" ]; then
	LIVE="${RENEWED_LINEAGE}"
else
	ENV_FILE="${REPO_ROOT}/.env"
	SITE_DOMAIN=""
	if [ -f "${ENV_FILE}" ]; then
		SITE_DOMAIN="$(grep -E '^SITE_DOMAIN=' "${ENV_FILE}" | tail -n1 | cut -d= -f2-)"
		case "${SITE_DOMAIN}" in
			\"*\") SITE_DOMAIN="${SITE_DOMAIN#\"}"; SITE_DOMAIN="${SITE_DOMAIN%\"}" ;;
			\'*\') SITE_DOMAIN="${SITE_DOMAIN#\'}"; SITE_DOMAIN="${SITE_DOMAIN%\'}" ;;
		esac
	fi
	if [ -z "${SITE_DOMAIN}" ]; then
		echo "SITE_DOMAIN is not set and RENEWED_LINEAGE is empty." >&2
		exit 1
	fi
	LIVE="/etc/letsencrypt/live/${SITE_DOMAIN}"
fi

if [ ! -f "${LIVE}/fullchain.pem" ] || [ ! -f "${LIVE}/privkey.pem" ]; then
	echo "Let's Encrypt files not found in ${LIVE}" >&2
	exit 1
fi

mkdir -p "${CERT_DIR}"
# install(1) does an atomic replace so nginx never reads a half-written pem.
install -m 644 "${LIVE}/fullchain.pem" "${CERT_DIR}/fullchain.pem"
install -m 600 "${LIVE}/privkey.pem" "${CERT_DIR}/privkey.pem"
# Renew as root can leave root-owned pems; keep the certs dir owner (sudo user).
if [ -d "${CERT_DIR}" ]; then
	chown --reference="${CERT_DIR}" "${CERT_DIR}/fullchain.pem" "${CERT_DIR}/privkey.pem" 2>/dev/null \
		|| chown "$(stat -c '%u:%g' "${CERT_DIR}")" "${CERT_DIR}/fullchain.pem" "${CERT_DIR}/privkey.pem" || true
fi

if ! docker ps -q -f "name=^${CONTAINER}$" | grep -q .; then
	echo "Installed cert from ${LIVE} (${CONTAINER} not running; it will pick this up on start)"
	exit 0
fi

reload_nginx() {
	docker exec "${CONTAINER}" nginx -t >/dev/null 2>&1 \
		&& docker exec "${CONTAINER}" nginx -s reload
}

restart_hawser_if_running() {
	if docker ps -q -f "name=^${HAWSER_CONTAINER}$" | grep -q .; then
		docker restart "${HAWSER_CONTAINER}" >/dev/null
		echo "Restarted ${HAWSER_CONTAINER} to pick up new certs"
	fi
}

if reload_nginx; then
	echo "Installed cert from ${LIVE} and reloaded ${CONTAINER}"
	restart_hawser_if_running
	exit 0
fi

echo "nginx reload failed (often: upstream not in Docker DNS yet). Restarting ${CONTAINER}..." >&2
docker restart "${CONTAINER}" >/dev/null
# Brief wait so compose health / listeners come back.
for _i in 1 2 3 4 5 6 7 8 9 10; do
	if docker ps -q -f "name=^${CONTAINER}$" | grep -q .; then
		echo "Installed cert from ${LIVE} and restarted ${CONTAINER}"
		restart_hawser_if_running
		exit 0
	fi
	sleep 1
done

echo "Cert files are in ${CERT_DIR}, but ${CONTAINER} did not come back. Check: docker compose ps" >&2
exit 1
