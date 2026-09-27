# Inactive house cleanup (3 days)

Houses are freed when the owner stays offline longer than `houseCleanOld`. With rent set to `"never"`, the C++ rent path never runs. Cleanup is done in Lua.

## Server settings

| Config | Value | Role |
| -------- | ------: | ------ |
| `houseCleanOld` | `3 * 24 * 60 * 60` | Seconds offline before a house can be cleared. `0` disables auto-clean and `!myhouse`. |
| `houseRentPeriod` | `"never"` | Disables `Houses::payHouses()`. Built-in C++ `HOUSE_CLEAN_OLD` inside rent payment does not run. |
| `worldId` | (your world) | Auto-clean only touches houses for this world. |

Set the same value in:

- `server/config.lua` (live)
- `server/config.lua.template` (defaults for new setups)

## How inactivity is measured

Last activity is:

```text
GREATEST(IFNULL(lastlogout, 0), IFNULL(lastlogin, 0))
```

`lastlogout` is preferred when present. `lastlogin` is the fallback if logout was never saved.

A house is inactive when that timestamp is older than `now - houseCleanOld`.

Orphan houses (owner GUID with no `players` row) are cleared at once. They do not wait 3 days.

Online owners are never cleared. Both paths check `getPlayerByGUID` first.

## Automatic cleanup

Script: `server/data/globalevents/scripts/house_clean_old.lua`

Wired in `server/data/globalevents/globalevents.xml`:

| Event | When |
| -------- | ------ |
| `house_clean_old` | Every 30 minutes (`interval="1800000"`) |

It does not run on startup or globalsave. Online owners stay protected by `getPlayerByGUID` during the interval tick.

Flow:

1. Skip if `houseCleanOld <= 0`.
2. Select owned houses that are orphaned or past the inactivity cutoff.
3. Skip owners who are online.
4. Call `doCleanHouse(houseId)` while the owner is still set (moves pickupable items to depot).
5. Call `setHouseOwner(houseId, 0, false)` to clear the owner without cleaning again.
6. If any house was cleared, run `doSaveServer()` so house tiles are written and loot cannot come back after a restart.

Console log when any house is cleared: `> Cleared N inactive house(s).`

## One-shot free-house loot strip

God command: `/cleanhouses` → `server/data/talkactions/scripts/cleanhouses.lua`

Access: same as `/owner` (`access="5"`).

Runs a scan or cleanup on free houses (`owner = 0`). Leftover pickupable items are removed on confirm (no owner to receive a depot transfer). Use once to clear houses left dirty by the old clear-owner-first bug. Strips in Lua (does not need `doCleanHouse`). Engine `doCleanHouse` still needs a rebuild for owned-house reclaim/auto-clean when `townid="0"` (depot needs a town; free/unloadable-owner delete does not).

Usage:

- `/cleanhouses` — scan only. Reports how many free houses exist and how many still have removable loot.
- `/cleanhouses confirm` — clean those dirty free houses, then save.

## Player reclaim (`!myhouse`)

Talkaction: `!myhouse` → `server/data/talkactions/scripts/eject.lua`

Wiring: `server/data/talkactions/talkactions.xml`

This command does **not** buy the house. It only clears an inactive owner so anyone can buy it the normal way.

How to use it:

1. Stand facing the house door.
2. Say `!myhouse`.
3. If the owner is inactive for at least `houseCleanOld` (or the owner row is missing), the house becomes free.
4. Buy the house with the normal house purchase flow.

Same threshold and activity rules as automatic cleanup.

## What happens to items

Cleanup calls `doCleanHouse` while the old owner is still set, then clears the owner with `setHouseOwner(..., false)`. Pickupable items go to the owner depot when the character can be loaded. If the owner cannot be loaded, those items are removed. A server save follows so the emptied house is stored.

## How to change the delay

Edit `houseCleanOld` in `config.lua` (and the template if you want new installs to match). Example for 7 days:

```lua
houseCleanOld = 7 * 24 * 60 * 60
```

Reload or restart so both the globalevent and `!myhouse` read the new value. No Lua edit is required for the delay alone.

To disable both auto-clean and `!myhouse` reclaim:

```lua
houseCleanOld = 0
```

## Related engine code (not used with rent never)

`Houses::payHouse` in `src/house.cpp` also checks `HOUSE_CLEAN_OLD` during rent payment. That path only runs when `houseRentPeriod` is not `"never"`. Keep the Lua globalevent while rent stays disabled.
