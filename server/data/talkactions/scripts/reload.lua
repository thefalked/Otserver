--[[
  /reload <type>. hot-reload without restarting the server.

  Works at runtime:
    actions, chat, config, creatureevents/creaturescripts, globalevents,
    highscores, monsters, moveevents/movements, npcs, quests, raids,
    spells, stages/experience, talkactions/commands, mods, all

  Listed but broken / no-op (do not rely on these):
    items, outfits, weapons (TODO stubs), groups (disabled), vocations
    (often fails), houseprices (no C++ handler), gameservers (login-server
    build only)

  Still needs a full restart:
    map/.otbm and existing map spawns, binary/C++ changes, items.otb,
    outfits/weapons/groups as above, some config.lua options that only
    apply at startup (ports, DB, core engine flags)

  Notes:
    - Already-spawned NPCs may keep old state until replaced.
    - Reloading spells also reloads monsters. Reloading raids restarts
      the raid system. SIGCONT on the process also reloads all.
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

local workingTypes =
  "actions, chat, config, creatureevents, globalevents, highscores, monsters, moveevents, npcs, quests, raids, spells, stages, talkactions, mods, all"

local function sendWorkingList(cid, prefix)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, (prefix or "") .. "Working reload types: " .. workingTypes)
end

function onSay(cid, words, param, channel)
  if param == "" then
    sendWorkingList(cid, "Command param required. ")
    return true
  end

  param = param:lower()
  local str = "Reload type not found."
  local found = false
  for _, v in ipairs(reloadInfo) do
    if table.isStrIn(param, v) then
      doReloadInfo(v[1], cid)
      str = "Reloading " .. v[2] .. "..."
      found = true
      break
    end
  end

  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, str)
  if not found then
    sendWorkingList(cid)
  end
  return true
end
