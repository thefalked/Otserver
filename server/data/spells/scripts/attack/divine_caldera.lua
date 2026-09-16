local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_HOLYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HOLYAREA)
-- level/5 (was level/15) so Caldera scales at high level. See docs/spell-balance-15k.md
setAttackFormula(combat, COMBAT_FORMULA_LEVELMAGIC, 5, 5, 14, 17)

local area = createCombatArea(AREA_CIRCLE3X3)
setCombatArea(combat, area)

function onCastSpell(cid, var)
  return doCombat(cid, combat, var)
end
