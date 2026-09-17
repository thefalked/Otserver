function onUse(cid, item, frompos, item2, topos)
  if item.uid == 9058 then
    queststatus = getPlayerStorageValue(cid, 90064)
    if queststatus == -1 then
      doPlayerSendTextMessage(cid, 22, "Voc\234 Ganhou Uma Master Legs!.")
      doPlayerAddItem(cid, 5918, 1)
      setPlayerStorageValue(cid, 90064, 1)
    else
      doPlayerSendTextMessage(cid, 22, "Voc\234 j\225 fez essa quest!")
    end
  else
    return 0
  end
  return 1
end
