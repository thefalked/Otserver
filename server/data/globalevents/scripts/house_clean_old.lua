local function cleanInactiveHouses()
  local cleanAfter = tonumber(getConfigValue("houseCleanOld")) or 0
  if cleanAfter <= 0 then
    return true
  end

  local worldId = tonumber(getConfigValue("worldId")) or 0
  local cutoff = os.time() - cleanAfter
  local result = db.getResult(
    "SELECT `h`.`id` AS `houseid`, `h`.`owner` AS `owner` FROM `houses` AS `h`"
      .. " LEFT JOIN `players` AS `p` ON `p`.`id` = `h`.`owner`"
      .. " WHERE `h`.`world_id` = "
      .. worldId
      .. " AND `h`.`owner` > 0 AND (`p`.`id` IS NULL OR GREATEST("
      .. "IFNULL(`p`.`lastlogout`, 0), IFNULL(`p`.`lastlogin`, 0)) < "
      .. cutoff
      .. ");"
  )
  if result:getID() == -1 then
    return true
  end

  local toClear = {}
  repeat
    local houseId = result:getDataInt("houseid")
    local owner = result:getDataInt("owner")
    if not getPlayerByGUID(owner) then
      table.insert(toClear, houseId)
    end
  until not result:next()
  result:free()

  local cleared = 0
  local cleanFailed = 0
  local cleanedUnowned = 0
  for i = 1, #toClear do
    local houseId = toClear[i]
    -- Clean while owner is still set (moves loot to depot), then clear owner.
    if not doCleanHouse(houseId) then
      cleanFailed = cleanFailed + 1
    elseif setHouseOwner(houseId, 0, false) then
      cleared = cleared + 1
    else
      cleanedUnowned = cleanedUnowned + 1
      print("> House " .. houseId .. " was cleaned but owner clear failed.")
    end
  end

  if cleared > 0 or cleanedUnowned > 0 then
    doSaveServer()
  end
  if cleared > 0 then
    print("> Cleared " .. cleared .. " inactive house(s).")
  end
  if cleanFailed > 0 then
    print("> Failed to clean " .. cleanFailed .. " inactive house(s).")
  end
  return true
end

function onThink(interval)
  return cleanInactiveHouses()
end
