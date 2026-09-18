# Distance weapon swing (potting)

Distance weapons used to pause auto-attack while the player drank potions or used other items. Listed distance entries in `weapons.xml` now keep attacking through that lock.

## What `swing` means

`swing` is a weapons.xml flag. It does not control animation.

| Value | Effect |
| --- | --- |
| `swing="1"` (true) | Keep attacking while an action lock is active (pots, use-with items). |
| omitted / false | Pause the next shot until `canDoAction()` is true again. |

Server logic (`Player::doAttacking`):

1. Using a potion goes through `useItemEx`.
2. That sets `nextAction` from `timeBetweenExActions` (default **1000 ms**).
3. If the weapon has `interruptSwing()` (`swing` false) and the player cannot act yet, the attack is delayed.

Melee and wands default to `swing` true. Distance weapons default to false in C++ (`WeaponDistance` constructor).

## Change made

All **28** `<distance>` entries in `server/data/weapons/weapons.xml` set `swing="1"`.

That includes:

- Bows and crossbows listed in the file
- Thrown weapons such as **Baiakzik Star** (`7368`) and **Master Spear** (`3965`)
- Ammo entries listed in the file (poison/burst arrows, elemental bolts, Vip Star script, etc.)

No `src/` change. Reload weapons or restart the server to apply.

## Limitation

Bows that shoot ammo **not** listed in `weapons.xml` (for example normal arrows `2544` or bolts `2543`) still use the C++ distance default (`swing = false`). Those shots can still pause while potting.

For those cases, either:

- Add a `<distance swing="1" id="..." .../>` entry for that ammo id, or
- Lower `timeBetweenExActions` in config (affects all use-with items, including runes).

## Related files

- `server/data/weapons/weapons.xml`
- `src/weapons.cpp` (`WeaponDistance` default `swing = false`, XML can override)
- `src/player.cpp` (`doAttacking` + `interruptSwing`)
- `src/actions.cpp` (`useItemEx` sets the action lock)
- `server/config.lua` / template: `timeBetweenExActions`
