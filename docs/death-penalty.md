# Death penalty (experience / levels)

## Server settings

| Config | Value | Role |
| -------- | ------: | ------ |
| `deathLostPercent` | `20` | Base death hardness. Applied in `login.lua` as `loss * 10`. |
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
LOSS_EXPERIENCE = 20 * 10 = 200
eachBlessReduction = 2
5 blessings => subtract 10
Vip Baiak lessLoss = 10
```

| Player type | Vocation | `lessLoss` | Bless | percent | Above level 25 approx |
| ------------- | ---------- | ----------: | ------: | --------: | ------------------------ |
| Non-VIP | Base vocations (ids 1-4) | 0 | 0 | `200 / 100 = 2.0` | `((level + 50) / 100) * 2.0` |
| Non-VIP | Base vocations (ids 1-4) | 0 | 5 | `(200 - 10) / 100 = 1.9` | `((level + 50) / 100) * 1.9` |
| VIP | Vip Baiak vocations (ids 5-8) | 10 | 0 | `(200 - 10) / 100 = 1.9` | `((level + 50) / 100) * 1.9` |
| VIP | Vip Baiak vocations (ids 5-8) | 10 | 5 | `(200 - 10 - 10) / 100 = 1.8` | `((level + 50) / 100) * 1.8` |

VIP classes lose a little less than non-VIP because of `lessloss="10"` in `server/data/XML/vocations.xml`. Five blessings subtract another 10 from the scale. At `deathLostPercent = 20` that is about a **5%** softer death hit than unblessed.

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

So `deathLostPercent = 20` is **2×** the old default of `10` (which already meant full formula strength, not “10% of a level”).

## Expected level loss @ `deathLostPercent = 20`, `eachBlessReduction = 2`

Assumptions:

- Mid-level (50% into the current level).
- Non-VIP = no vocation `lessLoss`. VIP = `lessloss="10"` on Vip Baiak classes.
- `0b` = no blessings. `5b` = all five from `!bless` (docs baseline).

| Level | Non-VIP 0b lose | Non-VIP 0b ends | Non-VIP 5b lose | Non-VIP 5b ends | VIP 0b lose | VIP 0b ends | VIP 5b lose | VIP 5b ends |
| ------: | ----------------: | ----------------: | ----------------: | ----------------: | ------------: | ------------: | ------------: | ------------: |
| 10 | 0.63 | 9 | 0.59 | 9 | 0.59 | 9 | 0.55 | 9 |
| 20 | 1.34 | 19 | 1.27 | 19 | 1.27 | 19 | 1.20 | 19 |
| 30 | 1.57 | 28 | 1.48 | 29 | 1.48 | 29 | 1.40 | 29 |
| 40 | 1.79 | 38 | 1.69 | 38 | 1.69 | 38 | 1.60 | 38 |
| 50 | 2.00 | 48 | 1.90 | 48 | 1.90 | 48 | 1.79 | 48 |
| 60 | 2.20 | 58 | 2.09 | 58 | 2.09 | 58 | 1.97 | 58 |
| 70 | 2.40 | 68 | 2.28 | 68 | 2.28 | 68 | 2.15 | 68 |
| 80 | 2.60 | 77 | 2.47 | 78 | 2.47 | 78 | 2.33 | 78 |
| 90 | 2.81 | 87 | 2.66 | 87 | 2.66 | 87 | 2.52 | 87 |
| 100 | 3.01 | 97 | 2.86 | 97 | 2.86 | 97 | 2.70 | 97 |
| 150 | 4.03 | 146 | 3.82 | 146 | 3.82 | 146 | 3.61 | 146 |
| 200 | 5.04 | 195 | 4.78 | 195 | 4.78 | 195 | 4.52 | 195 |
| 250 | 6.05 | 244 | 5.74 | 244 | 5.74 | 244 | 5.43 | 245 |
| 300 | 7.06 | 293 | 6.70 | 293 | 6.70 | 293 | 6.34 | 294 |
| 400 | 9.08 | 391 | 8.62 | 391 | 8.62 | 391 | 8.15 | 392 |
| 500 | 11.10 | 489 | 10.53 | 489 | 10.53 | 489 | 9.97 | 490 |
| 600 | 13.12 | 587 | 12.45 | 588 | 12.45 | 588 | 11.78 | 588 |
| 700 | 15.14 | 685 | 14.37 | 686 | 14.37 | 686 | 13.60 | 686 |
| 800 | 17.16 | 783 | 16.29 | 784 | 16.29 | 784 | 15.41 | 785 |
| 900 | 19.18 | 881 | 18.21 | 882 | 18.21 | 882 | 17.23 | 883 |
| 1000 | 21.21 | 979 | 20.12 | 980 | 20.12 | 980 | 19.04 | 981 |
| 2000 | 41.41 | 1959 | 39.30 | 1961 | 39.30 | 1961 | 37.19 | 1963 |
| 3000 | 61.62 | 2938 | 58.48 | 2942 | 58.48 | 2942 | 55.34 | 2945 |
| 4000 | 81.83 | 3918 | 77.65 | 3922 | 77.65 | 3922 | 73.49 | 3927 |
| 5000 | 102.03 | 4898 | 96.83 | 4903 | 96.83 | 4903 | 91.64 | 4908 |
| 6000 | 122.24 | 5878 | 116.00 | 5884 | 116.00 | 5884 | 109.78 | 5890 |
| 7000 | 142.44 | 6858 | 135.18 | 6865 | 135.18 | 6865 | 127.93 | 6872 |
| 8000 | 162.65 | 7837 | 154.36 | 7846 | 154.36 | 7846 | 146.08 | 7854 |
| 9000 | 182.86 | 8817 | 173.53 | 8826 | 173.53 | 8826 | 164.23 | 8836 |
| 10000 | 203.06 | 9797 | 192.71 | 9807 | 192.71 | 9807 | 182.38 | 9818 |
| 11000 | 223.27 | 10777 | 211.88 | 10788 | 211.88 | 10788 | 200.52 | 10799 |
| 12000 | 243.47 | 11757 | 231.06 | 11769 | 231.06 | 11769 | 218.67 | 11781 |
| 13000 | 263.68 | 12736 | 250.24 | 12750 | 250.24 | 12750 | 236.82 | 12763 |
| 14000 | 283.89 | 13716 | 269.41 | 13731 | 269.41 | 13731 | 254.97 | 13745 |
| 15000 | 304.09 | 14696 | 288.59 | 14711 | 288.59 | 14711 | 273.12 | 14727 |

## Recalculate locally

```bash
python3 scripts/death_penalty.py
python3 scripts/death_penalty.py --death-lost 20 --each-bless 2 --bless 0,5 --compact
```

Defaults match current server settings (`deathLostPercent=20`, `eachBlessReduction=2`, bless `0,5`, VIP `lessLoss=10`). Baseline play assumes `!bless` (5 blessings).

The script mirrors `login.lua` and `Player::getLostExperience()` / `getExpForLevel()`.

## Ops notes

- Commit / edit `server/config.lua.template`. Live `server/config.lua` is generated and gitignored.
- After changing the template, re-render or update `server/config.lua` and **restart** the game server.
- On restart every player must log in again. `login.lua` then stamps the new `deathLostPercent * 10` onto the character. That stamped value is what death uses until the next login overwrite.
- `lessloss` from `vocations.xml` is loaded at server start and applied at death. No login step is involved.
