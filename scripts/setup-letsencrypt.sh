#!/usr/bin/env bash
# Issue (or renew) a Let's Encrypt certificate for SITE_DOMAIN.
#
# Why a separate script: HTTP-01 needs nginx already publishing port 80 with
# the ACME location, and DNS must already point at this VPS. setup-vps.sh
# usually runs before either is true, so it only installs certbot + the hook.
#
# Run as root, after `docker compose up -d` and after the domain's A/AAAA
# record points here:
#   sudo bash scripts/setup-letsencrypt.sh
#
# Uses webroot (no nginx stop). A self-signed cert is replaced in
# docker/nginx/certs; nginx is reloaded, not restarted.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root: sudo bash scripts/setup-letsencrypt.sh" >&2
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
ACME_ROOT="${REPO_ROOT}/docker/nginx/acme"
CONTAINER="${NGINX_CONTAINER:-otserver-nginx}"

if [ ! -f "${ENV_FILE}" ]; then
	echo "Missing ${ENV_FILE}." >&2
	exit 1
fi

env_val() {
	local raw
	raw="$(grep -E "^${1}=" "${ENV_FILE}" | tail -n1 | cut -d= -f2-)"
	case "${raw}" in
		\"*\") raw="${raw#\"}"; raw="${raw%\"}" ;;
		\'*\') raw="${raw#\'}"; raw="${raw%\'}" ;;
	esac
	printf '%s' "${raw}"
}

SITE_DOMAIN="$(env_val SITE_DOMAIN)"
LETSENCRYPT_EMAIL="$(env_val LETSENCRYPT_EMAIL)"

if [ -z "${SITE_DOMAIN}" ] || [ "${SITE_DOMAIN}" = "localhost" ]; then
	echo "Set SITE_DOMAIN in .env to a public hostname (not localhost)." >&2
	exit 1
fi
if echo "${SITE_DOMAIN}" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
	echo "Let's Encrypt does not issue certificates for raw IP addresses. Use a DNS name." >&2
	exit 1
fi

if [ -z "${LETSENCRYPT_EMAIL}" ]; then
	if [ ! -e /dev/tty ]; then
		echo "LETSENCRYPT_EMAIL is empty in .env and there is no TTY to prompt." >&2
		exit 1
	fi
	printf 'Let'\''s Encrypt account email: ' > /dev/tty
	IFS= read -r LETSENCRYPT_EMAIL < /dev/tty
fi
if [ -z "${LETSENCRYPT_EMAIL}" ]; then
	echo "An email is required (expiry notices)." >&2
	exit 1
fi

if ! command -v certbot >/dev/null 2>&1; then
	echo "certbot is not installed. Re-run scripts/setup-vps.sh or: apt-get install -y certbot" >&2
	exit 1
fi

if [ -z "$(docker ps -q -f "name=^${CONTAINER}$")" ]; then
	echo "${CONTAINER} is not running. Start the stack (port 80 must be published) first." >&2
	exit 1
fi

if command -v getent >/dev/null 2>&1; then
	if ! getent ahosts "${SITE_DOMAIN}" >/dev/null 2>&1; then
		echo "Warning: ${SITE_DOMAIN} does not resolve yet. Certbot will likely fail until DNS points here." >&2
	fi
fi

mkdir -p "${ACME_ROOT}"

echo "Requesting a certificate for ${SITE_DOMAIN} (webroot ${ACME_ROOT})"
echo "If this fails: DNS A/AAAA for ${SITE_DOMAIN} must point at this VPS, and port 80 must be reachable from the internet."

certbot certonly \
	--webroot \
	--webroot-path "${ACME_ROOT}" \
	-d "${SITE_DOMAIN}" \
	--email "${LETSENCRYPT_EMAIL}" \
	--agree-tos \
	--non-interactive \
	--keep-until-expiring \
	--deploy-hook "${REPO_ROOT}/scripts/install-letsencrypt-certs.sh"

# certonly --deploy-hook runs on success; call again in case the hook path
# was missing on an older install.
"${REPO_ROOT}/scripts/install-letsencrypt-certs.sh"

echo
echo "HTTPS should now serve a public certificate for https://${SITE_DOMAIN}/"
echo "Renewal: certbot.timer (twice daily). The deploy hook reloads nginx."
