-- Custom Auto Loot for Baiak Vip9 (TFS 0.4).
--
-- Rules (intentional):
-- 1. Last hit only. Only the player who landed the killing blow runs autoloot.
--    Corpse owner is not checked. Anyone may open drops by hand on this server.
-- 2. No range check. Last hitter can be anywhere when the delayed collect runs.
-- 3. Slots: 2 free base slots, plus 1 per forever VIP quest (Vip3-Vip9). Max 9.
--    Vip2 / timed VIP (13540) is ignored on purpose.
-- 4. Min level: AutoLoot.MinLevel (1500). Below that, Enabled is cleared automatically.
-- 5. Loot: remove from corpse first. Only then add to the player. If add fails,
--    the item is put back into the corpse.
-- 6. Sell is manual and one-shot: !autoloot sell. Half of Mad/Rashid price to bank
--    (best of the two when both buy the item). Never sells on kill. Never sells equipped gear.
-- 7. Collect waits CorpseDelay ms because onKill runs before the corpse exists.
-- 8. Stacked corpses: snapshot corpse UIDs on the tile at kill time (before the new
--    body exists). After the delay, loot only a new unclaimed UID. Claim avoids two
--    near-simultaneous kills both grabbing the same body.
--
-- Item names for add/remove come from items.xml (getItemIdByName).
--
-- Talkaction: !autoloot / /autoloot
--   on | off | add, name | remove, name | clear | list | sell | help

