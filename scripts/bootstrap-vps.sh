#!/usr/bin/env bash
# =============================================================================
# Empty-VPS entrypoint — this GitHub repo is PRIVATE, so a bare `git clone`
# and a bare curl of this file both fail without auth.
#
# Recommended (no GitHub token on the VPS): copy the tree from your laptop,
# then run setup-vps.sh. You already have the repo there.
#
#   # laptop, from the repo root
#   rsync -az --exclude '.git' ./ root@VPS_IP:/opt/otserver/
#   ssh -t root@VPS_IP bash /opt/otserver/scripts/setup-vps.sh
#
# Alternative: GitHub PAT (Contents: Read-only on this repo). The token is
# used once to clone, then stripped from `git remote` so it is not saved.
#
#   # laptop: create the PAT, then on the VPS as root:
#   read -s GITHUB_TOKEN; echo
#   curl -fsSL \
#     -H "Authorization: Bearer ${GITHUB_TOKEN}" \
#     -H "Accept: application/vnd.github.raw" \
#     "https://api.github.com/repos/thefalked/Otserver/contents/scripts/bootstrap-vps.sh?ref=master" \
#     | sudo env GITHUB_TOKEN="${GITHUB_TOKEN}" bash
#
# Env (optional):
#   GITHUB_TOKEN     PAT or fine-grained token (prompted if clone is needed)
#   OTSERVER_REPO    HTTPS git URL (default https://github.com/thefalked/Otserver.git)
#   OTSERVER_REF     branch/tag (default master)
#   OTSERVER_DIR     clone/copy path (default /opt/otserver)
#   SITE_DOMAIN      hostname prompt default (baiakvip9.thefalked.dev)
# =============================================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root." >&2
	exit 1
fi

if [ ! -e /dev/tty ]; then
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
export SITE_DOMAIN="${SITE_DOMAIN:-baiakvip9.thefalked.dev}"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# HTTPS origin with no secrets — written back after a token clone.
origin_public() {
	printf '%s' "${OTSERVER_REPO}" | sed -E 's#https://[^@]+@#https://#'
}

prompt_token() {
	local value=""
	printf '%s' "GitHub token (Contents: Read on this private repo, input hidden): " > /dev/tty
	IFS= read -rs value < /dev/tty
	printf '\n' > /dev/tty
	printf '%s' "${value}"
}

echo "=== OTServer clone + VPS setup ==="
echo "Repo:    ${OTSERVER_REPO}"
echo "Ref:     ${OTSERVER_REF}"
echo "Dir:     ${OTSERVER_DIR}"
echo "Domain:  ${SITE_DOMAIN}  (Enter at the hostname prompt to keep this)"
echo "This repository is private: clone needs a token, or copy the tree with rsync first."
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
	fi
	if [ -z "${GITHUB_TOKEN}" ]; then
		echo "No GITHUB_TOKEN. Either pass one, or rsync the repo from your laptop to ${OTSERVER_DIR}." >&2
		exit 1
	fi

	# Askpass so the token is not stored in the remote URL or in `ps` argv.
	ASKPASS="$(mktemp)"
	chmod 700 "${ASKPASS}"
	cat > "${ASKPASS}" <<'EOF'
#!/bin/sh
case "$1" in
	*Username*) printf '%s\n' "x-access-token" ;;
	*) printf '%s\n' "${GITHUB_TOKEN}" ;;
esac
EOF
	echo "==> Cloning ${OTSERVER_REF} into ${OTSERVER_DIR} (private HTTPS)"
	export GITHUB_TOKEN
	GIT_ASKPASS="${ASKPASS}" GIT_TERMINAL_PROMPT=0 \
		git clone --branch "${OTSERVER_REF}" --depth 1 "${OTSERVER_REPO}" "${OTSERVER_DIR}"
	rm -f "${ASKPASS}"
	unset GITHUB_TOKEN
	git -C "${OTSERVER_DIR}" remote set-url origin "$(origin_public)"
	echo "Clone done. git remote has no token. Later pulls need a deploy key or a new token."
fi

if [ ! -f "${OTSERVER_DIR}/scripts/setup-vps.sh" ]; then
	echo "No scripts/setup-vps.sh in ${OTSERVER_DIR}." >&2
	exit 1
fi

echo "==> Running scripts/setup-vps.sh"
exec bash "${OTSERVER_DIR}/scripts/setup-vps.sh"
