# `/reload` command

Hot-reload without restarting the game process. Entry points:

- Talkaction: `server/data/talkactions/scripts/reload.lua`
- Engine: `Game::reloadInfo` in `src/game.cpp`
- Constants: `RELOAD_*` in `server/data/lib/000-constant.lua` and `src/game.h`

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
| `all` | loops every engine reload id through `RELOAD_WEAPONS`, then mods |

`SIGCONT` on the process also triggers `RELOAD_ALL`.

## Broken / no-op types

These are listed in the talkaction for discovery, but `/reload` refuses them and tells the player they do not work. Left unchanged in C++ for now.

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

Decision for now: keep C++ as-is. The talkaction documents working vs broken lists and blocks broken types so the server does not report a fake success.
