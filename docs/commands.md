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
- Last-hit killer (`killed_by`)
- Most-damage killer (`altkilled_by`), when different

Player killers are shown by name. Monster or environment killers are shown as names.

## Files

| Piece | Path |
| ------ | ---- |
| Talkaction XML | `server/data/talkactions/talkactions.xml` (`words="/deathlist"`) |
| Talkaction script | `server/data/talkactions/scripts/deathlist.lua` |
| Death recorder | `server/data/creaturescripts/scripts/playerdeath.lua` (`PlayerDeath`) |
| Commands list text | `server/data/talkactions/scripts/commands.lua` |

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
maxDeathRecords = 5
```

`playerdeath.lua` writes rows into `player_deaths` only when `deathListEnabled` is true. If it is off, `/deathlist` reports no deaths.

## Database

Query source: `player_deaths`.

| Column | Meaning |
| -------- | ------- |
| `player_id` | Victim GUID |
| `time` | Unix timestamp |
| `level` | Victim level at death |
| `killed_by` | Last hit (player GUID string, or creature name) |
| `altkilled_by` | Most damage when different (same format) |

Old rows for a player are trimmed to `maxDeathRecords` after each insert.
