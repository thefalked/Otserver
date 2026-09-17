#!/usr/bin/env python3
"""Death penalty calculator matching this server's engine.

Mirrors:
  - login.lua: LOSS_EXPERIENCE = deathLostPercent * 10
  - Player::getLostExperience() in src/player.cpp
  - Player::getExpForLevel() in src/player.h
  - VIP lessloss from server/data/XML/vocations.xml (ids 5-8 => 10)

Examples:
  python3 scripts/death_penalty.py
  python3 scripts/death_penalty.py --death-lost 80 --each-bless 2
  python3 scripts/death_penalty.py --death-lost 80 --each-bless 2 --bless 0,5
  python3 scripts/death_penalty.py --death-lost 80 --each-bless 2 --csv

Baseline play assumes !bless (5 blessings). See docs/death-penalty.md.
"""

from __future__ import annotations

import argparse
import math
import sys
from typing import Iterable


def get_exp_for_level(lv: int) -> int:
    """Match Player::getExpForLevel in src/player.h."""
    lv = lv - 1
    return ((50 * lv * lv * lv) - (150 * lv * lv) + (400 * lv)) // 3


def engine_percent(
    death_lost_percent: int,
    less_loss: int = 0,
    blessings: int = 0,
    each_bless: int = 2,
) -> float:
    loss_experience = death_lost_percent * 10
    return (loss_experience - less_loss - blessings * each_bless) / 100.0


def get_lost_experience(
    level: int,
    experience: int,
    death_lost_percent: int,
    less_loss: int = 0,
    blessings: int = 0,
    each_bless: int = 2,
) -> int:
    percent = engine_percent(death_lost_percent, less_loss, blessings, each_bless)
    if percent <= 0:
        return 0
    if level <= 25:
        return math.floor(experience * percent / 10.0)

    base = level
    levels = (base + 50) / 100.0
    lost = 0
    while levels > 1.0:
        lost += get_exp_for_level(base) - get_exp_for_level(base - 1)
        base -= 1
        levels -= 1.0
    if levels > 0:
        lost += math.floor(
            (get_exp_for_level(base) - get_exp_for_level(base - 1)) * levels
        )
    return math.floor(lost * percent)


def apply_remove(level: int, experience: int, lost: int) -> tuple[int, int]:
    experience -= min(lost, experience)
    while level > 1 and experience < get_exp_for_level(level):
        level -= 1
    return level, experience


def fractional_level(level: int, experience: int) -> float:
    cur = get_exp_for_level(level)
    nxt = get_exp_for_level(level + 1)
    if nxt <= cur:
        return float(level)
    return level + (experience - cur) / (nxt - cur)


def levels_lost(
    level: int,
    death_lost_percent: int,
    less_loss: int = 0,
    blessings: int = 0,
    each_bless: int = 2,
    progress: float = 0.5,
) -> tuple[float, int, int]:
    """Return (levels_lost, end_level, lost_exp)."""
    cur = get_exp_for_level(level)
    nxt = get_exp_for_level(level + 1)
    experience = cur + int((nxt - cur) * progress)
    lost = get_lost_experience(
        level, experience, death_lost_percent, less_loss, blessings, each_bless
    )
    new_level, new_exp = apply_remove(level, experience, lost)
    before = fractional_level(level, experience)
    after = fractional_level(new_level, new_exp)
    return before - after, new_level, lost


def default_levels() -> list[int]:
    levels = list(range(10, 101, 10))
    levels += [150, 200, 250, 300, 400, 500, 600, 700, 800, 900, 1000]
    levels += list(range(2000, 15001, 1000))
    return levels


def parse_int_list(raw: str) -> list[int]:
    return [int(part.strip()) for part in raw.split(",") if part.strip()]


def build_scenarios(
    each_bless_values: Iterable[int],
    bless_counts: Iterable[int],
) -> list[tuple[str, int, int, int]]:
    """(label, less_loss, blessings, each_bless)."""
    scenarios: list[tuple[str, int, int, int]] = []
    for each in each_bless_values:
        for bless in bless_counts:
            scenarios.append((f"NonVIP {bless}b e={each}", 0, bless, each))
            scenarios.append((f"VIP {bless}b e={each}", 10, bless, each))
    return scenarios


