# Pacote para o site: Pena de morte + bless mais forte (2026-09-19)

Use depois de publicar `deathLostPercent = 15` e `eachBlessReduction = 6`. Reinicie o servidor de jogo. Jogadores precisam relogar para a nova pena de morte aplicar. O valor de bless entra no restart (lido do config na morte).

Detalhe técnico: [death-penalty.md](death-penalty.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
💀 Pena de morte ajustada + ✨ !bless mais forte
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Ajuste na pena de morte:

💀 [b]Base um pouco mais leve[/b]
A perda de experiência na morte ficou cerca de [b]25% mais leve[/b] na base (de 20 para 15).

✨ [b]!bless vale bem mais[/b]
Cada blessing reduz bem mais a perda de XP.
Com [b]!bless[/b] completo (5 blessings), a morte fica bem mais suave do que sem bless.
Itens e bags continuam protegidos com bless, como antes.

📌 [b]Dica:[/b] use [b]!bless[/b] antes de caçar (80k). VIP Baiak ainda perde um pouco menos que non-VIP.

Comente nesta notícia se ficou bom. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
💀 Morte mais leve (base 20→15). ✨ !bless reduz bem mais a perda de XP. Use !bless.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Pena de morte: deathLostPercent 20 para 15. eachBlessReduction 2 para 6 (!bless reduz mais XP).`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Pena de morte: deathLostPercent 20 para 15. eachBlessReduction 2 para 6 (!bless reduz mais XP).');
```
