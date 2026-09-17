# Pacote para o site: Balanceamento de magias (2026-09-16)

Use depois de publicar as alterações dos scripts de magia. Recarregue as magias ou reinicie o servidor de jogo primeiro.

Detalhe técnico: [spell-balance-15k.md](spell-balance-15k.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
⚡ Balanceamento de Magias: High Level (até 15k)
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Rebalanceamos várias magias de vocação para o [b]high level[/b] (cerca de nível [b]2000-15000[/b]).

⚔️ [b]Elite Knight[/b]
[b]Wound Cleansing[/b] ([i]exana mort[/i]): cura bem mais forte, agora escala perto da Mana Rune (um pouco menos).
[b]Fierce Berserk[/b] ([i]exori gran[/i]): melhor escala de nível no AoE corpo a corpo.

🔥 [b]Master Sorcerer[/b]
[b]Hell's Core[/b] ([i]exevo gran mas flam[/i]) e [b]Rage of the Skies[/b] ([i]exevo gran mas vis[/i]): AoE mais forte.
[b]suden death[/b] ([i]exevo gran mas mort[/i]) continua o AoE mais forte de mage (caminho menor).

❄️ [b]Elder Druid[/b]
[b]Eternal Winter[/b] ([i]exevo gran mas frigo[/i]): AoE mais forte, ainda abaixo de flam/vis/mort.

🏹 [b]Royal Paladin[/b]
[b]Divine Caldera[/b] ([i]exevo mas san[/i]): volta a escalar direito em high level.

📌 [b]Sem mudança:[/b] Sudden Death rune ([i]SD[/i]), suden death ([i]exevo gran mas mort[/i]).

Comente nesta notícia como ficou o balanceamento no jogo. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo das mudanças.
```

---

## Ticker de notícias (opcional, curto)

```text
⚡ Balanceamento: 💚 cura EK (exana mort), 🔥 AoE mage (flam/vis/frigo), ⚔️ Fierce Berserk + 🏹 Divine Caldera. Mort segue #1 no AoE.
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
