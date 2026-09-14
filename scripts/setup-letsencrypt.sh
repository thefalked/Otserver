#!/usr/bin/env bash
# Issue (or renew) a Let's Encrypt certificate for SITE_DOMAIN (+ optional aliases).
#
# Why a separate script: HTTP-01 needs nginx already publishing port 80 with
# the ACME location, and DNS must already point at this VPS. setup-vps.sh
# usually runs before either is true, so it only installs certbot + the hook.
#
# Run as root, after `docker compose up -d` and after each domain's A/AAAA
# record points here:
#   sudo bash scripts/setup-letsencrypt.sh
#   sudo bash scripts/setup-letsencrypt.sh baiakvip9.thefalked.dev   # extra -d
#
# Domains: SITE_DOMAIN, plus SITE_DOMAIN_ALIASES in .env (space/comma-separated),
# plus any hostnames passed as arguments. One cert, many SANs — nginx/Hawser
# still use docker/nginx/certs/fullchain.pem.
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

# Valid public DNS label (not localhost, not raw IPv4).
is_public_hostname() {
	local h="$1"
	[ -n "${h}" ] || return 1
	[ "${h}" != "localhost" ] || return 1
	echo "${h}" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' && return 1
	echo "${h}" | grep -Eq '^[a-zA-Z0-9]([a-zA-Z0-9.-]{0,251}[a-zA-Z0-9])?$'
}

SITE_DOMAIN="$(env_val SITE_DOMAIN)"
LETSENCRYPT_EMAIL="$(env_val LETSENCRYPT_EMAIL)"
SITE_DOMAIN_ALIASES="$(env_val SITE_DOMAIN_ALIASES)"

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

# Build unique domain list: primary, aliases from .env, then CLI extras.
DOMAINS=()
add_domain() {
	local d="$1" x
	[ -n "${d}" ] || return 0
	for x in "${DOMAINS[@]+"${DOMAINS[@]}"}"; do
		[ "${x}" = "${d}" ] && return 0
	done
	if ! is_public_hostname "${d}"; then
		echo "Skipping invalid hostname: ${d}" >&2
		return 0
	fi
	DOMAINS+=("${d}")
}

add_domain "${SITE_DOMAIN}"
# shellcheck disable=SC2086
for _alias in ${SITE_DOMAIN_ALIASES//,/ }; do
	add_domain "${_alias}"
done
for _extra in "$@"; do
	case "${_extra}" in
		-h|--help)
			sed -n '2,18p' "$0" | sed 's/^# \?//'
			exit 0
			;;
		*) add_domain "${_extra}" ;;
	esac
done

if [ "${#DOMAINS[@]}" -eq 0 ]; then
	echo "No domains to request." >&2
	exit 1
fi

if command -v getent >/dev/null 2>&1; then
	for _d in "${DOMAINS[@]}"; do
		if ! getent ahosts "${_d}" >/dev/null 2>&1; then
			echo "Warning: ${_d} does not resolve yet. Certbot will likely fail until DNS points here." >&2
		fi
	done
fi

mkdir -p "${ACME_ROOT}"

CERTBOT_D_ARGS=()
for _d in "${DOMAINS[@]}"; do
	CERTBOT_D_ARGS+=(-d "${_d}")
done

echo "Requesting a certificate for: ${DOMAINS[*]}"
echo "  webroot ${ACME_ROOT}  cert-name ${SITE_DOMAIN}"
echo "If this fails: DNS A/AAAA for every name must point at this VPS, and port 80 must be reachable."

# --expand: add SANs to an existing lineage (needed when aliases are new).
# Do not use --keep-until-expiring here — that skips reissue when not near
# expiry and would block adding a new domain to the cert.
certbot certonly \
	--webroot \
	--webroot-path "${ACME_ROOT}" \
	--cert-name "${SITE_DOMAIN}" \
	"${CERTBOT_D_ARGS[@]}" \
	--email "${LETSENCRYPT_EMAIL}" \
	--agree-tos \
	--non-interactive \
	--expand \
	--deploy-hook "${REPO_ROOT}/scripts/install-letsencrypt-certs.sh"

# certonly --deploy-hook runs on success; call again in case the hook path
# was missing on an older install.
"${REPO_ROOT}/scripts/install-letsencrypt-certs.sh"

echo
echo "HTTPS should now serve a public certificate for:"
for _d in "${DOMAINS[@]}"; do
	echo "  https://${_d}/"
done
echo "Renewal: certbot.timer (twice daily). The deploy hook reloads nginx."
