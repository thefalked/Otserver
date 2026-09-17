#!/usr/bin/env bash
# Apply host-hardening that setup-vps.sh would do on a *fresh* box, onto an
# already-running VPS (after git pull of the host security batch).
#
# Idempotent. Does not re-run full bootstrap.
#
# Safe default (UFW + compose only. no SSH / docker-group / git changes):
#   sudo bash scripts/apply-host-hardening.sh
#
#   sudo bash scripts/apply-host-hardening.sh --compose-only
#   sudo bash scripts/apply-host-hardening.sh --no-compose
#   sudo bash scripts/apply-host-hardening.sh --remove-docker-group
#   sudo bash scripts/apply-host-hardening.sh --remove-git-credentials
#
# Password SSH: do NOT flip here. After a tested key login:
#   sudo bash scripts/disable-ssh-passwords.sh
#
# What the default run does:
#   - Drop UFW allow 8080 if present (H3)
#   - Restore repo ownership so git pull works (website not left as root/www-data)
#   - docker compose up -d --force-recreate website nginx hawser (H1/H3/H4/H6/H11)
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root: sudo bash scripts/apply-host-hardening.sh" >&2
	exit 1
fi

DO_COMPOSE=1
DO_UFW=1
REMOVE_DOCKER_GROUP=0
REMOVE_GIT_CREDENTIALS=0
for arg in "$@"; do
	case "${arg}" in
		--compose-only)
			DO_UFW=0
			;;
		--no-compose)
			DO_COMPOSE=0
			;;
		--remove-docker-group)
			REMOVE_DOCKER_GROUP=1
			;;
		--remove-git-credentials)
			REMOVE_GIT_CREDENTIALS=1
			;;
		-h|--help)
			sed -n '2,22p' "$0" | sed 's/^# \?//'
			exit 0
			;;
		*)
			echo "Unknown option: ${arg}" >&2
			exit 1
			;;
	esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Prefer the invoking sudo user. Never treat root's keys/creds as the admin's.
OWNER="${SUDO_USER:-}"
if [ -z "${OWNER}" ] || [ "${OWNER}" = "root" ]; then
	_repo_owner="$(stat -c '%U' "${REPO_ROOT}" 2>/dev/null || echo "")"
	if [ -n "${_repo_owner}" ] && [ "${_repo_owner}" != "root" ]; then
		OWNER="${_repo_owner}"
	else
		OWNER=""
	fi
fi
OWNER_HOME=""
if [ -n "${OWNER}" ]; then
	OWNER_HOME="$(getent passwd "${OWNER}" 2>/dev/null | cut -d: -f6 || true)"
	OWNER_HOME="${OWNER_HOME:-/home/${OWNER}}"
fi

if [ "${DO_UFW}" = "1" ]; then
	echo "==> UFW: remove public 8080 (H3)"
	if command -v ufw >/dev/null 2>&1; then
		ufw delete allow 8080/tcp >/dev/null 2>&1 && echo "Removed UFW allow 8080/tcp." || echo "No UFW 8080 rule (ok)."
		ufw status | grep -E '8080|Status' || true
	else
		echo "ufw not installed; skip."
	fi
fi

echo "==> SSH PasswordAuthentication (H2)"
echo "Left unchanged. After a working key login in another terminal:"
echo "  sudo bash ${REPO_ROOT}/scripts/disable-ssh-passwords.sh"

if [ "${REMOVE_DOCKER_GROUP}" = "1" ]; then
	echo "==> docker group (H5). --remove-docker-group"
	if [ -z "${OWNER}" ]; then
		echo "Cannot resolve sudo user; skip docker group change." >&2
	elif [ "${OTSERVER_DOCKER_GROUP:-0}" = "1" ]; then
		echo "OTSERVER_DOCKER_GROUP=1 set. not removing."
	elif id "${OWNER}" >/dev/null 2>&1 && id -nG "${OWNER}" 2>/dev/null | grep -qw docker; then
		gpasswd -d "${OWNER}" docker
		echo "Removed ${OWNER} from group docker (use: sudo docker compose)."
		echo "Re-login required for group change to apply."
	else
		echo "${OWNER} not in docker group (ok)."
	fi
else
	echo "==> docker group (H5): left unchanged (pass --remove-docker-group to drop it)."
fi

if [ "${REMOVE_GIT_CREDENTIALS}" = "1" ]; then
	echo "==> git credentials (H9). --remove-git-credentials"
	if [ -z "${OWNER_HOME}" ]; then
		echo "Cannot resolve sudo user home; skip." >&2
	elif [ "${OTSERVER_SAVE_GIT_CREDENTIALS:-0}" = "1" ]; then
		echo "OTSERVER_SAVE_GIT_CREDENTIALS=1. leaving credentials alone."
	elif [ -f "${OWNER_HOME}/.git-credentials" ]; then
		rm -f "${OWNER_HOME}/.git-credentials"
		echo "Removed ${OWNER_HOME}/.git-credentials. Prefer a deploy key, or scripts/set-git-credentials.sh"
	else
		echo "No ${OWNER_HOME}/.git-credentials (ok)."
	fi
else
	echo "==> git credentials (H9): left unchanged (pass --remove-git-credentials to delete)."
fi

echo "==> Repo ownership (git pull must work as ${OWNER:-deploy user})"
bash "${SCRIPT_DIR}/fix-repo-ownership.sh" "${REPO_ROOT}"

if [ "${DO_COMPOSE}" = "1" ]; then
	echo "==> Recreate website + nginx (+ hawser if VPS overlay) (H1/H3/H4/H6/H11)"
	if [ ! -f "${REPO_ROOT}/docker-compose.yml" ]; then
		echo "No docker-compose.yml in ${REPO_ROOT}" >&2
		exit 1
	fi
	# Migrate legacy webroot counter into config/ (RW mount; avoids file-bind footgun).
	_legacy="${REPO_ROOT}/website/usercounter.dat"
	_new="${REPO_ROOT}/website/config/usercounter.dat"
	if [ -f "${_legacy}" ] && [ ! -f "${_new}" ]; then
		cp -a "${_legacy}" "${_new}" 2>/dev/null || true
	fi
	mkdir -p "${REPO_ROOT}/website/config" 2>/dev/null || true
	touch "${_new}" 2>/dev/null || true
	(
		cd "${REPO_ROOT}"
		# H1: recreate nginx (SNI :2376) + hawser (no host publish) when vps overlay is present.
		if docker compose config --services 2>/dev/null | grep -qx hawser; then
			docker compose up -d --force-recreate website nginx hawser
		else
			docker compose up -d --force-recreate website nginx
		fi
	)
	# Entrypoints must not steal ownership; re-assert after recreate.
	bash "${SCRIPT_DIR}/fix-repo-ownership.sh" "${REPO_ROOT}"
	echo "Compose recreated (brief 502 possible while ensure-schema runs)."
	echo "Check: curl -sI http://127.0.0.1:8080/ | head -5"
	echo "Public :8080 should be closed; HTTPS on 443 unchanged."
	echo "H1 Dockhand: use https://SITE_MAINTENANCE_DOMAIN:2376 (SNI must match)."
fi

echo
echo "=== apply-host-hardening done ==="
echo "Verify from outside the VPS:  nc -vz YOUR_HOST 8080   # should fail / refuse"
echo "SSH passwords: still as before until you run scripts/disable-ssh-passwords.sh"
