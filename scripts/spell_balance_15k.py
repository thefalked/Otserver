#!/usr/bin/env python3
"""Spell balance checker for levels 2000-15000.

Mirrors FORMULA_LEVELMAGIC from src/combat.cpp:
  value = (level / minl + ML * minm) * mina + minb

Edit FORMULAS below, re-run, then copy winners into the Lua spell scripts.
See docs/spell-balance-15k.md.
"""

from __future__ import annotations

import argparse
import sys

# Config defaults (formulaLevel / formulaMagic)
FL = 5.0
FM = 1.0

LEVELS = [2000, 5000, 8000, 10000, 15000]
ML_MAGE = 130
ML_RP = 40
ML_EK = 12
EK_SKILL = 140
EK_WEAPON_ATK = 55
RP_DIST_SKILL = 120

# --- Planned / current formulas (tweak here for what-if) ---
FORMULAS = {
    # name, words, kind, args, vocation_ml_key
    # kind: raw4 | attack_af | heal_af | mana_raw4 | fierce | spear | sd_rune
    "Wound Cleansing (exana mort) NEW": ("heal_raw4", (4.5, 0, 2.7, 0), "ek"),
    "Wound Cleansing (exana mort) OLD": ("heal_af", (5, 5, 11, 15), "ek"),
    "Mana Rune (id 2276)": ("mana_raw4", (5, 4, 3, 2), "ek"),
    "suden death (exevo gran mas mort)": ("raw4", (-7, -9, -2, -1), "mage"),
    "Hell's Core (exevo gran mas flam) NEW": ("raw4", (-6, -6, -2, -1), "mage"),
    "Hell's Core (exevo gran mas flam) OLD": ("attack_af", (5, 5, 7, 14), "mage"),
    "Rage of the Skies (exevo gran mas vis) NEW": ("raw4", (-5.8, -5, -1.9, -0.9), "mage"),
    "Rage of the Skies (exevo gran mas vis) OLD": ("attack_af", (5, 5, 5, 12), "mage"),
    "Eternal Winter (exevo gran mas frigo) NEW": ("raw4", (-5.5, -5, -1.8, -0.8), "mage"),
    "Eternal Winter (exevo gran mas frigo) OLD": ("attack_af", (5, 5, 6, 12), "mage"),
    "Divine Caldera (exevo mas san) NEW": ("attack_af", (5, 5, 14, 17), "rp"),
    "Divine Caldera (exevo mas san) OLD": ("attack_af", (15, 15, 14, 17), "rp"),
    # fierce args: (level_div, level_mul). Pre-SD-removal NEW was (5, 1).
    "Fierce Berserk (exori gran) NEW": ("fierce", (5, 7.5), "ek"),
    "Fierce Berserk (exori gran) OLD": ("fierce", (5, 1), "ek"),
    # spear args: (level_mul,). Pre-buff was (1,).
    "Ethereal Spear (exori con) NEW": ("spear", (5.5,), "rp"),
    "Ethereal Spear (exori con) OLD": ("spear", (1,), "rp"),
    "Sudden Death rune (id 2268)": ("sd_rune", (), "ek"),
    "Sudden Death rune RP (id 2268)": ("sd_rune", (), "rp"),
    "Divine Healing (exura san)": ("heal_af", (5, 5, 20, 40), "rp"),
}


def lm(level: float, ml: float, mina: float, minb: float, maxa: float, maxb: float,
       minl: float = FL, maxl: float = FL, minm: float = FM, maxm: float = FM) -> tuple[float, float]:
    mn = (level / minl + ml * minm) * mina + minb
    mx = (level / maxl + ml * maxm) * maxa + maxb
    return mn, mx


def avg_mag(pair: tuple[float, float]) -> float:
    a, b = pair
    return (abs(a) + abs(b)) / 2.0


def avg_heal(pair: tuple[float, float]) -> float:
    a, b = pair
    return (a + b) / 2.0


