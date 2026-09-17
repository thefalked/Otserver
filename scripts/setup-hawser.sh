#!/usr/bin/env bash
# Enable Hawser (Dockhand agent) on an existing VPS without re-running setup-vps.sh.
#
# Idempotent: safe on first bootstrap (called from setup-vps.sh) and on a live box.
#   sudo bash scripts/setup-hawser.sh              # host prep + compose up hawser
#   sudo bash scripts/setup-hawser.sh --host-only  # stacks, config, token, UFW, stop systemd
#
# What it does:
#   - /opt/hawser-stacks bind-mount dir
#   - /etc/hawser/config with TOKEN (keeps an existing file)
#   - /etc/hawser/token (raw token for compose TOKEN_FILE mount; root:600)
#   - UFW allow 2376/tcp
#   - disable systemd `hawser` if present (avoids fighting compose for the port)
#   - docker compose up -d hawser (unless --host-only)
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root: sudo bash scripts/setup-hawser.sh" >&2
	exit 1
fi

HOST_ONLY=0
for arg in "$@"; do
	case "${arg}" in
		--host-only) HOST_ONLY=1 ;;
		-h|--help)
			sed -n '2,14p' "$0" | sed 's/^# \?//'
			exit 0
			;;
		*)
			echo "Unknown option: ${arg} (try --host-only)" >&2
			exit 1
			;;
	esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Prefer the sudo user, else the repo tree owner (setup-vps chowns to that user).
OWNER="${SUDO_USER:-}"
if [ -z "${OWNER}" ] || [ "${OWNER}" = "root" ]; then
	OWNER="$(stat -c '%U' "${REPO_ROOT}" 2>/dev/null || echo root)"
fi

echo "==> Hawser host prep"

install -d -m 755 /opt/hawser-stacks
if id "${OWNER}" >/dev/null 2>&1 && [ "${OWNER}" != "root" ]; then
	chown "${OWNER}:${OWNER}" /opt/hawser-stacks || true
fi

install -d -m 755 /etc/hawser

if [ ! -f /etc/hawser/config ]; then
	echo "==> Creating /etc/hawser/config (TOKEN for Dockhand)"
	_hawser_tok="$(openssl rand -base64 32)"
	umask 077
	cat > /etc/hawser/config <<EOF
# Hawser: TOKEN mirrored to /etc/hawser/token for otserver-hawser (compose)
PORT=2376
TOKEN=${_hawser_tok}
DOCKER_SOCKET=/var/run/docker.sock
EOF
	chmod 600 /etc/hawser/config
	echo "    TOKEN written to /etc/hawser/config (mode 600). Use it in local Dockhand."
else
	echo "==> Keeping existing /etc/hawser/config"
fi

# Compose mounts this as TOKEN_FILE (container reads it as root). Avoids
# env_file:/etc/hawser/config which fails for non-root `docker compose`.
sync_hawser_token_file() {
	local raw=""
	raw="$(grep -E '^TOKEN=' /etc/hawser/config | tail -n1 | cut -d= -f2- || true)"
	case "${raw}" in
		\"*\") raw="${raw#\"}"; raw="${raw%\"}" ;;
		\'*\') raw="${raw#\'}"; raw="${raw%\'}" ;;
	esac
	if [ -z "${raw}" ]; then
		echo "No TOKEN= in /etc/hawser/config" >&2
		exit 1
	fi
	umask 077
	printf '%s\n' "${raw}" > /etc/hawser/token
	chmod 600 /etc/hawser/token
	chown root:root /etc/hawser/token
	echo "==> Synced /etc/hawser/token from config (for compose TOKEN_FILE)"
}
sync_hawser_token_file

if command -v ufw >/dev/null 2>&1; then
	ufw allow 2376/tcp comment 'Hawser Dockhand' || true
	echo "==> UFW: 2376/tcp allowed (Docker may still publish even if UFW is off)"
fi

if systemctl list-unit-files hawser.service >/dev/null 2>&1; then
	if systemctl is-enabled hawser.service >/dev/null 2>&1 \
		|| systemctl is-active hawser.service >/dev/null 2>&1; then
		echo "==> Disabling systemd hawser (compose owns port 2376)"
		systemctl disable --now hawser.service || true
	fi
fi

if [ "${HOST_ONLY}" -eq 1 ]; then
	echo "Done (host prep only)."
	exit 0
fi

ENV_FILE="${REPO_ROOT}/.env"
if [ ! -f "${ENV_FILE}" ]; then
	echo "Missing ${ENV_FILE}." >&2
	exit 1
fi

compose_has_vps=0
if grep -q 'docker-compose.vps.yml' "${ENV_FILE}" 2>/dev/null; then
	compose_has_vps=1
fi
case "${COMPOSE_FILE:-}" in
	*docker-compose.vps.yml*) compose_has_vps=1 ;;
esac
if [ "${compose_has_vps}" -eq 0 ]; then
	echo "COMPOSE_FILE does not include docker-compose.vps.yml. add it to .env, then re-run." >&2
	echo "  COMPOSE_FILE=docker-compose.yml:docker-compose.vps.yml" >&2
	exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
	echo "docker not installed." >&2
	exit 1
fi

echo "==> Starting otserver-hawser + nginx (H1: SNI proxy on :2376)"
cd "${REPO_ROOT}"
if id "${OWNER}" >/dev/null 2>&1 && [ "${OWNER}" != "root" ]; then
	sudo -u "${OWNER}" docker compose up -d hawser nginx
else
	docker compose up -d hawser nginx
fi

_site=""
_maint=""
if [ -f "${ENV_FILE}" ]; then
	_site="$(grep -E '^SITE_DOMAIN=' "${ENV_FILE}" | tail -n1 | cut -d= -f2- || true)"
	case "${_site}" in
		\"*\") _site="${_site#\"}"; _site="${_site%\"}" ;;
		\'*\') _site="${_site#\'}"; _site="${_site%\'}" ;;
	esac
	_maint="$(grep -E '^SITE_MAINTENANCE_DOMAIN=' "${ENV_FILE}" | tail -n1 | cut -d= -f2- || true)"
	case "${_maint}" in
		\"*\") _maint="${_maint#\"}"; _maint="${_maint%\"}" ;;
		\'*\') _maint="${_maint#\'}"; _maint="${_maint%\'}" ;;
	esac
	if [ -z "${_maint}" ]; then
		_alias="$(grep -E '^SITE_DOMAIN_ALIASES=' "${ENV_FILE}" | tail -n1 | cut -d= -f2- || true)"
		case "${_alias}" in
			\"*\") _alias="${_alias#\"}"; _alias="${_alias%\"}" ;;
			\'*\') _alias="${_alias#\'}"; _alias="${_alias%\'}" ;;
		esac
		_maint="${_alias%%[, ]*}"
	fi
fi
_dockhand="${_maint:-${_site:-SITE_DOMAIN}}"

echo
echo "Hawser is up (internal). Public Dockhand: https://${_dockhand}:2376"
echo "  H1: nginx publishes :2376 and only proxies SNI=${_dockhand}"
echo "  TOKEN from /etc/hawser/config"
echo "  TLS: maintenance-fullchain.pem (on hawser; SNI must be maintenance hostname)"
echo "  Public site: https://${_site:-SITE_DOMAIN}/"
echo "  docker compose ps hawser nginx"
echo "  docker compose logs -f hawser"
