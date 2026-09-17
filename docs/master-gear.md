# Master gear (VIP9)

Reference for the Master armor set and Master weapons. Stats live in `server/data/items/items.xml`. Wand/rod damage lives in `server/data/weapons/weapons.xml`.

## Master armor set

Sold by NPC Vip9 (`server/data/npc/baiak_vip9.xml`). Armor pieces also come from VIP9 quest scripts under `server/data/actions/scripts/quest_vips/`.

| Item | ID | Slot | Stats |
| --- | --- | --- | --- |
| Master Helmet | 6096 | head | armor **800**, fire **+10%**, energy **+10%** |
| Master Armor | 6095 | body | armor **800**, death **+25%**, holy **+10%** |
| Master Legs | 5918 | legs | armor **800**, ice **+10%**, earth **+10%** |
| Master Boots | 5462 | feet | armor **150**, speed **40**, HP regen 250/2.5s, mana regen 600/1.6s |
| Master Shield | 6433 | shield | defense **800**, all absorb **+5%**, shielding **+5** |
| Master Spellscroll | 8904 | off-hand | defense **200**, magic level **+6**, mage vocs, level 70 |

Full physical set (helmet + armor + legs + boots + shield): **2550 armor + 800 def**, plus elemental resists and shield all-absorb.

Mages use **Master Spellscroll** instead of Master Shield (ML +6, lower defense).

### Master Spellscroll notes

- Equip movevent has **no `slot` attribute** (same pattern as Baiak Cap). This lets `EquipItem` apply `magiclevelpoints`.
- ML bonus matches Baiak Cap (`12618`): **+6** (was 30, but did not apply in-game).
- Defense lowered from 600 to **200** because the item is no longer shield-slot gated.
- Requires mage vocations 1/2/5/6 and level 70.
- Client protocol sends ML as one byte (0–255). If the UI already shows 255, the number may not move even when the server applies +6.

### Boots speed context

| Boots | Speed | Role |
| --- | --- | --- |
| Boots of haste | 40 | classic speed |
| Baiak shoes | 90 | armor + fire |
| Boots of Baiak | 100 | pure speed |
| Master Vip Boots | 150 | pure speed, weaker set |
| Master Boots | **40** | regen + armor + modest speed |

## Master weapons

Sold by NPC New master (`server/data/npc/new_master.xml`).

| Item | ID | Type | items.xml | weapons.xml |
| --- | --- | --- | --- | --- |
| Master Sword | 7407 | sword | atk 700, def 45, extradef +10, ice +110 | level 30, K/EK |
| Master Axe | 3962 | axe | atk 700, def 55, extradef +10, earth +110 | level 30, K/EK |
| Master Club | 7450 | club | atk 700, def 50, extradef +10, energy +110 | level 30, K/EK |
| Master Spear | 3965 | distance | atk 600, range 5, no break | level 80, Pala/RP |
| Master Wand | 8922 | wand | holy, range 3 | level 42, mana 13, **2000–2900**, Sorc/MS |
| Master Rod | 7735 | wand | holy, range 5 | level 200, mana 50, **2000–2900**, Druid/ED |

Melee Masters share physical attack 700 with different elemental damage. Wand and Rod share the same holy damage band.

## Quest sources

| Script | Items |
| --- | --- |
| `quest_vips/new_baiak_helmet.lua` | 6096 |
| `quest_vips/new_baiak_armor.lua` | 6095 |
| `quest_vips/new_baiak_legs.lua` | 5918 |
| `quest_vips/new_baiak_shield.lua` | 6433 + 5462 |

## Related files

- `server/data/items/items.xml`
- `server/data/weapons/weapons.xml`
- `server/data/movements/movements.xml` (Spellscroll, Boots, Shield equip)
- `server/data/npc/baiak_vip9.xml`
- `server/data/npc/new_master.xml`
