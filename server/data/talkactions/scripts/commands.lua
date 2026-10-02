local config = {
  guildTalksEnabled = getBooleanFromString(getConfigValue("ingameGuildManagement")),
}

-- Short descriptions shown next to each command (like !spells).
-- Keys must match the words attribute from talkactions.xml (first word if several).
local descriptions = {
  -- Players
  ["!commands"] = "List available commands",
  ["/commands"] = "List available commands",
  ["!myhouse"] = "Eject players from your house",
  ["!frags"] = "Show your unjustified kills",
  ["!aol"] = "Buy an Amulet of Loss",
  ["!online"] = "Show players online",
  ["!removeskull"] = "Remove your skull (costs gold)",
  ["!uptime"] = "Show server uptime",
  ["!pvp"] = "Show current world PvP type",
  ["!bless"] = "Buy all blessings (80k)",
  ["!q"] = "Show your carried gold",
  ["!serverinfo"] = "Show rates and protection level",
  ["!addon"] = "Use an addon doll",
  ["!reparar"] = "Repair the item in your hand",
  ["/reparar"] = "Repair the item in your hand",
  ["!vipdays"] = "Check remaining VIP days",
  ["!buyvip"] = "Buy VIP days",
  ["!party"] = "Party options",
  ["!changeoutfit"] = "Change guild outfit",
  ["!glist"] = "Show guild list",
  ["!rank"] = "Show rankings",
  ["!backpack"] = "Get a backpack",
  ["!spells"] = "List your spells by level",
  ["!tp"] = "VIP teleport",
  ["!autoloot"] = "Configure auto loot",
  ["/autoloot"] = "Configure auto loot",
  ["!buyhouse"] = "Buy the house you are looking at",
  ["!sellhouse"] = "Sell your house",
  ["!leavehouse"] = "Leave your house",
  ["!createguild"] = "Create a guild",
  ["!joinguild"] = "Join a guild",
  ["!notice"] = "Show server notice",
  ["!afk"] = "Toggle AFK status",
  ["!treinando"] = "Training helper",
  ["!save"] = "Save your character",
  ["!necromancer"] = "Necromancer outfit command",
  ["!nightmare"] = "Nightmare outfit command",
  ["!attackguild"] = "Attack guild command",
  ["!jail"] = "Jail a player",
  ["/jail"] = "Jail a player",
  ["!unjail"] = "Unjail a player",
  ["/unjail"] = "Unjail a player",
  ["!createpoll"] = "Create a poll",
  ["!activatepoll"] = "Activate a poll",
  ["!cancelpoll"] = "Cancel a poll",
  ["!seepoll"] = "View a poll",
  ["!seeresults"] = "View poll results",
  ["!remvotes"] = "Remove your poll vote",
  ["!rempoll"] = "Remove a poll",
  ["!votepoll"] = "Vote on a poll",

  -- Staff (shown only if you have access)
  ["/baninfo"] = "Show banishment info",
  ["/pos"] = "Show your position",
  ["/mute"] = "Mute a player",
  ["/desmute"] = "Unmute a player",
  ["/notations"] = "Manage notations",
  ["/info"] = "Show player info",
  ["/gethouse"] = "Show house owner",
  ["/b"] = "Broadcast a message",
  ["/goto"] = "Teleport to a player or position",
  ["/r"] = "Remove a creature or item",
  ["/ghost"] = "Toggle ghost mode",
  ["/squelch"] = "Toggle staff channel filter",
  ["/cliport"] = "Toggle click teleport",
  ["/t"] = "Teleport to temple",
  ["/a"] = "Teleport by tiles",
  ["/kick"] = "Kick a player",
  ["/send"] = "Send a player somewhere",
  ["/unban"] = "Unban a player",
  ["/town"] = "Teleport to a town",
  ["/up"] = "Go one floor up",
  ["/down"] = "Go one floor down",
  ["/reports"] = "Read reports",
  ["/mc"] = "Multi-client check",
  ["/wp"] = "Waypoint tools",
  ["/s"] = "Summon a creature",
  ["/n"] = "Create a monster by name",
  ["/m"] = "Create a monster",
  ["/reload"] = "Reload scripts or data",
  ["/raid"] = "Start a raid",
  ["/newtype"] = "Change outfit type",
  ["/storage"] = "Read or set storage",
  ["/config"] = "Show config values",
  ["/i"] = "Create an item",
  ["/z"] = "Play a magic effect",
  ["/x"] = "Play an animation effect",
  ["/y"] = "Show animated text",
  ["/mkick"] = "Mass kick players",
  ["/c"] = "Teleport a player to you",
  ["/serverdiag"] = "Server diagnostics",
  ["/mode"] = "Change game mode",
  ["/owner"] = "Set house owner",
  ["/cleanhouses"] = "Clean houses",
  ["/mergedepots"] = "Merge account depots",
  ["/bc"] = "Broadcast by class",
  ["/save"] = "Save the server",
  ["/clean"] = "Clean the map",
  ["/giveitem"] = "Give an item to a player",
  ["/checkvip"] = "Check VIP status",
  ["/delvip"] = "Remove VIP",
  ["/addvip"] = "Add VIP days",
  ["/vip"] = "VIP admin tools",
  ["/all"] = "Show all player infos",
  ["/attr"] = "Edit thing properties",
  ["/closeserver"] = "Close the server",
  ["/openserver"] = "Open the server",
  ["/promote"] = "Promote a player",
  ["/demote"] = "Demote a player",
  ["/shutdown"] = "Shutdown the server",
  ["/war"] = "Guild war management",
  ["/balance"] = "Guild balance management",
  ["/guild"] = "Guild broadcast",
}

local accessNames = {
  [0] = "Player",
  [1] = "Tutor",
  [2] = "Senior Tutor",
  [3] = "Gamemaster",
  [4] = "Community Manager",
  [5] = "God",
  [6] = "Admin",
}

local function describe(words)
  local first = words:match("^[^;]+") or words
  return descriptions[first] or descriptions[words]
end

function onSay(cid, words, param, channel)
  local playerAccess, t = getPlayerAccess(cid), {}
  for _, talk in ipairs(getTalkActionList()) do
    if not talk.hide and playerAccess >= talk.access then
      local tmp = talk.words:sub(1, 1):trim()
      if
        (config.guildTalksEnabled or (talk.words ~= "!joinguild" and talk.words ~= "!createguild"))
        and (tmp == "!" or tmp == "/")
      then
        table.insert(t, talk)
      end
    end
  end

  table.sort(t, function(a, b)
    if a.access ~= b.access then
      return a.access < b.access
    end
    return a.words < b.words
  end)

  local lastAccess, str = -1, ""
  for i, talk in ipairs(t) do
    if lastAccess ~= talk.access then
      if i ~= 1 then
        str = str .. "\n"
      end
      local label = accessNames[talk.access] or ("Access " .. talk.access)
      str = str .. "- " .. label .. " commands:\n"
      lastAccess = talk.access
    end

    local desc = describe(talk.words)
    if desc then
      str = str .. "\149 " .. talk.words .. " - " .. desc .. "\n"
    else
      str = str .. "\149 " .. talk.words .. "\n"
    end
  end

  doShowTextDialog(cid, 7528, str)
  return true
end
