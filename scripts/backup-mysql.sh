#!/usr/bin/env bash
# Hot MySQL backup. does not stop MySQL or the game.
#
# Why this is safe to run while the server is up: InnoDB supports
# --single-transaction, which opens one consistent snapshot and dumps from
# that. It does not FLUSH TABLES WITH READ LOCK and does not shut the
# instance down. Players can stay online. Restore is a separate, offline step.
#
# Usage (from anywhere; finds the repo from this file's path):
#   ./scripts/backup-mysql.sh
#
# Env (optional):
#   BACKUP_KEEP_DAYS  how long to keep .sql.gz files (default 14)
#   BACKUP_DIR        destination directory (default <repo>/backups/mysql)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
CONTAINER="${MYSQL_CONTAINER:-otserver-mysql}"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-14}"
BACKUP_DIR="${BACKUP_DIR:-${REPO_ROOT}/backups/mysql}"

if [ ! -f "${ENV_FILE}" ]; then
	echo "Missing ${ENV_FILE}. Copy .env.example and set MYSQL_* first." >&2
	exit 1
fi

if ! printf '%s' "${KEEP_DAYS}" | grep -Eq '^[0-9]+$'; then
	echo "BACKUP_KEEP_DAYS must be a non-negative integer (got: ${KEEP_DAYS})." >&2
	exit 1
fi

# Pull only the keys we need so a weird .env line cannot rewrite PATH.
# Strips one matching layer of single or double quotes around the value.
env_val() {
	local raw
	raw="$(grep -E "^${1}=" "${ENV_FILE}" | tail -n1 | cut -d= -f2-)"
	case "${raw}" in
		\"*\") raw="${raw#\"}"; raw="${raw%\"}" ;;
		\'*\') raw="${raw#\'}"; raw="${raw%\'}" ;;
	esac
	printf '%s' "${raw}"
}

MYSQL_ROOT_PASSWORD="$(env_val MYSQL_ROOT_PASSWORD)"
MYSQL_DATABASE="$(env_val MYSQL_DATABASE)"
MYSQL_DATABASE="${MYSQL_DATABASE:-ot}"

if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
	echo "MYSQL_ROOT_PASSWORD is empty in .env." >&2
	exit 1
fi

if ! docker info >/dev/null 2>&1; then
	echo "Docker is not running (or this user cannot talk to it)." >&2
	exit 1
fi

if [ -z "$(docker ps -q -f "name=^${CONTAINER}$")" ]; then
	echo "Container ${CONTAINER} is not running. Start the stack first." >&2
	exit 1
fi

mkdir -p "${BACKUP_DIR}"
chmod 700 "${BACKUP_DIR}" || true
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="${BACKUP_DIR}/${MYSQL_DATABASE}-${STAMP}.sql.gz"
PARTIAL="${OUT}.partial"
trap 'rm -f "${PARTIAL}"' EXIT

echo "Dumping ${MYSQL_DATABASE} from ${CONTAINER} (single-transaction, server stays up)"
# MYSQL_PWD keeps the password out of the mysqldump argv (still visible in
# docker exec env). --quick streams rows instead of buffering a whole table.
docker exec -e MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" "${CONTAINER}" mysqldump \
	-uroot \
	--single-transaction \
	--quick \
	--routines \
	--triggers \
	--events \
	--hex-blob \
	--databases "${MYSQL_DATABASE}" \
	| gzip -c > "${PARTIAL}"

mv "${PARTIAL}" "${OUT}"
trap - EXIT
chmod 600 "${OUT}" || true
echo "Wrote ${OUT} ($(du -h "${OUT}" | awk '{print $1}'))"

# Rotate old dumps. -mtime is whole days; 14 means "older than 14 days".
find "${BACKUP_DIR}" -type f -name '*.sql.gz' -mtime "+${KEEP_DAYS}" -delete
echo "Kept dumps from the last ${KEEP_DAYS} days in ${BACKUP_DIR}"
echo "Copy these files off the VPS (another machine, object storage). A dump that only lives here dies with the disk."
