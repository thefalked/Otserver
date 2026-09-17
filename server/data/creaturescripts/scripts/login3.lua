local message = "Seja bem vindo ao Alissow OTs!\n \nUtilize o canal help para maiores informa\231\245es.\n \nEnjoy xD"

function onLogin(cid)
  local msg = string.lower(param)
  if message[msg] ~= nil then
    str = getPlayerPopupFYI(message[msg][1])
  else
    str = getPlayerPopupFYI(8)
  end

  doPlayerPopupFYI(cid, message)
  return TRUE
end
