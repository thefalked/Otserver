local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_ENERGYDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_BIGCLOUDS)
-- Mindrage-style, below Hell's Core, above Eternal Winter. See docs/spell-balance-15k.md
setCombatFormula(combat, COMBAT_FORMULA_LEVELMAGIC, -5.8, -5, -1.9, -0.9)

local area = createCombatArea(AREA_CROSS6X6)
setCombatArea(combat, area)

function onCastSpell(cid, var)
  return doCombat(cid, combat, var)
end
