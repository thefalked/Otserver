-- In-memory login block for /mergedepots (no C++ rebuild). Cleared when merge finishes or aborts.
MERGE_DEPOT_BLOCKED_GUIDS = MERGE_DEPOT_BLOCKED_GUIDS or {}

function mergeDepotLockGuids(guids)
  for _, id in ipairs(guids) do
    MERGE_DEPOT_BLOCKED_GUIDS[id] = true
  end
end

function mergeDepotUnlockAll()
  MERGE_DEPOT_BLOCKED_GUIDS = {}
end

function isMergeDepotBlockedGuid(guid)
  return MERGE_DEPOT_BLOCKED_GUIDS[guid] == true
end

-- Return true so onLogin fails; onPlacedCreature kicks once (do not remove here).
function kickIfMergeDepotBlocked(cid)
  if not isMergeDepotBlockedGuid(getPlayerGUID(cid)) then
    return false
  end

  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "Your depot is being updated. Please try again in a few minutes."
  )
  return true
end
