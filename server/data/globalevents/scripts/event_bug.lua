-- Countdown 5..1 then spawn Event Bug at a random temple spot.
-- Despawns if not killed in time.
local config = {
  monsterName = "Event Bug",
  bugCidStorage = 2005, -- live Event Bug creature id
  positions = {
    { x = 155, y = 57, z = 7 },
    { x = 138, y = 54, z = 7 },
    { x = 136, y = 41, z = 7 },
    { x = 158, y = 37, z = 7 },
    { x = 183, y = 58, z = 7 },
  },
  checkRadius = 8, -- spectators around the live bug, not spawn tiles
  lifetimeMinutes = 15,
  countdownMinutes = 5,
  remainingWarnMinutes = 3, -- last N minutes of the fight
  areaName = "the temple area",
}

local function clearEventBugState(cid)
  setGlobalStorageValue(config.bugCidStorage, 0)
  if EventBugDamagers and cid then
    EventBugDamagers[cid] = nil
  end
end

local function getLiveEventBug()
  local cid = getGlobalStorageValue(config.bugCidStorage)
  if not cid or cid < 1 or not isCreature(cid) then
    return nil
  end
  if getCreatureName(cid) ~= config.monsterName then
    return nil
  end
  return cid
end

local function eventBugAlive()
  local cid = getLiveEventBug()
  if not cid then
    return false
  end
  local pos = getCreaturePosition(cid)
  local specs = getSpectators(pos, config.checkRadius, config.checkRadius, false)
  if not specs then
    return false
  end
  for _, uid in pairs(specs) do
    if isMonster(uid) and getCreatureName(uid) == config.monsterName then
      return true
    end
  end
  return false
end

function despawnEventBug(cid)
  if isCreature(cid) and getCreatureName(cid) == config.monsterName then
    doRemoveCreature(cid)
    doBroadcastMessage("[Event Bug] Time is up! The Event Bug escaped. Try again next time.", MESSAGE_STATUS_WARNING)
  end
  clearEventBugState(cid)
end

function announceEventBugCountdown(minutesLeft)
  if eventBugAlive() then
    return
  end
  local unit = minutesLeft == 1 and "minute" or "minutes"
  doBroadcastMessage(
    "[Event Bug] The Event Bug appears around " .. config.areaName .. " in " .. minutesLeft .. " " .. unit .. "!",
    MESSAGE_STATUS_WARNING
  )
end

function announceEventBugRemaining(minutesLeft, cid)
  if not isCreature(cid) or getCreatureName(cid) ~= config.monsterName then
    return
  end
  local unit = minutesLeft == 1 and "minute" or "minutes"
  doBroadcastMessage(
    "[Event Bug] "
      .. minutesLeft
      .. " "
      .. unit
      .. " remaining! Find it around "
      .. config.areaName
      .. " before it escapes!",
    MESSAGE_STATUS_WARNING
  )
end

function spawnEventBug()
  if eventBugAlive() then
    doBroadcastMessage(
      "[Event Bug] The Event Bug is still alive somewhere around " .. config.areaName .. "! Find it and finish it!",
      MESSAGE_STATUS_WARNING
    )
    return
  end

  local pos = config.positions[math.random(1, #config.positions)]
  local cid = doSummonCreature(config.monsterName, pos)
  if not cid or cid == false then
    print("[Event Bug] Failed to summon at " .. pos.x .. "," .. pos.y .. "," .. pos.z)
    return
  end

  setGlobalStorageValue(config.bugCidStorage, cid)
  EventBugDamagers = EventBugDamagers or {}
  EventBugDamagers[cid] = {}

  doSendMagicEffect(pos, CONST_ME_GROUNDSHAKER)
  doBroadcastMessage(
    "[Event Bug] Event started! A giant Event Bug appeared around "
      .. config.areaName
      .. "! You have "
      .. config.lifetimeMinutes
      .. " minutes. Group up, find it, and kill it for shared rewards!",
    MESSAGE_STATUS_WARNING
  )
  for minutesLeft = config.remainingWarnMinutes, 1, -1 do
    local delay = (config.lifetimeMinutes - minutesLeft) * 60 * 1000
    addEvent(announceEventBugRemaining, delay, minutesLeft, cid)
  end
  addEvent(despawnEventBug, config.lifetimeMinutes * 60 * 1000, cid)
end

function onTime()
  if eventBugAlive() then
    doBroadcastMessage(
      "[Event Bug] The Event Bug is still alive somewhere around " .. config.areaName .. "! Find it and finish it!",
      MESSAGE_STATUS_WARNING
    )
    return true
  end

  -- 5, 4, 3, 2, 1 then spawn ("Event started")
  for minutesLeft = config.countdownMinutes, 1, -1 do
    local delay = (config.countdownMinutes - minutesLeft) * 60 * 1000
    addEvent(announceEventBugCountdown, delay, minutesLeft)
  end
  addEvent(spawnEventBug, config.countdownMinutes * 60 * 1000)
  return true
end
