# VPS ops: first boot, domain, updates, SSH keys, Let's Encrypt, MySQL backups

**Capacity:** production is **2 CPU cores** and **2 GB RAM** (game + MySQL + web on one machine). Code and ops choices should assume that budget. Details for contributors and agents: **[production-host.md](production-host.md)**.

## Empty VPS (run setup from your PC)

The repo is private. Do **not** anonymous-clone on the VPS. From this repo on your **laptop** (Git Bash / macOS / Linux / WSL):

```bash
./scripts/setup-from-pc.sh
```

That script asks you for **everything on your laptop** (no remote prompts):

1. VPS IP/hostname, SSH user (`root` on a new machine), SSH port
2. GitHub token (hidden): fine-grained **Contents: Read-only** on this repo, or classic `repo`
3. New sudo username + password
4. Website hostname (default **baiakvip9.servegame.com**), Let’s Encrypt email
5. MySQL root and app passwords

It then SSHs in (host key / VPS root password if the provider did not inject your laptop key), installs git, clones into `/opt/otserver` (full history), and runs `setup-vps.sh` with those values. It also starts Docker Compose and tries Let’s Encrypt if you gave an email.

The GitHub token is **not** stored on disk by default (H9). Prefer a [deploy key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys) for later `git pull`. Opt-in PAT store:

```bash
# as the sudo user, from /opt/otserver. or:
sudo bash scripts/set-git-credentials.sh --user YOUR_SUDO_USER
# or during bootstrap: OTSERVER_SAVE_GIT_CREDENTIALS=1
```

Later:

```bash
ssh USER@VPS
cd /opt/otserver
git pull
sudo docker compose ps   # user is not in group docker by default (H5)
```

If you are already root on the VPS with `GITHUB_TOKEN` set: `sudo bash scripts/setup-vps.sh`.

## Already-running VPS (host hardening without re-bootstrap)

`setup-vps.sh` only runs on first install. After you pull host-security changes on a live box:

```bash
cd /opt/otserver
# If git pull fails with "unable to unlink ... Permission denied":
sudo bash scripts/fix-repo-ownership.sh
git pull
sudo bash scripts/apply-host-hardening.sh
```

`fix-repo-ownership.sh` / `apply-host-hardening.sh` keep the repo owned by your
deploy user. Website/otserver entrypoints no longer `chown` bind mounts to
container users (that used to break `git pull`).

Safe default (idempotent, like `setup-hawser.sh`):

- drops UFW `8080` if present (H3)
- recreates `website` + `nginx` (loopback `:8080`, lean env, read-only PHP. H3/H4/H6/H11)

It does **not** change SSH passwords, docker group, or `~/.git-credentials` unless you pass flags:

```bash
sudo bash scripts/apply-host-hardening.sh --remove-docker-group
sudo bash scripts/apply-host-hardening.sh --remove-git-credentials
sudo bash scripts/apply-host-hardening.sh --compose-only   # skip UFW
sudo bash scripts/apply-host-hardening.sh --no-compose     # UFW (+ optional flags) only
```

Password SSH: after a **tested** key login in another terminal:

```bash
sudo bash scripts/disable-ssh-passwords.sh
```

Expect a short 502 while `website` recreates (`ensure-schema` retries). Confirm `MYSQL_PASSWORD` is set in `.env` first or the container will crash-loop.

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

- `Unattended-Upgrade::Automatic-Reboot false`. The box does not reboot itself
- needrestart **skips** `docker`, `containerd`, and `ssh`. a libc upgrade will
  not bounce the game stack or drop your SSH session

Services other than those three may still restart when a library they use is
patched (short blip). Docker/OT/MySQL keep running the old libraries until
**you** choose a window:

```bash
sudo apt update
sudo apt upgrade            # already happening daily; this is the manual path
# when you are ready for kernel / docker:
sudo systemctl restart docker   # drops compose for a few seconds. pick off-peak
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

Password SSH stays **on** after bootstrap so you can still get in. Switch to
keys, then turn passwords off with `scripts/disable-ssh-passwords.sh`. Do this
from a laptop that already has a key, and **keep the current SSH session open**
until a second session works.

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

**Two separate certificates** (not one cert with both names as SANs): Certificate
Transparency would otherwise publish both hostnames on the same cert and link
your public site to the maintenance / Dockhand name.

Requirements:

- `SITE_DOMAIN` = public game/site hostname (default: `baiakvip9.servegame.com`)
- `SITE_MAINTENANCE_DOMAIN` = Dockhand / ops hostname (default: `baiakvip9.thefalked.dev`)
- DNS **A**/**AAAA** for **each** name points at the VPS
- compose up with VPS overlay (port **80** published)
- `LETSENCRYPT_EMAIL` in `.env`

```bash
SITE_DOMAIN=baiakvip9.servegame.com
OT_IP=baiakvip9.servegame.com
SITE_MAINTENANCE_DOMAIN=baiakvip9.thefalked.dev
LETSENCRYPT_EMAIL=you@example.com

