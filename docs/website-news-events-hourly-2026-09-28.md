# Pacote para o site: horários Zombie + Event Bug (2026-09-28)

Use depois de publicar:

- `config(zombie): wait 5 min before start` (`zombie_event.lua`)
- `config(events): hourly zombie/bug alternate` (`globalevents.xml`)

Recarregue globalevents, ou reinicie o servidor de jogo.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
🧟 Zombie + 🐛 Event Bug: agora de hora em hora
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de eventos:

🕐 [b]Um evento por hora[/b] (horário de São Paulo), alternando:
[b]Horas pares[/b] (00, 02, 04… 22): [b]Zombie Event[/b]
[b]Horas ímpares[/b] (01, 03, 05… 23): [b]Event Bug[/b]

🧟 [b]Zombie Event[/b]
Teleport de entrada no temple. Aberto por [b]5 minutos[/b] (antes 2).
Mínimo [b]4 jogadores[/b].
Último vivo leva: taça com nome + [b]arma Vip9 aleatória[/b] + [b]100 gold nuggets[/b].

🐛 [b]Event Bug[/b]
Aviso [b]5 minutos[/b] antes do spawn. Aparece perto do temple.
Vocês têm [b]15 minutos[/b] para matar.
Quem estiver perto no kill recebe recompensa compartilhada: [b]arma Baiakzik/Master + 50 nuggets[/b] OU [b]set Master completo[/b] (sorteio por jogador).

📌 Sempre tem algo rolando. Fique de olho no broadcast.

Comente nesta notícia como ficou. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
🧟🐛 Eventos de hora em hora SP: pares = Zombie (TP 5 min), ímpares = Event Bug (aviso 5 min).
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Zombie/Event Bug: 1 evento por hora SP (pares=Zombie, ímpares=Bug).`
2. `Zombie Event: teleport aberto 5 minutos (antes 2).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Zombie/Event Bug: 1 evento por hora SP (pares=Zombie, ímpares=Bug).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Zombie Event: teleport aberto 5 minutos (antes 2).');
```

---

## `!notice` (`server/noticias.txt`)

O arquivo no repo já foi atualizado com o resumo de hoje (Latin-1). Confirme no deploy:

```bash
file server/noticias.txt
# expect: ISO-8859 text
```
