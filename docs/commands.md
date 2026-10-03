# `/deathlist` command

Staff command that shows a player's recent deaths and killers.

## Usage

```text
/deathlist PlayerName
```

Access: Senior Tutor (`access` 2) and above.

Reload after XML or script changes:

```text
/reload talkactions
```

Or restart the server.

## What it shows

A popup with up to 10 deaths, newest first. Each line includes:

- Date and time
- Level at death
- Killers for that death (last hit first, then assists)

Player killers are shown by name. Monster or environment killers use the stored name. Summons show as `monster summoned by Player`.

## Files

| Piece | Path |
| ------ | ---- |
| Talkaction XML | `server/data/talkactions/talkactions.xml` (`words="/deathlist"`) |
| Talkaction script | `server/data/talkactions/scripts/deathlist.lua` |
| Death recorder | `IOLoginData::playerDeath` in `src/iologindata.cpp` |
| Commands list text | `server/data/talkactions/scripts/commands.lua` |

`server/data/creaturescripts/scripts/playerdeath.lua` is an old Lua recorder for a different schema. It is not registered on login and is not used by this command.

## Command descriptions (`!commands`)

Registering a talkaction in `talkactions.xml` makes the command work. It does **not** add a description to `!commands` / `/commands`.

For a description to appear, also add an entry in `server/data/talkactions/scripts/commands.lua` under the `descriptions` table. The key must match the `words` value from XML (first word if several are joined with `;`).

Example:

```lua
["/deathlist"] = "Show a player's recent deaths and killers",
```

If the key is missing, the command still lists for players with access, but with no text after the dash.

## Requirements

In `config.lua`:

```lua
deathListEnabled = true
```

Default is true. When enabled, the engine writes deaths on player death. If it is off, `/deathlist` reports no deaths.

## Database

Deaths use the engine schema (not the old `time` / `killed_by` columns).

| Table | Role |
| ------ | ---- |
| `player_deaths` | Victim, `date`, `level` |
| `killers` | Links a death to killer rows (`final_hit`, `unjustified`) |
| `player_killers` | Player GUID for a killer row |
| `environment_killers` | Monster or environment name for a killer row |

`/deathlist` joins those tables the same way as the website last-deaths page.
