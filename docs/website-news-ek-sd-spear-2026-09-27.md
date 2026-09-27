# Pacote para o site: SD no EK + magias + Auto Loot + eventos (2026-09-27)

Use depois de publicar:

- alterações de spells (SD vocation lock, Fierce Berserk, Ethereal Spear)
- Master Wand / Master Rod (`weapons.xml`: 3000-4900)
- Master Armor: removido absorb holy +10% (`items.xml`)
- Master Spear: `maxHitChance` 100 (`items.xml`)
- Auto Loot (`lib/autoloot.lua`, creaturescript, talkaction)
- Zombie Event (globalevent + creaturescript + reward Vip9)
- Event Bug (globalevent + death reward compartilhado)
- War system C++ ligado (`__WAR_SYSTEM__`) + docs `/war end` / `/war finish` no site
- (interno) ajuste de decay em `items.xml` (cadeia slain demon / Capeta)

Recarregue magias, weapons, items, talkactions, creaturescripts, globalevents e libs, ou reinicie o servidor de jogo.
Jogadores online precisam **relogar** para o Auto Loot registrar o evento de kill.
Build com `__WAR_SYSTEM__` precisa de recompile do binário.

Atualize também `server/noticias.txt` (Latin-1) para o `!notice`.

Detalhe técnico: [spell-balance-15k.md](spell-balance-15k.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
⚔️ EK sem SD + 🏹 Ethereal Spear + 🎒 Auto Loot + 🧟 Zombie + 🐛 Event Bug + 🏴 War
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Atualização de hoje:

⚔️ [b]Elite Knight[/b] (high level ~2000-15000)
[b]Sudden Death[/b] ([i]SD[/i]): [b]knights não usam mais[/b] a rune.
[b]Fierce Berserk[/b] ([i]exori gran[/i]): bem mais forte em high level. Vira o ataque principal do EK sem SD (AoE 3x3).

🏹 [b]Royal Paladin[/b]
[b]Ethereal Spear[/b] ([i]exori con[/i]): escala bem melhor de nível.
[b]Sudden Death[/b] ([i]SD[/i]): [b]paladins continuam podendo usar[/b].
[b]Master Spear[/b]: hit chance no teto ([b]100%[/b]). Antes usava a curva de spear (muitos miss).

🪄 [b]Master Sorcerer / Elder Druid[/b]
[b]Master Wand[/b] e [b]Master Rod[/b]: dano holy [b]3000-4900[/b] (antes 2000-2900).

🛡️ [b]Master Armor[/b]
Removido o [b]holy protect[/b] (+10% absorb holy). Continua com death +25%.

🎒 [b]Auto Loot[/b]
Novo comando [b]!autoloot[/b] (também [b]/autoloot[/b]).
[b]Level mínimo 1500[/b]. Começa com [b]2 slots[/b]. Quests VIP (Vip3 a Vip9) dão [b]+1 slot[/b] cada (máx. 9).
Só quem dá o [b]last hit[/b] coleta.
Comandos: [b]on[/b] | [b]off[/b] | [b]add, nome[/b] | [b]remove, nome[/b] | [b]clear[/b] | [b]list[/b] | [b]sell[/b].
[b]sell[/b] vende na hora os itens da lista que estão na backpack (metade do preço Mad/Rashid, gold no banco). Não vende o que está equipado. Não vende no kill.

🧟 [b]Zombie Event[/b]
Horários (São Paulo): [b]18:00[/b] e [b]22:00[/b].
Teleport de entrada no temple (aberto ~2 min). Mínimo [b]4 jogadores[/b].
Último vivo leva: taça com nome + [b]arma Vip9 aleatória[/b] + [b]100 gold nuggets[/b].

🐛 [b]Event Bug[/b]
Horários (São Paulo): spawn às [b]15:00[/b] e [b]20:00[/b] (aviso 5 min antes).
Aparece em um ponto aleatório perto do temple. Vocês têm [b]15 minutos[/b] para matar.
Quem estiver perto no kill recebe recompensa compartilhada: [b]arma Baiakzik/Master + 50 nuggets[/b] OU [b]set Master completo[/b] (sorteio por jogador).

🏴 [b]War entre guilds[/b]
Sistema de war ativo de novo (emblemas inimigo/amigo no client).
Para encerrar: [b]/war end, guild[/b] (armistício) e a outra confirma com [b]/war finish, guild[/b]. Detalhes na página de War do site.

📌 [b]Sem mudança no dano da SD[/b] para quem ainda usa. Só o EK perde o acesso.

Comente nesta notícia como ficou no jogo. Feedback ajuda a ajustar. 🙂

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (colar no ticker)

```text
⚔️ EK sem SD + exori gran. 🏹 RP exori con + Master Spear 100%. 🎒 !autoloot. 🧟 Zombie 18h/22h SP. 🐛 Event Bug 15h/20h SP. 🏴 War on.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server: Type: Change

1. `Sudden Death (SD): knights/EK não usam mais. Sorc/Druid/Pala (e promoções) seguem.`
2. `Buff Fierce Berserk (exori gran): escala bem mais em high level (EK sem SD).`
3. `Buff Ethereal Spear (exori con): escala bem mais em high level. RP mantém SD.`
4. `Master Spear: maxHitChance 100 (antes curva de spear ~75%, muitos miss).`
5. `Master Wand e Master Rod: dano holy 3000-4900 (antes 2000-2900).`
6. `Master Armor: removido holy protect (+10% absorb). Death +25% permanece.`

### Server: Type: Feature

1. `Auto Loot: !autoloot (lvl 1500+, 2 slots + VIP, last hit, sell manual metade Mad/Rashid no banco).`
2. `Zombie Event: 18:00/22:00 SP. TP no temple. Winner: taça + arma Vip9 + 100 nuggets.`
3. `Event Bug: spawn 15:00/20:00 SP no temple. 15 min. Reward compartilhado (arma+nuggets ou set Master).`
4. `War guild: sistema C++ ativo (emblemas). /war end e /war finish para encerrar.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Change', 'Server', UNIX_TIMESTAMP(), 'Sudden Death (SD): knights/EK não usam mais. Sorc/Druid/Pala (e promoções) seguem.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Fierce Berserk (exori gran): escala bem mais em high level (EK sem SD).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Buff Ethereal Spear (exori con): escala bem mais em high level. RP mantém SD.'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Master Spear: maxHitChance 100 (antes curva de spear ~75%, muitos miss).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Master Wand e Master Rod: dano holy 3000-4900 (antes 2000-2900).'),
('Change', 'Server', UNIX_TIMESTAMP(), 'Master Armor: removido holy protect (+10% absorb). Death +25% permanece.'),
('Feature', 'Server', UNIX_TIMESTAMP(), 'Auto Loot: !autoloot (lvl 1500+, 2 slots + VIP, last hit, sell manual metade Mad/Rashid no banco).'),
('Feature', 'Server', UNIX_TIMESTAMP(), 'Zombie Event: 18:00/22:00 SP. TP no temple. Winner: taça + arma Vip9 + 100 nuggets.'),
('Feature', 'Server', UNIX_TIMESTAMP(), 'Event Bug: spawn 15:00/20:00 SP no temple. 15 min. Reward compartilhado (arma+nuggets ou set Master).'),
('Feature', 'Server', UNIX_TIMESTAMP(), 'War guild: sistema C++ ativo (emblemas). /war end e /war finish para encerrar.');
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

- decay de Demon/Capeta (~45m para ~9m). Já no `items.xml`. Só ops/interno.
- detalhe técnico de corpos empilhados (snapshot/claim no Auto Loot). Já no código.
- label animado no TP do Zombie. Só UX.
- aviso de casa inativa no `/buy` (já existia limpeza de 3 dias).
- fix de membership de guild no save online (ops/website).
- `/cleanhouses` (comando god).
- ignore de `backup/Tibia` no git (ops).
