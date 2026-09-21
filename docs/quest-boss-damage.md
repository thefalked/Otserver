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

## Applied multipliers

### Pass 1 (mid values)

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

### Pass 2 (live test: still soloable)

After in-game testing, solo VIP clears were still too easy. Applied another bump on the pass-1 values. Also added **Infernatil** (270k HP, weak damage before).

| Monster | Pass 2 on current values | Notes |
| ------- | ------------------------ | ----- |
| Guardian, Ferumbras, Hellgorak | ×1.3 | Soft group |
| Bossing of Baiak, Ghazbaran | ×1.25 | Mid group |
| Quara Abominator | ×1.2 ice + lifedrain | Spike kit |
| Abominator, Dark Abominator | ×1.15 | Keep summons in mind |
| Infernatil (new) | ×2.5 spells, melee raised | First damage pass. HP unchanged. |
| Orshabaal (new) | ~×1.35 spells, melee small raise | Light buff only. |

File: `server/data/monster/demon_bosses/infernatil.xml`

Orshabaal file: `server/data/monster/demon_bosses/orshabaal.xml`

## Per-monster changes (pass 1)

### Guardian of The Sea

Was trivial: melee only (`skill` 120 / `attack` 80), 45000 HP.

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| melee | skill 120, attack 80 | skill 210, attack 150 | skill 260, attack 190 |
| ice AOE | (none) | -700 / -1400 | -910 / -1820 |

### Ghazbaran

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| melee | skill 230, attack 235 | skill 280, attack 280 | skill 320, attack 320 |
| manadrain | -600 / -1100 | -1200 / -2200 | -1500 / -2750 |
| physical (30s) | -300 / -530 | -600 / -1060 | -750 / -1325 |
| physical (5s) | -50 / -1175 | -100 / -2350 | -125 / -2940 |
| death | -250 / -600 | -500 / -1200 | -625 / -1500 |
| ice | -660 / -780 | -1320 / -1560 | -1650 / -1950 |

### Abominator

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| melee | -1500 / -2000 | -2400 / -3200 | -2760 / -3680 |
| fire | -900 / -1500 | -1440 / -2400 | -1660 / -2760 |
| melee AOE | -450 / -800 | -720 / -1280 | -830 / -1470 |
| energy | -300 / -1000 | -480 / -1600 | -550 / -1840 |
| physical | -300 / -500 | -480 / -800 | -550 / -920 |
| physical | -350 / -500 | -560 / -800 | -640 / -920 |
| physical | -300 / -450 | -480 / -720 | -550 / -830 |
| melee small | -200 / -300 | -320 / -480 | -370 / -550 |

### Quara Abominator

Melee left unchanged. Spike spells scaled twice.

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| ice | -1200 / -2200 | -2400 / -4400 | -2880 / -5280 |
| lifedrain | -1800 / -2600 | -3600 / -5200 | -4320 / -6240 |

Note: ice/lifedrain spikes can one-shot many mages. That is intended if the quest expects a tank plus support.

### Dark Abominator

Same scale as Abominator.

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| melee | -1500 / -2000 | -2400 / -3200 | -2760 / -3680 |
| fire | -100 / -1000 | -160 / -1600 | -180 / -1840 |
| melee AOE | -350 / -1100 | -560 / -1760 | -640 / -2020 |
| energy | -300 / -700 | -480 / -1120 | -550 / -1290 |
| physical | -300 / -400 | -480 / -640 | -550 / -740 |
| physical | -250 / -500 | -400 / -800 | -460 / -920 |
| physical | -250 / -350 | -400 / -560 | -460 / -640 |
| melee small | -150 / -300 | -240 / -480 | -280 / -550 |

### Ferumbras

Was very soft (spell peaks around 700). Physical immune. Strong self-heal left unchanged.

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| melee | skill 105, attack 85 | skill 160, attack 130 | skill 200, attack 160 |
| manadrain | -500 / -700 | -1500 / -2100 | -1950 / -2730 |
| earth | -300 / -600 | -900 / -1800 | -1170 / -2340 |
| energy | -40 / -350 | -120 / -1050 | -156 / -1365 |
| death | -305 / -450 | -915 / -1350 | -1190 / -1755 |
| lifedrain | -50 / -400 | -150 / -1200 | -195 / -1560 |

