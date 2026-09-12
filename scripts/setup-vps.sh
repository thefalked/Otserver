#!/usr/bin/env bash
# Bootstrap a fresh Ubuntu/Debian VPS for this OTServer stack:
#   apt update/upgrade, git + Docker, sudo user, SSH root lockout, UFW, nginx certs.
# Run as root:  sudo bash scripts/setup-vps.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run this script as root (sudo bash scripts/setup-vps.sh)." >&2
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

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

echo "=== OTServer VPS setup ==="
echo

USERNAME="$(prompt "New sudo username: ")"
if ! printf '%s' "${USERNAME}" | grep -Eq '^[a-z_][a-z0-9_-]{0,31}$'; then
	echo "Invalid username. Use lowercase letters, digits, underscore, or hyphen." >&2
	exit 1
fi
if [ "${USERNAME}" = "root" ]; then
	echo "Pick a non-root username." >&2
	exit 1
fi

PASSWORD="$(prompt_secret "Password for ${USERNAME}: ")"
PASSWORD_CONFIRM="$(prompt_secret "Confirm password: ")"
if [ -z "${PASSWORD}" ]; then
	echo "Password cannot be empty." >&2
	exit 1
fi
if [ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]; then
	echo "Passwords do not match." >&2
	exit 1
fi

DEFAULT_DOMAIN="$(hostname -f 2>/dev/null || hostname || echo localhost)"
SITE_DOMAIN_INPUT="$(prompt "Website hostname for the TLS certificate [${DEFAULT_DOMAIN}]: ")"
SITE_DOMAIN="${SITE_DOMAIN_INPUT:-${DEFAULT_DOMAIN}}"

echo
echo "User:        ${USERNAME}"
echo "TLS CN:      ${SITE_DOMAIN}"
echo "Open ports:  22, 80, 443, 8080, 7171, 7172"
echo

# --- packages ----------------------------------------------------------------
echo "==> Updating and upgrading packages"
apt-get update -y
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	git \
	gnupg \
	openssl \
	sudo \
	ufw

# --- sudo user ---------------------------------------------------------------
echo "==> Creating sudo user ${USERNAME}"
if id -u "${USERNAME}" >/dev/null 2>&1; then
	echo "User ${USERNAME} already exists; updating password and groups."
else
	useradd -m -s /bin/bash "${USERNAME}"
fi
echo "${USERNAME}:${PASSWORD}" | chpasswd
usermod -aG sudo "${USERNAME}"
printf '%s ALL=(ALL:ALL) ALL\n' "${USERNAME}" > "/etc/sudoers.d/90-${USERNAME}"
chmod 440 "/etc/sudoers.d/90-${USERNAME}"
visudo -cf "/etc/sudoers.d/90-${USERNAME}" >/dev/null

if [ -f /root/.ssh/authorized_keys ]; then
	install -d -m 700 -o "${USERNAME}" -g "${USERNAME}" "/home/${USERNAME}/.ssh"
	install -m 600 -o "${USERNAME}" -g "${USERNAME}" \
		/root/.ssh/authorized_keys "/home/${USERNAME}/.ssh/authorized_keys"
	echo "Copied root authorized_keys to ${USERNAME}."
fi

# --- Docker ------------------------------------------------------------------
echo "==> Installing Docker"
if command -v docker >/dev/null 2>&1; then
	echo "Docker already installed: $(docker --version)"
else
	curl -fsSL https://get.docker.com | sh
fi
usermod -aG docker "${USERNAME}"

# --- SSH: disable root login (after the sudo user exists) --------------------
echo "==> Disabling SSH root login"
install -d -m 755 /etc/ssh/sshd_config.d
# OpenSSH uses first-value-wins; 00- beats cloud-init's 50-cloud-init.conf.
cat > /etc/ssh/sshd_config.d/00-otserver-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
EOF
if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
	sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/' \
		/etc/ssh/sshd_config.d/50-cloud-init.conf
