#!/usr/bin/env bash
# Save a GitHub HTTPS token for `git pull` on this private repo (opt-in).
#
# setup-vps.sh does **not** write ~/.git-credentials by default (H9). Prefer a
# deploy key. If you still want a stored PAT:
#   bash scripts/set-git-credentials.sh
# Or as root for that user:
#   sudo bash scripts/set-git-credentials.sh --user YOUR_SUDO_USER
# Bootstrap opt-in: OTSERVER_SAVE_GIT_CREDENTIALS=1 with GITHUB_TOKEN set.set -euo pipefail

TARGET_USER=""
TOKEN="${GITHUB_TOKEN:-}"

while [ "$#" -gt 0 ]; do
	case "$1" in
		--user)
			TARGET_USER="${2:-}"
			shift 2
			;;
		-h|--help)
			sed -n '2,12p' "$0"
			exit 0
			;;
		*)
			echo "Unknown argument: $1" >&2
			exit 1
			;;
	esac
done

if [ "$(id -u)" -eq 0 ]; then
	if [ -z "${TARGET_USER}" ]; then
		echo "Run as root with: sudo bash scripts/set-git-credentials.sh --user SUDO_USERNAME" >&2
		exit 1
	fi
else
	TARGET_USER="$(id -un)"
fi

if ! id -u "${TARGET_USER}" >/dev/null 2>&1; then
	echo "User ${TARGET_USER} does not exist." >&2
	exit 1
fi

USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
USER_HOME="${USER_HOME:-/home/${TARGET_USER}}"

prompt_secret() {
	local value=""
	if [ ! -e /dev/tty ] || ! { : > /dev/tty; } 2>/dev/null; then
		echo "Need a TTY, or export GITHUB_TOKEN and re-run." >&2
		exit 1
	fi
	printf '%s' "$1" > /dev/tty
	IFS= read -rs value < /dev/tty
	printf '\n' > /dev/tty
	printf '%s' "${value}"
}

if [ -z "${TOKEN}" ]; then
	TOKEN="$(prompt_secret "GitHub token (Contents: Read on this repo, input hidden): ")"
fi
if [ -z "${TOKEN}" ]; then
	echo "Token is required." >&2
	exit 1
fi

install -d -m 700 -o "${TARGET_USER}" -g "${TARGET_USER}" "${USER_HOME}"
printf 'https://x-access-token:%s@github.com\n' "${TOKEN}" > "${USER_HOME}/.git-credentials"
chown "${TARGET_USER}:${TARGET_USER}" "${USER_HOME}/.git-credentials"
chmod 600 "${USER_HOME}/.git-credentials"

if [ ! -f "${USER_HOME}/.gitconfig" ]; then
	install -m 600 -o "${TARGET_USER}" -g "${TARGET_USER}" /dev/null "${USER_HOME}/.gitconfig"
fi
sudo -u "${TARGET_USER}" git config --global credential.helper store

unset TOKEN
echo "Wrote ${USER_HOME}/.git-credentials (mode 600) for ${TARGET_USER}."
echo "Then: cd /opt/otserver && git pull"
