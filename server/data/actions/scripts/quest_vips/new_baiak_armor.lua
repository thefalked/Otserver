function onUse(cid, item, frompos, item2, topos)
  if item.uid == 9057 then
    queststatus = getPlayerStorageValue(cid, 90063)
    if queststatus == -1 then
      doPlayerSendTextMessage(cid, 22, "Voc\234 Ganhou Uma Master Armor!.")
      doPlayerAddItem(cid, 6095, 1)
      setPlayerStorageValue(cid, 90063, 1)
    else
      doPlayerSendTextMessage(cid, 22, "Voc\234 j\225 fez essa quest!")
    end
  else
    return 0
  end
  return 1
end
