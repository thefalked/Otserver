--[[
    Talking Tp/signs/tiles for TFS 0.2+
    70%shawak,30%Damadgerz
    Idea by Damadgerz
    O3: one event chain per player; clear on disconnect / cid reuse
    Never stopEvent the timer that is currently executing (TFS executeTimer iterator).
]]
--
local time = 5 -- 1 = 1 sec, 2 = 2 sec, ...

local say_events = {} -- guid -> eventId
local say_guids = {} -- cid -> guid (so disconnect can clear without getPlayerGUID)

-- stopTimers=false when called from SayText (the running event cleans itself up)
local function clearTreinando(cid, guid, stopTimers)
  if stopTimers == nil then
    stopTimers = true
  end
  local previousGuid = cid ~= nil and say_guids[cid] or nil
  if guid == nil then
    guid = previousGuid
  end
  -- stop leftover chain from a prior occupant of this cid
  if previousGuid ~= nil and previousGuid ~= guid and say_events[previousGuid] ~= nil then
    if stopTimers then
      stopEvent(say_events[previousGuid])
    end
    say_events[previousGuid] = nil
  end
  if guid ~= nil and say_events[guid] ~= nil then
    if stopTimers then
      stopEvent(say_events[guid])
    end
    say_events[guid] = nil
  end
  if cid ~= nil then
    say_guids[cid] = nil
  end
  if guid ~= nil then
    for c, g in pairs(say_guids) do
      if g == guid then
        say_guids[c] = nil
      end
    end
  end
end

local function SayText(cid)
  local mappedGuid = say_guids[cid]
  if isPlayer(cid) ~= TRUE then
    clearTreinando(cid, mappedGuid, false)
    return TRUE
  end
  local guid = getPlayerGUID(cid)
  -- cid was reused by another player before this tick ran
  if mappedGuid ~= nil and mappedGuid ~= guid then
    clearTreinando(nil, mappedGuid, false)
    return TRUE
  end
  if say_events[guid] ~= nil then
    doSendAnimatedText(getPlayerPosition(cid), "Treinando!", math.random(01, 255))
    say_events[guid] = addEvent(SayText, time * 1000 / 2, cid)
    say_guids[cid] = guid
  end
  return TRUE
end

function onSay(cid, words, param, channel)
  local usage = "Use: !treinando on or !treinando off"
  if param == "" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, usage)
    return TRUE
  end
  local guid = getPlayerGUID(cid)
  if param == "on" then
    -- live chain for this session only; treat leftover guid entries as stale
    if say_events[guid] ~= nil and say_guids[cid] == guid then
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, "You are already marked (treinando).")
      return TRUE
    end
    clearTreinando(cid, guid)
    doSendAnimatedText(getPlayerPosition(cid), "Treinando!", math.random(01, 255))
    say_events[guid] = addEvent(SayText, time * 1000, cid)
    say_guids[cid] = guid
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, "You Now Stated you are (treinando).")
  elseif param == "off" then
    clearTreinando(cid, guid)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, "You Now stated your are not (treinando).")
  else
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, usage)
  end
  return TRUE
end
