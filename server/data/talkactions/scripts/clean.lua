local cleanEvent = 0

function onSay(cid, words, param, channel)
  if param == "" then
    doCleanMap()
    return true
  end

  if param == "tile" then
    local removeLoaded, t = false, string.explode(param, ",")
    if t[2] then
      removeLoaded = getBooleanFromString(t[2])
    end

    doCleanTile(getCreaturePosition(cid), removeLoaded)
    return true
  end

  if not tonumber(param) then
    doPlayerSendCancel(cid, "Command requires numeric param.")
    return true
  end

  stopEvent(cleanEvent)
  prepareClean(tonumber(param), cid)
  return true
end

function prepareClean(minutes, cid)
  if minutes == 0 then
    doCleanMap()
  elseif minutes > 0 then
    if minutes == 1 then
      doBroadcastMessage("The OT will be cleaned in 1 minute. Pick up your items from the floor.")
    else
      doBroadcastMessage("The OT will be cleaned in " .. minutes .. " minutes.")
    end

    cleanEvent = addEvent(prepareClean, 60000, minutes - 1, cid)
  end
end
