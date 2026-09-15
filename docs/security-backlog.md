# Security backlog — deferred / later

Items we intentionally skip for now. Pick one when ready; do not treat this file as “accepted forever.”

**Host:** <https://baiakvip9.servegame.com/>  
**Last updated:** 2026-09-14

---

## W4 — Captcha / bot signup

**Status:** deferred  
**Finding:** Account creation captcha is off; only session rate limiting slows automated signups.  
**Where:** `website/config/config.php` (and create-account flow)  
**Later:** Turn captcha on (or add an equivalent challenge) once UX/email path is settled. Re-test create account + rate limits.

---

## H7 — Non-root containers

**Status:** deferred  
**Finding:** Compose services run as root; quick `-u 1000` smoke test segfaulted TFS.  
**Later:** Dedicated USER in Dockerfiles, fix data dir ownership, re-test otserver + website.

---

## H10 — Hawser image pin

**Status:** keep `:latest` for now (ops choice)  
**Later (optional):** Pin `ghcr.io/finsys/hawser` to a digest/tag and document upgrade.

---

## W3 — Unsalted SHA1 passwords

**Status:** keep (TFS 0.4 / client protocol)  
**Later (major):** Only with a protocol/client migration path — not a site-only flip.

---

## O9 — Extreme rates / Baiak knobs

**Status:** intentional game design  
**No action** unless rates or idle/premium policy change.

---

## How to use

1. Pick an ID from this file (or from `docs/security-debrief.md`).
2. Implement in a small batch, verify, then update both this file and the debrief status line.
