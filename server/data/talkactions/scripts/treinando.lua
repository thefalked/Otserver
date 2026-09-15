--[[
    Talking Tp/signs/tiles for TFS 0.2+
    70%shawak,30%Damadgerz
    Idea by Damadgerz
    O3: stop previous event before starting a new chain
]]
--
local time = 5 -- 1 = 1 sec, 2 = 2 sec, ...

local say_events = {}
local function SayText(cid)
  if isPlayer(cid) == TRUE then
    local guid = getPlayerGUID(cid)
    if say_events[guid] ~= nil then
      doSendAnimatedText(getPlayerPosition(cid), "Treinando!", math.random(01, 255))
      say_events[guid] = addEvent(SayText, time * 1000 / 2, cid)
    end
  end
  return TRUE
end
function onSay(cid, words, param, channel)
  if param == "" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Command param required.")
    return true
  end
  local guid = getPlayerGUID(cid)
  if param == "on" then
    if say_events[guid] ~= nil then
      stopEvent(say_events[guid])
      say_events[guid] = nil
    end
    if isPlayer(cid) == TRUE then
      doSendAnimatedText(getPlayerPosition(cid), "Treinando!", math.random(01, 255))
    end
    say_events[guid] = addEvent(SayText, time * 1000, cid)
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, "You Now Stated you are (afk).")
  elseif param == "off" then
    if say_events[guid] ~= nil then
      stopEvent(say_events[guid])
      say_events[guid] = nil
    end
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_WARNING, "You Now stated your are not (afk).")
  end
  return TRUE
end
