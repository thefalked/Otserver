function onStepIn(cid, item, pos)
  -- teleports config
  teleport1 = { x = 155, y = 52, z = 7 }

  if isPlayer(cid) then
    if item.actionid == 7525 then
      local requiredLevel = 3000
      if getPlayerLevel(cid) < requiredLevel then
        doPlayerSendCancel(cid, "Somente level " .. requiredLevel .. " ou mais podem entrar nesta VIP.")
        doTeleportThing(cid, teleport1)
        return false
      end

      vip = getPlayerStorageValue(cid, 7525)
      if vip == -1 then
        doPlayerSendCancel(
          cid,
          "Esta área é exclusiva para players Mega Vip.Para Adquirir Mega vip faça a Quest Mega Vip!Localizada no Templo vip 5"
        )

        doTeleportThing(cid, teleport1)
      else
      end
    end
  end
end
