local shutdownEvent = 0
local shutdownEta = ""
local MAX_SHUTDOWN_MINUTES = 1440

-- Tibia 8.6 / OTClient expect ISO-8859-1 (Latin-1), not UTF-8.
-- Accents use decimal escapes so this file stays ASCII-safe.
-- a-acute=225 e-acute=233 i-acute=237 o-acute=243 u-acute=250
-- a-tilde=227 a-grave=224 a-circumflex=226 c-cedilla=231

local function etaSuffix()
  if shutdownEta == "" then
    return ""
  end
  local eta = shutdownEta:gsub("[%.!]+$", "")
  return " Previs\227o de retorno: " .. eta .. "."
end

local function sendUsage(cid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Uso de /shutdown:")
  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "/shutdown <minutos>[, previs\227o de retorno] - agenda o desligamento (1-"
      .. MAX_SHUTDOWN_MINUTES
      .. " min, ou 0/now)"
  )
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "/shutdown now|0 - desliga o servidor agora")
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "/shutdown stop|parar - cancela a contagem")
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "/shutdown kill - encerra o processo do servidor")
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Exemplo: /shutdown 10, amanh\227 \224s 15h")
end

local function clearShutdownEvent()
  if shutdownEvent ~= 0 then
    stopEvent(shutdownEvent)
    shutdownEvent = 0
  end
end

function onSay(cid, words, param, channel)
  param = param:match("^%s*(.-)%s*$") or ""

  if param == "" then
    sendUsage(cid)
    return true
  end

  local lower = param:lower()
  if lower == "stop" or lower == "parar" then
    if shutdownEvent ~= 0 then
      clearShutdownEvent()
      shutdownEta = ""
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Contagem de desligamento cancelada.")
    else
      shutdownEta = ""
      doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Nenhuma contagem de desligamento agendada.")
    end
    return true
  elseif lower == "kill" then
    os.exit()
    return true
  elseif lower == "now" then
    clearShutdownEvent()
    shutdownEta = ""
    return prepareShutdown(0)
  end

  local minutes, eta = param:match("^(%d+)%s*,%s*(.+)$")
  if not minutes then
    minutes = param:match("^(%d+)$")
  end

  minutes = tonumber(minutes)
  if not minutes then
    doPlayerSendCancel(cid, "Par\226metro inv\225lido. Digite /shutdown para ver o uso.")
    return true
  end

  if minutes > MAX_SHUTDOWN_MINUTES then
    doPlayerSendCancel(cid, "M\225ximo de " .. MAX_SHUTDOWN_MINUTES .. " minutos (1 dia).")
    return true
  end

  shutdownEta = eta and eta:match("^%s*(.-)%s*$") or ""
  clearShutdownEvent()
  return prepareShutdown(minutes)
end

function prepareShutdown(minutes)
  if minutes <= 0 then
    doBroadcastMessage("O servidor est\225 desligando..." .. etaSuffix())
    shutdownEvent = 0
    shutdownEta = ""
    doSetGameState(GAMESTATE_SHUTDOWN)
    return true
  end

  local suffix = etaSuffix()
  if minutes == 1 then
    doBroadcastMessage("O servidor vai desligar em 1 minuto, por favor deslogue agora!" .. suffix)
  elseif minutes <= 3 then
    doBroadcastMessage("O servidor vai desligar em " .. minutes .. " minutos, por favor deslogue." .. suffix)
  else
    doBroadcastMessage("O servidor vai desligar em " .. minutes .. " minutos." .. suffix)
  end

  shutdownEvent = addEvent(prepareShutdown, 60000, minutes - 1)
  return true
end
