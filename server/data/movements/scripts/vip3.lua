function onStepIn(cid, item, pos)
  -- teleports config
  teleport1 = { x = 155, y = 52, z = 7 }

  if isPlayer(cid) then
    if item.actionid == 15967 then
      local requiredLevel = 1200
      if getPlayerLevel(cid) < requiredLevel then
        doPlayerSendCancel(cid, "Somente level " .. requiredLevel .. " ou mais podem entrar nesta VIP.")
        doTeleportThing(cid, teleport1)
        return false
      end

      vip = getPlayerStorageValue(cid, 15967)
      if vip == -1 then
        doPlayerSendCancel(
          cid,
          "Esta área é exclusiva para players Master Vip.Para Adquirir master vip faça a Quest Master Vip!Localizada no Templo vip 2"
        )

        doTeleportThing(cid, teleport1)
      else
      end
    end
  end
end