def eval_spell(kind: str, args: tuple, level: int, ml: int) -> float:
    if kind == "raw4":
        return avg_mag(lm(level, ml, *args))
    if kind == "mana_raw4":
        return avg_heal(lm(level, ml, *args))
    if kind == "heal_raw4":
        return avg_heal(lm(level, ml, *args))
    if kind == "attack_af":
        minl, maxl, minm, maxm = args[:4]
        return avg_mag(lm(level, ml, -1, 0, -1, 0, minl, maxl, minm, maxm))
    if kind == "heal_af":
        minl, maxl, minm, maxm = args[:4]
        return avg_heal(lm(level, ml, 1, 0, 1, 0, minl, maxl, minm, maxm))
    if kind == "fierce":
        level_div, level_mul = args[0], args[1] if len(args) > 1 else 1.0
        st = EK_SKILL + EK_WEAPON_ATK * 3
        lt = (level / level_div) * level_mul
        lo = abs(-(st * 2.2 + lt))
        hi = abs(-(st * 6 + lt))
        return (lo + hi) / 2.0
    if kind == "spear":
        (level_mul,) = args
        lt = (level / 5.0) * level_mul
        lo = abs(-(((RP_DIST_SKILL + 35) / 5.0) + lt))
        hi = abs(-((RP_DIST_SKILL + 25) + lt))
        return (lo + hi) / 2.0
    if kind == "sd_rune":
        # setCombatFormula(-8, -35, -10, -35, 3, 3, 2, 1)
        return avg_mag(lm(level, ml, -8, -35, -10, -35, 3, 3, 2, 1))
    raise ValueError(kind)


def ml_for(key: str, ml_mage: int, ml_rp: int, ml_ek: int) -> int:
    return {"mage": ml_mage, "rp": ml_rp, "ek": ml_ek}[key]


def print_matrix(levels: list[int], ml_mage: int, ml_rp: int, ml_ek: int) -> None:
    print("=== BEFORE / AFTER averages ===\n")
    pairs = [
        ("Wound Cleansing (exana mort)", "Wound Cleansing (exana mort) OLD", "Wound Cleansing (exana mort) NEW"),
        ("Hell's Core (exevo gran mas flam)", "Hell's Core (exevo gran mas flam) OLD", "Hell's Core (exevo gran mas flam) NEW"),
        ("Rage of the Skies (exevo gran mas vis)", "Rage of the Skies (exevo gran mas vis) OLD", "Rage of the Skies (exevo gran mas vis) NEW"),
        ("Eternal Winter (exevo gran mas frigo)", "Eternal Winter (exevo gran mas frigo) OLD", "Eternal Winter (exevo gran mas frigo) NEW"),
        ("Fierce Berserk (exori gran)", "Fierce Berserk (exori gran) OLD", "Fierce Berserk (exori gran) NEW"),
        ("Ethereal Spear (exori con)", "Ethereal Spear (exori con) OLD", "Ethereal Spear (exori con) NEW"),
        ("Divine Caldera (exevo mas san)", "Divine Caldera (exevo mas san) OLD", "Divine Caldera (exevo mas san) NEW"),
    ]
    header = f"{'Spell':<42} {'L':>6} {'Before':>10} {'After':>10} {'Delta':>10}"
    print(header)
    print("-" * len(header))
    for label, old_k, new_k in pairs:
        okind, oargs, ovoc = FORMULAS[old_k]
        nkind, nargs, nvoc = FORMULAS[new_k]
        for level in levels:
            oml = ml_for(ovoc, ml_mage, ml_rp, ml_ek)
            nml = ml_for(nvoc, ml_mage, ml_rp, ml_ek)
            before = eval_spell(okind, oargs, level, oml)
            after = eval_spell(nkind, nargs, level, nml)
            print(f"{label:<42} {level:>6} {before:>10.0f} {after:>10.0f} {after - before:>+10.0f}")
        print()

    print("=== Mage AoE order (NEW, ML mage). mort must stay #1 ===\n")
    order = [
        "suden death (exevo gran mas mort)",
        "Hell's Core (exevo gran mas flam) NEW",
        "Rage of the Skies (exevo gran mas vis) NEW",
        "Eternal Winter (exevo gran mas frigo) NEW",
    ]
    print(f"{'Level':>6}", *[f"{n.split('(')[0].strip():>12}" for n in ["mort", "flam", "vis", "frigo"]])
    for level in levels:
        vals = []
        for key in order:
            kind, args, voc = FORMULAS[key]
            vals.append(eval_spell(kind, args, level, ml_for(voc, ml_mage, ml_rp, ml_ek)))
        print(f"{level:>6}", *[f"{v:>12.0f}" for v in vals])
    print()

    print("=== Heal HPS @ exhaust (EK 0.75s, RP 0.5s) ===\n")
    print(f"{'Spell':<28} {'L':>6} {'heal_avg':>10} {'HPS@1.0s':>10} {'HPS@live':>10}")
    print("-" * 68)
    heals = [
        ("Wound Cleansing (EK)", "Wound Cleansing (exana mort) NEW", "ek", 0.75),
        ("Divine Healing (RP)", "Divine Healing (exura san)", "rp", 0.5),
    ]
    for label, key, voc, exhaust_s in heals:
        kind, args, _ = FORMULAS[key]
        for level in levels:
            ml = ml_for(voc, ml_mage, ml_rp, ml_ek)
            avg = eval_spell(kind, args, level, ml)
            print(f"{label:<28} {level:>6} {avg:>10.0f} {avg / 1.0:>10.0f} {avg / exhaust_s:>10.0f}")
        print()


