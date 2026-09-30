--[[
  /reload <type>. hot-reload without restarting the server.

  Docs: docs/reload.md

  Works:
    actions, chat, config, creatureevents/creaturescripts, globalevents,
    highscores, monsters, moveevents/movements, npcs, quests, raids,
    spells, stages/experience, talkactions/commands, mods, all

  Blocked until fixed (must match RELOAD_ALL skip in game.cpp):
    items, outfits, weapons (TODO stubs)
    groups (disabled; Group* dangling risk)
    vocations (unsafe; Vocation* dangling risk)
    houseprices (no C++ handler; use /reload config)
    gameservers (login-server build only)

  Still needs a full restart:
    map/.otbm and existing map spawns, binary/C++ changes, items.otb,
    broken types above, some config.lua options that only apply at
    startup (ports, DB, core engine flags)

  Notes:
    - Already-spawned NPCs may keep old state until replaced.
    - Reloading spells also reloads monsters. Reloading raids restarts
      the raid system. SIGCONT on the process also reloads all.
    - /reload all and SIGCONT skip the same broken/unsafe types.
    - Do not remove a type from brokenReasons until the engine path is safe
      and the matching skip case in game.cpp RELOAD_ALL is removed too.
]]

local reloadInfo = {
  { RELOAD_ACTIONS, "actions", "action" },
  { RELOAD_CHAT, "chat", "channels" },
  { RELOAD_CONFIG, "config", "configuration" },
  {
    RELOAD_CREATUREEVENTS,
    "creatureevents",
    "creature events",
    "creaturescripts",
    "creature scripts",
    "creatureevent",
    "creature event",
    "creature script",
    "creaturescript",
  },
  { RELOAD_GAMESERVERS, "gameservers", "game servers", "servers" },
  { RELOAD_GLOBALEVENTS, "globalevents", "global events", "globalevent", "global event" },
  { RELOAD_GROUPS, "groups", "playergroups", "group" },
  { RELOAD_HIGHSCORES, "highscores", "scores", "highscore", "score" },
  { RELOAD_HOUSEPRICES, "houseprices", "house prices", "prices" },
  { RELOAD_ITEMS, "items", "item" },
  { RELOAD_MONSTERS, "monsters", "monster" },
  { RELOAD_MOVEEVENTS, "moveevents", "move events", "movements", "move", "movement" },
  { RELOAD_NPCS, "npcs", "npc" },
  { RELOAD_OUTFITS, "outfits", "outfit" },
  { RELOAD_QUESTS, "quests", "quest" },
  { RELOAD_RAIDS, "raids", "raid" },
  { RELOAD_SPELLS, "spells", "spell" },
  { RELOAD_STAGES, "stages", "experience" },
  { RELOAD_TALKACTIONS, "talkactions", "talk actions", "talk", "commands", "talkaction", "talk action" },
  { RELOAD_VOCATIONS, "vocations", "vocation" },
  { RELOAD_WEAPONS, "weapons", "weapon" },
  { RELOAD_MODS, "mods", "modifications" },
  { RELOAD_ALL, "all", "everything" },
}

-- Dangerous / broken types. Block every one until the engine path is fixed.
-- Keep ids identical to the RELOAD_ALL skip switch in game.cpp.
-- Layer 1 (here): direct /reload <type>. Layer 2 (C++): /reload all + SIGCONT.
local brokenReasons = {
  [RELOAD_GAMESERVERS] = "login-server build only",
  [RELOAD_GROUPS] = "disabled (online players keep Group* pointers)",
  [RELOAD_HOUSEPRICES] = "no C++ handler (use /reload config)",
  [RELOAD_ITEMS] = "TODO stub in engine",
  [RELOAD_OUTFITS] = "TODO stub in engine",
  [RELOAD_VOCATIONS] = "unsafe (online players keep Vocation* pointers)",
  [RELOAD_WEAPONS] = "TODO stub in engine",
}

local workingTypes =
  "actions, chat, config, creatureevents, globalevents, highscores, monsters, moveevents, npcs, quests, raids, spells, stages, talkactions, mods, all"

local brokenTypes = "items, outfits, weapons, groups, vocations, houseprices, gameservers"

local function sendReloadLists(cid, prefix)
  local head = prefix or ""
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, head .. "Working: " .. workingTypes)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Does not work: " .. brokenTypes)
end

function onSay(cid, words, param, channel)
  if param == "" then
    sendReloadLists(cid, "Command param required. ")
    return true
  end

  param = param:lower()
  local str = "Reload type not found."
  local found = false
  for _, v in ipairs(reloadInfo) do
    if table.isStrIn(param, v) then
      found = true
      local reason = brokenReasons[v[1]]
      if reason then
        str = "Reload type " .. v[2] .. " does not work: " .. reason .. "."
        sendReloadLists(cid)
      elseif not doReloadInfo(v[1], cid) then
        str = "Reload type " .. v[2] .. " rejected by engine (id out of range)."
      else
        str = "Reloading " .. v[2] .. "..."
      end
      break
    end
  end

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
  if not found then
    sendReloadLists(cid)
  end
  return true
end
