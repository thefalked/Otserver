function onUse(cid, item, frompos, item2, topos)
  pos = { x = 528, y = 14, z = 7 }
  if item.itemid == 8982 then
    if getPlayerStorageValue(cid, 7525) ~= 1 then
      doPlayerSendCancel(cid, "Voce precisa ser Vip6 para usar este item.")
      return 1
    end
    doPlayerSendCancel(cid, "Abra o bau para se tornar vip!")
    doTeleportThing(cid, pos)
    doRemoveItem(item.uid, 1)
  else
    doPlayerSendCancel(cid, "Fail !")
  end

  return 1
end
