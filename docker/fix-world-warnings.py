#!/usr/bin/env python3
"""Fix Baiak world warnings: house entries, spawn spawntime=0, bad monster names."""
from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORLD = ROOT / "data" / "world"
HOUSE_XML = WORLD / "Baiak Yurots-house.xml"
SPAWN_XML = WORLD / "Baiak Yurots-spawn.xml"
OTBM = WORLD / "Baiak Yurots.otbm"

START, END, ESCAPE = 0xFE, 0xFF, 0xFD
OTBM_ROOTV1 = 1
OTBM_MAP_DATA = 2
OTBM_TILE_AREA = 4
OTBM_TILE = 5
OTBM_ITEM = 6
OTBM_TOWNS = 12
OTBM_TOWN = 13
OTBM_HOUSETILE = 14
OTBM_WAYPOINTS = 15
OTBM_WAYPOINT = 16

ATTR_DESCRIPTION = 1
ATTR_EXT_FILE = 2
ATTR_TILE_FLAGS = 3
ATTR_ACTION_ID = 4
ATTR_UNIQUE_ID = 5
ATTR_TEXT = 6
ATTR_DESC = 7
ATTR_TELE_DEST = 8
ATTR_ITEM = 9
ATTR_DEPOT_ID = 10
ATTR_EXT_SPAWN_FILE = 11
ATTR_RUNE_CHARGES = 12
ATTR_EXT_HOUSE_FILE = 13
ATTR_HOUSEDOORID = 14
ATTR_COUNT = 15
ATTR_DURATION = 16
ATTR_DECAYING_STATE = 17
ATTR_WRITTENDATE = 18
ATTR_WRITTENBY = 19
ATTR_SLEEPERGUID = 20
ATTR_SLEEPSTART = 21
ATTR_CHARGES = 22


class Reader:
    def __init__(self, data: bytes, offset: int = 0):
        self.data = data
        self.pos = offset

    def getU8(self) -> int:
        b = self.data[self.pos]
        self.pos += 1
        if b == ESCAPE:
            b = self.data[self.pos]
            self.pos += 1
        return b

    def getU16(self) -> int:
        return self.getU8() | (self.getU8() << 8)

    def getU32(self) -> int:
        return (
            self.getU8()
            | (self.getU8() << 8)
            | (self.getU8() << 16)
            | (self.getU8() << 24)
        )

    def peek(self) -> int:
        b = self.data[self.pos]
        if b == ESCAPE:
            return self.data[self.pos + 1]
        return b

    def get_string(self) -> str:
        ln = self.getU16()
        return bytes(self.getU8() for _ in range(ln)).decode("latin-1", "replace")


def parse_otbm_houses(path: Path):
    data = path.read_bytes()
    r = Reader(data, 4)
    assert r.getU8() == START
    root_type = r.getU8()
    if root_type not in (0, OTBM_ROOTV1):
        raise RuntimeError(f"unexpected OTBM root type {root_type}")
    r.getU32()
    r.getU16()
    r.getU16()
    r.getU32()
    r.getU32()

    house_tiles: dict[int, list[tuple[int, int, int]]] = defaultdict(list)
    doors: dict[int, list[tuple[int, int, int]]] = defaultdict(list)

    def parse_item(house_id, x, y, z):
        ntype = r.getU8()
        assert ntype == OTBM_ITEM
        r.getU16()  # item id
        while r.peek() not in (START, END):
            attr = r.getU8()
            if attr in (ATTR_COUNT, ATTR_RUNE_CHARGES, ATTR_DECAYING_STATE):
                r.getU8()
            elif attr in (ATTR_ACTION_ID, ATTR_UNIQUE_ID, ATTR_DEPOT_ID, ATTR_CHARGES):
                r.getU16()
            elif attr in (ATTR_TEXT, ATTR_DESC, ATTR_DESCRIPTION, ATTR_WRITTENBY):
                r.get_string()
            elif attr == ATTR_TELE_DEST:
                r.getU16()
                r.getU16()
                r.getU8()
            elif attr == ATTR_HOUSEDOORID:
                r.getU8()
                if house_id is not None:
                    doors[house_id].append((x, y, z))
            elif attr in (ATTR_DURATION, ATTR_WRITTENDATE, ATTR_SLEEPERGUID, ATTR_SLEEPSTART):
                r.getU32()
            elif attr == ATTR_ITEM:
                r.getU16()
            else:
                raise RuntimeError(f"unknown item attr {attr} at {r.pos}")
        while r.peek() == START:
            r.getU8()
            parse_item(house_id, x, y, z)
        assert r.getU8() == END

    def parse_any(base_x=0, base_y=0, base_z=0):
        ntype = r.getU8()
        if ntype == OTBM_MAP_DATA:
            while r.peek() not in (START, END):
                attr = r.getU8()
                if attr in (
                    ATTR_DESCRIPTION,
                    ATTR_EXT_FILE,
                    ATTR_EXT_SPAWN_FILE,
                    ATTR_EXT_HOUSE_FILE,
                ):
                    r.get_string()
                else:
                    raise RuntimeError(f"map attr {attr}")
            while r.peek() == START:
                r.getU8()
                parse_any()
            assert r.getU8() == END
        elif ntype == OTBM_TILE_AREA:
            bx, by, bz = r.getU16(), r.getU16(), r.getU8()
            while r.peek() == START:
                r.getU8()
                parse_any(bx, by, bz)
            assert r.getU8() == END
        elif ntype in (OTBM_TILE, OTBM_HOUSETILE):
            x = base_x + r.getU8()
            y = base_y + r.getU8()
            hid = None
            if ntype == OTBM_HOUSETILE:
                hid = r.getU32()
                house_tiles[hid].append((x, y, base_z))
            while r.peek() not in (START, END):
                attr = r.getU8()
                if attr == ATTR_TILE_FLAGS:
                    r.getU32()
                elif attr == ATTR_ITEM:
                    r.getU16()
                else:
                    raise RuntimeError(f"tile attr {attr}")
            while r.peek() == START:
                r.getU8()
                parse_item(hid, x, y, base_z)
            assert r.getU8() == END
        elif ntype == OTBM_TOWNS:
            while r.peek() == START:
                r.getU8()
                parse_any()
            assert r.getU8() == END
        elif ntype == OTBM_TOWN:
            r.getU32()
            r.get_string()
            r.getU16()
            r.getU16()
            r.getU8()
            while r.peek() == START:
                r.getU8()
                parse_any()
            assert r.getU8() == END
        elif ntype == OTBM_WAYPOINTS:
            while r.peek() == START:
                r.getU8()
                parse_any()
            assert r.getU8() == END
        elif ntype == OTBM_WAYPOINT:
            r.get_string()
            r.getU16()
            r.getU16()
            r.getU8()
            while r.peek() == START:
                r.getU8()
                parse_any()
            assert r.getU8() == END
        else:
            raise RuntimeError(f"unknown node type {ntype} at {r.pos}")

    while r.peek() == START:
        r.getU8()
        parse_any()
    assert r.getU8() == END
    return house_tiles, doors


