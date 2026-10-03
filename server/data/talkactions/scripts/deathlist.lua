function onSay(cid, words, param, channel)
  if param == "" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
    return true
  end

  local displayLimit = 10
  local target = db.getResult("SELECT `name`, `id` FROM `players` WHERE `name` = " .. db.escapeString(param) .. ";")
  if target:getID() == -1 then
    doPlayerSendCancel(cid, "A player with that name does not exist.")
    return true
  end

  local targetName = target:getDataString("name")
  local targetGUID = target:getDataInt("id")
  target:free()

  local deaths = db.getResult(
    "SELECT `id`, `date`, `level` FROM `player_deaths` WHERE `player_id` = "
      .. targetGUID
      .. " ORDER BY `date` DESC LIMIT "
      .. displayLimit
      .. ";"
  )

  local list = {}
  if deaths:getID() ~= -1 then
    repeat
      table.insert(list, {
        id = deaths:getDataInt("id"),
        date = deaths:getDataInt("date"),
        level = deaths:getDataInt("level"),
      })
    until not deaths:next()
    deaths:free()
  end

  local str = ""
  if #list == 0 then
    str = "No deaths recorded."
  else
    for _, death in ipairs(list) do
      local killers = db.getResult(
        "SELECT ek.name AS monster_name, p.name AS player_name "
          .. "FROM killers k "
          .. "LEFT JOIN environment_killers ek ON k.id = ek.kill_id "
          .. "LEFT JOIN player_killers pk ON k.id = pk.kill_id "
          .. "LEFT JOIN players p ON p.id = pk.player_id "
          .. "WHERE k.death_id = "
          .. death.id
          .. " ORDER BY k.final_hit DESC, k.id ASC;"
      )

      local killed = "unknown"
      if killers:getID() ~= -1 then
        local parts = {}
        repeat
          local playerName = killers:getDataString("player_name")
          local monsterName = killers:getDataString("monster_name")
          local part = nil
          if playerName ~= "" then
            if monsterName ~= "" then
              part = monsterName .. " summoned by " .. playerName
            else
              part = playerName
            end
          elseif monsterName ~= "" then
            part = monsterName
          end
          if part then
            table.insert(parts, part)
          end
        until not killers:next()
        killers:free()

        if #parts > 0 then
          killed = parts[1]
          for i = 2, #parts do
            killed = killed .. " and by " .. parts[i]
          end
        end
      end

      if str ~= "" then
        str = str .. "\n"
      end
      str = str
        .. " "
        .. os.date("%d %B %Y %X", death.date)
        .. " Died at Level "
        .. death.level
        .. " by "
        .. killed
        .. "."
    end
  end

  doPlayerPopupFYI(cid, "Deathlist for player: " .. targetName .. ".\n\n" .. str)
  return true
end
