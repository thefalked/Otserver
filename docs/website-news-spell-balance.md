# Website paste pack — Spell balance (2026-09-16)

Use this after deploying the spell script changes. Reload spells or restart the game server first.

Technical detail: [spell-balance-15k.md](spell-balance-15k.md)

---

## Latest News (paste into Admin → New News)

**Topic:**

```text
Spell Balance Update — High Level (up to 15k)
```

**Body (plain text / HTML-ish Gesior style):**

```text
We rebalanced several vocation spells for high-level play (about level 2000–15000).

Elite Knight
- Wound Cleansing (exana mort): much stronger heal, now scales closer to Mana Rune (a bit less).
- Fierce Berserk (exori gran): better level scaling in melee AoE.

Master Sorcerer
- Hell's Core (exevo gran mas flam) and Rage of the Skies (exevo gran mas vis): stronger AoE.
- suden death (exevo gran mas mort) stays the strongest mage AoE (smaller path).

Elder Druid
- Eternal Winter (exevo gran mas frigo): stronger AoE, still below flam/vis/mort.

Royal Paladin
- Divine Caldera (exevo mas san): scales properly again at high level.

Not changed: Sudden Death rune (SD), suden death (exevo gran mas mort).

Please report odd numbers in-game so we can fine-tune.
```

---

## News ticker (optional, short)

```text
Spell balance live: stronger EK heal (exana mort), buffed mage AoE (flam/vis/frigo), Fierce Berserk + Divine Caldera. Mort stays #1 AoE.
```

---

## Changelog page (`?subtopic=changelog`)

Gesior changelog descriptions are short (about 150 characters). Add these as **Type: Add**, **Where: Server**:

1. `Buffed Wound Cleansing (exana mort): EK heal now scales near Mana Rune strength.`
2. `Buffed Hell's Core (exevo gran mas flam) and Rage of the Skies (exevo gran mas vis).`
3. `Buffed Eternal Winter (exevo gran mas frigo). Mort AoE stays strongest.`
4. `Buffed Fierce Berserk (exori gran) level scaling and Divine Caldera (exevo mas san).`

### Optional SQL (run on website DB if you prefer not to use the admin form)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Add', 'Server', UNIX_TIMESTAMP(), 'Buffed Wound Cleansing (exana mort): EK heal now scales near Mana Rune strength.'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Buffed Hell''s Core (exevo gran mas flam) and Rage of the Skies (exevo gran mas vis).'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Buffed Eternal Winter (exevo gran mas frigo). Mort AoE stays strongest.'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Buffed Fierce Berserk (exori gran) level scaling and Divine Caldera (exevo mas san).');
```