def fix_houses() -> int:
    house_tiles, doors = parse_otbm_houses(OTBM)
    xml = HOUSE_XML.read_text(encoding="latin-1")
    fixed = 0

    def repl(m: re.Match) -> str:
        nonlocal fixed
        attrs = dict(re.findall(r'(\w+)="([^"]*)"', m.group(1)))
        hid = int(attrs["houseid"])
        if int(attrs.get("entryx", "0") or 0) != 0:
            return m.group(0)
        if hid in doors:
            x, y, z = doors[hid][0]
        elif hid in house_tiles:
            # Prefer a middle tile; first is fine
            x, y, z = house_tiles[hid][0]
        else:
            return m.group(0)
        name = attrs.get("name") or f"House {hid}"
        townid = attrs.get("townid") or "1"
        if townid == "0":
            townid = "1"
        rent = attrs.get("rent") or "0"
        size = attrs.get("size") or str(len(house_tiles.get(hid, [])) or 1)
        fixed += 1
        return (
            f'<house name="{name}" houseid="{hid}" entryx="{x}" entryy="{y}" '
            f'entryz="{z}" rent="{rent}" townid="{townid}" size="{size}"/>'
        )

    new_xml = re.sub(r"<house\b([^>]+)/?>", repl, xml)
    HOUSE_XML.write_text(new_xml, encoding="latin-1")
    return fixed


def fix_spawns() -> tuple[int, int]:
    text = SPAWN_XML.read_text(encoding="latin-1")
    # Clamp spawntime < 2 (TFS rejects <= MINSPAWN_INTERVAL/1000 == 1)
    def bump_time(m: re.Match) -> str:
        v = int(m.group(1))
        if v < 2:
            return 'spawntime="60"'
        return m.group(0)

    text2, n_time = re.subn(r'\bspawntime="(\d+)"', bump_time, text)
    # Trim leading/trailing spaces in monster names
    def fix_name(m: re.Match) -> str:
        return f'name="{m.group(1).strip()}"'

    text3, n_name = re.subn(r'\bname="([^"]*)"', fix_name, text2)
    # Known missing / mismatched spawn names → registered monster names
    renames = {
        "Exp bug": "Bugzin",
        "Exp Bug": "Bugzin",
        "Arkhothep": "Ashmunrah",
    }
    monsters_xml = (ROOT / "data" / "monster" / "monsters.xml").read_text(
        encoding="latin-1", errors="replace"
    )
    registered = set(
        re.findall(r'<monster\s+name="([^"]+)"', monsters_xml, flags=re.I)
    )

    n_rename = 0
    for old, new in list(renames.items()):
        if new not in registered:
            continue
        text3, c = re.subn(
            rf'\bname="{re.escape(old)}"', f'name="{new}"', text3
        )
        n_rename += c

    # Remove spawns whose monster still isn't registered
    broken = {"Mr.Ever", "Arkhothep", "Exp bug", "Exp Bug"}
    removed = 0
    lines = []
    for line in text3.splitlines(keepends=True):
        m = re.search(r'<monster\b[^>]*\bname="([^"]+)"', line)
        if m and (m.group(1) in broken or m.group(1) not in registered) and m.group(1) in broken:
            removed += 1
            continue
        lines.append(line)
    text3 = "".join(lines)

    SPAWN_XML.write_text(text3, encoding="latin-1")
    return n_time, n_name + n_rename + removed


def main():
    h = fix_houses()
    t, n = fix_spawns()
    print(f"houses entry fixed: {h}")
    print(f"spawntime 0->60: {t}")
    print(f"spawn name fixes/removals: {n}")


if __name__ == "__main__":
    main()
