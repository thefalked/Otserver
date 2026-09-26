-- Auto Loot creaturescript.
-- Login registers kill. Collect runs only for last hit (see lib/autoloot.lua).
-- No range check. No corpse-owner check.
-- Stacked bodies: snapshot tile corpse UIDs at kill (before dropCorpse), then collect
-- only a new unclaimed UID after CorpseDelay.

function onLogin(cid)
  registerCreatureEvent(cid, "AutoLootKill")
  if AutoLoot.enforceLevel(cid) then
    doPlayerSendTextMessage(
      cid,
      MESSAGE_STATUS_CONSOLE_BLUE,
      "[Auto Loot] Desligado. Level minimo: " .. AutoLoot.MinLevel .. "."
    )
  end
  return true
end

function onKill(cid, target, damage, flags)
  -- flags bit 0 (value 1) = last hit (CreatureEvent::executeKill).
  if flags % 2 == 0 then
    return true
  end

  if not isPlayer(cid) or not isMonster(target) then
    return true
  end

  if AutoLoot.enforceLevel(cid) then
    return true
  end

  if not AutoLoot.isEnabled(cid) then
    return true
  end

  local pos = getCreaturePosition(target)
  local position = { x = pos.x, y = pos.y, z = pos.z }
  -- onKill runs before dropCorpse, so this list is only older stacked bodies.
  local beforeEncoded = AutoLoot.encodeUids(AutoLoot.listCorpseUids(position))

  local corpseItemId = 0
  local info = getMonsterInfo(getCreatureName(target))
  if info and info.lookCorpse then
    corpseItemId = info.lookCorpse
  end

  addEvent(AutoLoot.collect, AutoLoot.CorpseDelay, cid, position, beforeEncoded, corpseItemId)
  return true
end
