# Pacote para o site — Atualização 2026-09-17

Use depois de publicar os commits locais (ainda não enviados ao remote). Reinicie o servidor de jogo ou recarregue scripts/movements/creaturescripts conforme o que mudou.

Commits cobertos (8, desde o último push):

- balance: death exp ~8x, heal exhaust EK/RP, Master set
- VIP: level gates Vip2–Vip9, VIP7/8 exigem tier anterior
- website: SEO / sitemap
- fixes: afk/treinando, nginx rate-limit (ops), item de teste (interno)

Detalhe técnico: [death-penalty.md](death-penalty.md), [vip-level-gates.md](vip-level-gates.md), [master-gear.md](master-gear.md)

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
Atualização — Morte mais pesada, portões de level nas VIPs e Master set
```

**Texto (BBCode):**

```text
:cool: Nova atualização no ar. Resumo do que muda no jogo:

[b]Pena de morte[/b]
A perda de experiência na morte ficou bem mais forte (cerca de [b]8x[/b] a curva anterior).
Use [b]!bless[/b] antes de caçar. Bless reduz um pouco a perda de exp e protege itens/bags.

[b]Portões de level nas VIPs[/b]
Ter VIP não basta para entrar em Vip2–Vip9. Cada área exige level mínimo:

Vip2: 800 | Vip3: 1200 | Vip4: 1800 | Vip5: 2500
Vip6: 3000 | Vip7: 4000 | Vip8: 5000 | Vip9: 6500

Sem o level, você volta pro temple com aviso.

[b]VIP7 e VIP8[/b]
Para virar Vip7 você precisa ser Vip6.
Para virar Vip8 você precisa ser Vip7.

[b]Cura EK / RP[/b]
Exhaust da cura principal: [b]1.0s para 0.5s[/b] (Wound Cleansing e Divine Healing).

[b]Master set (VIP9)[/b]
Master Spellscroll: ML +6 agora aplica no equip.
Master Armor / Helmet / Legs / Boots / Shield: resists e stats retunados.

Comente nesta notícia o que achou. Feedback ajuda a ajustar. :)

Digite [b]!notice[/b] no jogo para ver o resumo.
```

---

## Ticker de notícias (opcional, curto)

```text
Morte ~8x mais pesada (use !bless). VIPs Vip2–Vip9 com level mínimo. VIP7 precisa VIP6, VIP8 precisa VIP7. Cura EK/RP mais rápida. Master set retunado.
```

---

## Changelog (`?subtopic=changelog`)

Descrições curtas (máx. 150 caracteres).

### Server — Type: Add

1. `Pena de morte bem mais forte (~8x). Use !bless para reduzir perda de exp e proteger itens.`
2. `Vip2–Vip9 exigem level mínimo para entrar (800 até 6500). Sem level, volta ao temple.`
3. `VIP7 exige Vip6 e VIP8 exige Vip7 (boneca e bau).`
4. `Exhaust da cura EK/RP (exana mort / exura san): 1.0s para 0.5s.`
5. `Master set VIP9 retunado: Spellscroll ML +6 no equip, resists e boots ajustados.`

### Server — Type: Remove (bugfix, opcional)

1. `Correção em !afk / !treinando: eventos não acumulam mais após logout ou reuso de cid.`

### Website — Type: Add

1. `SEO: meta tags, Open Graph, robots.txt e sitemap para indexação do site.`

### SQL opcional (banco do site)

```sql
INSERT INTO `z_changelog` (`type`, `where`, `date`, `description`) VALUES
('Add', 'Server', UNIX_TIMESTAMP(), 'Pena de morte bem mais forte (~8x). Use !bless para reduzir perda de exp e proteger itens.'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Vip2–Vip9 exigem level mínimo para entrar (800 até 6500). Sem level, volta ao temple.'),
('Add', 'Server', UNIX_TIMESTAMP(), 'VIP7 exige Vip6 e VIP8 exige Vip7 (boneca e bau).'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Exhaust da cura EK/RP (exana mort / exura san): 1.0s para 0.5s.'),
('Add', 'Server', UNIX_TIMESTAMP(), 'Master set VIP9 retunado: Spellscroll ML +6 no equip, resists e boots ajustados.'),
('Remove', 'Server', UNIX_TIMESTAMP(), 'Correção em !afk / !treinando: eventos não acumulam mais após logout ou reuso de cid.'),
('Add', 'Website', UNIX_TIMESTAMP(), 'SEO: meta tags, Open Graph, robots.txt e sitemap para indexação do site.');
```

---

## Fora do anúncio público

Não colar no site / `!notice`:

- fix do item de teste de exp (interno)
- rate-limit nginx do proxy do site (ops)
