function onUse(cid, item, frompos, item2, topos)
  if item.uid == 10012 then
    queststatus = getPlayerStorageValue(cid, 50001)
    if queststatus == -1 then
      doPlayerSendTextMessage(cid, 22, "Voc\234 Ganhou Uma Robe of The Underworld!.")
      doPlayerAddItem(cid, 8890, 1)
      setPlayerStorageValue(cid, 50001, 1)
    else
      doPlayerSendTextMessage(cid, 22, "Voc\234 j\225 fez essa quest!")
    end
  else
    return 0
  end
  return 1
end
