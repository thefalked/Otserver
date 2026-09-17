function onStepIn(cid, item, pos)
  -- teleports config
  teleport1 = { x = 155, y = 52, z = 7 }

  if isPlayer(cid) then
    if item.actionid == 7526 then
      local requiredLevel = 4000
      if getPlayerLevel(cid) < requiredLevel then
        doPlayerSendCancel(cid, "Somente level " .. requiredLevel .. " ou mais podem entrar nesta VIP.")
        doTeleportThing(cid, teleport1)
        return false
      end

      vip = getPlayerStorageValue(cid, 7526)
      if vip == -1 then
        doPlayerSendCancel(
          cid,
          "Esta \225rea \233 exclusiva para players Vip7.Para Adquirir Sua Vip7 Compre Um Vip7 Doll Na Vip6"
        )

        doTeleportThing(cid, teleport1)
      else
      end
    end
  end
end
