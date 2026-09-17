function onUse(cid, item, fromPosition, itemEx, toPosition)
  if item.uid == 35400 then
    queststatus = getPlayerStorageValue(cid, 35400)
    if queststatus == -1 or queststatus == 0 then
      doCreatureSay(cid, "VOc\234 recebeu seu beneficio por ser vip!", TALKTYPE_ORANGE_1)
      db.query(
        "UPDATE `players` SET `name` = '[Mvip] "
          .. getCreatureName(cid)
          .. "' WHERE `id` = "
          .. getPlayerGUID(cid)
          .. ";"
      )
      doPlayerSendTextMessage(cid, 25, "Voc\234 ser\225 kickado em 5 segundos para mudan\231a de nome.")
      doPlayerAddAddons(cid, 1)
      addEvent(doRemoveCreature, 5 * 1000, cid, true)
      setPlayerStorageValue(cid, 35400, 1)
      doSendMagicEffect(getCreaturePosition(cid), CONST_ME_HOLYDAMAGE)
    else
      doPlayerSendTextMessage(cid, 22, "voc\234 j\225 tem o [MVip] no nome.")
    end
    return true
  end
end
