-- PvP bounty: every 15 min pick one level 4000+ player in open PvP.
local config = {
  storage = 2100, -- bounty target player GUID
  lastStorage = 2101, -- last pick (survives claim clear; avoids back-to-back)
  minLevel = 4000, -- same as Vip7 entry gate
  trainerRadius = 5,
}

local function playerLabel(cid)
  return getCreatureName(cid) .. " (level " .. getPlayerLevel(cid) .. ")"
end

local function nearTrainer(cid)
  local pos = getCreaturePosition(cid)
  local specs = getSpectators(pos, config.trainerRadius, config.trainerRadius, false)
  if not specs then
    return false
  end
  -- Covers Vip Trainer, Training Monk, Treiner ("Saco de Pancada"), Trainedr, typos.
  local hints = { "trainer", "training", "trainig", "treiner", "trainedr", "saco", "pancada" }
  for _, uid in pairs(specs) do
    if isMonster(uid) then
      local name = string.lower(getCreatureName(uid))
      for _, hint in ipairs(hints) do
        if string.find(name, hint, 1, true) then
          return true
        end
      end
    end
  end
  return false
end

local function isEligible(tid)
  if
    not hasPlayerClient(tid)
    or isPlayerGhost(tid)
    or getPlayerAccountManager(tid) ~= MANAGER_NONE
    or getPlayerAccess(tid) >= 3
  then
    return false
  end
  if getPlayerLevel(tid) < config.minLevel then
    return false
  end
  local tile = getTileInfo(getCreaturePosition(tid))
  if not tile or tile.protection or tile.house or tile.optional then
    return false
  end
  if nearTrainer(tid) then
    return false
  end
  return true
end

function onThink(interval, lastExecution)
  setGlobalStorageValue(config.storage, 0)

  local lastGuid = getGlobalStorageValue(config.lastStorage)
  local list, fallback = {}, {}
  for _, tid in ipairs(getPlayersOnline()) do
    if isEligible(tid) then
      fallback[#fallback + 1] = tid
      if getPlayerGUID(tid) ~= lastGuid then
        list[#list + 1] = tid
      end
    end
  end
  if #list == 0 then
    list = fallback
  end
  if #list == 0 then
    return true
  end

  local target = list[math.random(1, #list)]
  local guid = getPlayerGUID(target)
  setGlobalStorageValue(config.storage, guid)
  setGlobalStorageValue(config.lastStorage, guid)
  doBroadcastMessage(
    "[BOUNTY] " .. playerLabel(target) .. " has a bounty on their head for 15 minutes!",
    MESSAGE_STATUS_CONSOLE_RED
  )
  return true
end
