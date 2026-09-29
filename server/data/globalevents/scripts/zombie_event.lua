local config = {
  playerCount = 2001, -- Global storage for counting the players left/entered in the event
  zombieCount = 2002, -- Global storage for counting the zombies in the event
  teleportActionId = 2000, -- Action id of the teleport needed for the movement script
  teleportPosition = { x = 158, y = 52, z = 7 }, -- Where the teleport will be created
  teleportToPosition = { x = 56, y = 525, z = 7 }, -- Where the teleport will take you
  teleportId = 1387, -- Id of the teleport
  timeToStartEvent = 5, -- Minutes, after these minutes the teleport will be removed and the event will be declared started
  timeBetweenSpawns = 20, -- Seconds between each spawn of zombie
  zombieName = "Event Zombie", -- Must match monsters.xml name
  playersNeededToStartEvent = 2,
  tpOpenStorage = 2003,
  labelTokenStorage = 2004, -- bumps each open so old text loops die
  startPlayerCountStorage = 2006, -- players at start; <4 => reduced reward
  labelInterval = 1500,
  labelText = "Zombie Event",

  -- Should be the same as in the creaturescript!
  -- The zombies will spawn randomly inside this area
  fromPosition = { x = 44, y = 514, z = 7 }, -- top left cornor of the playground
  toPosition = { x = 70, y = 539, z = 7 }, -- bottom right cornor of the playground
}

local function getZombieTeleport()
  return getTileItemById(config.teleportPosition, config.teleportId)
end

local function removeZombieTeleport()
  local tp = getZombieTeleport()
  if tp and tp.uid and tp.uid > 0 then
    doRemoveItem(tp.uid)
  end
  setGlobalStorageValue(config.tpOpenStorage, 0)
end

function showZombieTpLabel(token)
  if getGlobalStorageValue(config.labelTokenStorage) ~= token then
    return
  end
  if getGlobalStorageValue(config.tpOpenStorage) ~= 1 then
    return
  end
  local tp = getZombieTeleport()
  if not tp or not tp.uid or tp.uid <= 0 then
    setGlobalStorageValue(config.tpOpenStorage, 0)
    return
  end
  doSendAnimatedText(config.teleportPosition, config.labelText, math.random(1, 255))
  addEvent(showZombieTpLabel, config.labelInterval, token)
end

function announceZombieCountdown(minutesLeft)
  if getGlobalStorageValue(config.tpOpenStorage) ~= 1 then
    return
  end
  local unit = minutesLeft == 1 and "minute" or "minutes"
  local joined = getGlobalStorageValue(config.playerCount)
  if not joined or joined < 0 then
    joined = 0
  end
  doBroadcastMessage(
    "[Zombie Event] Teleport closes in "
      .. minutesLeft
      .. " "
      .. unit
      .. "! Need "
      .. config.playersNeededToStartEvent
      .. " players to start (currently "
      .. joined
      .. "). Enter at the temple!",
    MESSAGE_STATUS_WARNING
  )
end

function onTime()
  removeZombieTeleport()

  local tp = doCreateTeleport(config.teleportId, config.teleportToPosition, config.teleportPosition)
  if not tp or tp == false then
    print(
      "[Zombie] Failed to create teleport at "
        .. config.teleportPosition.x
        .. ","
        .. config.teleportPosition.y
        .. ","
        .. config.teleportPosition.z
    )
    return true
  end

  doItemSetAttribute(tp, "aid", config.teleportActionId)
  setGlobalStorageValue(config.playerCount, 0)
  setGlobalStorageValue(config.zombieCount, 0)
  setGlobalStorageValue(config.startPlayerCountStorage, 0)
  setGlobalStorageValue(config.tpOpenStorage, 1)

  local token = getGlobalStorageValue(config.labelTokenStorage)
  if not token or token < 0 then
    token = 0
  end
  token = token + 1
  setGlobalStorageValue(config.labelTokenStorage, token)
  showZombieTpLabel(token)

  for minutesLeft = config.timeToStartEvent, 1, -1 do
    local delay = (config.timeToStartEvent - minutesLeft) * 60 * 1000
    addEvent(announceZombieCountdown, delay, minutesLeft)
  end
  addEvent(startEvent, config.timeToStartEvent * 1000 * 60)
  return true
end

function startEvent()
  removeZombieTeleport()

  local fromp, top = config.fromPosition, config.toPosition

  local joined = getGlobalStorageValue(config.playerCount)
  if joined >= config.playersNeededToStartEvent then
    setGlobalStorageValue(config.startPlayerCountStorage, joined)
    addEvent(spawnZombie, config.timeBetweenSpawns * 1000)
    doBroadcastMessage("Good luck in the zombie event people! The teleport has closed!", MESSAGE_STATUS_WARNING)

    for x = fromp.x, top.x do
      for y = fromp.y, top.y do
        for z = fromp.z, top.z do
          areapos = { x = x, y = y, z = z, stackpos = 253 }
          getPlayers = getThingfromPos(areapos)
          if isPlayer(getPlayers.uid) then
            doPlayerSendTextMessage(
              getPlayers.uid,
              MESSAGE_EVENT_ADVANCE,
              "The first zombie will spawn in " .. config.timeBetweenSpawns .. " seconds! Good luck!"
            )
          end
        end
      end
    end
  else
    doBroadcastMessage(
      "The Zombie event could not start because of to few players participating.\n At least "
        .. config.playersNeededToStartEvent
        .. " players is needed!",
      MESSAGE_STATUS_WARNING
    )
    for x = fromp.x, top.x do
      for y = fromp.y, top.y do
        for z = fromp.z, top.z do
          areapos = { x = x, y = y, z = z, stackpos = 253 }
          getPlayers = getThingfromPos(areapos)
          if isPlayer(getPlayers.uid) then
            doTeleportThing(getPlayers.uid, getTownTemplePosition(getPlayerTown(getPlayers.uid)), false)
            doSendMagicEffect(getPlayerPosition(getPlayers.uid), CONST_ME_TELEPORT)
          end
        end
      end
    end
    setGlobalStorageValue(config.playerCount, 0)
    setGlobalStorageValue(config.startPlayerCountStorage, 0)
  end
end

function spawnZombie()
  if getGlobalStorageValue(config.playerCount) >= 2 then
    pos = {
      x = math.random(config.fromPosition.x, config.toPosition.x),
      y = math.random(config.fromPosition.y, config.toPosition.y),
      z = math.random(config.fromPosition.z, config.toPosition.z),
    }
    doSummonCreature(config.zombieName, pos)
    doSendMagicEffect(pos, CONST_ME_MORTAREA)
    setGlobalStorageValue(config.zombieCount, getGlobalStorageValue(config.zombieCount) + 1)
    doBroadcastMessage(
      "A zombie has spawned! There is currently "
        .. getGlobalStorageValue(config.zombieCount)
        .. " zombies in the zombie event!",
      MESSAGE_STATUS_CONSOLE_RED
    )
    addEvent(spawnZombie, config.timeBetweenSpawns * 1000)
  end
end
