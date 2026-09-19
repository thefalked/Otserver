# Quest boss damage (2-player target)

This pass raises attack damage on selected quest and VIP bosses so solo clears are harder. The design goal is that a fight should need about **2 players** (for example a VIP knight tank plus a healer or shooter).

Monster HP, loot, defenses, summons, and immunities were left alone. Only attack values changed (plus one new ice attack on Guardian of The Sea).

Active files come from `server/data/monster/monsters.xml`. Duplicate XML under `bosses/` is not loaded for these names.

## Why these bosses felt easy

Player sustain on this Baiak setup is very high.

### Player HP (approx formula)

`HP ≈ 185 + (level - 8) × gainhp`

| Vocation | gainhp | HP at L200 | Passive regen |
| -------- | -----: | ---------: | ------------- |
| Elite Knight / Vip Baiak Knight | 15 | ~3065 | EK ~210 HP/s, VIP EK ~230 HP/s |
| Royal Paladin / Vip Baiak Paladin | 10 | ~2105 | RP ~200 HP/s, VIP RP ~210 HP/s |
| Master Sorcerer / Elder Druid / VIP mages | 5 | ~1145 | ~50–67 HP/s |

Source: `server/data/XML/vocations.xml` (`gainhp`, `gainhpticks`, `gainhpamount`).

### Potions dominate average DPS

Source: `server/data/actions/scripts/liquids/potions.lua`

| Potion | Heal range | Notes |
| ------ | ---------- | ----- |
| Ultimate health (8473) | 1000–11000 | Knights L130+. Average about 6000 per use. |
| Great health (7591) | 1300–1500 | Knights L80+. |
| Great spirit (8472) | 500–8000 HP | Paladins. Also restores mana. |

A solo VIP knight spamming ultimate health potions can recover thousands of HP per second. Average monster DPS under about 1500 barely matters. What kills players is **burst** (a big hit before the next pot) and **overlapping AOEs**.

### Balance implication

- Raising only HP makes fights longer, not harder.
- Raising `min`/`max` (and melee skill/attack) raises burst and forces a second player.
- Soft bosses (Guardian, Ferumbras, Hellgorak) needed large multipliers.
- Strong bosses (Abominator, Dark Abominator) needed a smaller bump so they stay around 2 players, not 3–4.

## Applied multipliers (mid values)

| Monster | Multiplier | File |
| ------- | ---------- | ---- |
| Guardian of The Sea | ~×3.5 melee + new ice AOE | `server/data/monster/quest/guardian_of_the_sea.xml` |
| Ferumbras | ×3 spells, melee raised | `server/data/monster/sorcerers/ferumbras.xml` |
| Hellgorak | ×2.75 spells, melee raised | `server/data/monster/the_ruthless_seven_minions/hellgorak.xml` |
| Bossing of Baiak | ×2.1 all attacks | `server/data/monster/vip/bossing_of_baiak.xml` |
| Ghazbaran | ×2 spells, melee ~+20% | `server/data/monster/demon_bosses/ghazbaran.xml` |
| Quara Abominator | ×2 ice and lifedrain | `server/data/monster/quest/quara_abominator.xml` |
| Abominator | ×1.6 all attacks | `server/data/monster/demon_bosses/abominator.xml` |
| Dark Abominator | ×1.6 all attacks | `server/data/monster/demon_bosses/dark_abominator.xml` |

## Per-monster changes

### Guardian of The Sea

Was trivial: melee only (`skill` 120 / `attack` 80), 45000 HP.

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | skill 120, attack 80 | skill 210, attack 150 |
| ice AOE | (none) | min -700, max -1400, interval 2000, chance 25, radius 3 |

### Ghazbaran

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | skill 230, attack 235 | skill 280, attack 280 |
| manadrain | -600 / -1100 | -1200 / -2200 |
| physical (30s) | -300 / -530 | -600 / -1060 |
| physical (5s) | -50 / -1175 | -100 / -2350 |
| death | -250 / -600 | -500 / -1200 |
| ice | -660 / -780 | -1320 / -1560 |

### Abominator

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | -1500 / -2000 | -2400 / -3200 |
| fire | -900 / -1500 | -1440 / -2400 |
| melee AOE | -450 / -800 | -720 / -1280 |
| energy | -300 / -1000 | -480 / -1600 |
| physical | -300 / -500 | -480 / -800 |
| physical | -350 / -500 | -560 / -800 |
| physical | -300 / -450 | -480 / -720 |
| melee small | -200 / -300 | -320 / -480 |

### Quara Abominator

Melee left unchanged. Spike spells doubled.

