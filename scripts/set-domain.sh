#!/usr/bin/env bash
# Change the public hostname later without re-running the full VPS bootstrap.
#
# What it updates in .env:
#   SITE_DOMAIN  nginx / Let's Encrypt name
#   OT_IP        address advertised to game clients (same host unless you pass
#                --keep-ot-ip)
#
# Usage:
#   sudo bash scripts/set-domain.sh                         # prompt
#   sudo bash scripts/set-domain.sh baiakvip9.thefalked.dev
#   sudo bash scripts/set-domain.sh play.example.com
#   sudo bash scripts/set-domain.sh play.example.com --keep-ot-ip
#
# After this: restart otserver so config.lua picks up OT_IP, then (as root)
# re-issue the cert: sudo bash scripts/setup-letsencrypt.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
KEEP_OT_IP=0
NEW_DOMAIN=""

for arg in "$@"; do
	case "${arg}" in
		--keep-ot-ip) KEEP_OT_IP=1 ;;
		-h|--help)
			sed -n '2,18p' "$0"
			exit 0
			;;
		*)
			if [ -n "${NEW_DOMAIN}" ]; then
				echo "Unexpected argument: ${arg}" >&2
				exit 1
			fi
			NEW_DOMAIN="${arg}"
			;;
	esac
done

if [ ! -f "${ENV_FILE}" ]; then
	echo "Missing ${ENV_FILE}. Run setup-vps.sh first." >&2
	exit 1
fi

if [ -z "${NEW_DOMAIN}" ]; then
	if [ ! -e /dev/tty ]; then
		echo "Need /dev/tty to prompt, or pass the hostname as an argument." >&2
		exit 1
	fi
	CURRENT="$(grep -E '^SITE_DOMAIN=' "${ENV_FILE}" | tail -n1 | cut -d= -f2-)"
	case "${CURRENT}" in
		\"*\") CURRENT="${CURRENT#\"}"; CURRENT="${CURRENT%\"}" ;;
		\'*\') CURRENT="${CURRENT#\'}"; CURRENT="${CURRENT%\'}" ;;
	esac
	CURRENT="${CURRENT:-baiakvip9.thefalked.dev}"
	printf 'New hostname [%s]: ' "${CURRENT}" > /dev/tty
	IFS= read -r NEW_DOMAIN < /dev/tty
	NEW_DOMAIN="${NEW_DOMAIN:-${CURRENT}}"
fi

# Same rules as Let's Encrypt: a DNS label, not localhost, not a raw IPv4.
if ! printf '%s' "${NEW_DOMAIN}" | grep -Eq '^[a-zA-Z0-9]([a-zA-Z0-9.-]{0,251}[a-zA-Z0-9])?$'; then
	echo "Invalid hostname: ${NEW_DOMAIN}" >&2
	exit 1
fi
if [ "${NEW_DOMAIN}" = "localhost" ]; then
	echo "Use a public DNS name, not localhost." >&2
	exit 1
fi
if printf '%s' "${NEW_DOMAIN}" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
	echo "Let's Encrypt needs a DNS name, not an IP. For clients you can still set OT_IP separately with --keep-ot-ip." >&2
	exit 1
fi

# Same approach as setup-vps.sh: rewrite via temp file so values with |/& are safe.
upsert_env() {
	local file="$1" key="$2" value="$3"
	local tmp
	tmp="$(mktemp)"
	if [ -f "${file}" ]; then
		grep -v "^${key}=" "${file}" > "${tmp}" || true
	else
		: > "${tmp}"
	fi
	printf '%s=%s\n' "${key}" "${value}" >> "${tmp}"
	mv "${tmp}" "${file}"
}

upsert_env "${ENV_FILE}" SITE_DOMAIN "${NEW_DOMAIN}"
if [ "${KEEP_OT_IP}" -eq 0 ]; then
	upsert_env "${ENV_FILE}" OT_IP "${NEW_DOMAIN}"
	echo "Set SITE_DOMAIN and OT_IP to ${NEW_DOMAIN}"
else
	echo "Set SITE_DOMAIN to ${NEW_DOMAIN} (OT_IP unchanged)"
fi

# Point game clients at the new name: config.lua is rendered at container start.
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 \
	&& docker ps -q -f 'name=^otserver$' | grep -q .; then
	echo "Restarting otserver so OT_IP is picked up (brief game disconnect)"
	docker restart otserver >/dev/null
fi

echo
echo "Point DNS A/AAAA for ${NEW_DOMAIN} at this VPS, then issue a matching cert:"
echo "  sudo bash ${REPO_ROOT}/scripts/setup-letsencrypt.sh"
echo "Until then nginx still serves whatever pem is in docker/nginx/certs/."
