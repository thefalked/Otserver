# Pacote para o site: SD no EK + magias high level + corpos Demon (2026-09-26)

Use depois de publicar:

- alterações de spells (SD vocation lock, Fierce Berserk, Ethereal Spear)
- ajuste de decay em `items.xml` (cadeia slain demon / Capeta)

Recarregue magias e items, ou reinicie o servidor de jogo.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

Detalhe técnico: [spell-balance-15k.md](spell-balance-15k.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
⚔️ EK sem SD + 🏹 Ethereal Spear + ❄️ Eternal Winter + 🦴 corpos Demon
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de hoje:

⚔️ [b]Elite Knight[/b] (high level ~2000-15000)
[b]Sudden Death[/b] ([i]SD[/i]): [b]knights não usam mais[/b] a rune.
[b]Fierce Berserk[/b] ([i]exori gran[/i]): bem mais forte em high level. Vira o ataque principal do EK sem SD (AoE 3x3).

🏹 [b]Royal Paladin[/b]
[b]Ethereal Spear[/b] ([i]exori con[/i]): escala bem melhor de nível.
[b]Sudden Death[/b] ([i]SD[/i]): [b]paladins continuam podendo usar[/b].

❄️ [b]Elder Druid[/b]
[b]Eternal Winter[/b] ([i]exevo gran mas frigo[/i]): AoE mais forte no high level.
Continua abaixo de flam / vis / mort (mort segue o AoE #1 de mage).

🦴 [b]Corpos de Demon e Capeta[/b]
Cadeias de corpse caem em cerca de [b]9 minutos[/b] no chão (antes ~45m).
Mesmo padrão frost / hydra / reaper / nightmare. Menos lixo no chão.

📌 [b]Sem mudança no dano da SD[/b] para quem ainda usa. Só o EK perde o acesso.

Comente nesta notícia como ficou no jogo. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
⚔️ EK sem SD: exori gran bem mais forte. 🏹 RP exori con escala melhor (SD liberado). ❄️ ED Eternal Winter buff. 🦴 Demon/Capeta corpses ~9m.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Sudden Death (SD): knights/EK não usam mais. Sorc/Druid/Pala (e promoções) seguem.`
2. `Buff Fierce Berserk (exori gran): escala bem mais em high level (EK sem SD).`
3. `Buff Ethereal Spear (exori con): escala bem mais em high level. RP mantém SD.`
4. `Buff Eternal Winter (exevo gran mas frigo). AoE mort continua o mais forte.`
5. `Corpos de Demon/Capeta: decay ~45m para ~9m no chão (mesmo padrão frost/hydra/reaper/nightmare).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Sudden Death (SD): knights/EK não usam mais. Sorc/Druid/Pala (e promoções) seguem.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Fierce Berserk (exori gran): escala bem mais em high level (EK sem SD).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Ethereal Spear (exori con): escala bem mais em high level. RP mantém SD.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Eternal Winter (exevo gran mas frigo). AoE mort continua o mais forte.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Corpos de Demon/Capeta: decay ~45m para ~9m no chão (mesmo padrão frost/hydra/reaper/nightmare).');
```

---

## `!notice` (`server/noticias.txt`)

O arquivo no repo já foi atualizado com o resumo de hoje (Latin-1). Confirme no deploy:

```bash
file server/noticias.txt
# expect: ISO-8859 text
```
