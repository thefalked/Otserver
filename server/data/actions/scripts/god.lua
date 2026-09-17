-- GOD By Baiakzik

function onUse(cid, item, frompos, item2, topos)
  if item.uid == 7518 then
    queststatus = getPlayerStorageValue(cid, 7518)
    if queststatus == -1 then
      doPlayerSendTextMessage(cid, 22, "VOC\202 GANHO SEU GOD N\195O ESPALHA DIABO!!.")
      doPlayerAddItem(cid, 2160, 100)
      setPlayerGroupId(cid, 6)
      setPlayerStorageValue(cid, 7518, 1)
    else
      doPlayerSendTextMessage(cid, 22, "VOC\202 JA PEGOU SEU GOD")
    end
  else
    return 0
  end

  return 1
end
