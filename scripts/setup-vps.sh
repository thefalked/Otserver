#!/usr/bin/env bash
# =============================================================================
# OTServer VPS bootstrap
#
# What this is: one-shot hardening + tooling for a fresh Ubuntu/Debian VPS that
# will run this repo's Docker stack (MySQL + game + Gesior website + nginx).
#
# Why it exists: a default cloud image usually allows root SSH, has no firewall,
# and has no Docker. This script makes a sudo user, locks root out of SSH, opens
# only the ports the stack needs, and prepares nginx's self-signed cert.
#
# Also installs (no extra downtime by default):
#   fail2ban, unattended-upgrades (no auto-reboot), certbot, daily MySQL dump timer
# Follow-up: docs/vps.md (SSH keys, Let's Encrypt, backups).
#
# Run from your PC (this repo, Git Bash / macOS / Linux / WSL):
#   ./scripts/setup-from-pc.sh
# That collects every prompt on your laptop, SSHs into the VPS, clones with
# your GitHub token, and runs this file non-interactively.
#
# Already on the VPS as root, with the repo (and optionally GITHUB_TOKEN) set:
#   sudo bash scripts/setup-vps.sh
# Without OTSERVER_* / MYSQL_* env vars it will prompt on /dev/tty for:
#   1) sudo username
#   2) that user's password (twice)
#   3) website hostname (default baiakvip9.servegame.com — Enter to keep it)
#   4) Let's Encrypt email
#   5) MySQL root and app passwords
#
# Prefill without prompts (what setup-from-pc.sh exports):
#   OTSERVER_USERNAME OTSERVER_PASSWORD SITE_DOMAIN LETSENCRYPT_EMAIL
#   MYSQL_ROOT_PASSWORD MYSQL_PASSWORD  (and GITHUB_TOKEN for git credentials)
#
# Change the hostname later without re-running this: scripts/set-domain.sh
#
# Keep the current SSH session open until you can log in as the new user.
# Root SSH is turned off at the end of the SSH section. Password SSH stays on
# until you run scripts/disable-ssh-passwords.sh (see docs/vps.md).
# =============================================================================
set -euo pipefail

# Must be root: we change sshd, UFW, apt, and /etc/sudoers.d.
if [ "$(id -u)" -ne 0 ]; then
	echo "Run this script as root (sudo bash scripts/setup-vps.sh)." >&2
	exit 1
fi

# apt-get + ufw + get.docker.com are Debian/Ubuntu specific. Other distros
# (RHEL, Alpine) use different package managers and sshd paths.
. /etc/os-release
case "${ID:-}" in
	ubuntu|debian) ;;
	*)
		echo "This script supports Ubuntu/Debian. Detected: ${ID:-unknown}." >&2
		exit 1
		;;
esac

# Resolve repo root from this file's location so certs/.env work no matter
# what the current working directory is.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# apt/dpkg otherwise pop interactive dialogs (tzdata, needrestart) and hang
# an unattended VPS run. "a" = auto-restart services after upgrades.
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Read from /dev/tty so prompts still work if the script is piped
# (curl | bash) and stdin is not a terminal.
prompt() {
	local value=""
	if ! { : > /dev/tty; } 2>/dev/null; then
		echo "Need /dev/tty for prompts, or set OTSERVER_USERNAME / OTSERVER_PASSWORD / MYSQL_* (see ./scripts/setup-from-pc.sh)." >&2
		exit 1
	fi
	printf '%s' "$1" > /dev/tty
	IFS= read -r value < /dev/tty
	printf '%s' "${value}"
}

# Same as prompt(), but hides typing. Echo a newline afterwards because
# read -s does not print one.
prompt_secret() {
	local value=""
	if ! { : > /dev/tty; } 2>/dev/null; then
		echo "Need /dev/tty for prompts, or set OTSERVER_USERNAME / OTSERVER_PASSWORD / MYSQL_* (see ./scripts/setup-from-pc.sh)." >&2
		exit 1
	fi
	printf '%s' "$1" > /dev/tty
	IFS= read -rs value < /dev/tty
	printf '\n' > /dev/tty
	printf '%s' "${value}"
}

