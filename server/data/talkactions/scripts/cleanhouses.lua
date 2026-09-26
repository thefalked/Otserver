local function houseHasRemovableLoot(houseId)
  local info = getHouseInfo(houseId, false)
  if not info or not info.tiles then
    return false
  end

  for _, tilePos in pairs(info.tiles) do
    local count = getTileThingByPos({ x = tilePos.x, y = tilePos.y, z = tilePos.z, stackpos = -1 })
    if type(count) == "number" then
      for stackpos = 0, count - 1 do
        local thing = getTileThingByPos({ x = tilePos.x, y = tilePos.y, z = tilePos.z, stackpos = stackpos })
        if thing and thing.uid and thing.uid > 0 and thing.itemid and thing.itemid > 0 then
          local itemInfo = getItemInfo(thing.itemid)
          if itemInfo and itemInfo.pickupable then
            return true
          end
          if isContainer(thing.uid) and getContainerSize(thing.uid) > 0 then
            return true
          end
        end
      end
    end
  end
  return false
end

function onSay(cid, words, param, channel)
  local houses = getTownHouses()
  if not houses then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No houses found.")
    return true
  end

  local confirm = tostring(param or ""):lower() == "confirm"
  local free = 0
  local dirty = 0
  local cleaned = 0

  for _, houseId in pairs(houses) do
    local owner = getHouseOwner(houseId)
    if not owner or owner == 0 then
      free = free + 1
      if houseHasRemovableLoot(houseId) then
        dirty = dirty + 1
        if confirm and doCleanHouse(houseId) then
          cleaned = cleaned + 1
        end
      end
    end
  end

  if not confirm then
    doPlayerSendTextMessage(
      cid,
      MESSAGE_STATUS_CONSOLE_BLUE,
      "Free houses: " .. free .. ". With removable loot: " .. dirty .. ". Type: /cleanhouses confirm"
    )
    return true
  end

  if cleaned > 0 then
    doSaveServer(true)
  end

  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "Ran cleanup on " .. cleaned .. " free house(s) with loot (of " .. dirty .. " dirty / " .. free .. " free)."
  )
  print(
    "> "
      .. getCreatureName(cid)
      .. " ran /cleanhouses: cleaned "
      .. cleaned
      .. " (dirty "
      .. dirty
      .. ", free "
      .. free
      .. ")."
  )
  return true
end
