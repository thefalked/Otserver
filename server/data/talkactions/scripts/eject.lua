function onSay(cid, words, param)
  local position = getPlayerPosition(cid)
  local lookDir = getPlayerLookDir(cid)
  local positions = {
    x = position.x,
    y = position.y,
    z = position.z,
  }

  if lookDir == 0 then
    positions.y = positions.y - 1
  elseif lookDir == 1 then
    positions.x = positions.x + 1
  elseif lookDir == 2 then
    positions.y = positions.y + 1
  elseif lookDir == 3 then
    positions.x = positions.x - 1
  end

  local houseId = getHouseFromPos(positions)
  if not houseId or houseId == false then
    doPlayerSendTextMessage(cid, 27, "Voc\234 precisa estar na frente a porta da casa para usar o comando.")
    return true
  end

  local inactiveSeconds = tonumber(getConfigValue("houseCleanOld")) or 0
  if inactiveSeconds <= 0 then
    doPlayerSendTextMessage(cid, 27, "A recuperacao de casas esta desativada.")
    return true
  end

  local own = getHouseOwner(houseId)
  if not own or own == 0 then
    doPlayerSendTextMessage(cid, 27, "Esta casa ja esta sem dono.")
    return true
  end

  if getPlayerByGUID(own) then
    doPlayerSendTextMessage(cid, 27, "O proprietario desta casa ainda esta ativo no servidor, tente outra casa.")
    return true
  end

  local qry = db.getResult(
    "SELECT GREATEST(IFNULL(`lastlogout`, 0), IFNULL(`lastlogin`, 0)) AS `lastactive`"
      .. " FROM `players` WHERE `id` = "
      .. own
  )

  -- Missing player row = orphan house, allow reclaim.
  local inactive = false
  if qry:getID() == -1 then
    inactive = true
  else
    local last = tonumber(qry:getDataInt("lastactive")) or 0
    qry:free()
    inactive = last < (os.time() - inactiveSeconds)
  end

  if not inactive then
    local days = math.floor(inactiveSeconds / (24 * 60 * 60))
    doPlayerSendTextMessage(
      cid,
      27,
      "O proprietario ainda nao ficou offline por " .. days .. " dia(s). Tente outra casa."
    )
    return true
  end

  if not doCleanHouse(houseId) then
    doPlayerSendTextMessage(cid, 27, "Nao foi possivel limpar esta casa. Tente novamente.")
    return true
  end

  local cleared = setHouseOwner(houseId, 0, false)
  doSaveServer(true)
  if cleared then
    doPlayerSendTextMessage(cid, 27, "A Casa agora esta sem dono, voc\234 ou outro jogador pode compra-la")
  else
    doPlayerSendTextMessage(
      cid,
      27,
      "Os itens foram movidos ao depot, mas nao foi possivel liberar o dono da casa. Avise um administrador."
    )
  end
  return true
end
