#!/usr/bin/env bash
# =============================================================================
# Run full VPS setup from your PC (macOS, Linux, WSL, or Git Bash).
#
# One script: every prompt happens here on your laptop, then SSH/SCP applies
# it on the server (no remote prompts).
#
# From this repo on your laptop:
#   ./scripts/setup-from-pc.sh
#
# You need: ssh and scp, and either an SSH key already on the VPS (typical for
# cloud images) or the VPS root password when ssh asks.
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
SETUP_VPS="${SCRIPT_DIR}/setup-vps.sh"

if [ ! -f "${BOOTSTRAP}" ] || [ ! -f "${SETUP_VPS}" ]; then
	echo "Missing ${BOOTSTRAP} or ${SETUP_VPS}. Run this from a clone of the Otserver repo." >&2
	exit 1
fi

if ! command -v ssh >/dev/null 2>&1 || ! command -v scp >/dev/null 2>&1; then
	echo "ssh and scp are required on this PC (OpenSSH, Git Bash, or WSL)." >&2
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
echo "All secrets are collected here, then applied on the VPS over SSH (no remote prompts)."
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

OTSERVER_USERNAME="$(prompt "New sudo username: ")"
if ! printf '%s' "${OTSERVER_USERNAME}" | grep -Eq '^[a-z_][a-z0-9_-]{0,31}$'; then
	echo "Invalid username. Use lowercase letters, digits, underscore, or hyphen." >&2
	exit 1
fi
if [ "${OTSERVER_USERNAME}" = "root" ]; then
	echo "Pick a non-root username." >&2
	exit 1
fi

OTSERVER_PASSWORD="$(prompt_secret "Password for ${OTSERVER_USERNAME}: ")"
_confirm="$(prompt_secret "Confirm password: ")"
if [ -z "${OTSERVER_PASSWORD}" ]; then
	echo "Password cannot be empty." >&2
	exit 1
fi
if [ "${OTSERVER_PASSWORD}" != "${_confirm}" ]; then
	echo "Passwords do not match." >&2
	exit 1
fi
unset _confirm

DEFAULT_SITE_DOMAIN="${SITE_DOMAIN:-baiakvip9.servegame.com}"
SITE_DOMAIN_INPUT="$(prompt "Website hostname [${DEFAULT_SITE_DOMAIN}]: ")"
SITE_DOMAIN="${SITE_DOMAIN_INPUT:-${DEFAULT_SITE_DOMAIN}}"
SITE_DOMAIN_ALIASES="${SITE_DOMAIN_ALIASES:-baiakvip9.thefalked.dev}"

LETSENCRYPT_EMAIL="$(prompt "Let's Encrypt email (Enter to skip HTTPS cert for now): ")"

MYSQL_ROOT_PASSWORD="$(prompt_secret "MySQL root password: ")"
_confirm="$(prompt_secret "Confirm MySQL root password: ")"
if [ -z "${MYSQL_ROOT_PASSWORD}" ] || [ "${MYSQL_ROOT_PASSWORD}" != "${_confirm}" ]; then
	echo "MySQL root password empty or did not match." >&2
	exit 1
fi
unset _confirm

MYSQL_PASSWORD="$(prompt_secret "MySQL app (ot) password: ")"
_confirm="$(prompt_secret "Confirm MySQL app password: ")"
if [ -z "${MYSQL_PASSWORD}" ] || [ "${MYSQL_PASSWORD}" != "${_confirm}" ]; then
	echo "MySQL app password empty or did not match." >&2
	exit 1
fi
unset _confirm

OTSERVER_REF="${OTSERVER_REF:-master}"
OTSERVER_DIR="${OTSERVER_DIR:-/opt/otserver}"

echo
echo "Target:  ${SSH_USER}@${VPS_HOST}:${SSH_PORT}"
echo "Clone:   ${OTSERVER_REF} → ${OTSERVER_DIR}"
echo "User:    ${OTSERVER_USERNAME}"
echo "TLS CN:  ${SITE_DOMAIN}"
echo "LE email:${LETSENCRYPT_EMAIL:- (skip for now)}"
echo

