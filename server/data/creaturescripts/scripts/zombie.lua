local config = {
  playerCount = 2001, -- Global storage for counting the players left/entered in the event
  startPlayerCountStorage = 2006, -- players when event started (set by zombie_event.lua)
  fullRewardMinPlayers = 4,

  goblet = 5805, -- gold goblet with winner name
  staminaPotion = 5468,
  moneyReward = { 2157, 100 }, -- gold nuggets (full reward)
  reducedMoneyReward = { 2157, 50 }, -- gold nuggets (2-3 players)
  vip9Weapons = {
    7391, -- Baiak Vip9 Sword
    7456, -- Baiak Vip9 Axe
    7425, -- Baiak Vip9 Mace
    7754, -- Baiak Vip9 Staff
    7367, -- Baiak Vip9 Spear
  },

  -- Should be same as in the globalevent!
  fromPosition = { x = 44, y = 514, z = 7 },
  toPosition = { x = 70, y = 539, z = 7 },
}

local function inZombieArena(cid)
  return isInArea(getCreaturePosition(cid), config.fromPosition, config.toPosition)
end

local function clearArenaMonsters()
  for x = config.fromPosition.x, config.toPosition.x do
    for y = config.fromPosition.y, config.toPosition.y do
      for z = config.fromPosition.z, config.toPosition.z do
        local areapos = { x = x, y = y, z = z, stackpos = 253 }
        local thing = getThingfromPos(areapos)
        if isMonster(thing.uid) then
          doRemoveCreature(thing.uid)
        end
      end
    end
  end
end

-- No logout while standing in the arena (waiting or mid-event).
function onLogout(cid, forceLogout)
  if not forceLogout and inZombieArena(cid) then
    doPlayerSendCancel(cid, "You cannot logout during the Zombie event.")
    return false
  end
  return true
end

-- Arena is non-PvP: players cannot attack each other there.
function onCombat(cid, target)
  if isPlayer(cid) and isPlayer(target) then
    if inZombieArena(cid) or inZombieArena(target) then
      return false
    end
  end
  return true
end

function onStatsChange(cid, attacker, type, combat, value)
  -- HEALTHLOSS and MANALOSS: utamo turns hits into mana. Armor-blocked hits never reach here.
  if type ~= STATSCHANGE_HEALTHLOSS and type ~= STATSCHANGE_MANALOSS then
    return true
  end
  if not isPlayer(cid) or not isMonster(attacker) then
    return true
  end
  if not inZombieArena(cid) then
    return true
  end

  local count = getGlobalStorageValue(config.playerCount)
  if count >= 2 then
    doBroadcastMessage(getPlayerName(cid) .. " Foi Comido Por Zombies!", MESSAGE_STATUS_CONSOLE_RED)
    local corpse = doCreateItem(3058, 1, getPlayerPosition(cid))
    doItemSetAttribute(
      corpse,
      "description",
      "You recognize "
        .. getCreatureName(cid)
        .. ". He was killed by a "
        .. string.lower(getCreatureName(attacker))
        .. "."
    )
    doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
    doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)), false)
    doSendMagicEffect(getPlayerPosition(cid), CONST_ME_TELEPORT)
    setGlobalStorageValue(config.playerCount, count - 1)
    return false
  elseif count == 1 then
    doBroadcastMessage(getPlayerName(cid) .. " Ganhou o Zombie Event! Parab\233ns!", MESSAGE_STATUS_WARNING)
    local goblet = doPlayerAddItem(cid, config.goblet, 1)
    doItemSetAttribute(goblet, "description", "Consedido A " .. getPlayerName(cid) .. " Por ganhar o Zombie event.")
    local corpse = doCreateItem(3058, 1, getPlayerPosition(cid))
    doItemSetAttribute(
      corpse,
      "description",
      "You recognize "
        .. getCreatureName(cid)
        .. ". He was killed by a "
        .. string.lower(getCreatureName(attacker))
        .. "."
    )
    doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
    doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)), false)
    doSendMagicEffect(getPlayerPosition(cid), CONST_ME_TELEPORT)

    local startedWith = getGlobalStorageValue(config.startPlayerCountStorage)
    if not startedWith or startedWith < 0 then
      startedWith = 0
    end
    if startedWith >= config.fullRewardMinPlayers then
      doPlayerAddItem(cid, config.vip9Weapons[math.random(1, #config.vip9Weapons)], 1)
      doPlayerAddItem(cid, config.moneyReward[1], config.moneyReward[2])
    else
      doPlayerAddItem(cid, config.staminaPotion, 1)
      doPlayerAddItem(cid, config.reducedMoneyReward[1], config.reducedMoneyReward[2])
    end

    clearArenaMonsters()
    setGlobalStorageValue(config.playerCount, 0)
    setGlobalStorageValue(config.startPlayerCountStorage, 0)
    return false
  end
  return true
end

-- Mid-event /reload: swap live Event Zombies to the armor-proof attack type.
if not _G.ZombieEventRefreshPending then
  _G.ZombieEventRefreshPending = true
  addEvent(function()
    _G.ZombieEventRefreshPending = nil
    local n = getGlobalStorageValue(config.playerCount)
    if not n or n < 2 then
      return
    end
    local removed = 0
    for x = config.fromPosition.x, config.toPosition.x do
      for y = config.fromPosition.y, config.toPosition.y do
        for z = config.fromPosition.z, config.toPosition.z do
          local thing = getThingfromPos({ x = x, y = y, z = z, stackpos = 253 })
          if isMonster(thing.uid) and getCreatureName(thing.uid) == "Event Zombie" then
            doRemoveCreature(thing.uid)
            removed = removed + 1
          end
        end
      end
    end
    for _ = 1, math.max(removed, 1) do
      local pos = {
        x = math.random(config.fromPosition.x, config.toPosition.x),
        y = math.random(config.fromPosition.y, config.toPosition.y),
        z = config.fromPosition.z,
      }
      doSummonCreature("Event Zombie", pos)
      doSendMagicEffect(pos, CONST_ME_MORTAREA)
    end
  end, 500)
end
