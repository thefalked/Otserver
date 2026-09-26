# Pacote para o site: SD no EK + magias high level (2026-09-26)

Use depois de publicar as alterações de spells (SD vocation lock, Fierce Berserk, Ethereal Spear). Recarregue as magias ou reinicie o servidor de jogo.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

Detalhe técnico: [spell-balance-15k.md](spell-balance-15k.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
⚔️ EK sem SD + 🏹 Ethereal Spear + ❄️ Eternal Winter
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de magias no [b]high level[/b] (cerca de nível [b]2000-15000[/b]):

⚔️ [b]Elite Knight[/b]
[b]Sudden Death[/b] ([i]SD[/i]): [b]knights não usam mais[/b] a rune.
[b]Fierce Berserk[/b] ([i]exori gran[/i]): bem mais forte em high level. Vira o ataque principal do EK sem SD (AoE 3x3).

🏹 [b]Royal Paladin[/b]
[b]Ethereal Spear[/b] ([i]exori con[/i]): escala bem melhor de nível.
[b]Sudden Death[/b] ([i]SD[/i]): [b]paladins continuam podendo usar[/b].

❄️ [b]Elder Druid[/b]
[b]Eternal Winter[/b] ([i]exevo gran mas frigo[/i]): AoE mais forte no high level.
Continua abaixo de flam / vis / mort (mort segue o AoE #1 de mage).

📌 [b]Sem mudança no dano da SD[/b] para quem ainda usa. Só o EK perde o acesso.

Comente nesta notícia como ficou no jogo. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
⚔️ EK sem SD: exori gran bem mais forte. 🏹 RP exori con escala melhor (SD liberado). ❄️ ED Eternal Winter buff (abaixo de mort).
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Sudden Death (SD): knights/EK não usam mais. Sorc/Druid/Pala (e promoções) seguem.`
2. `Buff Fierce Berserk (exori gran): escala bem mais em high level (EK sem SD).`
3. `Buff Ethereal Spear (exori con): escala bem mais em high level. RP mantém SD.`
4. `Buff Eternal Winter (exevo gran mas frigo). AoE mort continua o mais forte.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Sudden Death (SD): knights/EK não usam mais. Sorc/Druid/Pala (e promoções) seguem.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Fierce Berserk (exori gran): escala bem mais em high level (EK sem SD).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Ethereal Spear (exori con): escala bem mais em high level. RP mantém SD.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Eternal Winter (exevo gran mas frigo). AoE mort continua o mais forte.');
```

---

## `!notice` (`server/noticias.txt`)

O arquivo no repo já foi atualizado com o resumo de hoje (Latin-1). Confirme no deploy:

```bash
file server/noticias.txt
# expect: ISO-8859 text
```
