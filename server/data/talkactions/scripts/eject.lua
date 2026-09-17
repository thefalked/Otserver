function onSay(cid, words, param)
  local position = getPlayerPosition(cid)

  if getPlayerLookDir(cid) == 0 then
    positions = { x = position.x, y = position.y - 1, z = position.z }
  elseif getPlayerLookDir(cid) == 1 then
    positions = { x = position.x + 1, y = position.y, z = position.z }
  elseif getPlayerLookDir(cid) == 2 then
    positions = { x = position.x, y = position.y + 1, z = position.z }
  elseif getPlayerLookDir(cid) == 3 then
    positions = { x = position.x - 1, y = position.y, z = position.z }
  end

  if getHouseFromPos(positions) == false then
    doPlayerSendTextMessage(cid, 27, "Voc\234 precisa estar na frente a porta da casa para usar o comando.")
    return true
  end

  -- Inactive threshold: 3 real days without login (see lastlogin check below).
  local inactiveDays = 3
  local inactiveSeconds = inactiveDays * 24 * 60 * 60
  local own = getHouseOwner(getHouseFromPos(positions))
  local qry = db.getResult("SELECT `lastlogin` FROM `players` WHERE `id` = " .. own)

  if qry:getID() ~= -1 then
    last = tonumber(qry:getDataInt("lastlogin"))
    if last < os.time() - inactiveSeconds then
      -- Clear owner (same as leavehouse.lua); NO_OWNER_PHRASE was undefined here (O12).
      setHouseOwner(getHouseFromPos(positions), 0, true)
      doPlayerSendTextMessage(cid, 27, "A Casa agora esta sem dono, voc\234 ou outro jogador pode compra-la")
    end
    if last > os.time() - inactiveSeconds then
      doPlayerSendTextMessage(cid, 27, "O proprietario desta casa ainda esta ativo no servidor, tente outra casa.")
    end
  end
  return true
end