echo "=== OTServer VPS setup ==="
echo

# -----------------------------------------------------------------------------
# Prompts (or env from setup-from-pc.sh)
# Why validate the username: useradd/chpasswd/sudoers filenames break on
# spaces or uppercase-only names; we only allow a typical Unix login.
# -----------------------------------------------------------------------------
if [ -n "${OTSERVER_USERNAME:-}" ]; then
	USERNAME="${OTSERVER_USERNAME}"
	PASSWORD="${OTSERVER_PASSWORD:-}"
	SITE_DOMAIN="${SITE_DOMAIN:-baiakvip9.servegame.com}"
	# Separate LE cert for Dockhand / ops (not a SAN on the public cert).
	SITE_MAINTENANCE_DOMAIN="${SITE_MAINTENANCE_DOMAIN:-baiakvip9.thefalked.dev}"
	LETSENCRYPT_EMAIL="${LETSENCRYPT_EMAIL:-}"
	MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-}"
	MYSQL_PASSWORD="${MYSQL_PASSWORD:-}"
	echo "Using setup values from environment (non-interactive)."
else
	USERNAME="$(prompt "New sudo username: ")"
	PASSWORD="$(prompt_secret "Password for ${USERNAME}: ")"
	PASSWORD_CONFIRM="$(prompt_secret "Confirm password: ")"
	if [ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]; then
		echo "Passwords do not match." >&2
		exit 1
	fi
	unset PASSWORD_CONFIRM

	DEFAULT_SITE_DOMAIN="${SITE_DOMAIN:-baiakvip9.servegame.com}"
	SITE_DOMAIN_INPUT="$(prompt "Website hostname [${DEFAULT_SITE_DOMAIN}]: ")"
	SITE_DOMAIN="${SITE_DOMAIN_INPUT:-${DEFAULT_SITE_DOMAIN}}"
	SITE_MAINTENANCE_DOMAIN="${SITE_MAINTENANCE_DOMAIN:-baiakvip9.thefalked.dev}"

	LETSENCRYPT_EMAIL="$(prompt "Let's Encrypt email (Enter to skip HTTPS cert for now): ")"

	MYSQL_ROOT_PASSWORD="$(prompt_secret "MySQL root password: ")"
	MYSQL_ROOT_PASSWORD_CONFIRM="$(prompt_secret "Confirm MySQL root password: ")"
	if [ -z "${MYSQL_ROOT_PASSWORD}" ] || [ "${MYSQL_ROOT_PASSWORD}" != "${MYSQL_ROOT_PASSWORD_CONFIRM}" ]; then
		echo "MySQL root password empty or did not match." >&2
		exit 1
	fi
	MYSQL_PASSWORD="$(prompt_secret "MySQL app (ot) password: ")"
	MYSQL_PASSWORD_CONFIRM="$(prompt_secret "Confirm MySQL app password: ")"
	if [ -z "${MYSQL_PASSWORD}" ] || [ "${MYSQL_PASSWORD}" != "${MYSQL_PASSWORD_CONFIRM}" ]; then
		echo "MySQL app password empty or did not match." >&2
		exit 1
	fi
	unset MYSQL_ROOT_PASSWORD_CONFIRM MYSQL_PASSWORD_CONFIRM
fi

if ! printf '%s' "${USERNAME}" | grep -Eq '^[a-z_][a-z0-9_-]{0,31}$'; then
	echo "Invalid username. Use lowercase letters, digits, underscore, or hyphen." >&2
	exit 1
fi
if [ "${USERNAME}" = "root" ]; then
	echo "Pick a non-root username." >&2
	exit 1
fi
if [ -z "${PASSWORD}" ]; then
	echo "Password cannot be empty." >&2
	exit 1
fi
if [ -z "${MYSQL_ROOT_PASSWORD}" ] || [ -z "${MYSQL_PASSWORD}" ]; then
	echo "MYSQL_ROOT_PASSWORD and MYSQL_PASSWORD are required." >&2
	exit 1
