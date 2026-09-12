#!/bin/sh
set -eu

CERT_DIR=/etc/nginx/certs
CERT="${CERT_DIR}/fullchain.pem"
KEY="${CERT_DIR}/privkey.pem"
DOMAIN="${SITE_DOMAIN:-localhost}"
OT_IP="${OT_IP:-127.0.0.1}"

is_ipv4() {
	echo "$1" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'
}

san_entry() {
	if is_ipv4 "$1"; then
		echo "IP:$1"
	else
		echo "DNS:$1"
	fi
}

mkdir -p "${CERT_DIR}"

if [ ! -f "${CERT}" ] || [ ! -f "${KEY}" ]; then
	echo "Generating self-signed certificate for ${DOMAIN} (OT_IP=${OT_IP})"
	SAN="$(san_entry "${DOMAIN}"),$(san_entry localhost),IP:127.0.0.1"
	if [ -n "${OT_IP}" ] && [ "${OT_IP}" != "${DOMAIN}" ] && [ "${OT_IP}" != "localhost" ]; then
		SAN="${SAN},$(san_entry "${OT_IP}")"
	fi

	openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
		-keyout "${KEY}" \
		-out "${CERT}" \
		-subj "/CN=${DOMAIN}" \
		-addext "subjectAltName=${SAN}"
	chmod 644 "${CERT}"
	chmod 600 "${KEY}" || true
fi

exec nginx -g 'daemon off;'
