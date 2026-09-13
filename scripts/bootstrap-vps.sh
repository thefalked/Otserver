#!/usr/bin/env bash
# =============================================================================
# Clone the private repo on the VPS, then run setup-vps.sh.
#
# Called by scripts/setup-from-pc.sh (from your laptop). You can also run this
# on the VPS as root if GITHUB_TOKEN is already set.
#
# When launched from setup-from-pc.sh, all setup secrets are already in the
# environment and no /dev/tty prompts are needed.
#
# The token is kept long enough for setup-vps.sh to install a git credential
# helper for the new sudo user so they can `git pull` later. It is not stored
# in `git remote`.
# =============================================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root." >&2
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
export SITE_DOMAIN="${SITE_DOMAIN:-baiakvip9.thefalked.dev}"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# HTTPS origin with no secrets — written back after a token clone.
origin_public() {
	printf '%s' "${OTSERVER_REPO}" | sed -E 's#https://[^@]+@#https://#'
}

prompt_token() {
	local value=""
	# -e /dev/tty is true even with no controlling terminal; opening fails with ENXIO.
	if ! { : > /dev/tty; } 2>/dev/null; then
		echo "No GITHUB_TOKEN and no /dev/tty. Re-run from your PC: ./scripts/setup-from-pc.sh" >&2
		exit 1
	fi
	printf '%s' "GitHub token (Contents: Read on this private repo, input hidden): " > /dev/tty
	IFS= read -rs value < /dev/tty
	printf '\n' > /dev/tty
	printf '%s' "${value}"
}

echo "=== OTServer clone + VPS setup ==="
echo "Repo:    ${OTSERVER_REPO}"
echo "Ref:     ${OTSERVER_REF}"
echo "Dir:     ${OTSERVER_DIR}"
echo "Domain:  ${SITE_DOMAIN}"
echo "This repository is private: a GitHub token is required to clone."
echo

echo "==> Installing git and curl"
apt-get update -y
apt-get install -y --no-install-recommends ca-certificates curl git

if [ -f "${OTSERVER_DIR}/scripts/setup-vps.sh" ]; then
	echo "==> ${OTSERVER_DIR} already has the project (rsync/scp); skipping GitHub"
else
	if [ -e "${OTSERVER_DIR}" ] && [ -n "$(ls -A "${OTSERVER_DIR}" 2>/dev/null || true)" ]; then
		echo "${OTSERVER_DIR} exists and is not this project. Set OTSERVER_DIR or empty that directory." >&2
		exit 1
	fi

	if [ -z "${GITHUB_TOKEN:-}" ]; then
		GITHUB_TOKEN="$(prompt_token)"
	else
		echo "Using GITHUB_TOKEN from environment."
	fi
	if [ -z "${GITHUB_TOKEN}" ]; then
		echo "No GITHUB_TOKEN. Re-run from your PC: ./scripts/setup-from-pc.sh" >&2
		exit 1
	fi

	# Askpass so the token is not stored in the remote URL or in `ps` argv.
	ASKPASS="$(mktemp)"
	chmod 700 "${ASKPASS}"
	trap 'rm -f "${ASKPASS}"' EXIT
	cat > "${ASKPASS}" <<'EOF'
#!/bin/sh
case "$1" in
	*Username*) printf '%s\n' "x-access-token" ;;
	*) printf '%s\n' "${GITHUB_TOKEN}" ;;
esac
EOF
	echo "==> Cloning ${OTSERVER_REF} into ${OTSERVER_DIR} (private HTTPS, full history)"
	export GITHUB_TOKEN
	GIT_ASKPASS="${ASKPASS}" GIT_TERMINAL_PROMPT=0 \
		git clone --branch "${OTSERVER_REF}" "${OTSERVER_REPO}" "${OTSERVER_DIR}"
	rm -f "${ASKPASS}"
	trap - EXIT
	git -C "${OTSERVER_DIR}" remote set-url origin "$(origin_public)"
	echo "Clone done. Token stays in env only so setup-vps.sh can enable git pull for the sudo user."
fi

if [ ! -f "${OTSERVER_DIR}/scripts/setup-vps.sh" ]; then
	echo "No scripts/setup-vps.sh in ${OTSERVER_DIR}." >&2
	exit 1
fi

# Prefer setup-vps.sh uploaded by setup-from-pc.sh (matches your laptop even if
# the VPS clone is older). Caller removes the upload bundle after we exit.
if [ -n "${OTSERVER_PC_SETUP_VPS:-}" ] && [ -f "${OTSERVER_PC_SETUP_VPS}" ]; then
	echo "==> Applying setup-vps.sh from your PC"
	install -m 755 "${OTSERVER_PC_SETUP_VPS}" "${OTSERVER_DIR}/scripts/setup-vps.sh"
fi

echo "==> Running scripts/setup-vps.sh"
exec bash "${OTSERVER_DIR}/scripts/setup-vps.sh"
