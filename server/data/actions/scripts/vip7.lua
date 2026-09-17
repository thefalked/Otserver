-- Script By Th3uz1k ADM Th3uz1k --
function onUse(cid, item, frompos, item2, topos)
  if item.uid == 7521 then
    queststatus = getPlayerStorageValue(cid, 7526)
    if queststatus == 1 then
      doPlayerSendTextMessage(cid, 22, "Voc\234 jah pegou sua recompensa.")
    elseif getPlayerStorageValue(cid, 7525) ~= 1 then
      doPlayerSendTextMessage(cid, 22, "Voc\234 precisa ser Vip6 para se tornar Vip7.")
    else
      doPlayerSendTextMessage(cid, 22, "Voc\234 agora \233 um Vip7. System Vip By {ADM}~Th3uz1k~.")
      doSendMagicEffect(topos, 35)
      coins_uid = doPlayerAddItem(cid, 2160, 100)
      coins_uid = doPlayerAddItem(cid, 9693, 1)
      setPlayerStorageValue(cid, 7526, 1)
    end
    return 0
  end
  return 1
end
