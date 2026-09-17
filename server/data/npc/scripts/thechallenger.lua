local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}
function onCreatureAppear(cid)
  npcHandler:onCreatureAppear(cid)
end
function onCreatureDisappear(cid)
  npcHandler:onCreatureDisappear(cid)
end
function onCreatureSay(cid, type, msg)
  npcHandler:onCreatureSay(cid, type, msg)
end
function onThink()
  npcHandler:onThink()
end
function creatureSayCallback(cid, type, msg)
  if not npcHandler:isFocused(cid) then
    return false
  end
  local crystalid = 2349
  local storage = 2349
  local getstorage = getPlayerStorageValue(cid, storage)
  local sorrymessage = "Desculpe, voc\234 n\227o tem todos os Blue note necess\225rios para completar as miss\245es..."
  local talkUser = NPCHANDLER_CONVBEHAVIOR == CONVERSATION_DEFAULT and 0 or cid
  if msgcontains(msg, "Blue Note") then
    if getstorage == 6 then
      npcHandler:say("Voc\234 jah completou a quest", cid)
    elseif getstorage < 6 then
      npcHandler:say("Voc\234 tem todos os Blue note necess\225rios?", cid)
      talkState[talkUser] = 1
    end
  elseif msgcontains(msg, "quest") then
    if getstorage < 1 then
      npcHandler:say("Voc\234 precisa de 1 {Blue note} para come\231ar.", cid)
    elseif getstorage == 1 then
      npcHandler:say("Voc\234 esta na segunda miss\227o e precisa de mais 1 Blue note para continuar.", cid)
    elseif getstorage == 2 then
      npcHandler:say("Voc\234 esta na terceira miss\227o e precisa de mais 1 Blue note para continuar.", cid)
    elseif getstorage == 3 then
      npcHandler:say("Voc\234 esta na quarta miss\227o e precisa de mais 1 Blue note para continuar.", cid)
    elseif getstorage == 4 then
      npcHandler:say("Voc\234 esta na quinta miss\227o e precisa de mais 1 Blue note para continuar.", cid)
    elseif getstorage == 5 then
      npcHandler:say("Voc\234 esta na sexta e \250ltima miss\227o e precisa de mais 1 Blue note para continuar.", cid)
    elseif getstorage == 6 then
      npcHandler:say("Voc\234 j\225 completou todas as miss\245es.", cid)
    end
  elseif msgcontains(msg, "yes") then
    if talkState[talkUser] == 1 then
      if getstorage < 0 then
        if doPlayerRemoveItem(cid, crystalid, 1) == TRUE then
          npcHandler:say("Voc\234 jah me deu 1 Blue note. Agora irei precisar de mais {1}.", cid)
          setPlayerStorageValue(cid, storage, 1)
          doPlayerAddExp(cid, 10000)
          talkState[talkUser] = 0
        elseif doPlayerRemoveItem(cid, crystalid, 1) == FALSE then
          npcHandler:say(sorrymessage, cid)
          talkState[talkUser] = 0
        end
      elseif getstorage == 1 then
        if doPlayerRemoveItem(cid, crystalid, 1) == TRUE then
          npcHandler:say("Voc\234 jah me deu mais 2 blue note. Agora irei precisar de mais {1}.", cid)
          setPlayerStorageValue(cid, storage, 2)
          doPlayerAddExp(cid, 50000)
          talkState[talkUser] = 0
        elseif doPlayerRemoveItem(cid, crystalid, 1) == FALSE then
          npcHandler:say(sorrymessage, cid)
          talkState[talkUser] = 0
        end
      elseif getstorage == 2 then
        if doPlayerRemoveItem(cid, crystalid, 1) == TRUE then
          npcHandler:say("Voc\234 jah me deu 3 blue note. Agora irei precisar de mais {1}.", cid)
          setPlayerStorageValue(cid, storage, 3)
          doPlayerAddExp(cid, 70000)
          talkState[talkUser] = 0
        elseif doPlayerRemoveItem(cid, crystalid, 1) == FALSE then
          npcHandler:say(sorrymessage, cid)
          talkState[talkUser] = 0
        end
      elseif getstorage == 3 then
        if doPlayerRemoveItem(cid, crystalid, 1) == TRUE then
          npcHandler:say("Voc\234 jah me deu 4 blue note. Agora irei precisar de mais {1}.", cid)
          setPlayerStorageValue(cid, storage, 4)
          doPlayerAddExp(cid, 10000)
          talkState[talkUser] = 0
        elseif doPlayerRemoveItem(cid, crystalid, 1) == FALSE then
          npcHandler:say(sorrymessage, cid)
          talkState[talkUser] = 0
        end
      elseif getstorage == 4 then
        if doPlayerRemoveItem(cid, crystalid, 1) == TRUE then
          npcHandler:say("Voc\234 jah me deu 5 blue note. E por \250ltimo, irei precisar de mais {1}.", cid)
          setPlayerStorageValue(cid, storage, 5)
          doPlayerAddExp(cid, 150000)
          talkState[talkUser] = 0
        elseif doPlayerRemoveItem(cid, crystalid, 1) == FALSE then
          npcHandler:say(sorrymessage, cid)
          talkState[talkUser] = 0
        end
      elseif getstorage == 5 then
        if doPlayerRemoveItem(cid, crystalid, 1) == TRUE then
          npcHandler:say(
            "Muito bem, voc\234 completou todas as miss\245es. Irei te dar experi\234ncia e um {blessed shield} como pr\234mio.",
            cid
          )
          setPlayerStorageValue(cid, storage, 6)
          doPlayerAddExp(cid, 900000)
          doPlayerAddItem(cid, 2523, 1)
          talkState[talkUser] = 0
        elseif doPlayerRemoveItem(cid, crystalid, 1) == FALSE then
          npcHandler:say(sorrymessage, cid)
          talkState[talkUser] = 0
        end
      end
    end
  elseif msgcontains(msg, "no") and talkState[talkUser] == 1 then
    npcHandler:say("OK, Volte quando estiver pronto.", cid)
    talkState[talkUser] = 0
  end
  return TRUE
end
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
