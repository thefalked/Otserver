#!/usr/bin/env bash
# =============================================================================
# Run VPS setup from your PC (macOS, Linux, WSL, or Git Bash).
#
# Why: the GitHub repo is private and a new VPS has no git/project. This script
# SSHs in as root, clones with your token (so the VPS can `git pull` later),
# then runs scripts/setup-vps.sh on the server. User, passwords, hostname, and
# MySQL secrets are prompted over that SSH session.
#
# From this repo on your laptop:
#   ./scripts/setup-from-pc.sh
#
# You need: ssh, and either an SSH key already on the VPS (typical for cloud
# images) or the VPS root password when ssh asks.
#
# GitHub token: Settings → Developer settings → Personal access tokens,
# this repo, Contents: Read-only (classic: `repo` scope).
#
# Host keys: StrictHostKeyChecking=accept-new trusts the first key OpenSSH
# sees (TOFU). On an untrusted network, verify the provider fingerprint first.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOTSTRAP="${SCRIPT_DIR}/bootstrap-vps.sh"

if [ ! -f "${BOOTSTRAP}" ]; then
	echo "Missing ${BOOTSTRAP}. Run this from a clone of the Otserver repo." >&2
	exit 1
fi

if ! command -v ssh >/dev/null 2>&1; then
	echo "ssh is required on this PC (OpenSSH, Git Bash, or WSL)." >&2
	exit 1
fi

if [ ! -e /dev/tty ]; then
	echo "Need an interactive terminal." >&2
	exit 1
fi

prompt() {
	local value=""
	printf '%s' "$1" > /dev/tty
	IFS= read -r value < /dev/tty
	printf '%s' "${value}"
}

prompt_secret() {
	local value=""
	printf '%s' "$1" > /dev/tty
	IFS= read -rs value < /dev/tty
	printf '\n' > /dev/tty
	printf '%s' "${value}"
}

echo "=== OTServer setup from this PC ==="
echo "This will SSH into the VPS, git clone the private repo, and run the full setup there."
echo "After SSH connects you will be asked for the sudo user, passwords, hostname, and MySQL secrets."
echo

VPS_HOST="$(prompt "VPS IP or hostname: ")"
if [ -z "${VPS_HOST}" ]; then
	echo "VPS address is required." >&2
	exit 1
fi

SSH_USER="$(prompt "SSH user on the VPS [root]: ")"
SSH_USER="${SSH_USER:-root}"
SSH_PORT="$(prompt "SSH port [22]: ")"
SSH_PORT="${SSH_PORT:-22}"

# Always prompt. An exported GITHUB_TOKEN (shell profile, CI, Cursor) used to
# skip this and look like the script "never asked". Enter keeps the existing value.
if [ -n "${GITHUB_TOKEN:-}" ]; then
	echo "GITHUB_TOKEN is set in this environment (will reuse if you press Enter)." > /dev/tty
	_entered="$(prompt_secret "GitHub token (Enter to reuse, input hidden): ")"
	if [ -n "${_entered}" ]; then
		GITHUB_TOKEN="${_entered}"
	fi
	unset _entered
else
	GITHUB_TOKEN="$(prompt_secret "GitHub token (input hidden): ")"
fi
if [ -z "${GITHUB_TOKEN}" ]; then
	echo "A GitHub token is required so the VPS can clone and later git pull." >&2
	exit 1
fi

OTSERVER_REF="${OTSERVER_REF:-master}"
OTSERVER_DIR="${OTSERVER_DIR:-/opt/otserver}"
SITE_DOMAIN="${SITE_DOMAIN:-baiakvip9.thefalked.dev}"

echo
echo "Target:  ${SSH_USER}@${VPS_HOST}:${SSH_PORT}"
echo "Clone:   ${OTSERVER_REF} → ${OTSERVER_DIR}"
echo

# Env exports go on remote stdin (with the bootstrap script), not in ssh argv,
# so the token does not show up in `ps` on the VPS.
{
	printf 'export GITHUB_TOKEN=%q\n' "${GITHUB_TOKEN}"
	printf 'export SITE_DOMAIN=%q\n' "${SITE_DOMAIN}"
	printf 'export OTSERVER_REF=%q\n' "${OTSERVER_REF}"
	printf 'export OTSERVER_DIR=%q\n' "${OTSERVER_DIR}"
	cat "${BOOTSTRAP}"
} | ssh -p "${SSH_PORT}" -t \
	-o StrictHostKeyChecking=accept-new \
	"${SSH_USER}@${VPS_HOST}" \
	"exec bash -s"

unset GITHUB_TOKEN
echo
echo "Remote setup finished. On the VPS later, as the sudo user:"
echo "  cd ${OTSERVER_DIR} && git pull"
echo "SSH:  ssh -p ${SSH_PORT} <sudo-user>@${VPS_HOST}"
