function onStepIn(cid, item, pos)
  -- teleports config
  teleport1 = { x = 155, y = 52, z = 7 }

  if isPlayer(cid) then
    if item.actionid == 13539 then
      local requiredLevel = 800
      if getPlayerLevel(cid) < requiredLevel then
        doPlayerSendCancel(cid, "Somente level " .. requiredLevel .. " ou mais podem entrar nesta VIP.")
        doTeleportThing(cid, teleport1)
        return false
      end

      vip = getPlayerStorageValue(cid, 13540)
      if vip == -1 then
        doPlayerSendCancel(cid, "Esta \225rea \233 exclusiva para players Vips2.Para Adquirir vip2 fa\231a a Quest Vip")

        doTeleportThing(cid, teleport1)
      else
      end
    end
  end
end
