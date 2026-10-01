# Production host capacity

The live game runs on a **small VPS**: **2 CPU cores** and **2 GB RAM**. MySQL, the OT binary, nginx, and PHP share that box (Docker Compose on the VPS).

Treat that as a hard budget when you change server code, scripts, or ops defaults.

## Why this matters

- **Long synchronous work on the game thread freezes players.** There is no spare core to hide a full-map scan or a huge clean in one tick.
- **RAM is tight.** Large in-memory queues, unbounded caches, or loading extra data at startup can push the host into swap and make everything slow.
- **Global save and maintenance paths still run on the same hardware.** Prefer bounded batches and scheduler chunks over "do it all now" loops.

## Guidelines for server (C++) changes

- **Chunk heavy map work** (map clean, refresh, similar full-world passes). Use item or time budgets per scheduler tick, not "process every tile in one call."
- **Avoid full-map scans while `GAMESTATE_NORMAL`.** Prefer trash queues (`storeTrash`) and procedural clean when players are online.
- **Force synchronous clean only when the server is not live** (global save, shutdown, admin paths that expect immediate completion).
- **Do not hold `GAMESTATE_MAINTAIN` longer than necessary** on live worlds. Players feel it as lag or disconnects.
- **Log duration and counts** for heavy ops so you can tune batch sizes on real hardware.

## Guidelines for Lua and events

- **Globalevents and talkactions** that touch the whole map should call engine APIs that batch (for example `doCleanMap()` queuing tiles), not patterns that loop every tile from Lua.
- **Avoid tight loops** with thousands of `getTile` / item operations in one script callback.

## Tuning reference

Current map-clean defaults (see `Game::proceduralClean` in `src/game.cpp`) are chosen for this host:

- ~**150 items** removed per batch
- ~**50 ms** between batches
- Small trash lists (**≤ 25** marked tiles) may still run synchronously

If you change hardware, revisit those numbers. On this VPS, raising batch size without measuring often brings back micro-freezes.

## Related docs

- VPS bootstrap and ops: [vps.md](vps.md)
- Map clean behavior and Lua: [house-clean-old.md](house-clean-old.md) (house clean config), globalevent `server/data/globalevents/scripts/clean.lua`
