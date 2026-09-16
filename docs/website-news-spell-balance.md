# Pacote para o site — Balanceamento de magias (2026-09-16)

Use depois de publicar as alterações dos scripts de magia. Recarregue as magias ou reinicie o servidor de jogo primeiro.

Detalhe técnico: [spell-balance-15k.md](spell-balance-15k.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
Atualização de Balanceamento de Magias — High Level (até 15k)
```

**Texto:**

```text
Rebalanceamos várias magias de vocação para o high level (cerca de nível 2000–15000).

Elite Knight
- Wound Cleansing (exana mort): cura bem mais forte, agora escala perto da Mana Rune (um pouco menos).
- Fierce Berserk (exori gran): melhor escala de nível no AoE corpo a corpo.

Master Sorcerer
- Hell's Core (exevo gran mas flam) e Rage of the Skies (exevo gran mas vis): AoE mais forte.
- suden death (exevo gran mas mort) continua o AoE mais forte de mage (caminho menor).

Elder Druid
- Eternal Winter (exevo gran mas frigo): AoE mais forte, ainda abaixo de flam/vis/mort.

Royal Paladin
- Divine Caldera (exevo mas san): volta a escalar direito em high level.

Sem mudança: Sudden Death rune (SD), suden death (exevo gran mas mort).

Se ver números estranhos no jogo, avise para ajustarmos.
```

---

## Ticker de notícias (opcional, curto)

```text
Balanceamento ao vivo: cura EK (exana mort) mais forte, AoE mage (flam/vis/frigo) buffado, Fierce Berserk + Divine Caldera. Mort segue #1 no AoE.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (cerca de 150 caracteres). Adicionar como **Type: Add**, **Where: Server**:

1. `Buff em Wound Cleansing (exana mort): cura do EK agora escala perto da Mana Rune.`
2. `Buff em Hell's Core (exevo gran mas flam) e Rage of the Skies (exevo gran mas vis).`
3. `Buff em Eternal Winter (exevo gran mas frigo). AoE mort continua o mais forte.`
4. `Buff na escala de Fierce Berserk (exori gran) e Divine Caldera (exevo mas san).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Add', 'Server', UNIX_TIMESTAMP(), 'Buff em Wound Cleansing (exana mort): cura do EK agora escala perto da Mana Rune.'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Buff em Hell''s Core (exevo gran mas flam) e Rage of the Skies (exevo gran mas vis).'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Buff em Eternal Winter (exevo gran mas frigo). AoE mort continua o mais forte.'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Buff na escala de Fierce Berserk (exori gran) e Divine Caldera (exevo mas san).');
```