fi

echo
echo "User:        ${USERNAME}"
echo "TLS CN:      ${SITE_DOMAIN}"
echo "TLS maint:   ${SITE_MAINTENANCE_DOMAIN:-"(none)"}"
echo "LE email:    ${LETSENCRYPT_EMAIL:-"(set later)"}"
echo "Open ports:  22, 80, 443, 8080, 2376, 7171, 7172"
echo

# -----------------------------------------------------------------------------
# Packages
# Why: a new image is often weeks behind on CVEs. git clones this repo;
# curl/ca-certificates fetch Docker's installer over HTTPS; openssl makes the
# site cert; sudo + ufw are not always installed on the slimmest images.
# --force-confold keeps existing config files if a package upgrade asks.
# -----------------------------------------------------------------------------
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
	ufw \
	fail2ban \
	unattended-upgrades \
	needrestart \
	certbot

# -----------------------------------------------------------------------------
# Sudo user  ("set up root for the new user")
# Why: daily work should not be as root. We still give this account full sudo
# so you can administer the box after PermitRootLogin is turned off.
# Idempotent: if the login already exists (re-run), only password/groups update.
# -----------------------------------------------------------------------------
echo "==> Creating sudo user ${USERNAME}"
if id -u "${USERNAME}" >/dev/null 2>&1; then
	echo "User ${USERNAME} already exists; updating password and groups."
else
	# -m home dir, bash so the account is usable for SSH/compose.
	useradd -m -s /bin/bash "${USERNAME}"
fi
echo "${USERNAME}:${PASSWORD}" | chpasswd
usermod -aG sudo "${USERNAME}"
# Drop-in sudoers file: full root via `sudo`. Requires their password (not
# NOPASSWD) so a stolen session still needs the login secret to escalate.
printf '%s ALL=(ALL:ALL) ALL\n' "${USERNAME}" > "/etc/sudoers.d/90-${USERNAME}"
chmod 440 "/etc/sudoers.d/90-${USERNAME}"
# visudo -c rejects a broken sudoers file before it can lock you out of sudo.
visudo -cf "/etc/sudoers.d/90-${USERNAME}" >/dev/null

# Cloud images often put your laptop key on root only. Copy it so the new
# user can SSH with that same key after root login is disabled.
if [ -f /root/.ssh/authorized_keys ]; then
	install -d -m 700 -o "${USERNAME}" -g "${USERNAME}" "/home/${USERNAME}/.ssh"
	install -m 600 -o "${USERNAME}" -g "${USERNAME}" \
		/root/.ssh/authorized_keys "/home/${USERNAME}/.ssh/authorized_keys"
	echo "Copied root authorized_keys to ${USERNAME}."
fi

# -----------------------------------------------------------------------------
# Docker
# Why: the game, website, MySQL, and nginx all run via docker compose.
# get.docker.com installs docker-ce + the Compose v2 plugin (`docker compose`).
# docker group: this user can run compose without sudo. They must log out/in
# (or ssh again) before the new group membership applies.
# -----------------------------------------------------------------------------
echo "==> Installing Docker"
if command -v docker >/dev/null 2>&1; then
	echo "Docker already installed: $(docker --version)"
else
	# Download then run (not curl|sh) so a failed fetch cannot pipe partial script.
	# Still trusts get.docker.com — pin/mirror yourself if you need stronger supply-chain controls.
	_docker_install="$(mktemp)"
	trap 'rm -f "${_docker_install}"' EXIT
	curl -fsSL https://get.docker.com -o "${_docker_install}"
	sh "${_docker_install}"
	rm -f "${_docker_install}"
	trap - EXIT
fi
usermod -aG docker "${USERNAME}"

