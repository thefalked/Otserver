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
#   AWS_CLI_IMAGE     docker image for R2 upload (default amazon/aws-cli:2)
#
# Offsite (optional, all four required to upload):
#   R2_ACCOUNT_ID R2_BUCKET R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY
#   R2_PREFIX     object key prefix (default mysql/)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
CONTAINER="${MYSQL_CONTAINER:-otserver-mysql}"
KEEP_DAYS="${BACKUP_KEEP_DAYS:-14}"
BACKUP_DIR="${BACKUP_DIR:-${REPO_ROOT}/backups/mysql}"
AWS_CLI_IMAGE="${AWS_CLI_IMAGE:-amazon/aws-cli:2}"

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

# Rotate old local dumps. -mtime is whole days; 14 means "older than 14 days".
find "${BACKUP_DIR}" -type f -name '*.sql.gz' -mtime "+${KEEP_DAYS}" -delete
echo "Kept dumps from the last ${KEEP_DAYS} days in ${BACKUP_DIR}"

R2_ACCOUNT_ID="$(env_val R2_ACCOUNT_ID)"
R2_BUCKET="$(env_val R2_BUCKET)"
R2_ACCESS_KEY_ID="$(env_val R2_ACCESS_KEY_ID)"
R2_SECRET_ACCESS_KEY="$(env_val R2_SECRET_ACCESS_KEY)"
R2_PREFIX="$(env_val R2_PREFIX)"
R2_PREFIX="${R2_PREFIX:-mysql/}"
case "${R2_PREFIX}" in
	*/) ;;
	*) R2_PREFIX="${R2_PREFIX}/" ;;
esac

r2_set=0
for _r2 in "${R2_ACCOUNT_ID}" "${R2_BUCKET}" "${R2_ACCESS_KEY_ID}" "${R2_SECRET_ACCESS_KEY}"; do
	if [ -n "${_r2}" ]; then
		r2_set=1
		break
	fi
done

if [ "${r2_set}" -eq 1 ]; then
	if [ -z "${R2_ACCOUNT_ID}" ] || [ -z "${R2_BUCKET}" ] || [ -z "${R2_ACCESS_KEY_ID}" ] || [ -z "${R2_SECRET_ACCESS_KEY}" ]; then
		echo "R2 upload enabled but incomplete. Set R2_ACCOUNT_ID, R2_BUCKET, R2_ACCESS_KEY_ID, and R2_SECRET_ACCESS_KEY in .env." >&2
		exit 1
	fi
	R2_KEY="${R2_PREFIX}$(basename "${OUT}")"
	R2_ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
	echo "Uploading to s3://${R2_BUCKET}/${R2_KEY} via ${AWS_CLI_IMAGE}"
	# One-shot container. No compose service. First run pulls the image.
	# Checksum env works around aws-cli v2 + R2 compatibility.
	docker run --rm \
		-e AWS_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID}" \
		-e AWS_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY}" \
		-e AWS_DEFAULT_REGION=auto \
		-e AWS_REQUEST_CHECKSUM_CALCULATION=WHEN_REQUIRED \
		-e AWS_RESPONSE_CHECKSUM_VALIDATION=WHEN_REQUIRED \
		-v "${OUT}:/backup/$(basename "${OUT}"):ro" \
		"${AWS_CLI_IMAGE}" \
		s3 cp "/backup/$(basename "${OUT}")" "s3://${R2_BUCKET}/${R2_KEY}" \
		--endpoint-url "${R2_ENDPOINT}"
	echo "Uploaded s3://${R2_BUCKET}/${R2_KEY}"
else
	echo "R2_* not set. Dump is local only. Copy it off this disk or set R2 credentials in .env."
fi
