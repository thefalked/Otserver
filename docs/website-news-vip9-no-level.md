# Pacote para o site: Vip9 sem level mínimo

Use depois de publicar a remoção do portão de level em `vip9.lua`. Recarregue movements ou reinicie o servidor de jogo.

Detalhe técnico: [vip-level-gates.md](vip-level-gates.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
🚪 Vip9: removido o level mínimo
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Ajuste rápido nas VIPs:

🚪 [b]Vip9 sem level mínimo[/b]
Quem já é [b]Vip9[/b] entra na área sem precisar de level 6500.
Ainda precisa do status Vip9 (quest Vip8).

📌 [b]Sem mudança:[/b] Vip2 a Vip8 continuam com level mínimo (800 até 5000).

Comente nesta notícia se ficou bom. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
🚪 Vip9: removido o level 6500. Só status Vip9. Vip2-Vip8 seguem com level mínimo.
```

---

## Changelog (`?subtopic=changelog`)

Descrição curta (máx. 150 caracteres). **Type: Remove**, **Where: Server**:

1. `Vip9: removido level mínimo 6500 para entrar. Continua exigindo status Vip9.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Remove', 'Server', UNIX_TIMESTAMP(), 'Vip9: removido level mínimo 6500 para entrar. Continua exigindo status Vip9.');
```
