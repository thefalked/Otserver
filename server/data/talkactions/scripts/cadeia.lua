-- Sistema adaptado por FreaksOT --
-- Tempo em segundos que alguém ficará na prisão --
default_jail = 600
-- O group ID da permissão para alguém manda o outro para a cadeia. --
grouprequired = 5
-- StorageValue that the player gets --
jailedstoragevalue_time = 1338
jailedstoragevalue_bool = 1339
-- POSICAO DA CADEIA: --
jailpos = { x = 122, y = 48, z = 7 }
-- POSICAO DO LUGAR QUE ELE VOLTARÁ (RECOMENDADO TEMPO): --
unjailpos = { x = 160, y = 54, z = 7 }
-- auto kicker, dont edit
jail_list = {}
jail_list_work = 0

function checkJailList(param)
  for targetID, player in ipairs(jail_list) do
    if isPlayer(player) == TRUE then
      if getPlayerStorageValue(player, jailedstoragevalue_time) < os.time() then
        doTeleportThing(player, unjailpos, TRUE)
        setPlayerStorageValue(player, jailedstoragevalue_time, 0)
        setPlayerStorageValue(player, jailedstoragevalue_bool, 0)
        table.remove(jail_list, targetID)
        doPlayerSendTextMessage(player, MESSAGE_STATUS_CONSOLE_ORANGE, "Voc\234 foi chutado da pris\227o! At\233 logo")
      end
    else
      table.remove(jail_list, targetID)
    end
  end
  -- O8: only reschedule while someone is jailed
  if #jail_list > 0 then
    addEvent(checkJailList, 1000, {})
  else
    jail_list_work = 0
  end
end

function onSay(cid, words, param)
  if jail_list_work == 0 then
    jail_list_work = addEvent(checkJailList, 1000, {})
  end
  if param == "" and (words == "!unjail" or words == "/unjail") then
    if getPlayerStorageValue(cid, jailedstoragevalue_time) > os.time() then
      doPlayerSendTextMessage(
        cid,
        MESSAGE_INFO_DESCR,
        "Voc\234 est\225 preso at\233 "
          .. os.date("%H:%M:%S", getPlayerStorageValue(cid, jailedstoragevalue_time))
          .. " (Agora s\227o: "
          .. os.date("%H:%M:%S", os.time())
          .. ")."
      )
    else
      if getPlayerStorageValue(cid, jailedstoragevalue_bool) == 1 then
        table.insert(jail_list, cid)
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc\234 vai ser expulso da pris\227o em um segundo.")
      else
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc\234 n\227o est\225 preso.")
      end
    end
    return TRUE
  end
  local jail_time = -1
  for word in string.gmatch(tostring(param), "(%w+)") do
    if tostring(tonumber(word)) == word then
      jail_time = tonumber(word)
    end
  end
  local isplayer = getPlayerByName(param)
  if isPlayer(isplayer) ~= TRUE then
    isplayer = getPlayerByName(string.sub(param, string.len(jail_time) + 1))
    if isPlayer(isplayer) ~= TRUE then
      isplayer = getPlayerByName(string.sub(param, string.len(jail_time) + 2))
      if isPlayer(isplayer) ~= TRUE then
        isplayer = getPlayerByName(string.sub(param, string.len(jail_time) + 3))
      end
    end
  end
  if jail_time ~= -1 then
    jail_time = jail_time * 60
  else
    jail_time = default_jail
  end
  if words == "!jail" or words == "/jail" then
    if getPlayerGroupId(cid) >= grouprequired then
      if isPlayer(isplayer) == TRUE then
        doTeleportThing(isplayer, jailpos, TRUE)
        setPlayerStorageValue(isplayer, jailedstoragevalue_time, os.time() + jail_time)
        setPlayerStorageValue(isplayer, jailedstoragevalue_bool, 1)
        table.insert(jail_list, isplayer)
        doPlayerSendTextMessage(
          cid,
          MESSAGE_INFO_DESCR,
          "Voc\234 est\225 preso "
            .. getCreatureName(isplayer)
            .. " at\233 "
            .. os.date("%H:%M:%S", getPlayerStorageValue(isplayer, jailedstoragevalue_time))
            .. " (Agora s\227o: "
            .. os.date("%H:%M:%S", os.time())
            .. ")."
        )
        doPlayerSendTextMessage(
          isplayer,
          MESSAGE_INFO_DESCR,
          "Voc\234 foi preso por "
            .. getCreatureName(cid)
            .. " at\233 "
            .. os.date("%H:%M:%S", getPlayerStorageValue(isplayer, jailedstoragevalue_time))
            .. " (Agora s\227o: "
            .. os.date("%H:%M:%S", os.time())
            .. ")."
        )
        return TRUE
      else
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "O player com este nome n\227o existe ou est\225 offline.")
        return FALSE
      end
    else
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc\234 n\227o pode libertar outros jogadores.")
      return FALSE
    end
  elseif words == "!unjail" or words == "/unjail" then
    if getPlayerGroupId(cid) >= grouprequired then
      if isPlayer(isplayer) == TRUE then
        doTeleportThing(isplayer, unjailpos, TRUE)
        setPlayerStorageValue(isplayer, jailedstoragevalue_time, 0)
        setPlayerStorageValue(isplayer, jailedstoragevalue_bool, 0)
        table.remove(jail_list, targetID)
        doPlayerSendTextMessage(
          isplayer,
          MESSAGE_STATUS_CONSOLE_ORANGE,
          getCreatureName(cid) .. "vou deixar voc\234 sair da pris\227o!"
        )
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc\234 est\225 solto " .. getCreatureName(isplayer) .. ".")
      else
        doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "O player com este nome n\227o existe ou est\225 offline.")
        return FALSE
      end
    else
      doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Voc\234 n\227o pode libertar outros jogadores.")
      return FALSE
    end
  end
  return FALSE
end
