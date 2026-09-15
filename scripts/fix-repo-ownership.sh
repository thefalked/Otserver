#!/usr/bin/env bash
# Restore repo tree ownership so `git pull` works as the deploy user.
# Docker bind mounts + container entrypoints must not leave website/ (etc.) as root.
#
#   sudo bash scripts/fix-repo-ownership.sh
#   sudo bash scripts/fix-repo-ownership.sh /opt/otserver
#
# Safe to re-run. Does not restart containers.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root: sudo bash scripts/fix-repo-ownership.sh" >&2
	exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${1:-${SCRIPT_DIR}/..}" && pwd)"

OWNER="${SUDO_USER:-}"
if [ -z "${OWNER}" ] || [ "${OWNER}" = "root" ]; then
	OWNER="$(stat -c '%U' "${REPO_ROOT}" 2>/dev/null || echo "")"
fi
if [ -z "${OWNER}" ] || [ "${OWNER}" = "root" ]; then
	echo "Cannot resolve deploy user (SUDO_USER / repo owner). Set SUDO_USER or chown the repo first." >&2
	exit 1
fi
if ! id "${OWNER}" >/dev/null 2>&1; then
	echo "User ${OWNER} does not exist." >&2
	exit 1
fi

echo "==> chown -R ${OWNER}:${OWNER} ${REPO_ROOT}"
chown -R "${OWNER}:${OWNER}" "${REPO_ROOT}"

# Website RW bind mounts: keep deploy ownership, allow container www-data (uid 33) to write.
WEB="${REPO_ROOT}/website"
for rel in cache guilds images/head bdsave config; do
	dir="${WEB}/${rel}"
	mkdir -p "${dir}"
	chown -R "${OWNER}:${OWNER}" "${dir}"
	chmod -R a+rwX "${dir}" 2>/dev/null || true
done

# OT logs volume is inside Docker; bind-mounted data should stay deploy-owned and writable.
if [ -d "${REPO_ROOT}/server/data" ]; then
	chmod -R u+rwX,a+rX "${REPO_ROOT}/server/data" 2>/dev/null || true
	# Paths TFS writes at runtime
	for rel in logs world; do
		d="${REPO_ROOT}/server/data/${rel}"
		if [ -d "${d}" ]; then
			chmod -R a+rwX "${d}" 2>/dev/null || true
		fi
	done
fi

echo "Repo owned by ${OWNER}. You can: git pull (as ${OWNER})"
