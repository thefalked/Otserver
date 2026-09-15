# Security findings debrief — Baiak Vip9

**Host:** <https://baiakvip9.servegame.com/>  
**Mode:** fixes in progress (batch: host)  
**Date:** 2026-09-14  
**Fixed in repo (pending deploy):** F1, F2, W1, W2, W5 (partial: namelock + forum remove → POST), W6, W7, W8, W9, W10, H2, H3, H4, H5, H6, H8, H9, H11  
**Deferred:** **H7** non-root containers — quick `-u 1000` test segfaulted; needs dedicated USER + data ownership  
**Accepted / kept as-is:** F3 (status protocol still reports SOFTWARE_NAME / SOFTWARE_VERSION)  

Sources: code review; Docker/VPS audit; OTServer Lua audit; Gesior PHP audit; live probes against the host above.

Reply with finding IDs (e.g. `H1, W2, O3`) when you want fixes.

---

## Live verification summary

Probed read-only against <https://baiakvip9.servegame.com/> on 2026-09-14.

| Check | Result |
| --- | --- |
| `X-Powered-By` | **Present:** `PHP/8.5.10` |
| `Server` (nginx) | `nginx` — version number hidden (`server_tokens off` works) |
| Apache fingerprint | **Leaks on 404:** `Apache/2.4.68 (Debian)` in error page `<address>` |
| Meta author | **Present:** `Gesior \| Modified by [ADM] Energy` |
| TCP 80 / 443 | Open |
| TCP 8080 | **Open** — cleartext site + same PHP header |
| TCP 2376 | **Open** — Hawser/Dockhand surface |
| TCP 7171 / 7172 | Open (expected for game) |
| TCP 7173 | Closed/filtered (status protocol not public) |
| TCP 3306 | Closed/filtered |
| `install.php` | 403 |
| `config/config.ini` | 403 |
| `bdsave/` / `cache/` | 403 |
| Security headers | Missing HSTS, X-Frame-Options, nosniff, CSP |
| Account AJAX | Enumerates free vs taken names |
| Serverinfo | Lists `/addvip` among public commands; shows extreme rates |

---

## Critical

| ID | Area | Finding | Location | Live? |
| --- | --- | --- | --- | --- |
| **H1** | Host | Hawser publishes `:2376` with `/var/run/docker.sock`; UFW allows 2376 from anywhere. Stolen/weak TOKEN or agent bug → full host root | `docker-compose.vps.yml`, `scripts/setup-hawser.sh`, `scripts/setup-vps.sh` | **Confirmed open** |
| **O1** | OT | Any player can `/addvip` (no XML `access=`; script allows `group_id >= 1`). Bad target names can crash the script | `server/data/talkactions/talkactions.xml`, `…/scripts/addvip2.lua` | Listed on public serverinfo |
| **O2** | OT | `!notice` crashes if `noticias.txt` missing (`io.open` without nil check) | `server/data/talkactions/scripts/notice.lua` | Code-only |

---

## High

| ID | Area | Finding | Location | Live? |
| --- | --- | --- | --- | --- |
| **H2** | Host | Password SSH left enabled after bootstrap until `disable-ssh-passwords.sh` | `scripts/setup-vps.sh` | **Fixed in repo** — stays on until explicit disable script |
| **H3** | Host | Public cleartext AAC on `:8080` alongside HTTPS | compose + UFW + nginx | **Fixed in repo** — `127.0.0.1:8080` + UFW 8080 removed |
| **H4** | Host | Full `.env` (incl. `MYSQL_ROOT_PASSWORD`) injected into `website` / `nginx` | `docker-compose.yml` | **Fixed in repo** — explicit env only |
| **H5** | Host | Admin user in `docker` group ≈ host root without sudo | `scripts/setup-vps.sh` | **Fixed in repo** — opt-in `OTSERVER_DOCKER_GROUP=1` |
| **O3** | OT | `!afk` / `!treinando` schedule parallel `addEvent` chains without `stopEvent` → CPU/event DoS | `afk.lua`, `treinando.lua` | Code-only |
| **O4** | OT | `/mute` with invalid minutes → nil condition crash | `mute.lua` | Code-only |
| **O5** | OT | GM `/r` removes creatures/players with no access comparison | `remove.lua` | Code-only |
| **O6** | OT | Unbounded `/i` amount (CM+) → lag / economy bomb | `createitem.lua` | Code-only |
| **O7** | OT | Unbounded `/mkick` range → map-wide kick | `masskick.lua` | Code-only |
| **W1** | Web | Forum stored XSS: topic/author injected raw into mod `confirm('…')` | `website/forum.php` | **Fixed in repo** |
| **W2** | Web | Namelock accept/reject via GET; ACL only `page_access > 0`; no CSRF | `website/namelocks.php` | **Fixed in repo** |
| **W3** | Web/OT | Unsalted SHA1 account passwords — DB leak → fast offline crack | `encryptionType = "sha1"`, site hash helpers | Protocol/TFS constraint |
| **A1** | Acc | `god` / `godadmin` password re-applied on every `ensure-schema` run | `docker/mysql/08-god-energy.sql` | Code-only |
| **A2** | Acc | Default account `1` / `1` with Gesior admin `page_access` | `docker/mysql/03-gesior.sql`, README | Ops / change passwords |

---

## Medium

