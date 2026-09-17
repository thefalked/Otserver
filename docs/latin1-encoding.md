# Latin-1 text for the game client

Tibia 8.6 and OTClient expect **ISO-8859-1 (Latin-1)** for player-visible text. UTF-8 multi-byte accents show as mojibake in dialogs, cancels, NPC talk, and broadcasts.

The website can stay UTF-8. Game scripts and in-game notice files must not send UTF-8 accent bytes to the client.

## Lua scripts

### Player-visible strings

Put accents in short strings (`"..."` / `'...'`) as **Lua decimal escapes**. The source stays ASCII-safe. At runtime Lua turns `\DDD` into one Latin-1 byte.

Reference file: `server/data/talkactions/scripts/shutdown.lua`.

```lua
-- Tibia 8.6 / OTClient expect ISO-8859-1 (Latin-1), not UTF-8.
-- Accents use decimal escapes so this file stays ASCII-safe.
doPlayerSendCancel(cid, "Voc\234 n\227o tem level suficiente.")
-- shows: Você não tem level suficiente.
```

### Common escapes

| Char | Escape | Char | Escape |
| --- | --- | --- | --- |
| á | `\225` | Á | `\193` |
| à | `\224` | Ã | `\195` |
| â | `\226` | É | `\201` |
| ã | `\227` | Í | `\205` |
| ç | `\231` | Ó | `\211` |
| é | `\233` | Ú | `\218` |
| ê | `\234` | Ç | `\199` |
| í | `\237` | õ | `\245` |
| ó | `\243` | ô | `\244` |
| ú | `\250` | | |

Long strings (`[[...]]`) do **not** expand `\227`. Prefer short strings with escapes for any accented text.

### Comments

Comments are never sent to the client. They may keep UTF-8 accents.

```lua
-- posição da arma  (UTF-8 in comment is fine)
doPlayerSendCancel(cid, "Posi\231\227o inv\225lida.")
```

### Do not accent filenames

`io.open`, `dofile`, and similar must match the real path on disk. Example: the notice file is `noticias.txt` (ASCII). Do not rewrite it to `notícias.txt`.

## `noticias.txt` and `!notice`

Flow:

1. Player uses `!notice`.
2. `server/data/talkactions/scripts/notice.lua` opens `noticias.txt` from the server working directory.
3. The script reads the file as raw bytes and passes them to `doShowTextDialog`.

So `server/noticias.txt` must be **Latin-1 bytes on disk**, with real accented characters (not Lua `\DDD` escapes). Escapes only work inside Lua source.

Check encoding:

```bash
file server/noticias.txt
# expect: ISO-8859 text (or similar Latin-1 / ISO-8859-1)
```

If `file` says UTF-8, convert before deploy:

```bash
python3 -c "
from pathlib import Path
p = Path('server/noticias.txt')
t = p.read_text(encoding='utf-8').replace('\u2014', '-').replace('\u2013', '-')
p.write_bytes(t.encode('latin-1'))
"
```

## Helper scripts

| Script | Role |
| --- | --- |
| `docker/fix-lua-latin1.py` | Restores Portuguese accents in Lua string literals and rewrites them as `\DDD` escapes. Leaves comments as UTF-8. Does not rewrite the filename word `noticias`. |
| `docker/fix-website-utf8.py` | Website PHP/HTML only. Keeps the site on UTF-8. |

Run the Lua fixer from the repo root when cleaning scripts:

```bash
python3 docker/fix-lua-latin1.py
```

## Quick checklist

- [ ] New cancel / NPC / broadcast strings use `\DDD`, not raw UTF-8 accents.
- [ ] Comments may use UTF-8.
- [ ] Paths and filenames stay ASCII and match disk names.
- [ ] `noticias.txt` is Latin-1 (`file` does not say UTF-8).
- [ ] Website copy stays UTF-8 (separate from game text).