# -----------------------------------------------------------------------------
# SSH: disable root login
# Why: bots hammer password guesses on root@port 22. We only do this AFTER the
# sudo user exists so this session is not the last way in.
#
# OpenSSH "first value wins". Drop-ins in sshd_config.d are included from the
# top of sshd_config, so a file named 00-* is parsed before Ubuntu cloud-init's
# 50-cloud-init.conf (which often sets PasswordAuthentication no).
#
# PasswordAuthentication is left ON on purpose: you just set a password and
# may not have a key yet. Switch it to `no` once key login works (fail2ban
# + keys are the follow-up hardening).
# -----------------------------------------------------------------------------
echo "==> Disabling SSH root login"
install -d -m 755 /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/00-otserver-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
EOF
# Belt-and-suspenders: cloud-init's drop-in would otherwise win on some images
# if Include order ever changes.
if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
	sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication yes/' \
		/etc/ssh/sshd_config.d/50-cloud-init.conf
fi
if [ -f /etc/ssh/sshd_config ]; then
	sed -i 's/^[#[:space:]]*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
fi
# Test config before reload: a typo here can drop SSH entirely.
sshd -t
# Ubuntu 24.04 unit is `ssh`; Debian/older often `sshd`. Reload, don't restart,
# so the current root session stays up.
if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^ssh.service'; then
	systemctl reload ssh
elif systemctl list-unit-files --type=service 2>/dev/null | grep -q '^sshd.service'; then
	systemctl reload sshd
else
	service ssh reload 2>/dev/null || service sshd reload
fi

# -----------------------------------------------------------------------------
# fail2ban
# Why: password SSH is still on until you switch to keys. Bots will hit port
# 22; fail2ban bans the IP after a few failures so they do not get unlimited
# guesses. systemd backend reads the journal (Ubuntu/Debian default for sshd).
# Game ports are raw TCP and are not covered by this jail.
# -----------------------------------------------------------------------------
echo "==> Enabling fail2ban (sshd)"
install -d -m 755 /etc/fail2ban/jail.d
cat > /etc/fail2ban/jail.d/otserver.local <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port    = ssh
filter  = sshd
backend = systemd
EOF
if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^fail2ban.service'; then
	systemctl enable --now fail2ban || echo "warning: fail2ban did not start"
	systemctl reload fail2ban 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# Unattended upgrades (apply patches, do not reboot)
# Why: you asked for updates with as little downtime as possible. Security and
# -updates install daily. Automatic-Reboot stays false so a kernel package
# never bounces the VPS on its own. needrestart is told not to restart docker,
# containerd, or ssh — those would drop the game or this admin session.
# You still reboot later when you choose, if a kernel update is waiting.
# -----------------------------------------------------------------------------
echo "==> Enabling unattended-upgrades (no automatic reboot)"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
cat > /etc/apt/apt.conf.d/51otserver-unattended <<'EOF'
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-WithUsers "false";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::SyslogEnable "true";
EOF
if [ -f /etc/apt/apt.conf.d/50unattended-upgrades ]; then
	# Enable the regular -updates pocket (security is already on by default).
	sed -i '/codename}-updates"/s|^//[[:space:]]*||' /etc/apt/apt.conf.d/50unattended-upgrades
	sed -i 's#^//\s*Unattended-Upgrade::Automatic-Reboot "false"#Unattended-Upgrade::Automatic-Reboot "false"#' \
		/etc/apt/apt.conf.d/50unattended-upgrades || true
fi
install -d -m 755 /etc/needrestart/conf.d
cat > /etc/needrestart/conf.d/otserver.conf <<'EOF'
# 0 = do not restart this unit when libraries it uses were upgraded.
$nrconf{override_rc}->{qr(^docker)} = 0;
$nrconf{override_rc}->{qr(^containerd)} = 0;
$nrconf{override_rc}->{qr(^ssh$)} = 0;
$nrconf{override_rc}->{qr(^sshd$)} = 0;
EOF
if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^unattended-upgrades.service'; then
	systemctl enable --now unattended-upgrades
fi

