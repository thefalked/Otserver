-- Claim PvP bounty on last-hit kill. Same IP cannot claim. Timer not restarted.
local config = {
  storage = 2100, -- bounty target player GUID
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

local function playerLabel(cid)
  return getCreatureName(cid) .. " (level " .. getPlayerLevel(cid) .. ")"
end

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

-- Same pool as Event Bug. Returns short text for the chat broadcast.
local function giveRandomReward(uid)
  local roll = math.random(1, #config.weapons + 2)
  if roll <= #config.weapons then
    giveItemDropOk(uid, config.weapons[roll], 1)
    giveItemDropOk(uid, config.nuggetId, config.nuggetCount)
    return "1 Master weapon + " .. config.nuggetCount .. " gold nuggets"
  end
  if roll == #config.weapons + 1 then
    for _, itemId in pairs(config.masterSet) do
      giveItemDropOk(uid, itemId, 1)
    end
    return "full Master set (helmet, armor, legs, boots, shield)"
  end
  giveItemDropOk(uid, config.doubleXpId, 1)
  return "Double Xp"
end

function onKill(cid, target)
  if not isPlayer(cid) or not isPlayer(target) then
    return true
  end

  local bountyGuid = getGlobalStorageValue(config.storage)
  if not bountyGuid or bountyGuid < 1 or getPlayerGUID(target) ~= bountyGuid then
    return true
  end

  if getPlayerIp(cid) == getPlayerIp(target) then
    doPlayerSendTextMessage(
      cid,
      MESSAGE_STATUS_CONSOLE_RED,
      "[BOUNTY] You killed "
        .. playerLabel(target)
        .. " from the same IP and cannot claim. You cannot claim your own account."
    )
    return true
  end

  local rewardText = giveRandomReward(cid)
  setGlobalStorageValue(config.storage, 0)
  doBroadcastMessage(
    "[BOUNTY] "
      .. playerLabel(cid)
      .. " claimed the bounty on "
      .. playerLabel(target)
      .. "! Reward: "
      .. rewardText
      .. ". Next bounty on the usual 15-minute schedule.",
    MESSAGE_STATUS_CONSOLE_RED
  )
  return true
end
