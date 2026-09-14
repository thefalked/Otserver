# Baiak Vip9 OTServer

Dockerized **The Forgotten Server 0.4** (Baiakzik Vip9 / 8.60) with MySQL and a Gesior account website.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose v2
- A Tibia **8.60** client pointed at your host IP (ports **7171** / **7172**)

## VPS bootstrap

This GitHub repo is **private**. From **this PC** (Git Bash, macOS, Linux, or WSL), in the repo:

```bash
./scripts/setup-from-pc.sh
```

It asks for the VPS address and a GitHub token, SSHs in, `git clone`s into `/opt/otserver`, then runs the rest of setup on the server (sudo user, passwords, hostname, MySQL, firewall, Docker, Let’s Encrypt). Afterward, on the VPS: `cd /opt/otserver && git pull`.

Hostname default is **baiakvip9.servegame.com** (maintenance alias
**baiakvip9.thefalked.dev**). Change later with
`sudo bash scripts/set-domain.sh new.example.com`.

If you are already root on the VPS with the repo checked out:

```bash
sudo bash scripts/setup-vps.sh
```

The setup then:

- `apt update` / `upgrade`
- installs **git**, **Docker**, **fail2ban**, **unattended-upgrades**, and **certbot**
- creates the sudo user and copies `/root/.ssh/authorized_keys` if present
- disables SSH **root** login (password SSH stays on until you switch to keys)
- enables **UFW** (deny incoming; allow 22, 80, 443, 8080, 7171, 7172)
- applies apt updates daily **without rebooting**; docker/ssh are not auto-restarted
- installs a daily **MySQL hot dump** timer (`backups/mysql/`)
- sets `SITE_DOMAIN` and `OT_IP` to the hostname you confirmed

Compose uses `docker-compose.vps.yml` so **80** (ACME + redirect to HTTPS) and **443** are published. After the stack is up: `sudo bash scripts/setup-letsencrypt.sh`. Keep the root session open until you can `ssh` in as the new user.

Keys-only SSH, Let's Encrypt, domain changes, and backups: **[docs/vps.md](docs/vps.md)**.

## Home-server (optional)

