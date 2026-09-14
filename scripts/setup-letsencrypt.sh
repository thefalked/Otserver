#!/usr/bin/env bash
# Issue (or renew) Let's Encrypt certificates for SITE_DOMAIN and optional
# SITE_MAINTENANCE_DOMAIN as **separate** lineages (no shared SANs).
#
# Why separate: Certificate Transparency publishes every name on a cert.
# Putting public + maintenance on one cert links them for anyone looking.
#
# Run as root, after `docker compose up -d` and after each domain's A/AAAA
# points here:
#   sudo bash scripts/setup-letsencrypt.sh
#
# Uses webroot (no nginx stop). Pems land in docker/nginx/certs/; nginx is
# reloaded. Hawser uses the maintenance pair only.
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

is_public_hostname() {
	local h="$1"
	[ -n "${h}" ] || return 1
	[ "${h}" != "localhost" ] || return 1
	echo "${h}" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' && return 1
	echo "${h}" | grep -Eq '^[a-zA-Z0-9]([a-zA-Z0-9.-]{0,251}[a-zA-Z0-9])?$'
}

SITE_DOMAIN="$(env_val SITE_DOMAIN)"
LETSENCRYPT_EMAIL="$(env_val LETSENCRYPT_EMAIL)"
SITE_MAINTENANCE_DOMAIN="$(env_val SITE_MAINTENANCE_DOMAIN)"
if [ -z "${SITE_MAINTENANCE_DOMAIN}" ]; then
	_aliases="$(env_val SITE_DOMAIN_ALIASES)"
	SITE_MAINTENANCE_DOMAIN="${_aliases%%[, ]*}"
fi

for arg in "$@"; do
	case "${arg}" in
		-h|--help)
			sed -n '2,16p' "$0" | sed 's/^# \?//'
			exit 0
			;;
		*)
			echo "Unexpected argument: ${arg} (domains come from .env)" >&2
			exit 1
			;;
	esac
done

if [ -z "${SITE_DOMAIN}" ] || [ "${SITE_DOMAIN}" = "localhost" ]; then
	echo "Set SITE_DOMAIN in .env to a public hostname (not localhost)." >&2
	exit 1
fi
if ! is_public_hostname "${SITE_DOMAIN}"; then
	echo "SITE_DOMAIN is not a valid public hostname: ${SITE_DOMAIN}" >&2
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

issue_one() {
	local name="$1"
	if command -v getent >/dev/null 2>&1; then
		if ! getent ahosts "${name}" >/dev/null 2>&1; then
			echo "Warning: ${name} does not resolve yet. Certbot will likely fail until DNS points here." >&2
		fi
	fi
	echo "Requesting certificate for ${name} (separate lineage, webroot ${ACME_ROOT})"
	certbot certonly \
		--webroot \
		--webroot-path "${ACME_ROOT}" \
		--cert-name "${name}" \
		-d "${name}" \
		--email "${LETSENCRYPT_EMAIL}" \
		--agree-tos \
		--non-interactive \
		--deploy-hook "${REPO_ROOT}/scripts/install-letsencrypt-certs.sh"
}

mkdir -p "${ACME_ROOT}"

issue_one "${SITE_DOMAIN}"

if [ -n "${SITE_MAINTENANCE_DOMAIN}" ] && [ "${SITE_MAINTENANCE_DOMAIN}" != "${SITE_DOMAIN}" ]; then
	if ! is_public_hostname "${SITE_MAINTENANCE_DOMAIN}"; then
		echo "SITE_MAINTENANCE_DOMAIN is invalid: ${SITE_MAINTENANCE_DOMAIN}" >&2
		exit 1
	fi
	issue_one "${SITE_MAINTENANCE_DOMAIN}"
fi

"${REPO_ROOT}/scripts/install-letsencrypt-certs.sh"

echo
echo "Separate certificates installed:"
echo "  public:      https://${SITE_DOMAIN}/"
if [ -n "${SITE_MAINTENANCE_DOMAIN}" ] && [ "${SITE_MAINTENANCE_DOMAIN}" != "${SITE_DOMAIN}" ]; then
	echo "  maintenance: https://${SITE_MAINTENANCE_DOMAIN}/  (Dockhand :2376)"
fi
echo "Renewal: certbot.timer (twice daily). Deploy hook reloads nginx."
echo
echo "If you previously had one cert with both names as SANs, delete the old"
echo "lineage after confirming the new ones work, e.g.:"
echo "  sudo certbot delete --cert-name OLD_DUAL_NAME"
