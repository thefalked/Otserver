local doors = {
  [4531] = { allowed = { 5, 9 }, base = 1, name = "Sorcerer's" },
  [4532] = { allowed = { 6, 10 }, base = 2, name = "Druid's" },
  [4533] = { allowed = { 7, 11 }, base = 3, name = "Paladin's" },
  [4534] = { allowed = { 8, 12 }, base = 4, name = "Knight's" },
}

function onUse(cid, item, frompos, item2, topos)
  local door = doors[item.actionid]
  if not door then
    return 0
  end

  local voc = getPlayerVocation(cid)
  if voc ~= door.allowed[1] and voc ~= door.allowed[2] then
    if voc == door.base then
      doPlayerSendTextMessage(cid, 22, "Voc\234 precisa de promotion para passar. Fale com Johnny e diga promote.")
    else
      doPlayerSendTextMessage(cid, 22, "Apenas " .. door.name .. " podem passar.")
    end
    return 1
  end

  local pos = getPlayerPosition(cid)
  if pos.x == topos.x then
    if pos.y < topos.y then
      pos.y = topos.y + 1
    else
      pos.y = topos.y - 1
    end
  elseif pos.y == topos.y then
    if pos.x < topos.x then
      pos.x = topos.x + 1
    else
      pos.x = topos.x - 1
    end
  else
    doPlayerSendTextMessage(cid, 22, "Voc\234 precisa estar na frente da porta.")
    return 1
  end

  doTeleportThing(cid, pos)
  doSendMagicEffect(topos, 12)
  return 1
end
