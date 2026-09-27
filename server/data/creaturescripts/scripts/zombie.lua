local config = {
  playerCount = 2001, -- Global storage for counting the players left/entered in the event

  goblet = 5805, -- gold goblet with winner name
  moneyReward = { 2157, 100, 1 }, -- gold nuggets
  vip9Weapons = {
    7391, -- Baiak Vip9 Sword
    7456, -- Baiak Vip9 Axe
    7425, -- Baiak Vip9 Mace
    7754, -- Baiak Vip9 Staff
    7367, -- Baiak Vip9 Spear
  },

  -- Should be same as in the globalevent!
  fromPosition = { x = 44, y = 514, z = 7 },
  toPosition = { x = 70, y = 539, z = 7 },
}

function onStatsChange(cid, attacker, type, combat, value)
  if isPlayer(cid) and isMonster(attacker) then
    if isInArea(getPlayerPosition(cid), config.fromPosition, config.toPosition) then
      if getGlobalStorageValue(config.playerCount) >= 2 then
        doBroadcastMessage(getPlayerName(cid) .. " Foi Comido Por Zombies!", MESSAGE_STATUS_CONSOLE_RED)
        local corpse = doCreateItem(3058, 1, getPlayerPosition(cid))
        doItemSetAttribute(
          corpse,
          "description",
          "You recognize "
            .. getCreatureName(cid)
            .. ". He was killed by "
            .. (isMonster(attacker) and "a " .. string.lower(getCreatureName(attacker)) or isCreature(attacker) and getCreatureName(
              attacker
            ) or "a field item")
            .. "."
        )
        doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
        doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)), false)
        doSendMagicEffect(getPlayerPosition(cid), CONST_ME_TELEPORT)
        setGlobalStorageValue(config.playerCount, getGlobalStorageValue(config.playerCount) - 1)
      elseif getGlobalStorageValue(config.playerCount) == 1 then
        if isInArea(getPlayerPosition(cid), config.fromPosition, config.toPosition) then
          doBroadcastMessage(getPlayerName(cid) .. " Ganhou o Zombie Event! Parab\233ns!", MESSAGE_STATUS_WARNING)
          local goblet = doPlayerAddItem(cid, config.goblet, 1)
          doItemSetAttribute(
            goblet,
            "description",
            "Consedido A " .. getPlayerName(cid) .. " Por ganhar o Zombie event."
          )
          local corpse = doCreateItem(3058, 1, getPlayerPosition(cid))
          doItemSetAttribute(
            corpse,
            "description",
            "You recognize "
              .. getCreatureName(cid)
              .. ". He was killed by "
              .. (isMonster(attacker) and "a " .. string.lower(getCreatureName(attacker)) or isCreature(attacker) and getCreatureName(
                attacker
              ) or "a field item")
              .. "."
          )
          doSendMagicEffect(getPlayerPosition(cid), CONST_ME_POFF)
          doTeleportThing(cid, getTownTemplePosition(getPlayerTown(cid)), false)
          doSendMagicEffect(getPlayerPosition(cid), CONST_ME_TELEPORT)
          doPlayerAddItem(cid, config.vip9Weapons[math.random(1, #config.vip9Weapons)], 1)
          if config.moneyReward[3] == 1 then
            doPlayerAddItem(cid, config.moneyReward[1], config.moneyReward[2])
          end
        end

        for x = config.fromPosition.x, config.toPosition.x do
          for y = config.fromPosition.y, config.toPosition.y do
            for z = config.fromPosition.z, config.toPosition.z do
              areapos = { x = x, y = y, z = z, stackpos = 253 }
              getMonsters = getThingfromPos(areapos)
              if isMonster(getMonsters.uid) then
                doRemoveCreature(getMonsters.uid)
              end
            end
          end
        end
      end
      return false
    end
  end
  return true
end
