# Pacote para o site: Vip9 hunts balance (2026-09-30)

Use depois de publicar:

- XP das caves Vip9 (`assasin.xml`, `elf.xml`, `werewolf.xml`, `swamp_troll.xml`)
- Respawn das caves Vip9 em `baiak_yurots-spawn.xml` (só área Vip9)

Recarregue monsters + spawns, ou reinicie o servidor de jogo.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
⚔️ Vip9: caves mais balanceadas
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Ajuste de hoje:

⚔️ [b]Vip9 hunts[/b]
As caves Vip9 foram ajustadas para ficarem [b]mais balanceadas[/b] (XP e respawn).

Comente nesta notícia como ficou. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
⚔️ Vip9: caves mais balanceadas (XP e respawn).
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Vip9 hunts: XP e respawn balanceados entre as caves.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Vip9 hunts: XP e respawn balanceados entre as caves.');
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

- nomes internos do spawn (Assassin, Wisp, Elf, Nomad, Werewolf, Swamp Troll)
- valores de XP ou tempos de respawn
- arquivos XML técnicos
