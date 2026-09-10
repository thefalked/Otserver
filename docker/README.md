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

- `server/config.lua` — Vip9 config with Docker MySQL (`sqlHost=mysql`, user/pass `ot`/`otserver`)
- `docker/config.lua` — symlink to `server/config.lua`
- Website `server_path=/ot/` mounts the same config + data

## Logins from imported DB

- Account `1` / password `1` (admin panel access)

## Reference pack

Original Windows Baiakzik tree: `backup/reference/[8.60] Baiakzik Vip9`  
See `backup/MANIFEST.txt`.
