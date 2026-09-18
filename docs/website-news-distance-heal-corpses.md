# Pacote para o site: Distância, cura EK e corpos (2026-09-17)

Use depois de publicar os commits de weapons/spells/items. Recarregue weapons e spells, ou reinicie o servidor de jogo. Itens (decay) pedem restart ou reload de items.

Commits cobertos:

- fix(weapons): distance attacks continuam com pot
- balance(spells): Exhaust da cura EK (exana mort) 0.5s para 0.75s
- perf(items): corpos de hunt (frost/hydra/reaper/nightmare) caem em ~8m

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
🏹 Distância com pot + 💚 cura EK + 🦴 corpos mais rápidos
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Três ajustes no ar:

🏹 [b]Armas de distância[/b]
Arcos, stars e spears listados [b]continuam atirando[/b] enquanto você usa potions.
Antes o action lock do pot pausava o tiro.

💚 [b]Cura do Elite Knight[/b]
[b]Wound Cleansing[/b] ([i]exana mort[/i]): exhaust de [b]0.5s para 0.75s[/b].
Estava forte demais em 0.5s.
[b]Divine Healing[/b] ([i]exura san[/i]) do RP continua em [b]0.5s[/b].

🦴 [b]Corpos no chão[/b]
Cadeias de corpse de hunt (frost / hydra / reaper / nightmare) caem bem mais rápido (~[b]8 minutos[/b] em vez de ~35m).
Menos lixo no chão e /clean mais leve.

Comente nesta notícia o que achou. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
🏹 Distância atira com pot. 💚 EK exana mort: 0.75s (RP san segue 0.5s). 🦴 Corpos de hunt ~8m no chão.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Fix

1. `Armas de distância (arcos/stars/spears) continuam atirando enquanto usa potions.`

### Server: Type: Change

1. `Wound Cleansing (exana mort): exhaust 0.5s para 0.75s. Divine Healing (RP) segue 0.5s.`
2. `Corpos de hunt (frost/hydra/reaper/nightmare): decay ~35m para ~8m no chão.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Fix', 'Server', UNIX_TIMESTAMP(), 'Armas de distância (arcos/stars/spears) continuam atirando enquanto usa potions.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Wound Cleansing (exana mort): exhaust 0.5s para 0.75s. Divine Healing (RP) segue 0.5s.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Corpos de hunt (frost/hydra/reaper/nightmare): decay ~35m para ~8m no chão.');
```

---

## Fora do anúncio público

Não colar no site / `!notice`:

- item de teste jalapeno (interno)
- fix de salt de senha no website (ops)
- tabela player_advances no MySQL (ops)
- reformats de XML
