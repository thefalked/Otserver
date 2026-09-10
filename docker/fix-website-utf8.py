#!/usr/bin/env python3
"""Normalize website PHP/HTML to UTF-8 and restore Portuguese accents."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "website"

# Broken layout / page strings → correct Portuguese (UTF-8)
REPLACEMENTS = [
    # layout menu (0x9D corruption of accents)
    ("\x9dltimas Not\x9dcias", "Últimas Notícias"),
    ("Atualiza\x9d\x9des", "Atualizações"),
    ("Quem est\x9d Online", "Quem está Online"),
    ("F\x9drum", "Fórum"),
    # common mojibake / lost accents
    ("Gr?tis", "Grátis"),
    ("Grátis", "Grátis"),  # noop if already good
    ("?ltimo", "Último"),
    ("?ltima", "Última"),
    ("?ltimas", "Últimas"),
    ("Not?cias", "Notícias"),
    ("not?cias", "notícias"),
    ("Atualiza??es", "Atualizações"),
    ("Parab?ns", "Parabéns"),
    ("parab?ns", "parabéns"),
    ("aleat?rio", "aleatório"),
    ("aleat?ria", "aleatória"),
    ("Servidor Ã©", "Servidor é"),
    ("Servidor �", "Servidor é"),
    ("ParabÃ©ns", "Parabéns"),
    ("Ã©", "é"),
    ("Ã¡", "á"),
    ("Ã£", "ã"),
    ("Ã§", "ç"),
    ("Ã³", "ó"),
    ("Ã´", "ô"),
    ("Ãº", "ú"),
    ("Ã­", "í"),
    ("Ãª", "ê"),
    ("Ãµ", "õ"),
    ("Ã‰", "É"),
    ("Ãš", "Ú"),
    ("Ã‡", "Ç"),
]

# Explicit full-line / phrase fixes in latestnews and elsewhere
PHRASE_FIXES = [
    ("Casas Gr?tis", "Casas Grátis"),
    ("Casas Gratis", "Casas Grátis"),
    ("Boas-vindas e desejo a voc? um bom jogo!", "Boas-vindas e desejo a você um bom jogo!"),
    ("Boas-vindas e desejo a voce um bom jogo!", "Boas-vindas e desejo a você um bom jogo!"),
    ("Melhor Jogador No Servidor Ã©:", "Melhor Jogador No Servidor é:"),
    ("Melhor Jogador No Servidor é:", "Melhor Jogador No Servidor é:"),
    ("Melhor Jogador No Servidor \xe9:", "Melhor Jogador No Servidor é:"),
    ("ParabÃ©ns !!!", "Parabéns !!!"),
    ("Parabéns !!!", "Parabéns !!!"),
    ("um jogador aleatório ganha um item aleatório!", "um jogador aleatório ganha um item aleatório!"),
    ("Último ganhador:", "Último ganhador:"),
    ("Notícias rápidas", "Notícias rápidas"),
    ("Guildas mais poderosas", "Guildas mais poderosas"),
]


def to_unicode(data: bytes) -> str:
    """Decode file bytes to str, preferring UTF-8 then latin-1."""
    if not data:
        return ""
    # Already valid UTF-8?
    try:
        text = data.decode("utf-8")
        # If it looks like mojibake of latin-1 Portuguese stored as utf-8 misread,
        # leave as-is; REPLACEMENTS handle common cases.
        return text
    except UnicodeDecodeError:
        pass
    # Latin-1 / CP1252
    return data.decode("latin-1")


def fix_text(text: str) -> str:
    for a, b in REPLACEMENTS + PHRASE_FIXES:
        if a in text:
            text = text.replace(a, b)
    # remaining lone 0x9D / U+009D control often stands for missing accent letter
    # Fix specific known words if still present with replacement char
    text = text.replace("\u009d", "")  # strip leftover controls after targeted fixes
    # common ? corruption patterns for PT
    text = re.sub(r"\bGr\?tis\b", "Grátis", text)
    text = re.sub(r"\bParab\?ns\b", "Parabéns", text)
    text = re.sub(r"\baleat\?ri([oa])\b", r"aleatóri\1", text)
    text = re.sub(r"\bNot\?cias\b", "Notícias", text)
    text = re.sub(r"\bnot\?cias\b", "notícias", text)
    text = re.sub(r"\b\?ltim([oa]s?)\b", r"Últim\1", text)
    text = re.sub(r"\bvoc\?\b", "você", text)
    text = re.sub(r"\bVoc\?\b", "Você", text)
    return text


def process_file(path: Path) -> bool:
    raw = path.read_bytes()
    # skip binary-ish
    if b"\x00" in raw[:1000]:
        return False
    text = to_unicode(raw)
    fixed = fix_text(text)
    # charset declarations → UTF-8
    fixed = re.sub(
        r"charset\s*=\s*ISO-8859-1",
        "charset=UTF-8",
        fixed,
        flags=re.I,
    )
    fixed = re.sub(
        r"charset\s*=\s*iso-8859-1",
        "charset=UTF-8",
        fixed,
        flags=re.I,
    )
    out = fixed.encode("utf-8")
    if out != raw:
        path.write_bytes(out)
        return True
    return False


def main():
    changed = []
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file():
            continue
        if path.suffix.lower() not in {".php", ".js", ".css", ".html", ".htm", ".txt", ".xml"}:
            continue
        if "phpmailer/language" in str(path).replace("\\", "/"):
            continue  # leave vendor langs alone
        if "/cache/" in str(path).replace("\\", "/"):
            continue
        try:
            if process_file(path):
                changed.append(str(path.relative_to(ROOT)))
        except Exception as e:
            print("FAIL", path, e)
    print(f"updated {len(changed)} files")
    for c in changed[:80]:
        print(" ", c)


if __name__ == "__main__":
    main()
