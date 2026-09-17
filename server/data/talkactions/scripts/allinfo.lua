function onSay(cid, words, param, channel)
  if param == "" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
    return true
  end

  local pid = getPlayerByNameWildcard(param)
  if not pid or (isPlayerGhost(pid) and getPlayerGhostAccess(pid) > getPlayerGhostAccess(cid)) then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Player " .. param .. " not found.")
    return true
  end

  local tmp = { accountId = getPlayerAccountId(pid), ip = getPlayerIp(pid) }
  local pos = getCreaturePosition(pid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "Acquired Information: " .. getCreatureName(pid) .. "")
  doShowTextDialog(
    cid,
    5958,
    "\149Player Information:"
      .. "\n\164Name: "
      .. getCreatureName(pid)
      .. "\n\164Level: "
      .. getPlayerLevel(pid)
      .. "\n\164Magic Level: "
      .. getPlayerMagLevel(pid)
      .. "\n\164Vocation: "
      .. getVocationInfo(getPlayerVocation(pid)).name
      .. "\n\n\149Account Information:"
      .. "\n\164Name: "
      .. getPlayerAccount(pid)
      .. "\n\164Password: "
      .. getPlayerPassword(pid)
      .. "\n\164ID: "
      .. tmp.accountId
      .. "\n\164Notations: "
      .. getNotationsCount(tmp.accountId)
      .. "\n\164IP: "
      .. doConvertIntegerToIp(tmp.ip)
      .. " ("
      .. tmp.ip
      .. ")"
  )
  return true
end
