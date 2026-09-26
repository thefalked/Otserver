-- Auto Loot talkaction: !autoloot / /autoloot
-- Tibia 8.6 / OTClient expect ISO-8859-1 (Latin-1), not UTF-8.
-- Accents use decimal escapes so this file stays ASCII-safe.

local function sendHelp(cid)
  local maxSlots = AutoLoot.getMaxSlots(cid)
  local used = AutoLoot.getUsedSlots(cid)
  local enabled = AutoLoot.isEnabled(cid) and "on" or "off"
  local levelOk = getPlayerLevel(cid) >= AutoLoot.MinLevel

  local msg = "[Auto Loot] Status: "
    .. enabled
    .. " | Slots: "
    .. used
    .. "/"
    .. maxSlots
    .. " | Min level: "
    .. AutoLoot.MinLevel
    .. "."
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, msg)

  if not levelOk then
    doPlayerSendTextMessage(
      cid,
      MESSAGE_STATUS_CONSOLE_BLUE,
      "[Auto Loot] Voc\234 precisa ser level " .. AutoLoot.MinLevel .. " ou mais."
    )
  else
    doPlayerSendTextMessage(
      cid,
      MESSAGE_STATUS_CONSOLE_BLUE,
      "[Auto Loot] Voc\234 come\231a com "
        .. AutoLoot.BaseSlots
        .. " slots. Quests VIP (Vip3-Vip9) d\227o +1 slot cada."
    )
  end

  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "[Auto Loot] Comandos: on | off | add, nome | remove, nome | clear | list | sell"
  )
  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "[Auto Loot] Use o nome do item no jogo (ex: Master Boots)."
  )
end

local function sendList(cid)
  local list = AutoLoot.getWhitelist(cid)
  local maxSlots = AutoLoot.getMaxSlots(cid)
  if #list < 1 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "[Auto Loot] Lista vazia. Slots: 0/" .. maxSlots .. ".")
    return
  end

  local parts = {}
  for i = 1, #list do
    table.insert(parts, getItemNameById(list[i]))
  end
  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "[Auto Loot] (" .. #list .. "/" .. maxSlots .. "): " .. table.concat(parts, ", ")
  )
end

function onSay(cid, words, param, channel)
  param = param and param:trim() or ""
  local parts = string.explode(param, ",")
  local cmd = parts[1] and parts[1]:lower() or ""
  local itemName = parts[2]

  -- Always allow off, even below MinLevel.
  if cmd == "off" then
    AutoLoot.disable(cid)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[Auto Loot] Desligado.")
    return true
  end

  -- Always allow help / status, even below MinLevel.
  if param == "" or param == "help" then
    AutoLoot.enforceLevel(cid)
    sendHelp(cid)
    return true
  end

  if AutoLoot.enforceLevel(cid) then
    doPlayerSendCancel(cid, "[Auto Loot] Desligado. Voc\234 precisa ser level " .. AutoLoot.MinLevel .. " ou mais.")
    return true
  end

  if getPlayerLevel(cid) < AutoLoot.MinLevel then
    doPlayerSendCancel(cid, "Voc\234 precisa ser level " .. AutoLoot.MinLevel .. " ou mais.")
    return true
  end

  if cmd == "on" then
    setPlayerStorageValue(cid, AutoLoot.Storage.Enabled, 1)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[Auto Loot] Ligado.")
    return true
  end

  if cmd == "sell" then
    local payout = AutoLoot.sellInventory(cid)
    if payout < 1 then
      doPlayerSendCancel(cid, "Nada para vender. Precisa ter itens da lista com pre\231o de venda na backpack.")
    else
      doPlayerSendTextMessage(
        cid,
        MESSAGE_STATUS_CONSOLE_ORANGE,
        "[Auto Loot] Vendido. +" .. payout .. " gold no banco (metade do pre\231o)."
      )
    end
    return true
  end

  if cmd == "list" then
    sendList(cid)
    return true
  end

  if cmd == "clear" then
    AutoLoot.clearWhitelist(cid)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_ORANGE, "[Auto Loot] Lista limpa.")
    return true
  end

  if cmd == "add" then
    if not itemName or itemName == "" then
      doPlayerSendCancel(cid, "Use: !autoloot add, nome do item")
      return true
    end

    local itemid = getItemIdByName(itemName, false)
    if not itemid then
      doPlayerSendCancel(cid, "Este item n\227o existe.")
      return true
    end

    if AutoLoot.isBlacklisted(itemid) then
      doPlayerSendCancel(cid, "Este item est\225 bloqueado pelo servidor.")
      return true
    end

    local ok, reason = AutoLoot.addToWhitelist(cid, itemid)
    if ok then
      doPlayerSendTextMessage(
        cid,
        MESSAGE_STATUS_CONSOLE_ORANGE,
        "[Auto Loot] Adicionado: " .. getItemNameById(itemid) .. "."
      )
    elseif reason == "exists" then
      doPlayerSendCancel(cid, "Este item j\225 est\225 na lista.")
    elseif reason == "noslots" then
      doPlayerSendCancel(cid, "Voc\234 n\227o tem slots dispon\237veis.")
    else
      doPlayerSendCancel(cid, "Lista cheia (" .. AutoLoot.getMaxSlots(cid) .. " slots). Remova um item antes.")
    end
    return true
  end

  if cmd == "remove" then
    if not itemName or itemName == "" then
      doPlayerSendCancel(cid, "Use: !autoloot remove, nome do item")
      return true
    end

    local itemid = getItemIdByName(itemName, false)
    if not itemid then
      doPlayerSendCancel(cid, "Este item n\227o existe.")
      return true
    end

    if AutoLoot.removeFromWhitelist(cid, itemid) then
      doPlayerSendTextMessage(
        cid,
        MESSAGE_STATUS_CONSOLE_ORANGE,
        "[Auto Loot] Removido: " .. getItemNameById(itemid) .. "."
      )
    else
      doPlayerSendCancel(cid, "Este item n\227o est\225 na lista.")
    end
    return true
  end

  sendHelp(cid)
  return true
end
