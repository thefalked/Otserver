function onUse(cid, item, frompos, item2, topos)
  sorte = math.random(1, 7)
  pos = getPlayerPosition(cid)

  if item.itemid == 2581 or item.itemid == 2582 or item.itemid == 2583 or item.itemid == 2584 and sorte == 1 then
    doSendMagicEffect(pos, 14)
    doPlayerSendTextMessage(cid, 22, "As nuvens est\227o incubrindo o C\233u")
  elseif item.itemid == 2581 or item.itemid == 2582 or item.itemid == 2583 or item.itemid == 2584 and sorte == 2 then
    doSendMagicEffect(pos, 14)
    doPlayerSendTextMessage(cid, 22, "Uma chuva de meteoros.")
  elseif item.itemid == 2581 or item.itemid == 2582 or item.itemid == 2583 or item.itemid == 2584 and sorte == 3 then
    doSendMagicEffect(pos, 14)
    doPlayerSendTextMessage(cid, 22, "Voc\234 viu o Cruzeiro do sul.")
  elseif item.itemid == 2581 or item.itemid == 2582 or item.itemid == 2583 or item.itemid == 2584 and sorte == 4 then
    doSendMagicEffect(pos, 14)
    doPlayerSendTextMessage(cid, 22, "As forma\231\227o das estrelas favorece o ganho de muitos gps")
  elseif item.itemid == 2581 or item.itemid == 2582 or item.itemid == 2583 or item.itemid == 2584 and sorte == 5 then
    doSendMagicEffect(pos, 14)
    doPlayerSendTextMessage(cid, 22, "O encontro de V\234nus com marte mostram que voc\234 ir\225 bem nos neg\243cios.")
  elseif item.itemid == 2581 or item.itemid == 2582 or item.itemid == 2583 or item.itemid == 2584 and sorte == 6 then
    doSendMagicEffect(pos, 14)
    doPlayerSendTextMessage(cid, 22, "J\250pter est\225 bem perto!!")
  elseif item.itemid == 2581 or item.itemid == 2582 or item.itemid == 2583 or item.itemid == 2584 and sorte == 7 then
    doSendMagicEffect(pos, 14)
    doPlayerSendTextMessage(cid, 22, "A lua est\225 toda furada parecendo queijo su\237\231o.")
  end
  return 1
end
