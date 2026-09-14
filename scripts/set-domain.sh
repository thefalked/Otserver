#!/usr/bin/env bash
# Change the public hostname later without re-running the full VPS bootstrap.
#
# What it updates in .env:
#   SITE_DOMAIN           primary nginx / Let's Encrypt / OT_IP name
#   SITE_DOMAIN_ALIASES   previous primary kept as a maintenance SAN (if any)
#   OT_IP                 address advertised to game clients (same host unless
#                         you pass --keep-ot-ip)
#
# Usage:
#   sudo bash scripts/set-domain.sh                         # prompt
#   sudo bash scripts/set-domain.sh baiakvip9.servegame.com
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

env_val() {
	local raw
	raw="$(grep -E "^${1}=" "${ENV_FILE}" | tail -n1 | cut -d= -f2- || true)"
	case "${raw}" in
		\"*\") raw="${raw#\"}"; raw="${raw%\"}" ;;
		\'*\') raw="${raw#\'}"; raw="${raw%\'}" ;;
	esac
	printf '%s' "${raw}"
}

for arg in "$@"; do
	case "${arg}" in
		--keep-ot-ip) KEEP_OT_IP=1 ;;
		-h|--help)
			sed -n '2,20p' "$0"
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

OLD_DOMAIN="$(env_val SITE_DOMAIN)"
OLD_ALIASES="$(env_val SITE_DOMAIN_ALIASES)"

if [ -z "${NEW_DOMAIN}" ]; then
	if [ ! -e /dev/tty ]; then
		echo "Need /dev/tty to prompt, or pass the hostname as an argument." >&2
		exit 1
	fi
	CURRENT="${OLD_DOMAIN:-baiakvip9.servegame.com}"
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

# Keep the previous primary (and any existing aliases) as maintenance SANs.
# Drop the new primary from the alias list so it is not listed twice.
build_aliases() {
	local out=() x
	for x in ${OLD_ALIASES//,/ } ${OLD_DOMAIN}; do
		[ -n "${x}" ] || continue
		[ "${x}" = "${NEW_DOMAIN}" ] && continue
		[ "${x}" = "localhost" ] && continue
		case " ${out[*]+${out[*]}} " in
			*" ${x} "*) continue ;;
		esac
		out+=("${x}")
	done
	if [ "${#out[@]}" -gt 0 ]; then
		printf '%s' "${out[*]}"
	fi
}

NEW_ALIASES="$(build_aliases)"

upsert_env "${ENV_FILE}" SITE_DOMAIN "${NEW_DOMAIN}"
upsert_env "${ENV_FILE}" SITE_DOMAIN_ALIASES "${NEW_ALIASES}"
if [ "${KEEP_OT_IP}" -eq 0 ]; then
	upsert_env "${ENV_FILE}" OT_IP "${NEW_DOMAIN}"
	echo "Set SITE_DOMAIN and OT_IP to ${NEW_DOMAIN}"
else
	echo "Set SITE_DOMAIN to ${NEW_DOMAIN} (OT_IP unchanged)"
fi
if [ -n "${NEW_ALIASES}" ]; then
	echo "SITE_DOMAIN_ALIASES=${NEW_ALIASES} (maintenance / alternate HTTPS)"
else
	echo "SITE_DOMAIN_ALIASES cleared"
fi

# Point game clients at the new name: config.lua is rendered at container start.
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 \
	&& docker ps -q -f 'name=^otserver$' | grep -q .; then
	echo "Restarting otserver so OT_IP is picked up (brief game disconnect)"
	docker restart otserver >/dev/null
fi

echo
echo "Point DNS A/AAAA for ${NEW_DOMAIN} (and aliases) at this VPS, then issue a matching cert:"
echo "  sudo bash ${REPO_ROOT}/scripts/setup-letsencrypt.sh"
echo "Until then nginx still serves whatever pem is in docker/nginx/certs/."
