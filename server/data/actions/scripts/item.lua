function onUse(cid, item, fromPosition, itemEx, toPosition)
  local levels = 100
  doPlayerAddLevel(cid, levels)
  doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_BLUE)
  doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You received " .. levels .. " level.")
  doRemoveItem(item.uid, 1)
  return true
end
