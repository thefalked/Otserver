#!/usr/bin/env python3
"""Normalize Lua script string literals to Latin-1 and restore Portuguese accents.

Comments stay UTF-8 (the game never shows them).

Pattern:
- Word/phrase fixes follow docker/fix-website-utf8.py (voce -> você, etc.).
- Accented bytes in strings use Lua decimal escapes like shutdown.lua
  (\\225 for á, \\227 for ã, \\231 for ç) so source files stay ASCII-safe.
- Tibia 8.6 / OTClient read those escapes as ISO-8859-1 at runtime.
"""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "server"

# Mojibake / double-UTF-8 → correct Unicode (from fix-website-utf8.py)
MOJIBAKE = [
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
    ("Ã", "Á"),
    ("Ã€", "À"),
    ("Ã“", "Ó"),
    ("ÃŠ", "Ê"),
    ("Âº", "º"),
    ("Âª", "ª"),
    ("Â°", "°"),
    ("â€”", "-"),
    ("â€“", "-"),
    ("â€™", "'"),
    ("â€œ", '"'),
    ("â€", '"'),
]

# Punctuation outside Latin-1
PUNCT = {
    "\u2014": "-",
    "\u2013": "-",
    "\u2018": "'",
    "\u2019": "'",
    "\u201c": '"',
    "\u201d": '"',
    "\u2022": "*",
    "\u2026": "...",
}

# Missing accents in plain ASCII Portuguese (string content only)
WORD_FIXES = [
    (r"\bnecessarios\b", "necessários"),
    (r"\bNecessarios\b", "Necessários"),
    (r"\bnecessario\b", "necessário"),
    (r"\bNecessario\b", "Necessário"),
    (r"\bexperiencia\b", "experiência"),
    (r"\bExperiencia\b", "Experiência"),
    (r"\binformacoes\b", "informações"),
    (r"\bInformacoes\b", "Informações"),
    (r"\binformacao\b", "informação"),
    (r"\bInformacao\b", "Informação"),
    (r"\bpermissoes\b", "permissões"),
    (r"\bpermissao\b", "permissão"),
    (r"\bmanutencao\b", "manutenção"),
    (r"\batencao\b", "atenção"),
    (r"\bAtencao\b", "Atenção"),
    (r"\bposicoes\b", "posições"),
    (r"\bposicao\b", "posição"),
    (r"\bPosicao\b", "Posição"),
    (r"\bvocacoes\b", "vocações"),
    (r"\bvocacao\b", "vocação"),
    (r"\bVocacao\b", "Vocação"),
    (r"\bmissoes\b", "missões"),
    (r"\bMissoes\b", "Missões"),
    (r"\bmissao\b", "missão"),
    (r"\bMissao\b", "Missão"),
    (r"\bparabens\b", "parabéns"),
    (r"\bParabens\b", "Parabéns"),
    # Do not rewrite "noticias" — it is also the on-disk filename noticias.txt.
    (r"\bcomecar\b", "começar"),
    (r"\bComecar\b", "Começar"),
    (r"\bproxima\b", "próxima"),
    (r"\bProxima\b", "Próxima"),
    (r"\bproximo\b", "próximo"),
    (r"\bProximo\b", "Próximo"),
    (r"\bultimas\b", "últimas"),
    (r"\bUltimas\b", "Últimas"),
    (r"\bultima\b", "última"),
    (r"\bUltima\b", "Última"),
    (r"\bultimo\b", "último"),
    (r"\bUltimo\b", "Último"),
    (r"\bminimo\b", "mínimo"),
    (r"\bMinimo\b", "Mínimo"),
    (r"\bmaximo\b", "máximo"),
    (r"\bMaximo\b", "Máximo"),
    (r"\bunico\b", "único"),
    (r"\bUnico\b", "Único"),
    (r"\bunica\b", "única"),
    (r"\bUnica\b", "Única"),
    (r"\bpremio\b", "prêmio"),
    (r"\bPremio\b", "Prêmio"),
    (r"\bpremios\b", "prêmios"),
    (r"\bgratis\b", "grátis"),
    (r"\bGratis\b", "Grátis"),
    (r"\btambem\b", "também"),
    (r"\bTambem\b", "Também"),
    (r"\bopcoes\b", "opções"),
    (r"\bopcao\b", "opção"),
    (r"\bacoes\b", "ações"),
    (r"\bacao\b", "ação"),
    (r"\bpossivel\b", "possível"),
    (r"\bimpossivel\b", "impossível"),
    (r"\bdificil\b", "difícil"),
    (r"\bfacil\b", "fácil"),
    (r"\bnumero\b", "número"),
    (r"\bNumero\b", "Número"),
    (r"\bnumeros\b", "números"),
    (r"\bareas\b", "áreas"),
    (r"\bArea\b", "Área"),
    (r"\barea\b", "área"),
    (r"\bestao\b", "estão"),
    (r"\bEstao\b", "Estão"),
    (r"\bsao\b", "são"),
    (r"\bSao\b", "São"),
    (r"\bvoce\b", "você"),
    (r"\bVoce\b", "Você"),
    (r"\bVOCE\b", "VOCÊ"),
    (r"\bnao\b", "não"),
    (r"\bNao\b", "Não"),
    (r"\bNAO\b", "NÃO"),
    (r"\bola\b", "olá"),
    (r"\bOla\b", "Olá"),
    (r"\bja\b", "já"),
    (r"\bJa\b", "Já"),
    (r"\bvoc\?\b", "você"),
    (r"\bVoc\?\b", "Você"),
    (r"\bGr\?tis\b", "grátis"),
    (r"\bParab\?ns\b", "parabéns"),
]