def print_markdown(
    death_lost: int,
    levels: list[int],
    scenarios: list[tuple[str, int, int, int]],
    progress: float,
) -> None:
    print(f"# deathLostPercent={death_lost}, progress={progress}")
    print()
    print("| Case | lessLoss | bless | eachBless | percent |")
    print("|------|---------:|------:|----------:|--------:|")
    for label, less_loss, blessings, each in scenarios:
        percent = engine_percent(death_lost, less_loss, blessings, each)
        print(
            f"| {label} | {less_loss} | {blessings} | {each} | {percent:.2f} |"
        )
    print()

    headers = ["Level"]
    for label, *_ in scenarios:
        headers.append(f"{label} lose")
        headers.append(f"{label} ends")
    print("| " + " | ".join(headers) + " |")
    print("|" + "|".join(["------:"] * len(headers)) + "|")

    for level in levels:
        cells = [str(level)]
        for _, less_loss, blessings, each in scenarios:
            lose, end, _ = levels_lost(
                level, death_lost, less_loss, blessings, each, progress
            )
            cells.append(f"{lose:.2f}")
            cells.append(str(end))
        print("| " + " | ".join(cells) + " |")


def print_csv(
    death_lost: int,
    levels: list[int],
    scenarios: list[tuple[str, int, int, int]],
    progress: float,
) -> None:
    headers = ["level"]
    for label, *_ in scenarios:
        headers.append(f"{label}_lose")
        headers.append(f"{label}_ends")
    print(",".join(headers))
    for level in levels:
        cells = [str(level)]
        for _, less_loss, blessings, each in scenarios:
            lose, end, _ = levels_lost(
                level, death_lost, less_loss, blessings, each, progress
            )
            cells.append(f"{lose:.2f}")
            cells.append(str(end))
        print(",".join(cells))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--death-lost",
        type=int,
        default=80,
        help="deathLostPercent from config (default 80)",
    )
    parser.add_argument(
        "--each-bless",
        type=str,
        default="2",
        help="eachBlessReduction value(s), comma-separated (default 2)",
    )
    parser.add_argument(
        "--bless",
        type=str,
        default="0,5",
        help="blessing counts to compare, comma-separated (default 0,5; 5 = !bless)",
    )
    parser.add_argument(
        "--progress",
        type=float,
        default=0.5,
        help="fraction into current level, 0..1 (default 0.5)",
    )
    parser.add_argument(
        "--csv",
        action="store_true",
        help="print CSV instead of markdown",
    )
    parser.add_argument(
        "--compact",
        action="store_true",
        help="only print lose columns (no end levels)",
    )
    args = parser.parse_args(argv)

    each_values = parse_int_list(args.each_bless)
    bless_counts = parse_int_list(args.bless)
    scenarios = build_scenarios(each_values, bless_counts)
    levels = default_levels()

    if args.compact:
        # Lose-only markdown table
        print(f"# deathLostPercent={args.death_lost}, progress={args.progress}")
        print()
        print("| Case | lessLoss | bless | eachBless | percent |")
        print("|------|---------:|------:|----------:|--------:|")
        for label, less_loss, blessings, each in scenarios:
            percent = engine_percent(args.death_lost, less_loss, blessings, each)
            print(
                f"| {label} | {less_loss} | {blessings} | {each} | {percent:.2f} |"
            )
        print()
        headers = ["Level"] + [label for label, *_ in scenarios]
        print("| " + " | ".join(headers) + " |")
        print("|" + "|".join(["------:"] * len(headers)) + "|")
        for level in levels:
            cells = [str(level)]
            for _, less_loss, blessings, each in scenarios:
                lose, _, _ = levels_lost(
                    level,
                    args.death_lost,
                    less_loss,
                    blessings,
                    each,
                    args.progress,
                )
                cells.append(f"{lose:.2f}")
            print("| " + " | ".join(cells) + " |")
        return 0

    if args.csv:
        print_csv(args.death_lost, levels, scenarios, args.progress)
    else:
        print_markdown(args.death_lost, levels, scenarios, args.progress)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