docker compose up --build -d
sudo bash scripts/setup-letsencrypt.sh
```

Files:

| Role | Files under `docker/nginx/certs/` |
| ---- | --------------------------------- |
| Public | `fullchain.pem` / `privkey.pem` |
| Maintenance + Hawser | `maintenance-fullchain.pem` / `maintenance-privkey.pem` |

### Switch primary to servegame (existing VPS)

```bash
sudo bash scripts/set-domain.sh baiakvip9.servegame.com
# → SITE_DOMAIN=servegame, SITE_MAINTENANCE_DOMAIN=thefalked, restarts otserver

sudo bash scripts/setup-letsencrypt.sh
# → two separate certbot lineages, nginx SNI, Hawser on maintenance pems

# recreate nginx so the new nginx.conf + entrypoint are live
docker compose up -d --build nginx hawser
```

If you previously issued **one** cert listing both names, after the new pair
works you can remove the old dual-SAN lineage:
`sudo certbot delete --cert-name OLD_NAME`.

If issuance fails, check DNS, port 80, and `docker compose logs nginx`.

## Hawser (Dockhand agent)

nginx publishes **2376** and only proxies TLS clients whose **SNI** is
`SITE_MAINTENANCE_DOMAIN` (e.g. `baiakvip9.thefalked.dev`). Hawser itself is
internal (`expose` only) and still uses the **maintenance** cert
(`maintenance-fullchain.pem`). Dockhand must use that hostname. not the
public servegame name and not a bare IP (wrong/missing SNI is dropped).

`TOKEN` lives in **`/etc/hawser/config`**; `setup-hawser.sh` mirrors it to
`/etc/hawser/token` for compose `TOKEN_FILE`.

**Already have a VPS** (do not re-run `setup-vps.sh`):

```bash
sudo bash scripts/setup-hawser.sh
# or after git pull of H1: sudo bash scripts/apply-host-hardening.sh
```

Dockhand: `https://baiakvip9.thefalked.dev:2376` + token from `/etc/hawser/config`.

Prefer locking UFW to your home IP later:
`ufw delete allow 2376/tcp` then
`ufw allow from YOUR_IP to any port 2376 proto tcp`.

## MySQL backups (no stop)

MySQL 8 InnoDB can dump a consistent snapshot while the instance keeps serving
queries. The game does **not** need to go down.

```bash
./scripts/backup-mysql.sh
```

Files land in `backups/mysql/` (`database-YYYYMMDDTHHMMSSZ.sql.gz`), mode `600`.
Dumps older than 14 days are deleted locally (`BACKUP_KEEP_DAYS` to change).

`setup-vps.sh` installs a systemd timer that runs this daily at 04:15 UTC.

### Offsite: Cloudflare R2

Set these in `.env` (S3 credentials from R2 → Manage R2 API Tokens):

```bash
R2_ACCOUNT_ID=your_account_id
R2_BUCKET=otserver-backup
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
R2_PREFIX=mysql/
```

When all four required keys are set, the backup script uploads with host
`aws`. If `aws` is missing it installs the `awscli` apt package (needs root
or sudo, which the daily systemd timer has). Docker `amazon/aws-cli:latest`
is only a fallback so Dockhand is not alerted by a one-shot container on the
normal path.

```bash
docker pull amazon/aws-cli:latest   # optional. only used if host aws fails
```

Optional: in the Cloudflare dashboard, set an R2 lifecycle rule on the bucket
(or prefix `mysql/`) to delete objects older than 14 days so remote retention
matches local.

**Restore** (this *does* interrupt the site/game. take them down first):

```bash
docker compose stop otserver website
gunzip -c backups/mysql/ot-....sql.gz | docker exec -i otserver-mysql mysql -uroot -p"$MYSQL_ROOT_PASSWORD"
docker compose start otserver website
```

Or download from R2 first, then pipe the same way. A dump that only lives on
the VPS disk is not a backup.
