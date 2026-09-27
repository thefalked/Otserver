-- Shared reward for everyone near the Event Bug when it dies.
-- Each player rolls: one Baiakzik/Master weapon + 50 nuggets, OR a full Master set.
local config = {
  rewardRadius = 15,
  nuggetId = 2157,
  nuggetCount = 50,
  -- Baiakzik + Master weapons (one random pick)
  weapons = {
    7417, -- Baiakzik Sword
    8926, -- Baiakzik Axe
    7368, -- Baiakzik Star
    7451, -- Baiakzik Club
    7424, -- Baiakzik Staff
    2453, -- Master Vip Staff
    7432, -- Master Vip Club
    8849, -- Master Vip Crossbow
    7735, -- Master Rod
    8922, -- Master Wand
    2399, -- New Master Star
  },
  -- Master set (no weapon, no nuggets)
  masterSet = {
    6096, -- Master Helmet
    6095, -- Master Armor
    5918, -- Master Legs
    5462, -- Master Boots
    6433, -- Master Shield
  },
}

local function giveWeaponReward(uid)
  local weaponId = config.weapons[math.random(1, #config.weapons)]
  doPlayerAddItem(uid, weaponId, 1)
  doPlayerAddItem(uid, config.nuggetId, config.nuggetCount)
  doPlayerSendTextMessage(
    uid,
    MESSAGE_EVENT_ADVANCE,
    "Event Bug reward: 1 weapon + " .. config.nuggetCount .. " gold nuggets."
  )
end

local function giveMasterSetReward(uid)
  for _, itemId in pairs(config.masterSet) do
    doPlayerAddItem(uid, itemId, 1)
  end
  doPlayerSendTextMessage(
    uid,
    MESSAGE_EVENT_ADVANCE,
    "Event Bug reward: full Master set (helmet, armor, legs, boots, shield)."
  )
end

function onDeath(cid, corpse, lastHitKiller, mostDamageKiller)
  local pos = getCreaturePosition(cid)
  local specs = getSpectators(pos, config.rewardRadius, config.rewardRadius, false)
  local rewarded = 0

  if specs then
    for _, uid in pairs(specs) do
      if isPlayer(uid) then
        if math.random(1, 2) == 1 then
          giveWeaponReward(uid)
        else
          giveMasterSetReward(uid)
        end
        rewarded = rewarded + 1
      end
    end
  end

  local killerName = "someone"
  if lastHitKiller and isPlayer(lastHitKiller) then
    killerName = getCreatureName(lastHitKiller)
  elseif mostDamageKiller and isPlayer(mostDamageKiller) then
    killerName = getCreatureName(mostDamageKiller)
  end

  doBroadcastMessage(
    "[Event Bug] The Event Bug was slain by " .. killerName .. "! " .. rewarded .. " player(s) nearby received rewards.",
    MESSAGE_STATUS_WARNING
  )
  return true
end
