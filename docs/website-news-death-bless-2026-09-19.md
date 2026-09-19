# Pacote para o site: Pena de morte + bless + bosses de quest (2026-09-19)

Use depois de publicar:

- `deathLostPercent = 15` e `eachBlessReduction = 6`
- buffs de dano nos bosses de quest listados abaixo

Reinicie o servidor de jogo. Jogadores precisam relogar para a nova pena de morte aplicar. O valor de bless entra no restart (lido do config na morte). Monsters XML entram no restart (ou reload de monsters, se você usar).

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

Detalhe técnico: [death-penalty.md](death-penalty.md), [quest-boss-damage.md](quest-boss-damage.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
💀 Pena de morte + ✨ !bless + ⚔️ Bosses de quest mais fortes
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de hoje:

💀 [b]Pena de morte um pouco mais leve[/b]
A perda de experiência na morte ficou cerca de [b]25% mais leve[/b] na base (de 20 para 15).

✨ [b]!bless vale bem mais[/b]
Cada blessing reduz bem mais a perda de XP.
Com [b]!bless[/b] completo (5 blessings), a morte fica bem mais suave do que sem bless.
Itens e bags continuam protegidos com bless, como antes.

⚔️ [b]Bosses de quest mais fortes[/b]
Aumentamos o dano (passada média) para ficar mais difícil solo e pedir cerca de [b]2 jogadores[/b]:

Guardian of The Sea, Ghazbaran, Abominator, Quara Abominator, Dark Abominator, Ferumbras, Bossing of Baiak, Hellgorak.

Vão com tank + suporte. Mages sozinhos em Quara Abominator vão sofrer com os spikes.

📌 [b]Dica:[/b] use [b]!bless[/b] antes de caçar (80k). VIP Baiak ainda perde um pouco menos que non-VIP.

Comente nesta notícia se ficou bom. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
💀 Morte mais leve (base 20→15). ✨ !bless reduz mais XP. ⚔️ Bosses de quest com mais dano (~2 players).
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Pena de morte: deathLostPercent 20 para 15. eachBlessReduction 2 para 6 (!bless reduz mais XP).`
2. `Bosses de quest com mais dano (Guardian, Ghazbaran, Abominator, Quara/Dark Abominator, Ferumbras, Bossing, Hellgorak).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Pena de morte: deathLostPercent 20 para 15. eachBlessReduction 2 para 6 (!bless reduz mais XP).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Bosses de quest com mais dano (Guardian, Ghazbaran, Abominator, Quara/Dark Abominator, Ferumbras, Bossing, Hellgorak).');
```

---

## `!notice` (`server/noticias.txt`)

O arquivo no repo já foi atualizado com o resumo de hoje (Latin-1). Confirme no deploy:

```bash
file server/noticias.txt
# expect: ISO-8859 text
```