AutoLoot = {
  MinLevel = 1500,
  -- onKill fires before dropCorpse. Delay must be > 0. Engine minimum is 50ms.
  CorpseDelay = 200,
  BaseSlots = 2,

  Storage = {
    Enabled = 45100,
    -- 45101 unused (old sell-toggle storage).
    Slots = { 45102, 45103, 45104, 45105, 45106, 45107, 45108, 45109, 45110 },
  },

  -- Forever VIP quest storages only (Vip3-Vip9). Not Vip2 / timed VIP 13540.
  VipSlotStorages = {
    15967, -- Vip3
    5722, -- Vip4
    7520, -- Vip5
    7525, -- Vip6
    7526, -- Vip7
    7527, -- Vip8
    13589, -- Vip9
  },

  -- Admin blocklist: itemid = true. Players cannot autoloot these even if whitelisted.
  -- Example: [4852] = true, -- Vip Stone
  Blacklist = {},

  -- uid -> true while a collect owns that corpse (same-tile multi-kill).
  Claimed = {},
  ClaimTtl = 5000,

  -- Mad + Rashid shop_sellable full prices (by itemid). Overlap uses the higher NPC price.
  -- Comments = items.xml names. !autoloot sell pays floor(price * count / 2).
  SellPrices = {
    [2135] = 200, -- scarab amulet
    [2142] = 200, -- ancient amulet
    [2195] = 40000, -- boots of haste
    [2376] = 25, -- sword
    [2377] = 400, -- two handed sword
    [2378] = 100, -- battle axe
    [2381] = 200, -- halberd
    [2383] = 800, -- spike sword
    [2387] = 200, -- double axe
    [2388] = 20, -- hatchet
    [2390] = 150000, -- magic longsword
    [2391] = 6000, -- war hammer
    [2392] = 3000, -- fire sword
    [2393] = 10000, -- giant sword
    [2396] = 4000, -- ice rapier
    [2398] = 30, -- mace
    [2400] = 120000, -- magic sword
    [2402] = 500, -- silver dagger
    [2406] = 30, -- short sword
    [2407] = 6000, -- bright sword
    [2408] = 100000, -- warlord sword
    [2409] = 1500, -- serpent sword
    [2413] = 70, -- broadsword
    [2414] = 10000, -- dragon lance
    [2417] = 60, -- battle hammer
    [2421] = 90000, -- thunder hammer
    [2423] = 200, -- clerical mace
    [2427] = 7500, -- guardian halberd
    [2430] = 2000, -- knight axe
    [2431] = 90000, -- stonecutter axe
    [2432] = 10000, -- fire axe
    [2434] = 2000, -- dragon hammer
    [2436] = 1000, -- Skull Staff
    [2439] = 110, -- daramanian mace
    [2440] = 1000, -- daramanian waraxe
    [2442] = 90, -- heavy machete
    [2454] = 9000, -- war axe
    [2458] = 35, -- chain helmet
    [2459] = 30, -- iron helmet
    [2462] = 4000, -- devil helmet
    [2463] = 400, -- plate armor
    [2464] = 100, -- chain armor
    [2465] = 200, -- brass armor
    [2466] = 30000, -- golden armor
    [2470] = 80000, -- golden legs
    [2472] = 200000, -- magic plate armor
    [2475] = 6000, -- warrior helmet
    [2476] = 5000, -- knight armor
    [2477] = 6000, -- knight legs
    [2487] = 20000, -- crown armor
    [2488] = 15000, -- crown legs
    [2491] = 5000, -- crown helmet
    [2492] = 60000, -- dragon scale mail
    [2494] = 90000, -- demon armor
    [2497] = 9000, -- crusader helmet
    [2498] = 40000, -- royal helmet
    [2500] = 2500, -- amazon armor
    [2503] = 20000, -- Baiakzik Armor
    [2514] = 150000, -- mastermind shield
    [2515] = 200, -- guardian shield
    [2518] = 1500, -- beholder shield
    [2519] = 5000, -- crown shield
    [2520] = 40000, -- demon shield
    [2521] = 400, -- dark shield
    [2522] = 100000, -- great shield
    [2523] = 150000, -- blessed shield
    [2525] = 100, -- dwarven shield
    [2528] = 4000, -- tower shield
    [2534] = 25000, -- vampire shield
    [2535] = 5000, -- castle shield
    [2536] = 9000, -- medusa shield
    [2537] = 4000, -- amazon shield
    [2540] = 2000, -- scarab shield
    [2541] = 80, -- bone shield
    [2645] = 40000, -- steel boots
    [2646] = 200000, -- golden boots
    [2647] = 500, -- plate legs
    [2656] = 15000, -- blue robe
    [2663] = 500, -- mystic turban
    [3968] = 1000, -- leopard armor
    [3972] = 7500, -- vip helmet
    [3982] = 1000, -- crocodile boots
    [5462] = 3000, -- Master Boots
    [5710] = 300, -- light shovel
    [5741] = 40000, -- skull helmet
    [5918] = 200, -- Master Legs
    [6095] = 500, -- Master Armor
    [6096] = 1000, -- Master Helmet
    [6131] = 150, -- tortoise shield
    [7379] = 1500, -- brutetamer's staff
    [7381] = 300, -- mammoth whopper
    [7387] = 3000, -- diamond sceptre
    [7402] = 20000, -- dragon slayer
    [7408] = 1500, -- wyvern fang
    [7419] = 30000, -- dreaded cleaver
    [7425] = 500, -- Baiak Vip9 Mace
    [7426] = 8000, -- amber staff
    [7430] = 3000, -- dragonbone staff
    [7432] = 1000, -- Master Vip Club
    [7437] = 7000, -- sapphire hammer
    [7449] = 600, -- crystal sword
    [7451] = 5000, -- Baiakzik Club
    [7457] = 2000, -- Master Vip Boots
    [7461] = 200, -- krimhorn helmet
    [7462] = 400, -- ragnir helmet
    [7463] = 6000, -- Master Vip Armor
    [8889] = 60000, -- skullcracker armor
    [8891] = 30000, -- paladin armor
  },
}

