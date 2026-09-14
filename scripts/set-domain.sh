#!/usr/bin/env bash
# Change the public hostname later without re-running the full VPS bootstrap.
#
# What it updates in .env:
#   SITE_DOMAIN              primary public hostname + OT_IP
#   SITE_MAINTENANCE_DOMAIN  previous primary kept for Dockhand / ops HTTPS
#                            (separate Let's Encrypt cert — not a SAN)
#   OT_IP                    unless --keep-ot-ip
#
# Usage:
#   sudo bash scripts/set-domain.sh                         # prompt
#   sudo bash scripts/set-domain.sh baiakvip9.servegame.com
#   sudo bash scripts/set-domain.sh play.example.com --keep-ot-ip
#
# Then: sudo bash scripts/setup-letsencrypt.sh
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
			sed -n '2,16p' "$0"
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
OLD_MAINT="$(env_val SITE_MAINTENANCE_DOMAIN)"
if [ -z "${OLD_MAINT}" ]; then
	_aliases="$(env_val SITE_DOMAIN_ALIASES)"
	OLD_MAINT="${_aliases%%[, ]*}"
fi

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

upsert_env() {
	local file="$1" key="$2" value="$3"
	local tmp owner group mode
	tmp="$(mktemp)"
	if [ -f "${file}" ]; then
		owner="$(stat -c '%u' "${file}")"
		group="$(stat -c '%g' "${file}")"
		mode="$(stat -c '%a' "${file}")"
		grep -v "^${key}=" "${file}" > "${tmp}" || true
	else
		owner="$(stat -c '%u' "$(dirname "${file}")")"
		group="$(stat -c '%g' "$(dirname "${file}")")"
		mode=600
		: > "${tmp}"
	fi
	printf '%s=%s\n' "${key}" "${value}" >> "${tmp}"
	# install(1) preserves intended owner — plain mv as root leaves root:600
	# and breaks unprivileged `docker compose` (.env unreadable).
	install -m "${mode}" -o "${owner}" -g "${group}" "${tmp}" "${file}"
	rm -f "${tmp}"
}

# Keep prior public name as maintenance (Dockhand), unless it equals the new primary.
NEW_MAINT="${OLD_MAINT}"
if [ -n "${OLD_DOMAIN}" ] && [ "${OLD_DOMAIN}" != "${NEW_DOMAIN}" ] \
	&& [ "${OLD_DOMAIN}" != "localhost" ]; then
	NEW_MAINT="${OLD_DOMAIN}"
fi
if [ "${NEW_MAINT}" = "${NEW_DOMAIN}" ]; then
	NEW_MAINT=""
fi

upsert_env "${ENV_FILE}" SITE_DOMAIN "${NEW_DOMAIN}"
upsert_env "${ENV_FILE}" SITE_MAINTENANCE_DOMAIN "${NEW_MAINT}"
# Drop legacy key so we do not keep dual-SAN behaviour by accident.
if grep -qE '^SITE_DOMAIN_ALIASES=' "${ENV_FILE}" 2>/dev/null; then
	tmp="$(mktemp)"
	owner="$(stat -c '%u' "${ENV_FILE}")"
	group="$(stat -c '%g' "${ENV_FILE}")"
	mode="$(stat -c '%a' "${ENV_FILE}")"
	grep -vE '^SITE_DOMAIN_ALIASES=' "${ENV_FILE}" > "${tmp}" || true
	install -m "${mode}" -o "${owner}" -g "${group}" "${tmp}" "${ENV_FILE}"
	rm -f "${tmp}"
fi

if [ "${KEEP_OT_IP}" -eq 0 ]; then
	upsert_env "${ENV_FILE}" OT_IP "${NEW_DOMAIN}"
	echo "Set SITE_DOMAIN and OT_IP to ${NEW_DOMAIN}"
else
	echo "Set SITE_DOMAIN to ${NEW_DOMAIN} (OT_IP unchanged)"
fi
if [ -n "${NEW_MAINT}" ]; then
	echo "SITE_MAINTENANCE_DOMAIN=${NEW_MAINT} (separate cert; Dockhand)"
else
	echo "SITE_MAINTENANCE_DOMAIN cleared"
fi

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1 \
	&& docker ps -q -f 'name=^otserver$' | grep -q .; then
	echo "Restarting otserver so OT_IP is picked up (brief game disconnect)"
	docker restart otserver >/dev/null
fi

echo
echo "Point DNS A/AAAA for ${NEW_DOMAIN} (and maintenance if set) at this VPS, then:"
echo "  sudo bash ${REPO_ROOT}/scripts/setup-letsencrypt.sh"
echo "That issues **separate** certs (no shared SANs in CT logs)."