def check_pass(levels: list[int], ml_mage: int, ml_rp: int, ml_ek: int) -> list[str]:
    errors: list[str] = []
    for level in levels:
        mort = eval_spell(*FORMULAS["suden death (exevo gran mas mort)"][:2], level, ml_mage)
        flam = eval_spell(*FORMULAS["Hell's Core (exevo gran mas flam) NEW"][:2], level, ml_mage)
        vis = eval_spell(*FORMULAS["Rage of the Skies (exevo gran mas vis) NEW"][:2], level, ml_mage)
        frigo = eval_spell(*FORMULAS["Eternal Winter (exevo gran mas frigo) NEW"][:2], level, ml_mage)
        if not (mort > flam > vis > frigo):
            errors.append(
                f"L{level}: expected mort > flam > vis > frigo, got "
                f"{mort:.0f} > {flam:.0f} > {vis:.0f} > {frigo:.0f}"
            )

        wound = eval_spell(*FORMULAS["Wound Cleansing (exana mort) NEW"][:2], level, ml_ek)
        mana = eval_spell(*FORMULAS["Mana Rune (id 2276)"][:2], level, ml_ek)
        ratio = wound / mana if mana else 0.0
        if not (0.88 <= ratio <= 0.92):
            errors.append(f"L{level}: Wound/Mana ratio {ratio:.3f} not in [0.88, 0.92]")

        sd_ek = eval_spell(*FORMULAS["Sudden Death rune (id 2268)"][:2], level, ml_ek)
        fierce = eval_spell(*FORMULAS["Fierce Berserk (exori gran) NEW"][:2], level, ml_ek)
        fierce_ratio = fierce / sd_ek if sd_ek else 0.0
        if not (0.50 <= fierce_ratio <= 0.70):
            errors.append(
                f"L{level}: Fierce/SD(EK) ratio {fierce_ratio:.3f} not in [0.50, 0.70]"
            )

        sd_rp = eval_spell(*FORMULAS["Sudden Death rune RP (id 2268)"][:2], level, ml_rp)
        spear = eval_spell(*FORMULAS["Ethereal Spear (exori con) NEW"][:2], level, ml_rp)
        spear_ratio = spear / sd_rp if sd_rp else 0.0
        if not (0.28 <= spear_ratio <= 0.42):
            errors.append(
                f"L{level}: Spear/SD(RP) ratio {spear_ratio:.3f} not in [0.28, 0.42]"
            )
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Spell balance matrix 2000-15000")
    parser.add_argument("--level", type=int, action="append", dest="levels",
                        help="Extra/override level (repeatable). Default: 2k-15k set.")
    parser.add_argument("--ml-mage", type=int, default=ML_MAGE)
    parser.add_argument("--ml-rp", type=int, default=ML_RP)
    parser.add_argument("--ml-ek", type=int, default=ML_EK)
    args = parser.parse_args()
    levels = sorted(set(args.levels)) if args.levels else LEVELS

    print(
        f"Assumptions: ML mage={args.ml_mage}, RP={args.ml_rp}, EK={args.ml_ek}; "
        f"EK skill={EK_SKILL} atk={EK_WEAPON_ATK}; RP dist={RP_DIST_SKILL}; "
        f"formulaLevel={FL} formulaMagic={FM}\n"
    )
    print_matrix(levels, args.ml_mage, args.ml_rp, args.ml_ek)
    errors = check_pass(levels, args.ml_mage, args.ml_rp, args.ml_ek)
    if errors:
        print("FAIL:")
        for e in errors:
            print(f"  - {e}")
        return 1
    print(
        "PASS: mort > flam > vis > frigo; Wound ≈ 90% Mana Rune; "
        "Fierce ≈ 50-70% SD; Spear ≈ 28-42% SD"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
