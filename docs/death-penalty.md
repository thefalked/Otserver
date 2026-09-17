# Death penalty (experience / levels)

## Server settings

| Config | Value | Role |
| -------- | ------: | ------ |
| `deathLostPercent` | `80` | Base death hardness. Applied in `login.lua` as `loss * 10`. |
| `eachBlessReduction` | `2` | Each blessing subtracts 2 from the experience loss scale. |
| Vip Baiak `lessloss` (ids 5-8) | `10` | Subtracted from the experience loss scale at death. |
| Epic `lessloss` (ids 9-12, commented out) | `30` | Same, if those vocations are enabled. |

Design baseline for published tables: **5 blessings**. Live players buy all five at once with `!bless` (`server/data/talkactions/scripts/bless.lua`, 80k gold). Tables still show `0b` for unblessed deaths.

Related script: `server/data/creaturescripts/scripts/login.lua`

- Sets `PLAYERLOSS_EXPERIENCE` from `deathLostPercent * 10` on login.
- That value is stored on the player and used when they die.
- Skill and mana loss then follow how much experience was removed.

`vocation.lessLoss` is loaded from `vocations.xml` at server start and read at death. It is not set in `login.lua`.

## How the engine calculates

Source: `Player::getLostExperience()` in `src/player.cpp`.

```text
percent = (LOSS_EXPERIENCE - vocation.lessLoss - blessings * eachBlessReduction) / 100
```

With current config and the `!bless` baseline:

```text
LOSS_EXPERIENCE = 80 * 10 = 800
eachBlessReduction = 2
5 blessings => subtract 10
Vip Baiak lessLoss = 10
```

| Player type | Vocation | `lessLoss` | Bless | percent | Above level 25 approx |
| ------------- | ---------- | ----------: | ------: | --------: | ------------------------ |
| Non-VIP | Base vocations (ids 1-4) | 0 | 0 | `800 / 100 = 8.0` | `((level + 50) / 100) * 8.0` |
| Non-VIP | Base vocations (ids 1-4) | 0 | 5 | `(800 - 10) / 100 = 7.9` | `((level + 50) / 100) * 7.9` |
| VIP | Vip Baiak vocations (ids 5-8) | 10 | 0 | `(800 - 10) / 100 = 7.9` | `((level + 50) / 100) * 7.9` |
| VIP | Vip Baiak vocations (ids 5-8) | 10 | 5 | `(800 - 10 - 10) / 100 = 7.8` | `((level + 50) / 100) * 7.8` |

VIP classes lose a little less than non-VIP because of `lessloss="10"` in `server/data/XML/vocations.xml`. Five blessings subtract another 10 from the scale. At `deathLostPercent = 80` that is only about a **1.25%** softer death hit than unblessed.

Then:

- **Level ≤ 25:** `lostExp = floor(totalExperience * percent / 10)`.
- **Level > 25:** build an experience sum equal to `(level + 50) / 100` level-bands, then multiply by `percent`.

## Blessings and item / container drop

This path is separate from experience. Source: `Player::dropLoot()` in `src/player.cpp`.

Config (see `server/config.lua.template`):

| Config | Value | Role |
|--------|------:|------|
| `blessingReductionBase` | `30` | First blessing subtracts this from the container-loss chance. |
| `blessingReductionDecrement` | `5` | Each next blessing subtracts 5 less than the previous one. |

Engine also accepts the old typo key `blessingReductionDecreament`.

Start from `loss = lossPercent[LOSS_CONTAINERS]` (default `100`). For each blessing count returned by `getBlessings()`:

```text
loss -= start
start -= blessingReductionDecrement
```

with `start` beginning at `blessingReductionBase`.

With base `30` and decrement `5`, and with all five from `!bless`:

| Blessings | Container roll (`loss`) | Item roll (`itemLoss`) |
| --------: | ----------------------: | ---------------------: |
| 0 | 100 | 10 |
| 1 | 70 | 7 |
| 2 | 45 | 5 |
| 3 | 25 | 3 |
| 4 | 10 | 1 |
| 5 (`!bless`) | 0 | 0 |

So a fully blessed player from `!bless` does not drop bags or items from the normal roll. A skull worse than white still forces drops.

`itemLoss = floor((5 + loss) * lossPercent[LOSS_ITEMS] / 1000)`. With default item loss percent `100`, that is `floor((5 + loss) / 10)`.

On death, each inventory slot rolls `1..100`:

- Containers drop when `roll < loss`.
- Non-containers drop when `roll < itemLoss`.
- Skull worse than white forces the drop.

`getBlessings()` returns `0` when blessings are disabled, or when `blessingOnlyPremium` is on and the player is not premium. Those players get no drop reduction and no experience bless reduction.

`eachBlessReduction` does **not** affect item drops. Only `blessingReductionBase` / `blessingReductionDecrement` do.

## Verified chain

Re-checked against source:

1. `login.lua` multiplies `deathLostPercent` by `10` before `doPlayerSetLossPercent(..., PLAYERLOSS_EXPERIENCE, ...)`.
2. `getLostExperience()` uses that value, minus `lessLoss`, minus `blessings * eachBlessReduction`.
3. Skill / mana loss scale from how much experience was removed (`Player::onDeath`), using the pre-death experience ratio.
4. `!bless` grants blessings 1-5 together (`server/data/talkactions/scripts/bless.lua`).

So `deathLostPercent = 80` is **8×** the old default of `10` (which already meant full formula strength, not “10% of a level”).

## Expected level loss @ `deathLostPercent = 80`, `eachBlessReduction = 2`

Assumptions:

