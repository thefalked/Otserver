local combat = createCombatObject()
setCombatParam(combat, COMBAT_PARAM_TYPE, COMBAT_PHYSICALDAMAGE)
setCombatParam(combat, COMBAT_PARAM_BLOCKARMOR, true)
setCombatParam(combat, COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_ETHEREALSPEAR)

function onGetFormulaValues(cid, level, skill, attack, factor)
  -- Level term *5.5 so RP distance scales at high level (RP keeps SD).
  -- See docs/spell-balance-15k.md
  local levelTotal = (level / 5) * 5.5
  return -(((skill + 35) / 5) + levelTotal), -((skill + 25) + levelTotal)
end

setCombatCallback(combat, CALLBACK_PARAM_SKILLVALUE, "onGetFormulaValues")
function onCastSpell(cid, var)
  return doCombat(cid, combat, var)
end
