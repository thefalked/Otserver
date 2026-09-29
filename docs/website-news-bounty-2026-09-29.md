# Pacote para o site: PvP Bounty (2026-09-29)

Use depois de publicar:

- Globalevent `bounty` a cada 15 minutos (`bounty.lua`, `globalevents.xml`)
- Claim no kill com mesmo pool do Event Bug (`bounty_kill.lua`, `creaturescripts.xml`, `login.lua`)

Recarregue globalevents e creaturescripts, ou reinicie o servidor de jogo.

---

## Últimas Notícias (colar em Admin → Nova Notícia)

**Tópico:**

```text
🎯 PvP Bounty: caça a cada 15 minutos
```

**Texto (BBCode + emoji Unicode):**

```text
😎 Novo evento:

🎯 [b]PvP Bounty[/b]
A cada [b]15 minutos[/b] o servidor escolhe [b]1 jogador Vip9[/b] em área de PvP (fora de PZ, house, trainer e no-PvP).
O nome sai no chat com o [b]level[/b].

Quem matar o alvo (IP diferente) leva o mesmo sorteio do Event Bug:
[b]arma Master + 50 nuggets[/b], OU [b]set Master completo[/b], OU [b]Double Xp[/b].

⚠️ Matar com o [b]mesmo IP[/b] não vale. Aviso só para quem matou. A bounty continua.
Se o alvo morrer de monstro ou logout, a bounty [b]continua[/b] até o próximo sorteio ou um claim válido.
Claim [b]não reinicia[/b] o timer. O próximo alvo só no ciclo de 15 minutos.

GM+ não entra no sorteio.

Comente nesta notícia como ficou. Feedback ajuda a ajustar. 🙂
```

---

## Ticker de notícias (colar no ticker)

```text
🎯 PvP Bounty a cada 15 min (Vip9 em PvP). Mate o alvo (IP diferente) e leve reward do Event Bug.
```

---

## Checklist rápido

- [ ] Colar notícia no Admin
- [ ] Colar ticker
- [ ] Reload globalevents + creaturescripts (ou restart)
- [ ] Confirmar broadcast de pick com nome + level
- [ ] Confirmar claim com reward no chat
- [ ] Confirmar aviso de mesmo IP sem limpar a bounty
