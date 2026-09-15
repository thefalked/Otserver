--- Script by esK~---
--- Notice System 0.1 Beta ---
function onSay(cid, words, param)
  local file = io.open("noticias.txt", "r")
  if not file then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No notices available.")
    return true
  end
  local notice = file:read("*a")
  file:close()
  if not notice or notice == "" then
    doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "No notices available.")
    return true
  end
  doShowTextDialog(cid, 7528, notice)
  return true
end
