# Pacote para o site: Pena de morte + Vip9 sem level

Use depois de publicar `deathLostPercent = 20` e a remoção do portão de level em `vip9.lua`. Reinicie o servidor de jogo (ou recarregue config + movements). Jogadores precisam relogar para a nova pena de morte aplicar.

Detalhe técnico: [death-penalty.md](death-penalty.md), [vip-level-gates.md](vip-level-gates.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
💀 Pena de morte mais leve + 🚪 Vip9 sem level
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Dois ajustes rápidos no ar:

💀 [b]Pena de morte mais leve[/b]
A curva forte da atualização anterior (~8x) ficou pesada demais.
Reduzimos a perda de experiência na morte para cerca de [b]1/4[/b] daquela curva.
Ainda use [b]!bless[/b] antes de caçar (reduz um pouco a perda e protege itens).

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
💀 Morte mais leve (~1/4 da curva anterior). 🚪 Vip9: sem level 6500 (só status Vip9).
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Pena de morte mais leve: deathLostPercent 80 para 20 (~1/4 da curva anterior). Use !bless.`

### Server: Type: Remove

1. `Vip9: removido level mínimo 6500 para entrar. Continua exigindo status Vip9.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Pena de morte mais leve: deathLostPercent 80 para 20 (~1/4 da curva anterior). Use !bless.'),
('Remove', 'Server', UNIX_TIMESTAMP(), 'Vip9: removido level mínimo 6500 para entrar. Continua exigindo status Vip9.');
```