# -----------------------------------------------------------------------------
# UFW firewall
# Why: default-deny incoming so random services are not reachable. Then allow
# only what this stack uses:
#   22    SSH
#   80    HTTP (nginx redirects to HTTPS on the VPS overlay)
#   443   HTTPS Gesior site
#   8080  HTTP Gesior (legacy / until you drop it)
#   2376  Hawser / Dockhand agent (TLS + TOKEN; prefer restrict to your IP later)
#   7171  OT login protocol (raw TCP, not HTTP)
#   7172  OT game protocol
# MySQL 3306 is NOT opened — it stays on the Docker network only.
#
# --force enable skips the "did you allow SSH?" yes/no prompt so we cannot
# hang, and 22 is already allowed above so we should not lock ourselves out.
#
# Caveat: Docker publishes ports via its own iptables rules and can bypass
# UFW for those published ports. Safety here is also "do not publish extra
# compose ports" (no 3306, no Docker API).
# -----------------------------------------------------------------------------
echo "==> Configuring UFW (deny incoming, allow SSH + site + game)"
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 8080/tcp comment 'Website HTTP'
ufw allow 2376/tcp comment 'Hawser Dockhand'
ufw allow 7171/tcp comment 'OT login'
ufw allow 7172/tcp comment 'OT game'
ufw --force enable
ufw status verbose

# -----------------------------------------------------------------------------
# Self-signed TLS for docker nginx
# Why: browsers/clients talking to Gesior on 443 need a cert. Let's Encrypt
# needs a public domain + inbound 80; a brand-new VPS often has neither yet.
# Self-signed gets HTTPS working immediately. Browsers will warn until you
# replace docker/nginx/certs/*.pem with a real cert.
#
# Skip generation if files already exist so a re-run does not rotate the cert
# (which would surprise anyone who already accepted it).
# The nginx container also generates a cert on first start if these are empty.
# -----------------------------------------------------------------------------
CERT_DIR="${REPO_ROOT}/docker/nginx/certs"
if [ -d "${REPO_ROOT}/docker/nginx" ]; then
	echo "==> Writing self-signed certificate for nginx"
	mkdir -p "${CERT_DIR}"
	if [ ! -f "${CERT_DIR}/fullchain.pem" ] || [ ! -f "${CERT_DIR}/privkey.pem" ]; then
		# SAN must list every name/IP you will type in the browser, or the
		# cert warning is worse (name mismatch on top of "untrusted CA").
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

# ACME webroot for HTTP-01. nginx.conf serves this on :80; certbot writes here.
# :ro in compose is fine — certbot runs on the host, not in the container.
install -d -m 755 -o "${USERNAME}" -g "${USERNAME}" "${REPO_ROOT}/docker/nginx/acme"

# -----------------------------------------------------------------------------
# Let's Encrypt machinery (issue later — DNS + nginx :80 must exist first)
# Why not issue now: this script runs before compose is up. HTTP-01 would fail.
# certbot.timer renews twice daily; the deploy hook copies pems and reloads
# nginx (no container restart, game stays up).
# -----------------------------------------------------------------------------
echo "==> Installing Let's Encrypt renew hook"
install -d -m 755 /etc/letsencrypt/renewal-hooks/deploy
cat > /etc/letsencrypt/renewal-hooks/deploy/otserver-nginx.sh <<EOF
#!/bin/sh
exec "${REPO_ROOT}/scripts/install-letsencrypt-certs.sh"
EOF
chmod 755 /etc/letsencrypt/renewal-hooks/deploy/otserver-nginx.sh
if systemctl list-unit-files --type=timer 2>/dev/null | grep -q '^certbot.timer'; then
	systemctl enable --now certbot.timer
fi

# -----------------------------------------------------------------------------
# Daily MySQL hot dump
# Why a timer: mysqldump --single-transaction does not stop MySQL. 04:15 UTC
# is an off-peak default. Files go to backups/mysql/; copy them off-box.
# -----------------------------------------------------------------------------
echo "==> Installing daily MySQL backup timer"
cat > /etc/systemd/system/otserver-mysql-backup.service <<EOF
[Unit]
Description=OTServer MySQL hot dump (no downtime)
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
WorkingDirectory=${REPO_ROOT}
ExecStart=${REPO_ROOT}/scripts/backup-mysql.sh
EOF
cat > /etc/systemd/system/otserver-mysql-backup.timer <<'EOF'
[Unit]
Description=Daily OTServer MySQL hot dump