# Bundle scripts + a runner on the VPS, then execute the runner as a *file*.
# That stays non-interactive even with ssh -t (needed for password auth).
# Piping into `bash -s` with a PTY made bash interactive and broke on `*)`.
REMOTE_BUNDLE="/tmp/otserver-pc-setup"
LOCAL_BUNDLE="$(mktemp -d "${TMPDIR:-/tmp}/otserver-pc-setup.XXXXXX")"
cleanup_local() {
	rm -rf "${LOCAL_BUNDLE}"
}
trap cleanup_local EXIT

cp "${BOOTSTRAP}" "${LOCAL_BUNDLE}/bootstrap-vps.sh"
cp "${SETUP_VPS}" "${LOCAL_BUNDLE}/setup-vps.sh"
chmod 700 "${LOCAL_BUNDLE}/bootstrap-vps.sh" "${LOCAL_BUNDLE}/setup-vps.sh"

# Runner embeds exports with bash %q so spaces/quotes in secrets are safe.
{
	printf '%s\n' '#!/usr/bin/env bash'
	printf '%s\n' 'set -euo pipefail'
	printf 'export GITHUB_TOKEN=%q\n' "${GITHUB_TOKEN}"
	printf 'export SITE_DOMAIN=%q\n' "${SITE_DOMAIN}"
	printf 'export SITE_DOMAIN_ALIASES=%q\n' "${SITE_DOMAIN_ALIASES:-baiakvip9.thefalked.dev}"
	printf 'export OTSERVER_REF=%q\n' "${OTSERVER_REF}"
	printf 'export OTSERVER_DIR=%q\n' "${OTSERVER_DIR}"
	printf 'export OTSERVER_USERNAME=%q\n' "${OTSERVER_USERNAME}"
	printf 'export OTSERVER_PASSWORD=%q\n' "${OTSERVER_PASSWORD}"
	printf 'export LETSENCRYPT_EMAIL=%q\n' "${LETSENCRYPT_EMAIL}"
	printf 'export MYSQL_ROOT_PASSWORD=%q\n' "${MYSQL_ROOT_PASSWORD}"
	printf 'export MYSQL_PASSWORD=%q\n' "${MYSQL_PASSWORD}"
	printf 'export OTSERVER_PC_SETUP_VPS=%q\n' "${REMOTE_BUNDLE}/setup-vps.sh"
	printf '%s\n' "exec bash $(printf '%q' "${REMOTE_BUNDLE}/bootstrap-vps.sh")"
} > "${LOCAL_BUNDLE}/run.sh"
chmod 700 "${LOCAL_BUNDLE}/run.sh"

SSH_OPTS=(-p "${SSH_PORT}" -o StrictHostKeyChecking=accept-new)
SCP_OPTS=(-P "${SSH_PORT}" -o StrictHostKeyChecking=accept-new)

echo "==> Uploading setup bundle to ${SSH_USER}@${VPS_HOST}:${REMOTE_BUNDLE}"
ssh -t "${SSH_OPTS[@]}" "${SSH_USER}@${VPS_HOST}" "rm -rf '${REMOTE_BUNDLE}' && mkdir -m 700 '${REMOTE_BUNDLE}'"
scp "${SCP_OPTS[@]}" \
	"${LOCAL_BUNDLE}/bootstrap-vps.sh" \
	"${LOCAL_BUNDLE}/setup-vps.sh" \
	"${LOCAL_BUNDLE}/run.sh" \
	"${SSH_USER}@${VPS_HOST}:${REMOTE_BUNDLE}/"

echo "==> Running remote setup"
# -t: allow password auth. Running a script *file* keeps bash non-interactive
# (unlike `bash -s` on a PTY, which broke on case `*)` globs).
ssh -t "${SSH_OPTS[@]}" "${SSH_USER}@${VPS_HOST}" \
	"bash '${REMOTE_BUNDLE}/run.sh'; ec=\$?; rm -rf '${REMOTE_BUNDLE}'; exit \$ec"

unset GITHUB_TOKEN OTSERVER_PASSWORD MYSQL_ROOT_PASSWORD MYSQL_PASSWORD
echo
echo "Remote setup finished. On the VPS later, as ${OTSERVER_USERNAME}:"
echo "  cd ${OTSERVER_DIR} && git pull"
echo "SSH:  ssh -p ${SSH_PORT} ${OTSERVER_USERNAME}@${VPS_HOST}"
