-- O15: previously contained unsanitized SQL (password/account/name changes).
-- Not registered in talkactions.xml; kept as a no-op stub so accidental
-- registration cannot revive the injection.
function onSay(cid, words, param, channel)
  doPlayerSendCancel(cid, "This command is disabled.")
  return true
end
