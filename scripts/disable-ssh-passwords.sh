#!/usr/bin/env bash
# Turn off SSH password logins after you have confirmed key-based login.
#
# Why not do this in setup-vps.sh: that script creates a password for a brand
# new user. Disabling passwords before you have a working key would lock you
# out. See docs/vps.md for generating keys and adding them.
#
# Run as root, from a session that already used a key (keep that session open):
#   sudo bash scripts/disable-ssh-passwords.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
	echo "Run as root: sudo bash scripts/disable-ssh-passwords.sh" >&2
	exit 1
fi

# Only count keys for non-root users. Root SSH is disabled by setup-vps.sh
# (PermitRootLogin no); keys under /root/.ssh cannot save you after that.
key_count=0
for keys in /home/*/.ssh/authorized_keys; do
	[ -f "${keys}" ] || continue
	# Count real key lines (ssh-ed25519 / ssh-rsa / ecdsa / sk-).
	c="$(grep -cE '^(ssh-(ed25519|rsa)|ecdsa-sha2-|sk-ssh-)' "${keys}" || true)"
	key_count="$((key_count + c))"
done

if [ "${key_count}" -lt 1 ]; then
	echo "No SSH public keys found in /home/*/.ssh/authorized_keys." >&2
	echo "Add a key for your sudo user first (docs/vps.md). Aborting so you are not locked out." >&2
	if [ -f /root/.ssh/authorized_keys ]; then
		echo "(Root has authorized_keys, but PermitRootLogin is off. those keys do not count.)" >&2
	fi
	exit 1
fi

echo "Found ${key_count} authorized SSH key(s) under /home. Disabling password authentication."
echo "Keep this SSH session open. Test a NEW login with a key before you disconnect."

install -d -m 755 /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/00-otserver-hardening.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
EOF

if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
	sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication no/' \
		/etc/ssh/sshd_config.d/50-cloud-init.conf
fi
if [ -f /etc/ssh/sshd_config ]; then
	sed -i 's/^[#[:space:]]*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
	sed -i 's/^[#[:space:]]*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
fi

sshd -t
if systemctl list-unit-files --type=service 2>/dev/null | grep -q '^ssh.service'; then
	systemctl reload ssh
elif systemctl list-unit-files --type=service 2>/dev/null | grep -q '^sshd.service'; then
	systemctl reload sshd
else
	service ssh reload 2>/dev/null || service sshd reload
fi

echo "Password SSH is off. In another terminal: ssh -o PreferredAuthentications=publickey USER@HOST"
