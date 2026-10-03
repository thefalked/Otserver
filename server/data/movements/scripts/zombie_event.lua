local config = {
  playerCount = 2001, -- Global storage for counting the players in the event
  maxPlayers = 15, -- Max players who can participate
}

-- Strip DoTs brought in from outside so they cannot tick during the event.
local entryClearConditions = {
  CONDITION_POISON,
  CONDITION_FIRE,
  CONDITION_ENERGY,
  CONDITION_DROWN,
  CONDITION_FREEZING,
  CONDITION_DAZZLED,
  CONDITION_CURSED,
}

local function clearEntryConditions(cid)
  for _, condition in ipairs(entryClearConditions) do
    if hasCondition(cid, condition) then
      doRemoveCondition(cid, condition)
    end
  end
end

function onStepIn(cid, item, position, lastPosition, fromPosition, toPosition, actor)
  -- CM access (4+) cannot take a participant slot
  if getPlayerAccess(cid) >= 4 then
    addEvent(tpBack, 1000, cid, fromPosition)
    doPlayerSendCancel(cid, "Community Managers cannot join the Zombie event.")
    return false
  end

  if getGlobalStorageValue(config.playerCount) < config.maxPlayers then
    clearEntryConditions(cid)
    setGlobalStorageValue(config.playerCount, getGlobalStorageValue(config.playerCount) + 1)
    if getGlobalStorageValue(config.playerCount) == config.maxPlayers then
      doBroadcastMessage(
        "The Zombie event is now full ["
          .. getGlobalStorageValue(config.playerCount)
          .. " players]! The event will soon start."
      )
    else
      doBroadcastMessage(
        getPlayerName(cid)
          .. " entered the Zombie event! Currently "
          .. getGlobalStorageValue(config.playerCount)
          .. " players have joined!",
        MESSAGE_STATUS_CONSOLE_RED
      )
    end
  else
    addEvent(tpBack, 1000, cid, fromPosition)
    doPlayerSendCancel(
      cid,
      "The event is full. There is already " .. config.maxPlayers .. " players participating in the quest."
    )
    return false
  end
  print(getStorage(config.playerCount) .. " Players in the zombie event.")
  return true
end

function tpBack(cid, fromPosition)
  doTeleportThing(cid, fromPosition, true)
  doSendMagicEffect(getPlayerPosition(cid), CONST_ME_TELEPORT)
end
