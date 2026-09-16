local shutdownEvent = 0
local shutdownEta = ""
local MAX_SHUTDOWN_MINUTES = 1440

local function etaSuffix()
  if shutdownEta == "" then
    return ""
  end
  local eta = shutdownEta:gsub("[%.!]+$", "")
  return " Previsão de retorno: " .. eta .. "."
end

local function sendUsage(cid)
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Uso de /shutdown:")
  doPlayerSendTextMessage(
    cid,
    MESSAGE_STATUS_CONSOLE_BLUE,
    "/shutdown <minutos>[, previsão de retorno] - agenda o desligamento (1-"
      .. MAX_SHUTDOWN_MINUTES
      .. " min, ou 0/now)"
  )
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "/shutdown now|0 - desliga o servidor agora")
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "/shutdown stop|parar - cancela a contagem")
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "/shutdown kill - encerra o processo do servidor")
  doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Exemplo: /shutdown 10, amanhã às 15h")
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
    doPlayerSendCancel(cid, "Parâmetro inválido. Digite /shutdown para ver o uso.")
    return true
  end

  if minutes > MAX_SHUTDOWN_MINUTES then
    doPlayerSendCancel(cid, "Máximo de " .. MAX_SHUTDOWN_MINUTES .. " minutos (1 dia).")
    return true
  end

  shutdownEta = eta and eta:match("^%s*(.-)%s*$") or ""
  clearShutdownEvent()
  return prepareShutdown(minutes)
end

function prepareShutdown(minutes)
  if minutes <= 0 then
    doBroadcastMessage("O servidor está desligando..." .. etaSuffix())
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
