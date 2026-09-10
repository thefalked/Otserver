# Docker runtime for Baiak Vip9 (Ubuntu 26.04)

## Layout

```
backup/     reference Baiakzik pack + optional SQL dumps (not used at runtime)
server/     game runtime (config, data, mods, Linux binary)
src/        TFS 0.4 sources (compile only)
website/    Gesior AAC
docker/     MySQL init scripts + helpers
```

## Quick start

```bash
docker compose up --build -d
```

`otserver` image is **runtime-only** — it copies `server/theforgottenserver` and does not compile.

Ports:

- **7171** login
- **7172** game
- **8080** Gesior website (**PHP 8.5** Apache)

## Website security notes

- SMTP / PagSeguro / reCAPTCHA credentials are **cleared** (unused). Re-add only if you enable those features.
- `install.php`, `signature.php`, PagSeguro callbacks are disabled; restarter has no `exec`.
- Session stores account id only; login/create-account are rate-limited; CSRF on shop buy, account mutations, create account.
- Helpers: `h()`, `csrf_field()`, `rate_limit()` in `config-and-functions.php`.

## Rebuild the game binary (rare)

When you change C++ under `src/`:

```bash
./server/compile.sh
docker compose up --build -d otserver
```

`theforgottenserver` replaces the old Windows `Baiak-Map.exe`.

## Config

Secrets and DB connection come from **`.env`** (see `.env.example`).

- `server/config.lua.template` — Vip9 game settings (tracked; no passwords)
- At container start, `docker/render-config.sh` writes `/ot/config.lua` via `envsubst`
- Local (non-Docker) render: `./docker/render-config.sh` → `server/config.lua` (gitignored)
- Website `server_path=/ot/` uses the rendered file inside the container

Env vars used in the template: `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`, `OT_IP`.

## Logins from imported DB

- Account `1` / password `1` (admin panel access)

## Reference pack

Original Windows Baiakzik tree: `backup/reference/[8.60] Baiakzik Vip9`  
See `backup/MANIFEST.txt`.
