# Pacote para o site: Master set slots + bosses de quest (2026-09-21)

Use depois de publicar:

- `fix(items): lock wearables to correct slots` (rebuild + restart do jogo)
- buffs de dano nos bosses de quest (pass 1 + pass 2, já no XML de monsters)

Reinicie o servidor de jogo (o fix de slots é C++). Monsters XML entram no restart (ou reload de monsters, se você usar). Recarregue movements se o binário já estiver novo e você só precisar dos Equip do Master set.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

Detalhe técnico: [master-gear.md](master-gear.md), [quest-boss-damage.md](quest-boss-damage.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
🛡️ Master set (slots) + ⚔️ Bosses de quest mais fortes
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de hoje:

🛡️ [b]Master set: um slot por peça[/b]
Master Armor, Helmet e Legs só funcionam no slot certo.
Não dá mais para colocar a armadura no escudo ou na flecha para empilhar resists (death/holy e outros).
Cada peça do set no lugar certo. Sem stack acidental.

⚔️ [b]Bosses de quest mais fortes[/b]
Aumentamos o dano para ficar mais difícil solo e pedir cerca de [b]2 jogadores[/b]:

Guardian of The Sea, Ghazbaran, Abominator, Quara Abominator, Dark Abominator, Ferumbras, Bossing of Baiak, Hellgorak, Infernatil, Orshabaal.

Infernatil continua com muita vida, mas agora o dano acompanha.
Orshabaal recebeu um aumento leve.
Vão com tank + suporte. Mages sozinhos em Quara Abominator vão sofrer com os spikes.

📌 [b]Dica:[/b] use [b]!bless[/b] antes de caçar (80k).

Comente nesta notícia se ficou bom. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
🛡️ Master set: cada peça só no slot certo (sem stack de resist). ⚔️ Bosses de quest com mais dano (~2 players, incl. Infernatil e Orshabaal).
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Fix

1. `Master Armor/Helmet/Legs só no slot certo. Sem stack de resists em escudo/flecha.`

### Server: Type: Change

1. `Bosses de quest com mais dano (Guardian, Ghazbaran, Abominator, Quara/Dark, Ferumbras, Bossing, Hellgorak, Infernatil, Orshabaal).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Fix', 'Server', UNIX_TIMESTAMP(), 'Master Armor/Helmet/Legs só no slot certo. Sem stack de resists em escudo/flecha.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Bosses de quest com mais dano (Guardian, Ghazbaran, Abominator, Quara/Dark, Ferumbras, Bossing, Hellgorak, Infernatil, Orshabaal).');
```

---

## `!notice` (`server/noticias.txt`)

O arquivo no repo já foi atualizado com o resumo de hoje (Latin-1). Confirme no deploy:

```bash
file server/noticias.txt
# expect: ISO-8859 text
```
