-- Script Vip Sytem 1.0 --
function onStepIn(cid, item, position, fromPosition)
  local config = {
    msgDenied = "Voc\234 n\227o e vip ,para adqrir sua vip fale !buyvip que custa 1KK",
    msgWelcome = "Seja Bem Vindo a \193rea vip.",
  }

  if getPlayerStorageValue(cid, 13545) - os.time() <= 0 then
    doTeleportThing(cid, fromPosition, true)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, config.msgDenied)
    doSendMagicEffect(getThingPos(cid), CONST_ME_MAGIC_BLUE)
    return TRUE
  end
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, config.msgWelcome)
  return TRUE
end
