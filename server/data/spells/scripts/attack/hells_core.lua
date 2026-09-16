local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_FIREAREA)
-- Mindrage-style, below suden death (exevo gran mas mort). See docs/spell-balance-15k.md
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -6, -6, -2, -1)

local area = createCombatArea(AREA_CROSS5X5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
  return doCombat(cid, combat, var)
end
