local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_EFFECT, CONST_ME_HITAREA)
setCombatParam(combat, COMBAT_PARAM_USECHARGES, true)

local area = createCombatArea(AREA_SQUARE1X1)
setCombatArea(combat, area)

function onGetFormulaValues(cid, level, skill, attack, factor)
  -- Level term *7.5 so EK AoE scales at high level without SD (~50-70% of SD).
  -- See docs/spell-balance-15k.md
  local skillTotal, levelTotal = skill + attack * 3, (level / 5) * 7.5
  return -(skillTotal * 2.2 + levelTotal), -(skillTotal * 6 + levelTotal)
end

setCombatCallback(combat, CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")
function onCastSpell(cid, var)
  return doCombat(cid, combat, var)
end
