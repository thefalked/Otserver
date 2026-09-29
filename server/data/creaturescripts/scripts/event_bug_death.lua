-- Damagers only. Items drop on the map if the backpack is full.
EventBugDamagers = EventBugDamagers or {}

local config = {
  bugCidStorage = 2005,
  nuggetId = 2157,
  nuggetCount = 50,
  weapons = {
    7407, -- Master Sword
    3962, -- Master Axe
    7450, -- Master Club
    3965, -- Master Spear
    8922, -- Master Wand
    7735, -- Master Rod
  },
  masterSet = {
    6096, -- Master Helmet
    6095, -- Master Armor
    5918, -- Master Legs
    5462, -- Master Boots
    6433, -- Master Shield
  },
  doubleXpId = 9109,
}

local function giveItemDropOk(uid, itemId, count)
  count = count or 1
  if isItemStackable(itemId) then
    local item = doCreateItemEx(itemId, count)
    doPlayerAddItemEx(uid, item, true)
    return
  end
  for _ = 1, count do
    local item = doCreateItemEx(itemId, 1)
    doPlayerAddItemEx(uid, item, true)
  end
end

-- Equal weight: each weapon(+nuggets), Master set, and Double Xp are one option each.
local function giveRandomReward(uid)
  local roll = math.random(1, #config.weapons + 2)
  if roll <= #config.weapons then
    giveItemDropOk(uid, config.weapons[roll], 1)
    giveItemDropOk(uid, config.nuggetId, config.nuggetCount)
    doPlayerSendTextMessage(
      uid,
      MESSAGE_EVENT_ADVANCE,
      "Event Bug reward: 1 weapon + " .. config.nuggetCount .. " gold nuggets."
    )
    return
  end
  if roll == #config.weapons + 1 then
    for _, itemId in pairs(config.masterSet) do
      giveItemDropOk(uid, itemId, 1)
    end
    doPlayerSendTextMessage(
      uid,
      MESSAGE_EVENT_ADVANCE,
      "Event Bug reward: full Master set (helmet, armor, legs, boots, shield)."
    )
    return
  end
  giveItemDropOk(uid, config.doubleXpId, 1)
  doPlayerSendTextMessage(uid, MESSAGE_EVENT_ADVANCE, "Event Bug reward: Double Xp.")
end

function onStatsChange(cid, attacker, type, combat, value)
  if type ~= STATSCHANGE_HEALTHLOSS then
    return true
  end
  if not isPlayer(attacker) then
    return true
  end
  EventBugDamagers[cid] = EventBugDamagers[cid] or {}
  EventBugDamagers[cid][attacker] = true
  return true
end

function onDeath(cid, corpse, deathList)
  local damagers = EventBugDamagers[cid] or {}
  local rewarded = 0
  local killerName = "someone"

  if type(deathList) == "table" then
    for _, uid in ipairs(deathList) do
      if isCreature(uid) then
        killerName = getCreatureName(uid)
        break
      end
    end
  end

  for uid, _ in pairs(damagers) do
    if isPlayer(uid) then
      giveRandomReward(uid)
      rewarded = rewarded + 1
    end
  end

  EventBugDamagers[cid] = nil
  setGlobalStorageValue(config.bugCidStorage, 0)

  doBroadcastMessage(
    "[Event Bug] The Event Bug was slain by "
      .. killerName
      .. "! "
      .. rewarded
      .. " player(s) who dealt damage received rewards.",
    MESSAGE_STATUS_WARNING
  )
  return true
end
