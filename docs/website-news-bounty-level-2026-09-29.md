# Pacote para o site: PvP Bounty level 4000+ (2026-09-29)

Use depois de publicar:

- Bounty: sorteio por level 4000+ (não mais Vip9) (`bounty.lua`)

Recarregue globalevents, ou reinicie o servidor de jogo.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
🎯 PvP Bounty: agora level 4000+
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Ajuste de hoje:

🎯 [b]PvP Bounty[/b]
O sorteio [b]não exige mais Vip9[/b].
Agora entra qualquer jogador [b]level 4000+[/b] em área de PvP (fora de PZ, house, trainer e no-PvP).
4000 é o mesmo mínimo de entrada da Vip7.

Restante igual: a cada [b]15 minutos[/b], mate o alvo (IP diferente) e leve a reward do Bounty.

Comente nesta notícia como ficou. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
🎯 PvP Bounty: agora level 4000+ (não precisa Vip9).
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `PvP Bounty: sorteio por level 4000+ (antes só Vip9).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'PvP Bounty: sorteio por level 4000+ (antes só Vip9).');
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
- Bounty ignora trainer / Saco de Pancada (`website-news-zombie-rewards-2026-09-29.md`)
- Zombie min 2 + rewards por tamanho (`website-news-zombie-rewards-2026-09-29.md`)
