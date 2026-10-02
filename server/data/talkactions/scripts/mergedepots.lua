-- Move orphan depot roots (pid ~= 1, pid < 100) into depot 1.
-- Keep the orphan depot until every direct child is verified under depot 1, then delete it.
-- Affected players are kicked, server closed (if it was open), and kept offline until merge SQL finishes.
-- Login lock is Lua-only (lib/051-mergedepots-lock.lua + login.lua). No C++ rebuild required.

local TARGET_DEPOT = 1
local POLL_MS = 500
local MAX_WAIT_POLLS = 240 -- 500ms * 240 = 120s
local SETTLE_POLLS = 4 -- 2s after world empty so logout saves finish before SQL

local mergeSession = {
  active = false,
  closedServer = false,
}

local function dbExec(sql)
  return db.query(sql) == true
end

-- Returns number on success, nil on query failure (never treat failure as zero).
-- COUNT(*) always yields a row, so getID()==-1 here is a real DB error.
local function queryCount(sql)
  local result = db.getResult(sql)
  if result:getID() == -1 then
    return nil
  end
  local n = result:getDataInt("n")
  result:free()
  return tonumber(n) or 0
end

local function collectAffectedPlayerIds()
  local n = queryCount(
    "SELECT COUNT(DISTINCT `player_id`) AS `n` FROM `player_depotitems` WHERE `pid` <> "
      .. TARGET_DEPOT
      .. " AND `pid` < 100"
  )
  if n == nil then
    return nil
  end
  if n == 0 then
    return {}
  end

  local ids = {}
  local result = db.getResult(
    "SELECT DISTINCT `player_id` FROM `player_depotitems` WHERE `pid` <> " .. TARGET_DEPOT .. " AND `pid` < 100"
  )
  if result:getID() == -1 then
    return nil
  end

  repeat
    ids[#ids + 1] = result:getDataInt("player_id")
  until not result:next()
  result:free()
  return ids
end

-- playerId -> sorted list of orphan depot town ids (pid 2, 3, …).
local function collectOrphanDepotsByPlayer()
  local n =
    queryCount("SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `pid` <> " .. TARGET_DEPOT .. " AND `pid` < 100")
  if n == nil then
    return nil
  end
  if n == 0 then
    return {}
  end

  local byPlayer = {}
  local result = db.getResult(
    "SELECT `player_id`, `pid` FROM `player_depotitems` WHERE `pid` <> "
      .. TARGET_DEPOT
      .. " AND `pid` < 100 ORDER BY `player_id`, `pid`"
  )
  if result:getID() == -1 then
    return nil
  end

  repeat
    local playerId = result:getDataInt("player_id")
    local depotPid = result:getDataInt("pid")
    local towns = byPlayer[playerId]
    if not towns then
      towns = {}
      byPlayer[playerId] = towns
    end
    if depotPid ~= towns[#towns] then
      towns[#towns + 1] = depotPid
    end
  until not result:next()
  result:free()
  return byPlayer
end

local function sendOrphanDepotPreview(cid)
  local byPlayer = collectOrphanDepotsByPlayer()
  if byPlayer == nil then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Database error while listing orphan depots.")
    return
  end

  local playerIds = {}
  for playerId in pairs(byPlayer) do
    playerIds[#playerIds + 1] = playerId
  end
  table.sort(playerIds)

  if #playerIds == 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No orphan depots found.")
    return
  end

  local onlineCount = 0
  for _, playerId in ipairs(playerIds) do
    if getPlayerByGUID(playerId) then
      onlineCount = onlineCount + 1
    end
  end

  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "Orphan depots: "
      .. #playerIds
      .. " player(s), "
      .. onlineCount
      .. " online. Say /mergedepots confirm to kick affected players, close logins, and merge."
  )

  local chunk = ""
  for _, playerId in ipairs(playerIds) do
    local towns = byPlayer[playerId]
    local name = getPlayerNameByGUID(playerId)
    if not name or name == "" then
      name = "?"
    end
    local online = getPlayerByGUID(playerId) and "ONLINE" or "offline"
    local line = "["
      .. online
      .. "] "
      .. name
      .. " (id "
      .. playerId
      .. "): depot town id "
      .. table.concat(towns, ", ")
      .. "."
    if #chunk + #line + 1 > 900 then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, chunk)
      chunk = line
    else
      chunk = chunk == "" and line or chunk .. "\n" .. line
    end
  end
  if chunk ~= "" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, chunk)
  end
end

local function getDepotRoots(playerId)
  local n =
    queryCount("SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `pid` < 100")
  if n == nil then
    return nil
  end
  if n == 0 then
    return {}
  end

  local roots = {}
  local result =
    db.getResult("SELECT `sid`, `pid` FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `pid` < 100")
  if result:getID() == -1 then
    return nil
  end

  repeat
    roots[#roots + 1] = {
      sid = result:getDataInt("sid"),
      pid = result:getDataInt("pid"),
    }
  until not result:next()
  result:free()
  return roots
end

-- Returns list, true on success. nil, false on query failure.
local function getDirectChildSids(playerId, parentSid)
  local n = queryCount(
    "SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `pid` = " .. parentSid
  )
  if n == nil then
    return nil, false
  end
  if n == 0 then
    return {}, true
  end

  local sids = {}
  local result = db.getResult(
    "SELECT `sid` FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `pid` = " .. parentSid
  )
  if result:getID() == -1 then
    return nil, false
  end

  repeat
    sids[#sids + 1] = result:getDataInt("sid")
  until not result:next()
  result:free()
  return sids, true
end

local function beginMergeSession()
  if mergeSession.active then
    return false
  end

  mergeSession.active = true
  mergeSession.closedServer = getGameState() ~= GAMESTATE_CLOSED
  if mergeSession.closedServer then
    doSetGameState(GAMESTATE_CLOSED)
  end
  return true
end

-- Always unlock and reopen. Safe to call more than once.
local function endMergeSession()
  local wasActive = mergeSession.active or mergeSession.closedServer
  mergeSession.active = false
  mergeSession.closedServer = false

  pcall(mergeDepotUnlockAll)
  if wasActive then
    -- Force open on success, abort, timeout, or Lua error. Never leave the world CLOSED.
    pcall(doSetGameState, GAMESTATE_NORMAL)
    print("> /mergedepots: server reopened (GAMESTATE_NORMAL).")
  end
end

local function kickAffectedOnline(affected)
  local kicked = 0
  for _, playerId in ipairs(affected) do
    local ok, pid = pcall(getPlayerByGUID, playerId)
    if ok and pid then
      if pcall(doRemoveCreature, pid, true) then
        kicked = kicked + 1
      end
    end
  end
  return kicked
end

local function kickAllOnline()
  local kicked = 0
  local ok, players = pcall(getPlayersOnline)
  if not ok or not players then
    return 0
  end
  for _, pid in ipairs(players) do
    if pcall(doRemoveCreature, pid, true) then
      kicked = kicked + 1
    end
  end
  return kicked
end

local function anyPlayersOnline()
  local ok, players = pcall(getPlayersOnline)
  return ok and players and #players > 0
end

local function anyAffectedStillInWorld(affected)
  for _, playerId in ipairs(affected) do
    local ok, pid = pcall(getPlayerByGUID, playerId)
    if ok and pid then
      return true
    end
  end
  return false
end

-- Run fn; on any Lua error reopen the server.
local function withSessionRescue(label, fn)
  local ok, err = pcall(fn)
  if not ok then
    print("> /mergedepots: ERROR in " .. label .. ": " .. tostring(err))
    endMergeSession()
  end
end

-- Reparent orphan locker contents under depot 1. Delete orphan only after verify.
-- Nested bags keep their own sid links. Only direct children of the locker move.
-- ponytail: START TRANSACTION via db.query; reconnect mid-txn can drop it. Abort and retry if verify fails.
local function mergeOrphanIntoTarget(playerId, orphanSid, targetSid)
  local childSids, listed = getDirectChildSids(playerId, orphanSid)
  if not listed then
    print("> /mergedepots: DB FAIL listing children player " .. playerId .. " orphan sid " .. orphanSid)
    return false, 0
  end

  local expected = #childSids

  if expected == 0 then
    if not dbExec("START TRANSACTION") then
      print("> /mergedepots: DB FAIL START TRANSACTION (empty) player " .. playerId .. " orphan sid " .. orphanSid)
      return false, 0
    end

    local childCount = queryCount(
      "SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `pid` = " .. orphanSid
    )
    if childCount == nil then
      dbExec("ROLLBACK")
      print("> /mergedepots: DB FAIL counting children player " .. playerId .. " orphan sid " .. orphanSid)
      return false, 0
    end
    if childCount ~= 0 then
      dbExec("ROLLBACK")
      print(
        "> /mergedepots: orphan sid "
          .. orphanSid
          .. " player "
          .. playerId
          .. " still has "
          .. childCount
          .. " children. Depot kept."
      )
      return false, 0
    end

    if
      not dbExec(
        "DELETE FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `sid` = " .. orphanSid .. " LIMIT 1"
      )
    then
      dbExec("ROLLBACK")
      print("> /mergedepots: DB FAIL delete empty orphan sid " .. orphanSid .. " player " .. playerId)
      return false, 0
    end

    local left = queryCount(
      "SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `sid` = " .. orphanSid
    )
    if left == nil or left ~= 0 then
      dbExec("ROLLBACK")
      print("> /mergedepots: delete verify FAIL orphan sid " .. orphanSid .. " player " .. playerId)
      return false, 0
    end

    if not dbExec("COMMIT") then
      dbExec("ROLLBACK")
      print("> /mergedepots: DB FAIL COMMIT (empty) orphan sid " .. orphanSid .. " player " .. playerId)
      return false, 0
    end
    return true, 0
  end

  if not dbExec("START TRANSACTION") then
    print("> /mergedepots: DB FAIL START TRANSACTION player " .. playerId .. " orphan sid " .. orphanSid)
    return false, 0
  end

  if
    not dbExec(
      "UPDATE `player_depotitems` SET `pid` = "
        .. targetSid
        .. " WHERE `player_id` = "
        .. playerId
        .. " AND `pid` = "
        .. orphanSid
    )
  then
    dbExec("ROLLBACK")
    print("> /mergedepots: DB FAIL UPDATE player " .. playerId .. " orphan sid " .. orphanSid)
    return false, 0
  end

  local stillUnderOrphan = queryCount(
    "SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `pid` = " .. orphanSid
  )
  local underTarget = queryCount(
    "SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `player_id` = "
      .. playerId
      .. " AND `pid` = "
      .. targetSid
      .. " AND `sid` IN ("
      .. table.concat(childSids, ",")
      .. ")"
  )

  if stillUnderOrphan == nil or underTarget == nil then
    dbExec("ROLLBACK")
    print("> /mergedepots: DB FAIL verify player " .. playerId .. " orphan sid " .. orphanSid .. ". Depot kept.")
    return false, 0
  end

  if stillUnderOrphan ~= 0 or underTarget ~= expected then
    dbExec("ROLLBACK")
    print(
      "> /mergedepots: VERIFY FAIL player "
        .. playerId
        .. " orphan sid "
        .. orphanSid
        .. " (left="
        .. stillUnderOrphan
        .. " moved="
        .. underTarget
        .. "/"
        .. expected
        .. "). Depot kept."
    )
    return false, 0
  end

  if
    not dbExec(
      "DELETE FROM `player_depotitems` WHERE `player_id` = " .. playerId .. " AND `sid` = " .. orphanSid .. " LIMIT 1"
    )
  then
    dbExec("ROLLBACK")
    print("> /mergedepots: DB FAIL DELETE orphan sid " .. orphanSid .. " player " .. playerId)
    return false, 0
  end

  if not dbExec("COMMIT") then
    dbExec("ROLLBACK")
    print("> /mergedepots: DB FAIL COMMIT player " .. playerId .. " orphan sid " .. orphanSid)
    return false, 0
  end
  return true, expected
end

local function pickTargetAndOrphans(roots, playerId)
  local depot1Roots = {}
  local orphans = {}

  for _, root in ipairs(roots) do
    if root.pid == TARGET_DEPOT then
      depot1Roots[#depot1Roots + 1] = root
    else
      orphans[#orphans + 1] = root
    end
  end

  table.sort(depot1Roots, function(a, b)
    return a.sid < b.sid
  end)

  local targetSid = nil
  if #depot1Roots > 0 then
    targetSid = depot1Roots[1].sid
    if #depot1Roots > 1 then
      print(
        "> /mergedepots: player "
          .. playerId
          .. " has "
          .. #depot1Roots
          .. " depot-1 lockers; using sid "
          .. targetSid
          .. " as target."
      )
      for i = 2, #depot1Roots do
        orphans[#orphans + 1] = depot1Roots[i]
      end
    end
  end

  return targetSid, orphans
end

local function mergePlayerDepots(playerId)
  local roots = getDepotRoots(playerId)
  if not roots then
    print("> /mergedepots: DB FAIL loading depot roots for player " .. playerId)
    return 0, 0, false
  end

  local targetSid, orphans = pickTargetAndOrphans(roots, playerId)

  if #orphans == 0 then
    return 0, 0, true
  end

  -- No depot 1 yet: promote first orphan locker to town 1. Items stay put.
  if not targetSid then
    local first = table.remove(orphans, 1)
    if
      not dbExec(
        "UPDATE `player_depotitems` SET `pid` = "
          .. TARGET_DEPOT
          .. " WHERE `player_id` = "
          .. playerId
          .. " AND `sid` = "
          .. first.sid
          .. " LIMIT 1"
      )
    then
      print("> /mergedepots: promote FAIL (UPDATE) player " .. playerId .. " sid " .. first.sid)
      return 0, 0, false
    end
    local ok = queryCount(
      "SELECT COUNT(*) AS `n` FROM `player_depotitems` WHERE `player_id` = "
        .. playerId
        .. " AND `sid` = "
        .. first.sid
        .. " AND `pid` = "
        .. TARGET_DEPOT
    )
    if ok == nil or ok ~= 1 then
      print("> /mergedepots: promote FAIL player " .. playerId .. " sid " .. first.sid)
      return 0, 0, false
    end
    targetSid = first.sid
    if #orphans == 0 then
      return 1, 0, true
    end
  end

  local mergedRoots, movedItems, allOk = 0, 0, true
  for _, orphan in ipairs(orphans) do
    local ok, moved = mergeOrphanIntoTarget(playerId, orphan.sid, targetSid)
    if ok then
      mergedRoots = mergedRoots + 1
      movedItems = movedItems + moved
    else
      allOk = false
    end
  end
  return mergedRoots, movedItems, allOk
end

local function runMerge(affected, kicked)
  local playersMerged, rootsMerged, itemsMoved, failed = 0, 0, 0, 0
  for _, playerId in ipairs(affected) do
    local roots, items, ok = mergePlayerDepots(playerId)
    if roots > 0 then
      playersMerged = playersMerged + 1
      rootsMerged = rootsMerged + roots
      itemsMoved = itemsMoved + items
    end
    if not ok then
      failed = failed + 1
    end
  end

  print(
    "> /mergedepots: players="
      .. playersMerged
      .. " roots="
      .. rootsMerged
      .. " directItems="
      .. itemsMoved
      .. " failedPlayers="
      .. failed
      .. " kicked="
      .. kicked
  )
end

local function abortMerge(reason, kicked)
  print("> /mergedepots: ABORT " .. reason .. " kicked=" .. kicked)
  endMergeSession()
end

local function waitForEmptyWorldThenMerge(affected, kicked, poll, settle)
  settle = settle or 0
  withSessionRescue("waitForEmptyWorldThenMerge", function()
    if anyPlayersOnline() then
      if poll >= MAX_WAIT_POLLS then
        abortMerge("timed out waiting for all players to leave before SQL merge", kicked)
        return
      end
      kicked = kicked + kickAllOnline()
      addEvent(function()
        waitForEmptyWorldThenMerge(affected, kicked, poll + 1, 0)
      end, POLL_MS)
      return
    end

    -- World empty; wait a few more ticks so force-logout saves finish before SQL.
    if settle < SETTLE_POLLS then
      addEvent(function()
        waitForEmptyWorldThenMerge(affected, kicked, poll, settle + 1)
      end, POLL_MS)
      return
    end

    local ok, err = pcall(runMerge, affected, kicked)
    if not ok then
      print("> /mergedepots: ERROR during merge: " .. tostring(err))
    end
    endMergeSession()
  end)
end

local function startSqlMergePhase(affected, kicked)
  withSessionRescue("startSqlMergePhase", function()
    local extraKicked = kickAllOnline()
    kicked = kicked + extraKicked
    addEvent(function()
      waitForEmptyWorldThenMerge(affected, kicked, 0, 0)
    end, POLL_MS)
  end)
end

local function waitForOfflineThenMerge(affected, kicked, poll)
  withSessionRescue("waitForOfflineThenMerge", function()
    kickAffectedOnline(affected)

    if anyAffectedStillInWorld(affected) then
      if poll >= MAX_WAIT_POLLS then
        abortMerge("timed out waiting for affected players to leave the game (still online or pending save)", kicked)
        return
      end
      addEvent(function()
        waitForOfflineThenMerge(affected, kicked, poll + 1)
      end, POLL_MS)
      return
    end

    startSqlMergePhase(affected, kicked)
  end)
end

function onSay(cid, words, param, channel)
  param = param and param:lower():gsub("^%s+", ""):gsub("%s+$", "") or ""

  if param == "confirm" then
    -- merge below
  else
    if param ~= "" and param ~= "preview" and param ~= "list" then
      doPlayerSendTextMessage(
        cid,
        MESSAGE_STATUS_CONSOLE_BLUE,
        "Usage: /mergedepots (preview) or /mergedepots confirm to merge orphan depots into depot 1."
      )
      return true
    end
    sendOrphanDepotPreview(cid)
    return true
  end

  if mergeSession.active then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "A depot merge is already in progress.")
    return true
  end

  local affected = collectAffectedPlayerIds()
  if affected == nil then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Database error while listing orphan depots.")
    return true
  end

  if #affected == 0 then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No orphan depots found.")
    return true
  end

  -- Lock before CLOSED so CanAlwaysLogin staff cannot load mid-kick window.
  mergeDepotLockGuids(affected)

  if not beginMergeSession() then
    mergeDepotUnlockAll()
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Could not start merge session.")
    return true
  end

  local started, kickErr = pcall(function()
    local kicked = kickAffectedOnline(affected)

    doPlayerSendTextMessage(
      cid,
      MESSAGE_STATUS_CONSOLE_BLUE,
      "Merging orphan depots for "
        .. #affected
        .. " player(s). Kicked "
        .. kicked
        .. ". Server closed until merge completes. All players will be kicked before SQL runs. See console."
    )

    addEvent(function()
      waitForOfflineThenMerge(affected, kicked, 0)
    end, POLL_MS)
  end)

  if not started then
    print("> /mergedepots: ERROR starting merge: " .. tostring(kickErr))
    endMergeSession()
  end

  return true
end
