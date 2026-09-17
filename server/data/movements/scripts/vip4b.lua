function onStepIn(cid, item, pos)
  -- teleports config
  teleport1 = { x = 155, y = 52, z = 7 }

  if isPlayer(cid) then
    if item.actionid == 5721 then
      local requiredLevel = 1800
      if getPlayerLevel(cid) < requiredLevel then
        doPlayerSendCancel(cid, "Somente level " .. requiredLevel .. " ou mais podem entrar nesta VIP.")
        doTeleportThing(cid, teleport1)
        return false
      end

      vip = getPlayerStorageValue(cid, 5721)
      if vip == -1 then
        doPlayerSendCancel(
          cid,
          "Esta área é exclusiva para players Vips4.Para Adquirir vip4 faça a quest baiakzik vip que fica localizada no templo vip3"
        )

        doTeleportThing(cid, teleport1)
      else
      end
    end
  end
end
