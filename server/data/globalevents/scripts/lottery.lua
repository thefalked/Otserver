-- Lottery System
local config = {
  lottery_hour = "30 minutos", -- Tempo ate a proxima loteria (Esse tempo vai aparecer somente como broadcast message)
  -- All items from Baiakzik Seller (baiakzik_seller.xml shop_buyable)
  rewards_id = {
    5468, -- Real stamina
    7417, -- Baiakzik Sword
    8926, -- Baiakzik Axe
    7368, -- Baiakzik Star
    7451, -- Baiakzik Club
    7424, -- Baiakzik Staff
    2538, -- Baiakzik Shield
    2503, -- Baiakzik Armor
    2474, -- Baiakzik Helmet
    2504, -- Baiakzik Legs
    9693, -- Addon Doll
    2641, -- Baiakzik Boots
    2157, -- gold nugget (uses quantity)
  },
  quantity = 50,
  website = "yes", -- Only if you have php scripts and table `lottery` in your database!
}
function onThink(interval, lastExecution)
  if getWorldCreatures(0) == 0 then
    return true
  end

  local list = {}
  for i, tid in ipairs(getPlayersOnline()) do
    list[i] = tid
  end

  local winner = list[math.random(1, #list)]
  local random_item = config.rewards_id[math.random(1, #config.rewards_id)]

  if random_item == 2157 then
    doPlayerAddItem(winner, random_item, config.quantity)
    doBroadcastMessage(
      "[LOTTERY SYSTEM] Winner: "
        .. getCreatureName(winner)
        .. ", Reward: "
        .. config.quantity
        .. " "
        .. getItemNameById(random_item)
        .. "s! Congratulations! (Pr\243xima Loteria em "
        .. config.lottery_hour
        .. ")"
    )
  else
    doBroadcastMessage(
      "[LOTTERY SYSTEM] Winner: "
        .. getCreatureName(winner)
        .. ", Reward: "
        .. getItemNameById(random_item)
        .. "! Congratulations! (Pr\243xima Loteria em "
        .. config.lottery_hour
        .. ")"
    )
    doPlayerAddItem(winner, random_item, 1)
  end

  if config.website == "yes" then
    db.query(
      "INSERT INTO `lottery` (`name`, `item`) VALUES ('"
        .. getCreatureName(winner)
        .. "', '"
        .. getItemNameById(random_item)
        .. "');"
    )
  end
  return true
end
