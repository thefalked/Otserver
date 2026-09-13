# VPS ops: first boot, domain, updates, SSH keys, Let's Encrypt, MySQL backups

## Empty VPS (run setup from your PC)

The repo is private. Do **not** anonymous-clone on the VPS. From this repo on your **laptop** (Git Bash / macOS / Linux / WSL):

```bash
./scripts/setup-from-pc.sh
```

That script asks you for:

1. VPS IP/hostname, SSH user (`root` on a new machine), SSH port
2. GitHub token (hidden) — fine-grained **Contents: Read-only** on this repo, or classic `repo`

It then SSHs in (host key / VPS root password if the provider did not inject your laptop key). On the server it installs git, clones into `/opt/otserver` (full history), and runs `setup-vps.sh`, which asks for the sudo user, passwords, hostname (default **baiakvip9.thefalked.dev**), Let’s Encrypt email, and MySQL passwords. It also starts Docker Compose and tries Let’s Encrypt if you gave an email.

The token is stored only as `~sudo-user/.git-credentials` (mode 600), not in `git remote`. Anyone who can read that file can `git pull` this private repo — treat it like a secret. Later:

```bash
ssh USER@VPS
cd /opt/otserver
git pull
```

If you are already root on the VPS with `GITHUB_TOKEN` set: `sudo bash scripts/setup-vps.sh`.

## Change the hostname later

DNS and the `.env` values are not frozen. After bootstrap:

```bash
sudo bash scripts/set-domain.sh                      # prompt
sudo bash scripts/set-domain.sh play.example.com     # set SITE_DOMAIN + OT_IP
sudo bash scripts/set-domain.sh play.example.com --keep-ot-ip
```

`set-domain.sh` restarts `otserver` so game clients get the new `OT_IP`. Then point DNS at the VPS and issue a cert for the new name:

```bash
sudo bash scripts/setup-letsencrypt.sh
```

You can also edit `SITE_DOMAIN` / `OT_IP` in `.env` by hand; `set-domain.sh` is the same thing plus the otserver restart.

The game (7171/7172) and MySQL stay up across cert renewals, package installs,
and database dumps. A **reboot is never automatic**. You still need one later
if a **kernel** update landed (check `apt list --upgradable` / `needrestart -l`).

## Automatic updates (no reboot)

`setup-vps.sh` enables **unattended-upgrades** so apt security/updates install
on their own, with:

- `Unattended-Upgrade::Automatic-Reboot false` — the box does not reboot itself
- needrestart **skips** `docker`, `containerd`, and `ssh` — a libc upgrade will
  not bounce the game stack or drop your SSH session

Services other than those three may still restart when a library they use is
patched (short blip). Docker/OT/MySQL keep running the old libraries until
**you** choose a window:

```bash
sudo apt update
sudo apt upgrade            # already happening daily; this is the manual path
# when you are ready for kernel / docker:
sudo systemctl restart docker   # drops compose for a few seconds — pick off-peak
sudo reboot                     # only when a kernel update says so
```

Optional (kernel patches without reboot, Ubuntu): [Ubuntu Pro Livepatch](https://ubuntu.com/security/livepatch) (`sudo pro attach`). Not configured by the script because it needs your token.

Logs: `/var/log/unattended-upgrades/` and `journalctl -u unattended-upgrades`.

## fail2ban

Installed and enabled for **sshd**. After a handful of failed logins the
source IP is banned for an hour.

```bash
sudo fail2ban-client status sshd
sudo fail2ban-client set sshd unbanip 1.2.3.4
```

Config: `/etc/fail2ban/jail.d/otserver.local`. This does not protect the game
ports (raw TCP, not SSH).

## SSH keys only

Password SSH is left **on** after bootstrap so you can still get in. Switch to
keys, then turn passwords off. Do this from a laptop that already has a key,
and **keep the current SSH session open** until a second session works.

### 1. Create a key on your laptop (if you do not have one)

```bash
ssh-keygen -t ed25519 -C "you@laptop" -f ~/.ssh/id_ed25519
```

Press enter for the default path. Set a passphrase on the key (unlocks locally;
it is not the VPS user password).

### 2. Install that key on the VPS

From the laptop, while password SSH still works:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub USER@VPS_IP
```

`USER` is the sudo username you typed into `setup-vps.sh`.

If `ssh-copy-id` is not available, append the **public** key by hand:

```bash
# on the laptop
cat ~/.ssh/id_ed25519.pub
# on the VPS (as USER)
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo 'PASTE_PUBLIC_KEY_LINE_HERE' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

`setup-vps.sh` already copies `/root/.ssh/authorized_keys` to the new user when
the provider injected a key at create time. In that case you may already be
able to log in with that same laptop key.

### 3. Test a new login (do not close the old one)

```bash
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no USER@VPS_IP
```

If that shell opens, keys work.

### 4. Turn off password SSH

On the VPS, as root, with the working key session still connected:

```bash
sudo bash scripts/disable-ssh-passwords.sh
```

Then test another new login. Only after that should you close the original session.

### Add another key later (second laptop, extra admin)

Password SSH is already off, so you must add the key from an existing session:

```bash
# laptop B
cat ~/.ssh/id_ed25519.pub
# existing session on the VPS
echo 'NEW_PUBLIC_KEY_LINE' >> ~/.ssh/authorized_keys
```

Or from laptop B if you still have a key that works:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub USER@VPS_IP
```

### Remove a key

Edit `~/.ssh/authorized_keys` and delete the line for that key. Do not delete
the last key you still use.

## Let's Encrypt

Bootstrap writes a **self-signed** cert so nginx can bind 443 immediately.
Browsers will warn until you issue a public cert.

Requirements:

- `SITE_DOMAIN` in `.env` is a public hostname (default on VPS: `baiakvip9.thefalked.dev`)
- DNS **A** (and **AAAA** if you have IPv6) for that name points at the VPS
- compose is up with the VPS overlay (host port **80** published)
- `LETSENCRYPT_EMAIL` in `.env` (or the script will ask)

```bash
# .env (setup-vps.sh already sets these to the hostname you confirmed)
SITE_DOMAIN=baiakvip9.thefalked.dev
OT_IP=baiakvip9.thefalked.dev
LETSENCRYPT_EMAIL=you@example.com

docker compose up --build -d
sudo bash scripts/setup-letsencrypt.sh
```

That uses HTTP-01 via `/.well-known/acme-challenge/` on port 80 (nginx does
**not** stop). The cert is copied into `docker/nginx/certs/` and nginx is
**reloaded**. Renewals: `certbot.timer` (twice daily) + the same deploy hook.

If issuance fails, check DNS, that 80 is reachable from the internet, and
`docker compose logs nginx`.

## MySQL backups (no stop)

MySQL 8 InnoDB can dump a consistent snapshot while the instance keeps serving
queries. The game does **not** need to go down.

```bash
./scripts/backup-mysql.sh
```

Files land in `backups/mysql/` (`database-YYYYMMDDTHHMMSSZ.sql.gz`), mode `600`.
Dumps older than 14 days are deleted (`BACKUP_KEEP_DAYS` to change).

`setup-vps.sh` installs a systemd timer that runs this daily at 04:15 UTC.

**Restore** (this *does* interrupt the site/game — take them down first):

```bash
docker compose stop otserver website
gunzip -c backups/mysql/ot-....sql.gz | docker exec -i otserver-mysql mysql -uroot -p"$MYSQL_ROOT_PASSWORD"
docker compose start otserver website
```

Copy dumps **off the VPS**. A backup that only exists on the same disk is not a backup.