- Mid-level (50% into the current level).
- Non-VIP = no vocation `lessLoss`. VIP = `lessloss="10"` on Vip Baiak classes.
- `0b` = no blessings. `5b` = all five from `!bless` (docs baseline).

| Level | Non-VIP 0b lose | Non-VIP 0b ends | Non-VIP 5b lose | Non-VIP 5b ends | VIP 0b lose | VIP 0b ends | VIP 5b lose | VIP 5b ends |
| ------: | ----------------: | ----------------: | ----------------: | ----------------: | ------------: | ------------: | ------------: | ------------: |
| 10 | 3.84 | 6 | 3.73 | 6 | 3.73 | 6 | 3.63 | 6 |
| 20 | 7.81 | 12 | 7.62 | 12 | 7.62 | 12 | 7.44 | 13 |
| 30 | 7.98 | 22 | 7.84 | 22 | 7.84 | 22 | 7.69 | 22 |
| 40 | 8.61 | 31 | 8.46 | 32 | 8.46 | 32 | 8.33 | 32 |
| 50 | 9.36 | 41 | 9.22 | 41 | 9.22 | 41 | 9.07 | 41 |
| 60 | 10.12 | 50 | 9.97 | 50 | 9.97 | 50 | 9.82 | 50 |
| 70 | 10.92 | 59 | 10.76 | 59 | 10.76 | 59 | 10.60 | 59 |
| 80 | 11.74 | 68 | 11.57 | 68 | 11.57 | 68 | 11.40 | 69 |
| 90 | 12.58 | 77 | 12.39 | 78 | 12.39 | 78 | 12.21 | 78 |
| 100 | 13.42 | 87 | 13.23 | 87 | 13.23 | 87 | 13.03 | 87 |
| 150 | 17.70 | 132 | 17.45 | 133 | 17.45 | 133 | 17.20 | 133 |
| 200 | 21.98 | 178 | 21.67 | 178 | 21.67 | 178 | 21.36 | 179 |
| 250 | 26.30 | 224 | 25.93 | 224 | 25.93 | 224 | 25.56 | 224 |
| 300 | 30.60 | 269 | 30.18 | 270 | 30.18 | 270 | 29.75 | 270 |
| 400 | 39.24 | 361 | 38.69 | 361 | 38.69 | 361 | 38.15 | 362 |
| 500 | 47.88 | 452 | 47.21 | 453 | 47.21 | 453 | 46.55 | 453 |
| 600 | 56.52 | 543 | 55.73 | 544 | 55.73 | 544 | 54.96 | 545 |
| 700 | 65.16 | 635 | 64.26 | 636 | 64.26 | 636 | 63.36 | 637 |
| 800 | 73.80 | 726 | 72.78 | 727 | 72.78 | 727 | 71.77 | 728 |
| 900 | 82.45 | 818 | 81.31 | 819 | 81.31 | 819 | 80.18 | 820 |
| 1000 | 91.09 | 909 | 89.84 | 910 | 89.84 | 910 | 88.58 | 911 |
| 2000 | 177.55 | 1822 | 175.11 | 1825 | 175.11 | 1825 | 172.67 | 1827 |
| 3000 | 264.01 | 2736 | 260.38 | 2740 | 260.38 | 2740 | 256.77 | 2743 |
| 4000 | 350.47 | 3650 | 345.66 | 3654 | 345.66 | 3654 | 340.86 | 3659 |
| 5000 | 436.93 | 4563 | 430.94 | 4569 | 430.94 | 4569 | 424.96 | 4575 |
| 6000 | 523.39 | 5477 | 516.22 | 5484 | 516.22 | 5484 | 509.06 | 5491 |
| 7000 | 609.86 | 6390 | 601.49 | 6399 | 601.49 | 6399 | 593.15 | 6407 |
| 8000 | 696.32 | 7304 | 686.77 | 7313 | 686.77 | 7313 | 677.25 | 7323 |
| 9000 | 782.78 | 8217 | 772.05 | 8228 | 772.05 | 8228 | 761.35 | 8239 |
| 10000 | 869.25 | 9131 | 857.33 | 9143 | 857.33 | 9143 | 845.44 | 9155 |
| 11000 | 955.71 | 10044 | 942.61 | 10057 | 942.61 | 10057 | 929.54 | 10070 |
| 12000 | 1042.17 | 10958 | 1027.88 | 10972 | 1027.88 | 10972 | 1013.63 | 10986 |
| 13000 | 1128.63 | 11871 | 1113.16 | 11887 | 1113.16 | 11887 | 1097.73 | 11902 |
| 14000 | 1215.10 | 12785 | 1198.44 | 12802 | 1198.44 | 12802 | 1181.83 | 12818 |
| 15000 | 1301.56 | 13698 | 1283.72 | 13716 | 1283.72 | 13716 | 1265.92 | 13734 |

## Recalculate locally

```bash
python3 scripts/death_penalty.py
python3 scripts/death_penalty.py --death-lost 80 --each-bless 2 --bless 0,5 --compact
```

Defaults match current server settings (`deathLostPercent=80`, `eachBlessReduction=2`, bless `0,5`, VIP `lessLoss=10`). Baseline play assumes `!bless` (5 blessings).

The script mirrors `login.lua` and `Player::getLostExperience()` / `getExpForLevel()`.

## Ops notes

- Commit / edit `server/config.lua.template`. Live `server/config.lua` is generated and gitignored.
- After changing the template, re-render or update `server/config.lua` and **restart** the game server.
- On restart every player must log in again. `login.lua` then stamps the new `deathLostPercent * 10` onto the character. That stamped value is what death uses until the next login overwrite.
- `lessloss` from `vocations.xml` is loaded at server start and applied at death. No login step is involved.
