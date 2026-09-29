-- PvP bounty: every 15 min pick one Vip9 player in open PvP.
local config = {
  storage = 2100, -- bounty target player GUID
  vip9Storage = 13589,
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
  if getPlayerStorageValue(tid, config.vip9Storage) == -1 then
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

  local list = {}
  for _, tid in ipairs(getPlayersOnline()) do
    if isEligible(tid) then
      list[#list + 1] = tid
    end
  end
  if #list == 0 then
    return true
  end

  local target = list[math.random(1, #list)]
  setGlobalStorageValue(config.storage, getPlayerGUID(target))
  doBroadcastMessage(
    "[BOUNTY] " .. playerLabel(target) .. " has a bounty on their head for 15 minutes!",
    MESSAGE_STATUS_CONSOLE_RED
  )
  return true
end
