function onStepIn(cid, item, pos)
  -- teleports config
  teleport1 = { x = 155, y = 52, z = 7 }

  if isPlayer(cid) then
    if item.actionid == 13589 then
      vip = getPlayerStorageValue(cid, 13589)
      if vip == -1 then
        doPlayerSendCancel(cid, "Esta \225rea \233 exclusiva para players Vips9.Para Adquirir vip9 fa\231a a Quest Vip8")

        doTeleportThing(cid, teleport1)
      else
      end
    end
  end
end