### Bossing of Baiak

No melee. All listed attacks scaled.

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| manadrain | -500 / -1000 | -1050 / -2100 | -1310 / -2625 |
| poison | -600 / -1000 | -1260 / -2100 | -1575 / -2625 |
| energy | -600 / -1200 | -1260 / -2520 | -1575 / -3150 |
| manadrain AOE | -625 / -1075 | -1310 / -2260 | -1640 / -2825 |
| lifedrain | -600 / -1050 | -1260 / -2205 | -1575 / -2755 |
| effect | -600 / -1200 | -1260 / -2520 | -1575 / -3150 |
| firecondition | -500 / -1000 | -1050 / -2100 | -1310 / -2625 |
| lifedrain beam | -350 / -750 | -735 / -1575 | -920 / -1970 |

### Hellgorak

| Attack | Before | After pass 1 | After pass 2 |
| ------ | ------ | ------------ | ------------ |
| melee | skill 130, attack 130 | skill 190, attack 190 | skill 240, attack 240 |
| energy | -250 / -819 | -690 / -2250 | -900 / -2925 |
| manadrain | -90 / -500 | -250 / -1375 | -325 / -1790 |
| fire | -50 / -520 | -140 / -1430 | -180 / -1860 |
| lifedrain | 0 / -150 | 0 / -410 | 0 / -535 |

### Infernatil (pass 2 only)

270000 HP sponge with soft damage. Spells ×2.5. Melee raised. Healing and HP left alone.

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | skill 210, attack 260 | skill 260, attack 320 |
| firecondition | -800 / -1200 | -2000 / -3000 |
| physical | -250 / -750 | -625 / -1875 |
| fire (50%) | -200 / -500 | -500 / -1250 |
| fire targeted | -350 / -850 | -875 / -2125 |
| fire beam | -500 / -1000 | -1250 / -2500 |
| fire spread | -300 / -1500 | -750 / -3750 |

### Orshabaal (pass 2, light)

Small bump only (~×1.35 on spells). Melee slightly raised. HP and summons unchanged.

| Attack | Before | After |
| ------ | ------ | ----- |
| melee | skill 180, attack 180 | skill 205, attack 205 |
| physical | -320 / -910 | -430 / -1230 |
| fire | -310 / -740 | -420 / -1000 |
| lifedrain | -500 / -1300 | -675 / -1755 |

## How to increase more if needed

Use these steps so you do not overshoot into 3–4 player fights.

1. Test solo VIP knight with ultimate health potions, then knight + elder druid (or similar duo).
2. If solo still clears easily, raise that monster by about **+20%** on attack `min`/`max` only (or melee skill/attack by about +10%).
3. If duo wipes often from one unlucky spike, lower **max** first and keep **min**. Average pressure stays high. RNG one-shots drop.
4. Prefer damage over more HP. Extra HP only lengthens an easy fight.
5. Infernatil already heals hard (5000–10000). Prefer more attack damage over more HP or more heal.
6. Quara Abominator ice/lifedrain are spike-heavy after pass 2. Prefer small bumps only.

### Suggested next-step multipliers (from pass 2 values)

| If still too easy | Next bump on current values |
| ----------------- | --------------------------- |
| Guardian, Ferumbras, Hellgorak, Infernatil | ×1.2 more |
| Bossing of Baiak, Ghazbaran | ×1.15 more |
| Quara Abominator | ×1.1 on ice and lifedrain only |
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
- [ ] Infernatil: long fight from HP, but damage should force potions and a second player.
- [ ] Confirm reload: restart server or reload monsters so XML changes apply.

## Related files

- Registry: `server/data/monster/monsters.xml`
- Vocations: `server/data/XML/vocations.xml`
- Potions: `server/data/actions/scripts/liquids/potions.lua`
- Website news + ticker paste pack: [website-news-death-bless-2026-09-19.md](website-news-death-bless-2026-09-19.md)
- In-game `!notice`: `server/noticias.txt`
