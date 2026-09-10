# Baiak Vip9 OTServer

Dockerized **The Forgotten Server 0.4** (Baiakzik Vip9 / 8.60) with MySQL and a Gesior account website.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose v2
- A Tibia **8.60** client pointed at your host IP (ports **7171** / **7172**)

## Home-server (optional)

When this repo sits next to [home-server](https://github.com/thefalked/home-server) (`tests/Otserver` beside `tests/home-server`), you can run the stack from home-server’s thin wrapper:

```bash
# from home-server
cp otserver/.env.example otserver/.env   # set MYSQL_* / OT_IP
cd otserver && docker compose up -d --build
```

That compose builds from this checkout (`../../Otserver`), puts MySQL/logs under `home-server/otserver/otserver_data/`, exposes the Gesior site via Traefik (`baiakvip9.thefalked.dev`), and routes login/game TCP through Traefik on host **7171** / **7172**. Do **not** run this repo’s `docker compose up` and the home-server wrapper at the same time (port and image conflicts). C++ rebuilds still use `./server/compile.sh` here. Recreate Traefik after enabling the wrapper so the new entrypoints bind.

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
| Login | TCP **7171** |
| Game | TCP **7172** |

Default admin accounts from the imported DB:

| Account | Password | Notes |
|---------|----------|--------|
| **1** | **1** | Gesior `page_access` admin; sample vocation templates |
| **god** | **godadmin** | Backup-derived ADM; character **Energy** (group ADM) plus Test / Smartbox Test |

Stop / tear down:

```bash
docker compose down          # keep DB volume
docker compose down -v       # also wipe MySQL data
```

## Configuration

Copy `.env.example` → `.env`. Compose and the containers read these values:

| Variable | Default | Purpose |
| ---------- | --------- | --------- |
| `MYSQL_ROOT_PASSWORD` | `otroot` | MySQL root |
| `MYSQL_DATABASE` | `ot` | Database name |
| `MYSQL_USER` / `MYSQL_PASSWORD` | `ot` / `otserver` | App DB user |
| `MYSQL_HOST` / `MYSQL_PORT` | `mysql` / `3306` | Host inside Docker network |
| `OT_IP` | `127.0.0.1` | IP advertised to game clients |
| `LOGIN_PORT` / `GAME_PORT` | `7171` / `7172` | Host port mappings |
| `WEBSITE_PORT` | `8080` | Host port for the website |

**Important:** set `OT_IP` to the address players (and you) use to reach the server. `127.0.0.1` only works for a client on the same machine.

Game settings live in `server/config.lua.template` (tracked, no secrets). At container start, `docker/render-config.sh` renders `/ot/config.lua` with `envsubst`. For a local (non-Docker) render:

```bash
./docker/render-config.sh   # writes server/config.lua (gitignored)
```

## Services

| Compose service | Image / role |
| ----------------- | -------------- |
| `mysql` | MySQL 8.4; schema + Gesior SQL on first init |
| `otserver` | Ubuntu 26.04 runtime; prebuilt `server/theforgottenserver` |
| `website` | PHP 8.5 Apache + Gesior AAC |

`otserver` is **runtime-only** — it does not compile C++ on `docker compose up`. The Linux binary must already exist at `server/theforgottenserver` (included when present in the repo).

Useful commands:

```bash
docker compose logs -f otserver website mysql
docker compose restart otserver
docker compose up --build -d website
```

## Rebuild the game binary

Only needed when you change C++ under `src/`:

```bash
./server/compile.sh
docker compose up --build -d otserver
```

`compile.sh` builds in a Docker builder image and writes `server/theforgottenserver` (replaces the old Windows `Baiak-Map.exe`).

## Project layout

```
.env.example          env template (copy to .env)
docker-compose.yml    MySQL + game + website
docker/               entrypoints, config render, MySQL init SQL
server/               binary, config template, data/, mods/
src/                  TFS 0.4 sources (compile only)
website/              Gesior AAC (PHP)
backup/               reference Baiakzik pack + optional SQL dumps (not used at runtime)
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