| ID | Area | Finding | Location | Live? |
| --- | --- | --- | --- | --- |
| **F1** | Fingerprint | Apache + PHP version leak | `website/Dockerfile`, live 404/`X-Powered-By` | **Fixed in repo** (rebuild website) |
| **F2** | Fingerprint | nginx can forward upstream identity; version already hidden | `docker/nginx/nginx.conf` + HTTPS writers | **Fixed in repo** (`proxy_hide_header`) |
| **F3** | Fingerprint | Status XML advertises `The Forgotten Server` / `0.4_SVN` | `src/status.cpp`, `src/definitions.h` | **Accepted** — kept; site does not display these fields; 7173 not public |
| **F4** | Fingerprint | HTML meta author reveals Gesior | `website/layouts/tibiacom/layout.php` | **Confirmed** |
| **O8** | OT | Jail timer never stops; XML missing access (script gates group ≥ 5) | `cadeia.lua`, `talkactions.xml` | Code-only |
| **O9** | OT | Extreme rates / `freePremium` / weak idle kick / etc. | `server/config.lua.template` | **Confirmed** rates live |
| **O10** | OT | Guild war payment not refunded on reject/cancel | `war.lua` | Code-only |
| **O11** | OT | Poll “one vote per account” is per character | `poll_system.lua` | Code-only |
| **O12** | OT | `!myhouse` / eject uses undefined `NO_OWNER_PHRASE` | `eject.lua` | Code-only |
| **O13** | OT | Zombie event `playersNeededToStartEvent = 1` (solo farm) | `zombie_event.lua` | Code-only |
| **W4** | Web | Captcha off — automated account creation (session rate limit only) | `website/config/config.php` | Config |
| **W5** | Web | CSRF tokens in GET URLs (Referer/logs leak) | forum/admin/etc. | **Partial** (namelock + forum remove) |
| **W6** | Web | Docker `chmod 777` fallbacks on runtime dirs | `website/docker-entrypoint.sh` | **Fixed in repo** |
| **W7** | Web | Guild logo `unlink` without path sanitize | `website/guilds.php` | **Fixed in repo** |
| **W8** | Web | Admin mass-mail HTML unsanitized (SMTP currently off) | `website/mail.php` | **Fixed in repo** |
| **H6** | Host | Website RW bind-mount persists RCE on host tree | `docker-compose.yml` | **Fixed in repo** — PHP tree `:ro` + RW subdirs |
| **H7** | Host | Containers as root; TFS built with root permission | Dockerfiles | **Deferred** — non-root test segfaulted |
| **H8** | Host | Setup secrets briefly under `/tmp` on VPS | `scripts/setup-from-pc.sh` | **Fixed in repo** — `/root/otserver-pc-setup.$$` |
| **H9** | Host | GitHub PAT in `~/.git-credentials` | setup scripts | **Fixed in repo** — opt-in only |
| **H10** | Host | Hawser image `:latest` (supply chain) | `docker-compose.vps.yml` | Code-only |

---

## Low

| ID | Area | Finding | Location |
| --- | --- | --- | --- |
| **W9** | Web | Admin reflected XSS on spell name | `website/adminpanel.php` — **Fixed in repo** |
| **W10** | Web | Account/email enumeration via AJAX | `website/ajax/check_account.php`, `check_email.php` — **Fixed in repo** (rate limit + softer copy) |
| **W11** | Web | Non-`hash_equals` password compares in some account flows | e.g. `accountmanagement.php` |
| **H11** | Host | `render-config.sh` defaults `MYSQL_PASSWORD=otserver` if env empty | `docker/render-config.sh` — **Fixed in repo** (fail if unset) |
| **O14** | OT | `systemvip` / `/delvip` weak XML access; exact `access == 5` misses ADM 6 | talkactions + scripts |
| **O15** | OT | Dormant `account.lua` SQL injection (not registered in XML) | `talkactions/scripts/account.lua` |

---

## Already OK (no action required)

| Item | Notes |
| --- | --- |
| MySQL not published to host | Docker network only |
| Website has no `docker.sock` | Only Hawser mounts it |
| `install.php` blocked | Live 403 + `.htaccess` + `install=no` |
| `config/` blocked | Live 403 |
| No classic SQLi / RCE / SQL dumps under `website/` | PDO quote + allowlists |
| nginx `server_tokens off` | Version string not in `Server` header |
| Status port 7173 not public | Live closed/filtered |

---

## Suggested pick lists (optional)

**Hardening / fingerprint (live-confirmed):** `F1, F4, H1, H3, W10`

**Stop breakage / abuse:** `O1, O2, O3, O4, O5, O6, O7, W1, W2, A1`

**Host blast radius:** `H1, H3, H4`

**Intentional Baiak / defer:** `O9` (rates), `W3` (SHA1 / TFS 0.4)

---

## Status

- **Fingerprint batch:** F1, F2 fixed; **F3 accepted**.
- **Web batch:** W1, W2, W5 (namelock + forum remove), W6–W10 fixed + committed.
- **Host batch:** H2–H6, H8, H9, H11 committed; live VPS: `sudo bash scripts/apply-host-hardening.sh` then optional `disable-ssh-passwords.sh`. **H7 deferred**.
- Next batch: **OT** (O1–O8, O10, O11, O13–O15) + **A1**.
