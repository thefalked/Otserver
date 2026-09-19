# Death penalty (experience / levels)

## Server settings

| Config | Value | Role |
| -------- | ------: | ------ |
| `deathLostPercent` | `15` | Base death hardness. Applied in `login.lua` as `loss * 10`. |
| `eachBlessReduction` | `6` | Each blessing subtracts 6 from the experience loss scale. |
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
LOSS_EXPERIENCE = 15 * 10 = 150
eachBlessReduction = 6
5 blessings => subtract 30
Vip Baiak lessLoss = 10
```

| Player type | Vocation | `lessLoss` | Bless | percent | Above level 25 approx |
| ------------- | ---------- | ----------: | ------: | --------: | ------------------------ |
| Non-VIP | Base vocations (ids 1-4) | 0 | 0 | `150 / 100 = 1.5` | `((level + 50) / 100) * 1.5` |
| Non-VIP | Base vocations (ids 1-4) | 0 | 5 | `(150 - 30) / 100 = 1.2` | `((level + 50) / 100) * 1.2` |
| VIP | Vip Baiak vocations (ids 5-8) | 10 | 0 | `(150 - 10) / 100 = 1.4` | `((level + 50) / 100) * 1.4` |
| VIP | Vip Baiak vocations (ids 5-8) | 10 | 5 | `(150 - 10 - 30) / 100 = 1.1` | `((level + 50) / 100) * 1.1` |

VIP classes lose a little less than non-VIP because of `lessloss="10"` in `server/data/XML/vocations.xml`. Five blessings subtract another 30 from the scale. At `deathLostPercent = 15` and `eachBlessReduction = 6` that is about a **20%** softer death hit than unblessed.

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

So `deathLostPercent = 15` is **1.5×** the old default of `10` (which already meant full formula strength, not “10% of a level”).

## Expected level loss @ `deathLostPercent = 15`, `eachBlessReduction = 6`

Assumptions:

- Mid-level (50% into the current level).
- Non-VIP = no vocation `lessLoss`. VIP = `lessloss="10"` on Vip Baiak classes.
- `0b` = no blessings. `5b` = all five from `!bless` (docs baseline).

| Level | Non-VIP 0b lose | Non-VIP 0b ends | Non-VIP 5b lose | Non-VIP 5b ends | VIP 0b lose | VIP 0b ends | VIP 5b lose | VIP 5b ends |
| ------: | ----------------: | ----------------: | ----------------: | ----------------: | ------------: | ------------: | ------------: | ------------: |
| 10 | 0.45 | 10 | 0.36 | 10 | 0.42 | 10 | 0.33 | 10 |
| 20 | 0.99 | 19 | 0.78 | 19 | 0.92 | 19 | 0.71 | 19 |
| 30 | 1.16 | 29 | 0.92 | 29 | 1.08 | 29 | 0.84 | 29 |
| 40 | 1.32 | 39 | 1.05 | 39 | 1.23 | 39 | 0.96 | 39 |
| 50 | 1.48 | 49 | 1.18 | 49 | 1.38 | 49 | 1.08 | 49 |
| 60 | 1.63 | 58 | 1.30 | 59 | 1.52 | 58 | 1.19 | 59 |
| 70 | 1.78 | 68 | 1.42 | 69 | 1.66 | 68 | 1.30 | 69 |
| 80 | 1.94 | 78 | 1.54 | 78 | 1.80 | 78 | 1.41 | 79 |
| 90 | 2.09 | 88 | 1.66 | 88 | 1.95 | 88 | 1.52 | 88 |
| 100 | 2.24 | 98 | 1.78 | 98 | 2.09 | 98 | 1.63 | 98 |
| 150 | 3.00 | 147 | 2.39 | 148 | 2.80 | 147 | 2.19 | 148 |
| 200 | 3.75 | 196 | 2.99 | 197 | 3.50 | 197 | 2.74 | 197 |
| 250 | 4.51 | 245 | 3.59 | 246 | 4.20 | 246 | 3.29 | 247 |
| 300 | 5.26 | 295 | 4.19 | 296 | 4.91 | 295 | 3.84 | 296 |
| 400 | 6.77 | 393 | 5.40 | 395 | 6.31 | 394 | 4.94 | 395 |
| 500 | 8.28 | 492 | 6.60 | 493 | 7.72 | 492 | 6.04 | 494 |
| 600 | 9.79 | 590 | 7.80 | 592 | 9.12 | 591 | 7.15 | 593 |
| 700 | 11.29 | 689 | 9.01 | 691 | 10.53 | 689 | 8.25 | 692 |
| 800 | 12.80 | 787 | 10.21 | 790 | 11.94 | 788 | 9.35 | 791 |
| 900 | 14.31 | 886 | 11.41 | 889 | 13.34 | 887 | 10.45 | 890 |
| 1000 | 15.82 | 984 | 12.61 | 987 | 14.75 | 985 | 11.55 | 988 |
| 2000 | 30.90 | 1969 | 24.64 | 1975 | 28.81 | 1971 | 22.56 | 1977 |
| 3000 | 45.97 | 2954 | 36.66 | 2963 | 42.86 | 2957 | 33.57 | 2966 |
| 4000 | 61.05 | 3939 | 48.69 | 3951 | 56.92 | 3943 | 44.58 | 3955 |
| 5000 | 76.13 | 4924 | 60.71 | 4939 | 70.98 | 4929 | 55.60 | 4944 |
| 6000 | 91.20 | 5909 | 72.74 | 5927 | 85.03 | 5915 | 66.61 | 5933 |
| 7000 | 106.28 | 6894 | 84.76 | 6915 | 99.09 | 6901 | 77.62 | 6922 |
| 8000 | 121.36 | 7879 | 96.79 | 7903 | 113.15 | 7887 | 88.63 | 7911 |
| 9000 | 136.43 | 8864 | 108.81 | 8891 | 127.21 | 8873 | 99.64 | 8900 |
| 10000 | 151.51 | 9848 | 120.83 | 9879 | 141.26 | 9859 | 110.65 | 9889 |
| 11000 | 166.59 | 10833 | 132.86 | 10867 | 155.32 | 10845 | 121.66 | 10878 |
| 12000 | 181.66 | 11818 | 144.88 | 11855 | 169.38 | 11831 | 132.67 | 11867 |
| 13000 | 196.74 | 12803 | 156.91 | 12843 | 183.43 | 12817 | 143.69 | 12856 |
| 14000 | 211.82 | 13788 | 168.93 | 13831 | 197.49 | 13803 | 154.70 | 13845 |
| 15000 | 226.89 | 14773 | 180.96 | 14819 | 211.55 | 14788 | 165.71 | 14834 |

## Recalculate locally

```bash
python3 scripts/death_penalty.py
python3 scripts/death_penalty.py --death-lost 15 --each-bless 6 --bless 0,5 --compact
```

Defaults match current server settings (`deathLostPercent=15`, `eachBlessReduction=6`, bless `0,5`, VIP `lessLoss=10`). Baseline play assumes `!bless` (5 blessings).

The script mirrors `login.lua` and `Player::getLostExperience()` / `getExpForLevel()`.

## Ops notes

- Commit / edit `server/config.lua.template`. Live `server/config.lua` is generated and gitignored.
- After changing the template, re-render or update `server/config.lua` and **restart** the game server.
- On restart every player must log in again. `login.lua` then stamps the new `deathLostPercent * 10` onto the character. That stamped value is what death uses until the next login overwrite.
- `lessloss` from `vocations.xml` is loaded at server start and applied at death. No login step is involved.