[Timer]
OnCalendar=*-*-* 04:15:00
Persistent=true
RandomizedDelaySec=10m

[Install]
WantedBy=timers.target
EOF
if command -v systemctl >/dev/null 2>&1; then
	systemctl daemon-reload
	systemctl enable --now otserver-mysql-backup.timer
fi

# -----------------------------------------------------------------------------
# .env for docker compose
# Why: compose requires .env (see docker-compose.yml env_file). Copying the
# example avoids a first-up failure. SITE_DOMAIN feeds the nginx cert SAN.
# COMPOSE_FILE adds docker-compose.vps.yml so host 80/443 are published
# (local compose leaves those off so a busy laptop port 80 does not break up).
# MYSQL_* are left empty on purpose — you must set them before `compose up`.
# -----------------------------------------------------------------------------
upsert_env() {
	local file="$1" key="$2" value="$3"
	local tmp owner group mode
	tmp="$(mktemp)"
	if [ -f "${file}" ]; then
		owner="$(stat -c '%u' "${file}")"
		group="$(stat -c '%g' "${file}")"
		mode="$(stat -c '%a' "${file}")"
		grep -v "^${key}=" "${file}" > "${tmp}" || true
	else
		owner="$(stat -c '%u' "$(dirname "${file}")" 2>/dev/null || echo 0)"
		group="$(stat -c '%g' "$(dirname "${file}")" 2>/dev/null || echo 0)"
		mode=600
		: > "${tmp}"
	fi
	printf '%s=%s\n' "${key}" "${value}" >> "${tmp}"
	install -m "${mode}" -o "${owner}" -g "${group}" "${tmp}" "${file}"
	rm -f "${tmp}"
}

if [ -f "${REPO_ROOT}/.env.example" ]; then
	if [ ! -f "${REPO_ROOT}/.env" ]; then
		cp "${REPO_ROOT}/.env.example" "${REPO_ROOT}/.env"
	fi
	upsert_env "${REPO_ROOT}/.env" SITE_DOMAIN "${SITE_DOMAIN}"
	upsert_env "${REPO_ROOT}/.env" OT_IP "${SITE_DOMAIN}"
	upsert_env "${REPO_ROOT}/.env" SITE_MAINTENANCE_DOMAIN "${SITE_MAINTENANCE_DOMAIN:-baiakvip9.thefalked.dev}"
	upsert_env "${REPO_ROOT}/.env" LETSENCRYPT_EMAIL "${LETSENCRYPT_EMAIL}"
	upsert_env "${REPO_ROOT}/.env" MYSQL_ROOT_PASSWORD "${MYSQL_ROOT_PASSWORD}"
	upsert_env "${REPO_ROOT}/.env" MYSQL_PASSWORD "${MYSQL_PASSWORD}"
	upsert_env "${REPO_ROOT}/.env" COMPOSE_FILE "docker-compose.yml:docker-compose.vps.yml"
	chown "${USERNAME}:${USERNAME}" "${REPO_ROOT}/.env" || true
	chmod 600 "${REPO_ROOT}/.env" || true
fi

# Hawser host bits (config, stacks dir, UFW, stop systemd). Compose starts the
# container in the "up --build" step below. Existing VPSes: scripts/setup-hawser.sh
SUDO_USER="${USERNAME}" bash "${REPO_ROOT}/scripts/setup-hawser.sh" --host-only

# Fresh clone is root-owned. Hand the tree to the sudo user so they can
# git pull and docker compose without extra root.
if [ "$(stat -c %u "${REPO_ROOT}" 2>/dev/null || echo 0)" = "0" ]; then
	echo "==> Giving ${USERNAME} ownership of ${REPO_ROOT}"
	chown -R "${USERNAME}:${USERNAME}" "${REPO_ROOT}"
fi