WORD_FIXES_COMPILED = [(re.compile(a), b) for a, b in WORD_FIXES]


def fix_mojibake(text: str) -> str:
    for a, b in MOJIBAKE:
        if a in text:
            text = text.replace(a, b)
    # second pass for double-encoded files
    for a, b in MOJIBAKE:
        if a in text:
            text = text.replace(a, b)
    return text


def fix_accents(text: str) -> str:
    for a, b in PUNCT.items():
        text = text.replace(a, b)
    for rx, repl in WORD_FIXES_COMPILED:
        text = rx.sub(repl, text)
    return text


def to_lua_decimal_escapes(s: str) -> str:
    """Encode non-ASCII as Lua \\DDD decimal escapes (Latin-1 code points).

    Same style as server/data/talkactions/scripts/shutdown.lua.
    Existing escapes like \\227 are left alone (ASCII).
    """
    out: list[str] = []
    i = 0
    n = len(s)
    while i < n:
        ch = s[i]
        o = ord(ch)
        # Preserve existing Lua escapes (\\, \n, \227, ...)
        if ch == "\\" and i + 1 < n:
            nxt = s[i + 1]
            if nxt.isdigit():
                j = i + 1
                while j < n and j < i + 4 and s[j].isdigit():
                    j += 1
                out.append(s[i:j])
                i = j
                continue
            out.append(s[i : i + 2])
            i += 2
            continue
        if o >= 128:
            if o <= 255:
                out.append(f"\\{o}")
            else:
                out.append("?")
            i += 1
            continue
        if ch == "\n":
            out.append("\\n")
            i += 1
            continue
        if ch == "\r":
            out.append("\\r")
            i += 1
            continue
        out.append(ch)
        i += 1
    return "".join(out)


def process_lua(text: str) -> bytes:
    """Comments/code as UTF-8. String contents use \\DDD Latin-1 escapes."""
    result = bytearray()
    i = 0
    n = len(text)

    def emit_utf8(s: str) -> None:
        result.extend(s.encode("utf-8"))

    def emit_short_string_body(s: str) -> None:
        result.extend(to_lua_decimal_escapes(fix_accents(s)).encode("ascii", "replace"))

    while i < n:
        if text.startswith("--[", i):
            j = i + 3
            eq = 0
            while j < n and text[j] == "=":
                eq += 1
                j += 1
            if j < n and text[j] == "[":
                close = "]" + ("=" * eq) + "]"
                k = text.find(close, j + 1)
                if k < 0:
                    emit_utf8(text[i:])
                    break
                emit_utf8(text[i : k + len(close)])
                i = k + len(close)
                continue

        if text.startswith("--", i):
            k = text.find("\n", i)
            if k < 0:
                emit_utf8(text[i:])
                break
            emit_utf8(text[i : k + 1])
            i = k + 1
            continue

        # Long string [[...]]: Lua ignores \\DDD there, so rewrite as "..." if needed.
        if text[i] == "[":
            j = i + 1
            eq = 0
            while j < n and text[j] == "=":
                eq += 1
                j += 1
            if j < n and text[j] == "[":
                close = "]" + ("=" * eq) + "]"
                k = text.find(close, j + 1)
                if k < 0:
                    emit_utf8(text[i:])
                    break
                content = text[j + 1 : k]
                fixed = fix_accents(content)
                needs_escape = fixed != content or any(ord(c) > 127 for c in fixed)
                if needs_escape:
                    body = to_lua_decimal_escapes(fixed).replace('"', '\\"')
                    emit_utf8('"' + body + '"')
                else:
                    emit_utf8(text[i : k + len(close)])
                i = k + len(close)
                continue

        if text[i] in ("'", '"'):
            quote = text[i]
            emit_utf8(quote)
            i += 1
            buf: list[str] = []
            # Allow raw newlines inside quotes (some OT scripts use them).
            while i < n:
                ch = text[i]
                if ch == "\\":
                    if i + 1 < n:
                        buf.append(text[i : i + 2])
                        i += 2
                        continue
                    buf.append(ch)
                    i += 1
                    continue
                if ch == quote:
                    emit_short_string_body("".join(buf))
                    emit_utf8(quote)
                    i += 1
                    break
                buf.append(ch)
                i += 1
            else:
                emit_short_string_body("".join(buf))
            continue

        emit_utf8(text[i])
        i += 1

    return bytes(result)


def decode_file(data: bytes) -> str:
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        text = data.decode("latin-1")
    return fix_mojibake(text)


def needs_work(text: str, data: bytes) -> bool:
    if any(ord(c) > 127 for c in text):
        return True
    if any(rx.search(text) for rx, _ in WORD_FIXES_COMPILED):
        return True
    return False


def process_file(path: Path) -> bool:
    raw = path.read_bytes()
    if not raw or b"\x00" in raw[:1000]:
        return False
    text = decode_file(raw)
    if not needs_work(text, raw):
        return False
    out = process_lua(text)
    if out == raw:
        return False
    path.write_bytes(out)
    return True


def main() -> None:
    changed: list[str] = []
    for path in sorted(ROOT.rglob("*.lua")):
        try:
            if process_file(path):
                changed.append(str(path.relative_to(ROOT)))
        except Exception as e:
            print("FAIL", path, e)
    print(f"updated {len(changed)} files")
    for c in changed[:80]:
        print(" ", c)
    if len(changed) > 80:
        print(f"  ... and {len(changed) - 80} more")


if __name__ == "__main__":
    main()
