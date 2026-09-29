# Pacote para o site: Zombie rewards + fixes (2026-09-29)

Use depois de publicar:

- Zombie: mínimo 2 jogadores + recompensa conforme o número de jogadores (`zombie_event.lua`, `zombie.lua`)
- Bounty: não sorteia perto de Saco de Pancada / trainers (`bounty.lua`). Fix depois da notícia do Bounty.
- Porta VIP2: aviso de promoção no Johnny (`vocdoor.lua`)

Recarregue globalevents, creaturescripts e actions, ou reinicie o servidor de jogo.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
🧟 Zombie: mínimo 2 + recompensa conforme jogadores + 🎯 Bounty trainers
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de hoje:

🧟 [b]Zombie Event[/b]
Mínimo agora é [b]2 jogadores[/b] (antes 4).
Reward do winner depende de quantos entraram quando o TP fechou:

[b]2-3 jogadores:[/b] taça com nome + [b]Stamina Potion[/b] + [b]50 gold nuggets[/b].
[b]4 ou mais:[/b] taça + [b]arma Vip9 aleatória[/b] + [b]100 gold nuggets[/b] (igual antes).

TP no temple, aberto [b]5 minutos[/b]. Horário SP: horas pares.

🎯 [b]PvP Bounty[/b] (ajuste)
O sorteio [b]não pega[/b] quem está perto de trainer / [b]Saco de Pancada[/b].
Restante igual: a cada 15 min, mate o Vip9 (IP diferente) e leve a reward do Bounty.

🚪 [b]Porta VIP2[/b]
Vocação base agora recebe aviso claro: precisa [b]promover no Johnny[/b] (antes a mensagem era só “vocation errada”).

Comente nesta notícia como ficou. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
🧟 Zombie: min 2. 2-3 = stamina+50 nuggets+taça. 4+ = Vip9+100. 🎯 Bounty ignora Saco de Pancada.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change / Fix

1. `Zombie Event: mínimo 2 jogadores. Reward reduzido com 2-3. Full com 4+.`
2. `Zombie Event: 2-3 jogadores = taça + Stamina Potion + 50 nuggets.`
3. `PvP Bounty: não sorteia jogador perto de trainer / Saco de Pancada.`
4. `Porta VIP2: aviso claro para promover no Johnny.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Zombie Event: mínimo 2 jogadores. Reward reduzido com 2-3. Full com 4+.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Zombie Event: 2-3 jogadores = taça + Stamina Potion + 50 nuggets.'),
('Fix', 'Server', UNIX_TIMESTAMP(), 'PvP Bounty: não sorteia jogador perto de trainer / Saco de Pancada.'),
('Fix', 'Server', UNIX_TIMESTAMP(), 'Porta VIP2: aviso claro para promover no Johnny.');
```

---

## `!notice` (`server/noticias.txt`)

O arquivo no repo já foi atualizado com o resumo de hoje (Latin-1). Confirme no deploy:

```bash
file server/noticias.txt
# expect: ISO-8859 text
```

---

## Já anunciado (não repetir no site)

Já saiu em notícias anteriores. Não precisa colar de novo:

- PvP Bounty 15 min + rewards + mesmo IP (`website-news-bounty-2026-09-29.md`)
- Master lvl 1500, Spear holy 550, Event Bug Double Xp, countdowns (`website-news-master-spear-events-2026-09-29.md`)
- Horários hora em hora Zombie/Bug (`website-news-events-hourly-2026-09-28.md`)

---

## Fora do anúncio público

Não colar no site / `!notice` / ticker / changelog:

- Lottery: só jogadores logados (`lottery.lua`)
- fix NPC `getDistanceToCreature` nil (`anunciante`, boats, etc.)
- docs `/reload` types bloqueados
