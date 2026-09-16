local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HEALING)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
setCombatParam(combat, COMBAT_PARAM_AGGRESSIVE, false)
setCombatParam(combat, COMBAT_PARAM_DISPEL, CONDITION_PARALYZE)
-- Mana-rune-like scaling (~90% of Mana Rune). See docs/spell-balance-15k.md
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 4.5, 0, 2.7, 0)

function onCastSpell(cid, var)
  return doCombat(cid, combat, var)
end
