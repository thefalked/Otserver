local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_ICETORNADO)
-- Mindrage-style, below Rage of the Skies. See docs/spell-balance-15k.md
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -5.5, -5, -1.8, -0.8)

local area = createCombatArea(AREA_CROSS5X5)
setCombatArea(combat, area)

function onCastSpell(cid, var)
  return doCombat(cid, combat, var)
end
