# Spell balance (level 2000–15000)

## Why these changes

At high level on this server, several class spells fell behind unfair formulas:

- **Elite Knight heal** (`Wound Cleansing` / `exana mort`) used normal `setHealingFormula` coeffs. With ML around 12 it barely beat `level/5`, while Mana Rune (`id 2276`) restores far more because it multiplies the whole `(level/5 + ML)` base.
- **Mage AoE** Hell’s Core (`exevo gran mas flam`), Rage of the Skies (`exevo gran mas vis`), and Eternal Winter (`exevo gran mas frigo`) used `setAttackFormula`. suden death (`exevo gran mas mort`) used a Mindrage 4-arg formula that multiplies the full base by up to 7. Mort stayed much stronger. Flam/vis/frigo were buffed toward that style but **kept weaker than mort** (mort has a smaller path/area).
- **Fierce Berserk** (`exori gran`) used `level/8` while Berserk/Groundshaker use `level/5`.
- **Divine Caldera** (`exevo mas san`) used `level/15`, so it collapsed as level rose.

**Not changed:** suden death (`exevo gran mas mort`), Sudden Death rune (`SD` / id 2268).

## How the engine calculates

From `src/combat.cpp` (`FORMULA_LEVELMAGIC`):

```text
min = (level / minl + ML * minm) * mina + minb
max = (level / maxl + ML * maxm) * maxa + maxb
```

Defaults when Lua only passes four args (`mina, minb, maxa, maxb`):

- `minl = maxl = formulaLevel` (config default `5.0`)
- `minm = maxm = formulaMagic` (config default `1.0`)

Helpers:

- `setAttackFormula(minl, maxl, minm, maxm)` → `mina = maxa = -1`, `minb = maxb = 0`
- `setHealingFormula(minl, maxl, minm, maxm)` → `mina = maxa = 1`, `minb = maxb = 0`

Fierce Berserk is skill-based:

```text
skillTotal = skill + attack * 3
min = -(skillTotal * 2.2 + level / 5)
max = -(skillTotal * 6   + level / 5)
```

## Assumptions for tables and tests

| Role | Level range | Magic level | Other |
| ------ | ------------- | ------------- | ------- |
| MS / ED | 2000–15000 | 130 | — |
| RP | 2000–15000 | 40 | — |
| EK | 2000–15000 | 12 | skill 140, weapon attack 55 |

## What changed

| Spell | Words | Class | Old formula | New formula | Intent |
| ------- | ------- | ------- | ------------- | ------------- | -------- |
| Wound Cleansing | `exana mort` | EK | `setHealingFormula(5, 5, 11, 15)` | `setCombatFormula(4.5, 0, 2.7, 0)` | ~90% of Mana Rune scaling |
| Hell’s Core | `exevo gran mas flam` | MS | `setAttackFormula(5, 5, 7, 14)` | `setCombatFormula(-6, -6, -2, -1)` | ~89% of mort |
| Rage of the Skies | `exevo gran mas vis` | MS | `setAttackFormula(5, 5, 5, 12)` | `setCombatFormula(-5.8, -5, -1.9, -0.9)` | ~86% of mort |
| Eternal Winter | `exevo gran mas frigo` | ED | `setAttackFormula(5, 5, 6, 12)` | `setCombatFormula(-5.5, -5, -1.8, -0.8)` | ~81% of mort |
| Fierce Berserk | `exori gran` | EK | `level / 8` | `level / 5` | Match other EK AoE level floor |
| Divine Caldera | `exevo mas san` | RP | `setAttackFormula(15, 15, 14, 17)` | `setAttackFormula(5, 5, 14, 17)` | Stop `level/15` collapse |

Target mage AoE order: **mort > flam > vis > frigo**.

## Re-run calculations after tweaks

From the repo root:

```bash
python3 scripts/spell_balance_15k.py
python3 scripts/spell_balance_15k.py --level 7500 --ml-ek 12 --ml-mage 130 --ml-rp 40
```

Edit the formula constants at the top of `scripts/spell_balance_15k.py`, re-run until pass criteria hold, then mirror the winning numbers into the Lua scripts listed above.

Pass criteria encoded in the script:

1. mort avg > flam avg > vis avg > frigo avg (ML 130)
2. Wound Cleansing / Mana Rune ratio between 0.88 and 0.92 (EK ML 12)
3. Exit non-zero if any check fails

## Files

- `server/data/spells/scripts/healing/wound_cleasing.lua`
- `server/data/spells/scripts/attack/hells_core.lua`
- `server/data/spells/scripts/attack/rage_of_the_skies.lua`
- `server/data/spells/scripts/attack/eternal_winter.lua`
- `server/data/spells/scripts/attack/fierce_berserk.lua`
- `server/data/spells/scripts/attack/divine_caldera.lua`
- `scripts/spell_balance_15k.py`
- `docs/spell-balance-15k.md`
