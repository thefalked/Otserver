function onSay(cid, words, param)
  if doPlayerRemoveMoney(cid, 20) == TRUE then
    local bp = doPlayerAddItem(cid, 1988, 1)
    doSendMagicEffect(getCreaturePosition(cid), 13)
    doCreatureSay(cid, "Voc\234 comprou uma backpack", TALKTYPE_ORANGE_1)
  else
    doCreatureSay(cid, "Voc\234 n\227o tem dinheiro suficiente", TALKTYPE_ORANGE_1)
    doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
  end
end