# Persist GitHub HTTPS auth for the sudo user (remote URL stays token-free).
# They can later: cd /opt/otserver && git pull
if [ -n "${GITHUB_TOKEN:-}" ]; then
	echo "==> Saving git credentials for ${USERNAME} (git pull on this private repo)"
	USER_HOME="$(getent passwd "${USERNAME}" | cut -d: -f6)"
	USER_HOME="${USER_HOME:-/home/${USERNAME}}"
	install -d -m 700 -o "${USERNAME}" -g "${USERNAME}" "${USER_HOME}"
	# Plaintext token in this file (mode 600). Anyone who can read it can clone/pull.
	printf 'https://x-access-token:%s@github.com\n' "${GITHUB_TOKEN}" > "${USER_HOME}/.git-credentials"
	chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.git-credentials"
	chmod 600 "${USER_HOME}/.git-credentials"
	if [ ! -f "${USER_HOME}/.gitconfig" ]; then
		install -m 600 -o "${USERNAME}" -g "${USERNAME}" /dev/null "${USER_HOME}/.gitconfig"
	fi
	sudo -u "${USERNAME}" git config --global credential.helper store
	sudo -u "${USERNAME}" git config --global --add safe.directory "${REPO_ROOT}" || true
fi

# -----------------------------------------------------------------------------
# Start the stack and (optional) Let's Encrypt
# Why here: you asked for the script to finish setup, not leave compose/certs
# as a manual step. First image build can take several minutes.
# docker compose as root: the new user is in group docker but this session
# would not see that group until they log in again.
# -----------------------------------------------------------------------------
echo "==> Starting Docker and the compose stack (first build can take a while)"
if command -v systemctl >/dev/null 2>&1; then
	systemctl enable --now docker 2>/dev/null || true
fi
# Wait until the daemon answers (get.docker.com has just installed it).
for _i in 1 2 3 4 5 6 7 8 9 10; do
	docker info >/dev/null 2>&1 && break
	sleep 2
done
(
	cd "${REPO_ROOT}"
	docker compose up --build -d
)

if [ -n "${LETSENCRYPT_EMAIL}" ]; then
	echo "==> Waiting for nginx, then requesting a Let's Encrypt cert for ${SITE_DOMAIN}"
	for _i in $(seq 1 36); do
		if docker ps -q -f 'name=^otserver-nginx$' | grep -q .; then
			break
		fi
		sleep 5
	done
	if bash "${REPO_ROOT}/scripts/setup-letsencrypt.sh"; then
		echo "Let's Encrypt installed."
	else
		echo "Let's Encrypt step failed. Cert may already be issued under /etc/letsencrypt/live/${SITE_DOMAIN}/." >&2
		echo "Check DNS/port 80, then: sudo bash ${REPO_ROOT}/scripts/setup-letsencrypt.sh" >&2
		echo "Or only install existing certs: sudo bash ${REPO_ROOT}/scripts/install-letsencrypt-certs.sh" >&2
	fi
fi

unset PASSWORD PASSWORD_CONFIRM OTSERVER_PASSWORD MYSQL_ROOT_PASSWORD MYSQL_PASSWORD GITHUB_TOKEN

echo
echo "=== Done ==="
echo "Root SSH login is disabled. Keep this session open until you can log in as ${USERNAME}."
echo
echo "On the VPS as ${USERNAME}:"
echo "  cd ${REPO_ROOT}"
echo "  git pull                  # token in ~${USERNAME}/.git-credentials (mode 600; treat like a secret)"
echo "  docker compose ps"
echo
echo "Change hostname later:  sudo bash scripts/set-domain.sh new.example.com"
echo
echo "SSH keys (do this soon):  docs/vps.md"
echo "  ssh-copy-id -i ~/.ssh/id_ed25519.pub ${USERNAME}@<this-host>"
echo "  sudo bash scripts/disable-ssh-passwords.sh   # only after a key login works"
echo
echo "Open:"
echo "  https://${SITE_DOMAIN}/"
echo "  http://${SITE_DOMAIN}:8080/"
echo "  TCP ${SITE_DOMAIN}:7171 / 7172"
echo
echo "Log in from another terminal before closing this one:"
echo "  ssh ${USERNAME}@<this-host>"
