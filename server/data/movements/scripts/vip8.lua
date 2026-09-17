function onStepIn(cid, item, pos)
  -- teleports config
  teleport1 = { x = 155, y = 52, z = 7 }

  if isPlayer(cid) then
    if item.actionid == 7527 then
      local requiredLevel = 5000
      if getPlayerLevel(cid) < requiredLevel then
        doPlayerSendCancel(cid, "Somente level " .. requiredLevel .. " ou mais podem entrar nesta VIP.")
        doTeleportThing(cid, teleport1)
        return false
      end

      vip = getPlayerStorageValue(cid, 7527)
      if vip == -1 then
        doPlayerSendCancel(
          cid,
          "Esta \225rea \233 exclusiva para players Vip8.Para Adquirir Vip8 Compre Um Vip8 Doll No Baiak-Zik Na Vip7"
        )

        doTeleportThing(cid, teleport1)
      else
      end
    end
  end
end