When this repo sits next to [home-server](https://github.com/thefalked/home-server) (`tests/Otserver` beside `tests/home-server`), you can run the stack from home-server’s thin wrapper:

```bash
# from home-server
cp otserver/.env.example otserver/.env   # set MYSQL_* / OT_IP
cd otserver && docker compose up -d --build
```

That compose builds from this checkout (`../../Otserver`), puts MySQL/logs under `home-server/otserver/otserver_data/`, exposes the Gesior site via Traefik (`baiakvip9.thefalked.dev`), and publishes login/game TCP **7171** / **7172** on the `otserver` container (raw OT protocol — not Traefik). Do **not** run this repo’s `docker compose up` and the home-server wrapper at the same time (port and container-name conflicts). C++ rebuilds still use `./server/compile.sh` here. Keep this repo’s `docker-compose.yml` service/SQL/port layout in sync with `home-server/otserver/docker-compose.yml`.

## Quick start

```bash
cp .env.example .env   # edit secrets / OT_IP if needed
docker compose up --build -d
```

Wait until MySQL is healthy and `otserver` / `website` are up:

```bash
docker compose ps
docker compose logs -f otserver
```

Then open the site and connect the client:

| Service | URL / port |
| --------- | ------------ |
| Website (Gesior) | <http://localhost:8080> |
| Login | TCP **7171** (via nginx stream) |
| Game | TCP **7172** (via nginx stream) |

Default admin accounts from the imported DB:

| Account | Password | Notes |
|---------|----------|--------|
| **1** | **1** | Gesior `page_access` admin; login shows **Account Manager** only (vocation Samples are hidden templates for website char creation) |
| **god** | **godadmin** | Backup-derived ADM; character **[ADM] Energy** (group ADM) plus Test / Smartbox Test |

Stop / tear down:

```bash
docker compose down          # keep DB volume
docker compose down -v       # also wipe MySQL data
```

## Configuration

Copy `.env.example` → `.env`. Compose and the containers read these values:

| Variable | Default | Purpose |
| ---------- | --------- | --------- |
| `MYSQL_ROOT_PASSWORD` | *(required)* | MySQL root — set in `.env` |
| `MYSQL_DATABASE` | `ot` | Database name |
| `MYSQL_USER` / `MYSQL_PASSWORD` | `ot` / *(required)* | App DB user |
| `MYSQL_HOST` / `MYSQL_PORT` | `mysql` / `3306` | Host inside Docker network |
| `OT_IP` | `127.0.0.1` | IP/hostname advertised to game clients (VPS: set to `SITE_DOMAIN`) |
| `WEBSITE_PORT` | `8080` | Host HTTP port for the website (standalone nginx) |
| `SITE_DOMAIN` | `localhost` | Nginx / Let's Encrypt primary hostname (VPS default `baiakvip9.servegame.com`) |
| `SITE_DOMAIN_ALIASES` | *(empty)* | Extra SANs on the same LE cert (VPS default `baiakvip9.thefalked.dev`) |
| `LETSENCRYPT_EMAIL` | *(empty)* | Account email for `scripts/setup-letsencrypt.sh` |

Login/game are fixed at host **7171** / **7172** (same as home-server). Compose requires a `.env` file (`cp .env.example .env`).

**Important:** set `OT_IP` to the address players (and you) use to reach the server. `127.0.0.1` only works for a client on the same machine.

Game settings live in `server/config.lua.template` (tracked, no secrets). At container start, `docker/render-config.sh` renders `/ot/config.lua` with `envsubst`. For a local (non-Docker) render:

```bash
./docker/render-config.sh   # writes server/config.lua (gitignored)
```

## Services

| Compose service | Image / role |
| ----------------- | -------------- |
| `mysql` | MySQL 8.4; schema + Gesior SQL on first init |
| `otserver` | Ubuntu 26.04; compiles `theforgottenserver` from `src/` in the image |
| `website` | PHP 8.5 Apache + Gesior AAC (internal port 80) |
| `nginx` | Reverse proxy: HTTPS site + TCP stream for 7171/7172 |

`otserver` builds the game binary **inside Docker** for the machine’s architecture. Do not rely on a checked-in `server/theforgottenserver` (an Apple Silicon build will fail on an amd64 VPS with `Exec format error`).

Useful commands:

```bash
docker compose logs -f otserver website mysql
docker compose restart otserver
docker compose up --build -d website
```

## Rebuild the game binary

`docker compose up --build -d otserver` recompiles when `src/` or `server/Dockerfile` change.

Optional: write a host copy next to `data/` (same builder image):

```bash
./server/compile.sh
```

`compile.sh` is optional for local tooling; the compose image does not use that file.

## Project layout

```
.env.example          env template (copy to .env)
docker-compose.yml    MySQL + game + website + nginx
docker/               entrypoints, config render, MySQL init SQL, nginx
scripts/              VPS bootstrap, Let's Encrypt, MySQL dump
docs/vps.md           SSH keys, updates, certs, backups
server/               binary, config template, data/, mods/
src/                  TFS 0.4 sources (compile only)
website/              Gesior AAC (PHP)
backup/               reference Baiakzik pack + optional SQL dumps (not used at runtime)
backups/              runtime MySQL dumps from scripts/backup-mysql.sh (gitignored)
```

## Connecting a client

1. Start the stack (`docker compose up -d`).
2. In your 8.60 client / OTClient, set the server IP to `OT_IP` (or `127.0.0.1` locally) and login port **7171**.
3. Create an account on <http://localhost:8080> or use **1** / **1**.

## Website notes

- SMTP / PagSeguro / reCAPTCHA credentials are cleared (unused). Re-add only if you enable those features.
- `install.php`, `signature.php`, and PagSeguro callbacks are disabled.
- Sessions store account id only; login / create-account are rate-limited; CSRF on shop buy, account mutations, and create account.
- Helpers: `h()`, `csrf_field()`, `rate_limit()` in `website/config-and-functions.php`.
- Runtime writes (bind-mount owned by host): `website/docker-entrypoint.sh` chowns/chmods `config/`, `images/head/`, `cache/`, `guilds/`, `bdsave/`, and `usercounter.dat` for `www-data`. After changing the entrypoint, **rebuild** the website image (`docker compose up --build -d website`). Headline PNGs fall back to streaming if the cache dir is still not writable.

## Shop / premium points

PagSeguro donate is **disabled by design** (`donate.php` early-returns; shop still spends `accounts.premium_points`). To fund the shop for testing or ops:

1. Log in as an AAC admin (`page_access` ≥ `access_admin_panel`, default seed **1** / **1**).
2. Open **Admin Panel** → **Grant points**.
3. Enter account name or id and a +/- points amount.

## Future / TODO

- Smoke/CI baseline: add `scripts/smoke.sh` (compose health, HTTP 200, CSRF reject, `render-config.sh`) and optional CI.

## Reference pack

Original Windows Baiakzik tree: `backup/reference/[8.60] Baiakzik Vip9`  
See `backup/MANIFEST.txt`.