fi
if [ -f /etc/ssh/sshd_config ]; then
	sed -i 's/^[#[:space:]]*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
fi
sshd -t
if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^ssh.service'; then
	systemctl reload ssh
elif systemctl list-unit-files --type=service 2>/dev/null | grep -q '^sshd.service'; then
	systemctl reload sshd
else
	service ssh reload 2>/dev/null || service sshd reload
fi

# --- UFW ---------------------------------------------------------------------
echo "==> Configuring UFW (deny incoming, allow SSH + site + game)"
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 8080/tcp comment 'Website HTTP'
ufw allow 7171/tcp comment 'OT login'
ufw allow 7172/tcp comment 'OT game'
ufw --force enable
ufw status verbose

# --- TLS material for docker nginx ------------------------------------------
CERT_DIR="${REPO_ROOT}/docker/nginx/certs"
if [ -d "${REPO_ROOT}/docker/nginx" ]; then
	echo "==> Writing self-signed certificate for nginx"
	mkdir -p "${CERT_DIR}"
	if [ ! -f "${CERT_DIR}/fullchain.pem" ] || [ ! -f "${CERT_DIR}/privkey.pem" ]; then
		SAN="DNS:localhost,IP:127.0.0.1"
		if printf '%s' "${SITE_DOMAIN}" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$'; then
			SAN="${SAN},IP:${SITE_DOMAIN}"
		else
			SAN="${SAN},DNS:${SITE_DOMAIN}"
		fi
		openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
			-keyout "${CERT_DIR}/privkey.pem" \
			-out "${CERT_DIR}/fullchain.pem" \
			-subj "/CN=${SITE_DOMAIN}" \
			-addext "subjectAltName=${SAN}"
		chmod 644 "${CERT_DIR}/fullchain.pem"
		chmod 600 "${CERT_DIR}/privkey.pem"
	else
		echo "Certificate already exists in ${CERT_DIR}; leaving it in place."
	fi
	chown -R "${USERNAME}:${USERNAME}" "${CERT_DIR}" || true
fi

upsert_env() {
	local file="$1" key="$2" value="$3"
	if [ ! -f "${file}" ]; then
		return 0
	fi
	if grep -q "^${key}=" "${file}"; then
		sed -i "s|^${key}=.*|${key}=${value}|" "${file}"
	else
		printf '\n%s=%s\n' "${key}" "${value}" >> "${file}"
	fi
}

if [ -f "${REPO_ROOT}/.env.example" ]; then
	if [ ! -f "${REPO_ROOT}/.env" ]; then
		cp "${REPO_ROOT}/.env.example" "${REPO_ROOT}/.env"
		echo "Created ${REPO_ROOT}/.env — set MYSQL_* and OT_IP before starting compose."
	fi
	upsert_env "${REPO_ROOT}/.env" SITE_DOMAIN "${SITE_DOMAIN}"
	upsert_env "${REPO_ROOT}/.env" COMPOSE_FILE "docker-compose.yml:docker-compose.vps.yml"
	chown "${USERNAME}:${USERNAME}" "${REPO_ROOT}/.env" || true
fi

unset PASSWORD PASSWORD_CONFIRM

echo
echo "=== Done ==="
echo "Root SSH login is disabled. Keep this session open until you can log in as ${USERNAME}."
echo
echo "Next (as ${USERNAME}):"
echo "  cd ${REPO_ROOT}"
echo "  nano .env          # MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD, OT_IP=${SITE_DOMAIN}"
echo "  docker compose up --build -d"
echo
echo "Open:"
echo "  https://${SITE_DOMAIN}/     (self-signed — browser warning is expected)"
echo "  http://${SITE_DOMAIN}:8080/ (HTTP reverse proxy)"
echo "  TCP ${SITE_DOMAIN}:7171 / 7172 (game, via nginx stream)"
echo
echo "Log in from another terminal before closing this one:"
echo "  ssh ${USERNAME}@<this-host>"