| Attack | Before | After |
| ------ | ------ | ----- |
| ice | -1200 / -2200 | -2400 / -4400 |
| lifedrain | -1800 / -2600 | -3600 / -5200 |

Note: ice/lifedrain spikes can one-shot many mages. That is intended if the quest expects a tank plus support.

### Dark Abominator

Same ×1.6 scale as Abominator. Keeps Dark slightly different per-spell values, but in the same band.

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | -1500 / -2000 | -2400 / -3200 |
| fire | -100 / -1000 | -160 / -1600 |
| melee AOE | -350 / -1100 | -560 / -1760 |
| energy | -300 / -700 | -480 / -1120 |
| physical | -300 / -400 | -480 / -640 |
| physical | -250 / -500 | -400 / -800 |
| physical | -250 / -350 | -400 / -560 |
| melee small | -150 / -300 | -240 / -480 |

### Ferumbras

Was very soft (spell peaks around 700). Physical immune. Strong self-heal left unchanged.

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | skill 105, attack 85 | skill 160, attack 130 |
| manadrain | -500 / -700 | -1500 / -2100 |
| earth | -300 / -600 | -900 / -1800 |
| energy | -40 / -350 | -120 / -1050 |
| death | -305 / -450 | -915 / -1350 |
| lifedrain | -50 / -400 | -150 / -1200 |

### Bossing of Baiak

No melee. All listed attacks ×2.1.

| Attack | Before | After |
| ------ | ------ | ----- |
| manadrain | -500 / -1000 | -1050 / -2100 |
| poison | -600 / -1000 | -1260 / -2100 |
| energy | -600 / -1200 | -1260 / -2520 |
| manadrain AOE | -625 / -1075 | -1310 / -2260 |
| lifedrain | -600 / -1050 | -1260 / -2205 |
| effect | -600 / -1200 | -1260 / -2520 |
| firecondition | -500 / -1000 | -1050 / -2100 |
| lifedrain beam | -350 / -750 | -735 / -1575 |

### Hellgorak

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | skill 130, attack 130 | skill 190, attack 190 |
| energy | -250 / -819 | -690 / -2250 |
| manadrain | -90 / -500 | -250 / -1375 |
| fire | -50 / -520 | -140 / -1430 |
| lifedrain | 0 / -150 | 0 / -410 |

## How to increase more if needed

Use these steps so you do not overshoot into 3–4 player fights.

1. Test solo VIP knight with ultimate health potions, then knight + elder druid (or similar duo).
2. If solo still clears easily, raise that monster by about **+25%** on attack `min`/`max` only (or melee skill/attack by about +15%).
3. If duo wipes often from one unlucky spike, lower **max** first and keep **min**. Average pressure stays high. RNG one-shots drop.
4. Prefer damage over more HP. Extra HP only lengthens an easy fight.
5. Do not push Abominator or Dark Abominator past about **×1.75 from the original** without a live test. Their Demon summons already add pressure.
6. Quara Abominator ice/lifedrain are already spike-heavy. Prefer small bumps on those two lines only.

### Suggested next-step multipliers (from the new values)

| If still too easy | Next bump on current values |
| ----------------- | --------------------------- |
| Guardian, Ferumbras, Hellgorak | ×1.25 more |
| Bossing of Baiak, Ghazbaran | ×1.2 more |
| Quara Abominator | ×1.15 on ice and lifedrain only |
| Abominator, Dark Abominator | ×1.1 more (stop and retest) |

### Rough burst targets (Baiak VIP + UHP)

| Goal | Useful single-hit band |
| ---- | ---------------------- |
| Soft vocation pressure | 1500–3000 |
| Force second player on bad RNG | 3000–5000 overlapping in under one pot tick |
| Likely needs 3+ if common | Sustained overlap above ~6000 while summons are up |

## Test plan

- [ ] Solo VIP knight with UHP vs each boss. Expect struggle or death on soft and mid bosses.
- [ ] Duo (knight + ED/MS or RP) clears each boss with focus and potions.
- [ ] Quara Abominator: mage solo should be unsafe. Tank + support should be viable.
- [ ] Abominator / Dark Abominator: duo stressed but clearable. If not, reduce max on the largest AOEs first.
- [ ] Confirm reload: restart server or reload monsters so XML changes apply.

## Related files

- Registry: `server/data/monster/monsters.xml`
- Vocations: `server/data/XML/vocations.xml`
- Potions: `server/data/actions/scripts/liquids/potions.lua`
- Website news + ticker paste pack: [website-news-death-bless-2026-09-19.md](website-news-death-bless-2026-09-19.md)
- In-game `!notice`: `server/noticias.txt`
