# Pacote para o site: Master gear + eventos (2026-09-29)

Use depois de publicar:

- Master weapons level 1500 (`weapons.xml`)
- Master Spear: attack 550 + dano holy (`items.xml`, `weapons.xml`)
- Event Bug: reward Master armas / set Master / Double Xp (`event_bug_death.lua`)
- Countdowns Zombie / Event Bug + TP Zombie no temple (`zombie_event.lua`, `event_bug.lua`)
- NPC Vip9: Master Shield. NPC New Master: nome Master Wand

Recarregue weapons, items, NPCs, creaturescripts e globalevents, ou reinicie o servidor de jogo.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

Referência: [master-gear.md](master-gear.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
⚔️ Master lvl 1500 + 🏹 Spear holy + 🐛 Event Bug + Double Xp + ⏱️ countdowns
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de hoje:

⚔️ [b]Armas Master[/b]
Agora pedem [b]level 1500[/b] para usar (Sword, Axe, Club, Spear, Wand e Rod).

🏹 [b]Master Spear[/b] (Pala/RP)
Ataque [b]550[/b] (antes 600).
Dano passa a ser [b]holy[/b] (antes físico).

🐛 [b]Event Bug[/b]
Sorteio por jogador (peso igual): [b]arma Master[/b] + 50 nuggets, OU [b]set Master completo[/b], OU [b]Double Xp[/b].
Não sai mais Baiakzik / Vip / Throwing Star nessa pool.

⏱️ [b]Avisos de evento[/b]
[b]Zombie:[/b] countdown a cada minuto enquanto o TP está aberto (mostra quantos já entraram).
[b]Event Bug:[/b] avisos nos últimos [b]3 minutos[/b] da luta.
TP do Zombie continua no temple (posição ajustada).

🛒 [b]NPCs[/b]
[b]Vip9:[/b] vende [b]Master Shield[/b] (não mais Master Boots no lugar do shield).

📌 Horários de hora em hora (SP) seguem iguais: pares = Zombie, ímpares = Event Bug.

Comente nesta notícia como ficou. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
⚔️ Master armas lvl 1500. 🏹 Master Spear atk 550 holy. 🐛 Event Bug: Master / set / Double Xp. ⏱️ Countdown Zombie + Bug.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Armas Master: level mínimo 1500 para usar (Sword/Axe/Club/Spear/Wand/Rod).`
2. `Master Spear: ataque 550 (antes 600) e dano holy.`
3. `Event Bug: sorteio Master arma+nuggets, set Master ou Double Xp.`
4. `Zombie/Event Bug: countdowns (Zombie a cada min no TP; Bug nos últimos 3 min).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Armas Master: level mínimo 1500 para usar (Sword/Axe/Club/Spear/Wand/Rod).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Master Spear: ataque 550 (antes 600) e dano holy.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Event Bug: sorteio Master arma+nuggets, set Master ou Double Xp.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Zombie/Event Bug: countdowns (Zombie a cada min no TP; Bug nos últimos 3 min).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'NPC Vip9: vende Master Shield. New Master: nome Master Wand.');
```

---

## `!notice` (`server/noticias.txt`)

O arquivo no repo já foi atualizado com o resumo de hoje (Latin-1). Confirme no deploy:

```bash
file server/noticias.txt
# expect: ISO-8859 text
```

---

## Fora do anúncio público

Não colar no site / `!notice` / ticker / changelog:

- reformat XML dos NPCs Vip9 / New Master (só estilo).
- coordenadas exatas do TP do Zombie (ainda no temple).
