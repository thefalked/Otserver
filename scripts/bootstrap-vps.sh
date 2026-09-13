#!/usr/bin/env bash
# =============================================================================
# Empty-VPS entrypoint — no git and no repo required on the machine yet.
#
# Why a separate file: setup-vps.sh lives in this git repo. A brand-new cloud
# image has neither git nor the project. This script is tiny on purpose so you
# can download it with curl, then it installs git, clones the repo, and runs
# the real setup.
#
# On the fresh VPS as root (Ubuntu/Debian):
#
#   curl -fsSL https://raw.githubusercontent.com/thefalked/Otserver/master/scripts/bootstrap-vps.sh | sudo bash
#
# Optional environment (pass through sudo with `env` or `sudo -E`):
#   OTSERVER_REPO    git URL   (default https://github.com/thefalked/Otserver.git)
#   OTSERVER_REF     branch    (default master)
#   OTSERVER_DIR     clone dir (default /opt/otserver)
#   SITE_DOMAIN      default hostname prompt in setup-vps.sh
#                    (default baiakvip9.thefalked.dev)
#
# Example, different branch or domain:
#   curl -fsSL .../bootstrap-vps.sh | sudo env OTSERVER_REF=master SITE_DOMAIN=play.example.com bash
# =============================================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root: curl -fsSL .../bootstrap-vps.sh | sudo bash" >&2
	exit 1
fi

if [ ! -t 0 ] && [ ! -e /dev/tty ]; then
	echo "Need a terminal for prompts (/dev/tty). SSH in and run this from an interactive shell." >&2
	exit 1
fi

. /etc/os-release
case "${ID:-}" in
	ubuntu|debian) ;;
	*)
		echo "This script supports Ubuntu/Debian. Detected: ${ID:-unknown}." >&2
		exit 1
		;;
esac

OTSERVER_REPO="${OTSERVER_REPO:-https://github.com/thefalked/Otserver.git}"
OTSERVER_REF="${OTSERVER_REF:-master}"
OTSERVER_DIR="${OTSERVER_DIR:-/opt/otserver}"
# Exported so setup-vps.sh can use it as the hostname prompt default.
export SITE_DOMAIN="${SITE_DOMAIN:-baiakvip9.thefalked.dev}"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "=== OTServer clone + VPS setup ==="
echo "Repo:    ${OTSERVER_REPO}"
echo "Ref:     ${OTSERVER_REF}"
echo "Dir:     ${OTSERVER_DIR}"
echo "Domain:  ${SITE_DOMAIN}  (Enter at the hostname prompt to keep this)"
echo

echo "==> Installing git (so we can clone the project)"
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates curl git

if [ -d "${OTSERVER_DIR}/.git" ]; then
	echo "==> ${OTSERVER_DIR} already a git repo; fetching ${OTSERVER_REF}"
	git -C "${OTSERVER_DIR}" fetch --prune origin
	git -C "${OTSERVER_DIR}" checkout "${OTSERVER_REF}"
	git -C "${OTSERVER_DIR}" pull --ff-only origin "${OTSERVER_REF}" || \
		git -C "${OTSERVER_DIR}" reset --hard "origin/${OTSERVER_REF}"
else
	if [ -e "${OTSERVER_DIR}" ] && [ -n "$(ls -A "${OTSERVER_DIR}" 2>/dev/null || true)" ]; then
		echo "${OTSERVER_DIR} exists and is not an empty git clone. Set OTSERVER_DIR to another path." >&2
		exit 1
	fi
	echo "==> Cloning into ${OTSERVER_DIR}"
	git clone --branch "${OTSERVER_REF}" --depth 1 "${OTSERVER_REPO}" "${OTSERVER_DIR}"
fi

if [ ! -f "${OTSERVER_DIR}/scripts/setup-vps.sh" ]; then
	echo "Clone succeeded but scripts/setup-vps.sh is missing on ref ${OTSERVER_REF}." >&2
	exit 1
fi

echo "==> Running scripts/setup-vps.sh"
exec bash "${OTSERVER_DIR}/scripts/setup-vps.sh"
