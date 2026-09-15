function onSay(cid, words, param)
  -- O1: God+ only (XML access=5); require online target
  local access = 5
  local days = 30

  if getPlayerAccess(cid) < access then
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You cannot use this command.")
    return true
  end

  if param == nil or param == "" then
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Usage: /addvip PlayerName")
    return true
  end

  local player = getPlayerByName(param)
  if not player or isPlayer(player) ~= TRUE then
    doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Player not found or offline.")
    return true
  end

  local daysvalue = days * 3600 * 24
  local storageplayer = getPlayerStorageValue(player, 29000)
  local timenow = os.time()
  local time
  if storageplayer == -1 or storageplayer == 0 then
    time = timenow + daysvalue
  else
    time = storageplayer + daysvalue
  end

  doPlayerSendTextMessage(
    player,
    MESSAGE_INFO_DESCR,
    "Foram adcionados " .. days .. " dias de VIP no seu character."
  )
  setPlayerStorageValue(player, 29000, time)
  local quantity = math.floor((getPlayerStorageValue(player, 29000) - timenow) / (3600 * 24))
  doPlayerSendTextMessage(player, MESSAGE_INFO_DESCR, "Você tem " .. quantity .. " dias de VIP restantes.")
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "VIP added to " .. getCreatureName(player) .. ".")
  return true
end
