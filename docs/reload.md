# `/reload` command

Hot-reload without restarting the game process. Entry points:

- Talkaction: `server/data/talkactions/scripts/reload.lua`
- Engine: `Game::reloadInfo` in `src/game.cpp`
- Constants: `RELOAD_*` in `server/data/lib/000-constant.lua` and `src/game.h`

## Safety layers

**Policy:** every broken or unsafe reload stays blocked until its engine path is fixed and pointer rebinding (or equivalent) is done. Do not enable a type in only one place.

Two places enforce that. Keep the id lists identical.

1. **Talkaction** (`brokenReasons` in `reload.lua`): refuses `/reload <type>` for those ids and prints why.
2. **Engine `RELOAD_ALL`** (skip switch in `game.cpp`): `/reload all` and `SIGCONT` loop `RELOAD_FIRST`..`RELOAD_LAST` and skip the same set. Without this, `all` would still run vocations/groups and risk dangling pointers.

When you fix a type, remove it from both lists in the same change. Until then, leave it blocked everywhere.

`RELOAD_LAST` is `RELOAD_MODS`, not `RELOAD_ALL`. That way `all` includes mods and does not recurse into itself. `luaDoReloadInfo` accepts ids through `RELOAD_ALL` so mods (22) and all (23) are not silent no-ops.

## Working types

These run a real reload path and are safe enough for normal use:

| Type | What reloads |
| ------ | -------------- |
| `actions` | `data/actions/` |
| `chat` | `channels.xml` |
| `config` | `config.lua` (also recalculates house prices if `housePriceEachSquare` changed) |
| `creatureevents` / `creaturescripts` | `data/creaturescripts/` |
| `globalevents` | `data/globalevents/` |
| `highscores` | highscores cache from DB |
| `monsters` | `data/monster/` |
| `moveevents` / `movements` | `data/movements/` |
| `npcs` | `data/npc/` (already-spawned NPCs may keep old state until replaced) |
| `quests` | `quests.xml` |
| `raids` | raids XML and raid system restart |
| `spells` | spells, then monsters |
| `stages` / `experience` | experience stages |
| `talkactions` / `commands` | `data/talkactions/` |
| `mods` | mods (also runs after every other reload type) |
| `all` | loops safe reload ids through `RELOAD_MODS` (skips broken/unsafe types) |

Note: `/reload mods` and `/reload all` need a binary rebuild. Older builds capped
`doReloadInfo` at `RELOAD_WEAPONS` (21), so ids 22/23 were ignored while Lua still
printed "Reloading...".

`SIGCONT` on the process also triggers `RELOAD_ALL` (same skip list).

## Broken / no-op types

Listed for discovery, but blocked in both the talkaction and `RELOAD_ALL` until fixed.
Individual C++ handlers may still exist (or be stubs). Callers must not reach them.

| Type | Why it fails | What is missing to make it work |
| ------ | -------------- | --------------------------------- |
| `items` | `RELOAD_ITEMS` is a TODO stub. It never calls `Items::reload()`. `Items::reload()` is commented out and returns `false`. | Wire `Item::items.reload()`, finish safe OTB + `items.xml` overlay reload (free conditions, reset removed XML fields). `items.otb` changes still need a restart. |
| `outfits` | TODO stub. `Outfits` has `loadFromXml()` only. | Add `Outfits::reload()` that clears maps then loads. Wire it in `Game::reloadInfo`. Optionally re-apply outfit bonuses for online players. |
| `weapons` | TODO stub in `Game::reloadInfo`, even though `Weapons` already inherits `BaseEvents::reload()`. | Call `g_weapons->reload()` then `g_weapons->loadDefaults()` (same as startup). |
| `groups` | `Groups::reload()` exists but the call is commented out. | After reload, rebind every online player's `Group*` (players store a raw pointer). Without that, reload frees groups and leaves dangling pointers. |
| `vocations` | `Vocations::reload()` is wired, but it deletes vocation objects while online players keep `Vocation*`. Unsafe. | Rebind online players with `setVocation(vocationId)` after reload, or update vocations in place. |
| `houseprices` | Lua uses id `9`. C++ has that slot unused (`//RELOAD_UNUSED = 9`). No switch case. | Restore `RELOAD_HOUSEPRICES` and a price recalculation case, or alias to config reload. Workaround: `/reload config` when `housePriceEachSquare` changed. |
| `gameservers` | Handler is behind `#ifdef __LOGIN_SERVER__`. Normal game builds do nothing. | Only useful on a login-server build. N/A for this game process. |

## Needs a full restart

- Map `.otbm` and already-placed map spawns
- C++ / binary changes
- `items.otb`
- Startup-only `config.lua` options (ports, DB, core engine flags)
- The broken types above, until their engine paths are finished

## Cautions (why they were left broken)

Naive reload is not always safe:

1. **Pointer lifetime** (`groups`, `vocations`): players hold raw pointers into maps that `clear()` deletes.
2. **Items**: `items.otb` is the binary base. `items.xml` only overlays. Blind clear+reload can free live `Condition*` objects or leave stale fields when an XML attribute is removed.
3. **Outfits**: reload without clearing maps would duplicate entries.
4. **Weapons / houseprices**: mostly unfinished wiring, not deep engine risk.

Decision: keep individual broken C++ paths as-is and block every dangerous type
in both layers until it is fixed. Talkaction blocks direct `/reload`. `RELOAD_ALL`
and `SIGCONT` skip the same set. Unblock a type only after the engine path is safe.