function AutoLoot.getMaxSlots(cid)
  local count = AutoLoot.BaseSlots
  for i = 1, #AutoLoot.VipSlotStorages do
    if getPlayerStorageValue(cid, AutoLoot.VipSlotStorages[i]) > 0 then
      count = count + 1
    end
  end
  return math.min(count, #AutoLoot.Storage.Slots)
end

function AutoLoot.isEnabled(cid)
  return getPlayerStorageValue(cid, AutoLoot.Storage.Enabled) == 1
end

function AutoLoot.disable(cid)
  setPlayerStorageValue(cid, AutoLoot.Storage.Enabled, -1)
end

-- Turns autoloot off when below MinLevel. Returns true if it disabled.
function AutoLoot.enforceLevel(cid)
  if getPlayerLevel(cid) < AutoLoot.MinLevel and AutoLoot.isEnabled(cid) then
    AutoLoot.disable(cid)
    return true
  end
  return false
end

function AutoLoot.isBlacklisted(itemid)
  return AutoLoot.Blacklist[itemid] == true
end

function AutoLoot.getWhitelist(cid)
  local list = {}
  local maxSlots = AutoLoot.getMaxSlots(cid)
  for i = 1, math.min(#AutoLoot.Storage.Slots, maxSlots) do
    local value = getPlayerStorageValue(cid, AutoLoot.Storage.Slots[i])
    if value > 0 then
      table.insert(list, value)
    end
  end
  return list
end

function AutoLoot.getUsedSlots(cid)
  return #AutoLoot.getWhitelist(cid)
end

function AutoLoot.isWhitelisted(cid, itemid)
  local list = AutoLoot.getWhitelist(cid)
  for i = 1, #list do
    if list[i] == itemid then
      return true
    end
  end
  return false
end

function AutoLoot.addToWhitelist(cid, itemid)
  if AutoLoot.isWhitelisted(cid, itemid) then
    return false, "exists"
  end

  local maxSlots = AutoLoot.getMaxSlots(cid)
  if maxSlots < 1 then
    return false, "noslots"
  end

  if AutoLoot.getUsedSlots(cid) >= maxSlots then
    return false, "full"
  end

  for i = 1, maxSlots do
    local key = AutoLoot.Storage.Slots[i]
    if getPlayerStorageValue(cid, key) <= 0 then
      setPlayerStorageValue(cid, key, itemid)
      return true
    end
  end

  return false, "full"
end

function AutoLoot.removeFromWhitelist(cid, itemid)
  for i = 1, #AutoLoot.Storage.Slots do
    local key = AutoLoot.Storage.Slots[i]
    if getPlayerStorageValue(cid, key) == itemid then
      setPlayerStorageValue(cid, key, -1)
      return true
    end
  end
  return false
end

function AutoLoot.clearWhitelist(cid)
  for i = 1, #AutoLoot.Storage.Slots do
    setPlayerStorageValue(cid, AutoLoot.Storage.Slots[i], -1)
  end
end

function AutoLoot.getItemCount(item)
  if item.type and item.type > 0 then
    return item.type
  end
  return 1
end

function AutoLoot.tryGiveItem(cid, itemid, count)
  local clone = doCreateItemEx(itemid, count)
  if not clone or clone == false then
    return false
  end

  local ret = doPlayerAddItemEx(cid, clone, false)
  if ret == RETURNVALUE_NOERROR then
    return true
  end

  -- Failed add: drop virtual item so it does not leak.
  doRemoveItem(clone)
  return false
end

-- Remove from corpse first. Give to player only if remove succeeded.
-- If give fails, put the item back into the corpse.
function AutoLoot.takeFromCorpse(cid, containerUid, item)
  local itemid = item.itemid
  local count = AutoLoot.getItemCount(item)

  if not doRemoveItem(item.uid, count) then
    return false
  end

  if AutoLoot.tryGiveItem(cid, itemid, count) then
    return true
  end

  local restored = doCreateItemEx(itemid, count)
  if restored and restored ~= false then
    if doAddContainerItemEx(containerUid, restored) ~= RETURNVALUE_NOERROR then
      doRemoveItem(restored)
    end
  end
  return false
end

-- Sells whitelist items with SellPrices from a container tree. Returns gold paid.
function AutoLoot.sellFromContainer(cid, containerUid, depth)
  depth = depth or 0
  if depth > 10 or containerUid <= 0 or not isContainer(containerUid) then
    return 0
  end

  local size = getContainerSize(containerUid)
  if type(size) ~= "number" or size <= 0 then
    return 0
  end

  local total = 0
  for slot = size - 1, 0, -1 do
    local item = getContainerItem(containerUid, slot)
    if item and item.uid and item.uid > 0 and item.itemid and item.itemid > 0 then
      if isContainer(item.uid) then
        total = total + AutoLoot.sellFromContainer(cid, item.uid, depth + 1)
      elseif
        not AutoLoot.isBlacklisted(item.itemid)
        and AutoLoot.isWhitelisted(cid, item.itemid)
        and AutoLoot.SellPrices[item.itemid]
      then
        local count = AutoLoot.getItemCount(item)
        local payout = math.floor((AutoLoot.SellPrices[item.itemid] * count) / 2)
        if payout >= 1 and doRemoveItem(item.uid, count) then
          doPlayerSetBalance(cid, getPlayerBalance(cid) + payout)
          total = total + payout
        end
      end
    end
  end
  return total
end

-- One-shot sell from backpack only (not equipped gear).
function AutoLoot.sellInventory(cid)
  local bp = getPlayerSlotItem(cid, CONST_SLOT_BACKPACK)
  if not bp or not bp.uid or bp.uid <= 0 then
    return 0
  end
  return AutoLoot.sellFromContainer(cid, bp.uid, 0)
end

function AutoLoot.processContainer(cid, containerUid, depth)
  depth = depth or 0
  if containerUid <= 0 or not isContainer(containerUid) then
    return
  end

  local size = getContainerSize(containerUid)
  if type(size) ~= "number" or size <= 0 then
    return
  end

  for slot = size - 1, 0, -1 do
    local item = getContainerItem(containerUid, slot)
    if item and item.uid and item.uid > 0 and item.itemid and item.itemid > 0 then
      if depth < 1 and isContainer(item.uid) then
        AutoLoot.processContainer(cid, item.uid, depth + 1)
      elseif not AutoLoot.isBlacklisted(item.itemid) and AutoLoot.isWhitelisted(cid, item.itemid) then
        AutoLoot.takeFromCorpse(cid, containerUid, item)
      end
    end
  end
end

function AutoLoot.listCorpseUids(position)
  local uids = {}
  local pos = { x = position.x, y = position.y, z = position.z, stackpos = 1 }
  for stackpos = 1, 20 do
    pos.stackpos = stackpos
    local thing = getThingFromPos(pos, false)
    if thing and thing.uid and thing.uid > 0 and isCorpse(thing.uid) and isContainer(thing.uid) then
      table.insert(uids, thing.uid)
    end
  end
  return uids
end

function AutoLoot.encodeUids(uids)
  if not uids or #uids < 1 then
    return ""
  end
  return table.concat(uids, ",")
end

function AutoLoot.decodeUidSet(encoded)
  local set = {}
  if not encoded or encoded == "" then
    return set
  end
  for part in string.gmatch(encoded, "[^,]+") do
    local uid = tonumber(part)
    if uid then
      set[uid] = true
    end
  end
  return set
end

function AutoLoot.releaseClaim(uid)
  AutoLoot.Claimed[uid] = nil
end

function AutoLoot.claimCorpse(uid)
  if AutoLoot.Claimed[uid] then
    return false
  end
  AutoLoot.Claimed[uid] = true
  addEvent(AutoLoot.releaseClaim, AutoLoot.ClaimTtl, uid)
  return true
end

-- Pick the new corpse for this kill. Ignores bodies that were already on the tile.
-- corpseItemId (lookCorpse) narrows same-tile mixes. Claim stops double-collect.
function AutoLoot.findCorpseUid(position, beforeEncoded, corpseItemId)
  local before = AutoLoot.decodeUidSet(beforeEncoded)
  corpseItemId = corpseItemId or 0

  local function gather(requireItemId)
    local list = {}
    local pos = { x = position.x, y = position.y, z = position.z, stackpos = 1 }
    for stackpos = 1, 20 do
      pos.stackpos = stackpos
      local thing = getThingFromPos(pos, false)
      if
        thing
        and thing.uid
        and thing.uid > 0
        and isCorpse(thing.uid)
        and isContainer(thing.uid)
        and not before[thing.uid]
        and not AutoLoot.Claimed[thing.uid]
        and (not requireItemId or thing.itemid == corpseItemId)
      then
        table.insert(list, thing.uid)
      end
    end
    table.sort(list)
    return list
  end

  local candidates = gather(corpseItemId > 0)
  if #candidates < 1 and corpseItemId > 0 then
    candidates = gather(false)
  end

  for i = 1, #candidates do
    if AutoLoot.claimCorpse(candidates[i]) then
      return candidates[i]
    end
  end
  return 0
end

function AutoLoot.collect(cid, position, beforeEncoded, corpseItemId)
  if not isPlayer(cid) then
    return
  end

  if AutoLoot.enforceLevel(cid) then
    return
  end

  if not AutoLoot.isEnabled(cid) then
    return
  end

  if AutoLoot.getUsedSlots(cid) < 1 then
    return
  end

  local corpseUid = AutoLoot.findCorpseUid(position, beforeEncoded, corpseItemId)
  if corpseUid <= 0 then
    return
  end

  AutoLoot.processContainer(cid, corpseUid, 0)
end
