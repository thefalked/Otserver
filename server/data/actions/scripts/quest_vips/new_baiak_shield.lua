function onUse(cid, item, frompos, item2, topos)
	if item.uid == 9055 then
		queststatus = getPlayerStorageValue(cid, 90061)
		if queststatus == -1 then
			doPlayerSendTextMessage(cid, 22, "Você Ganhou Uma Master Shield!.")
			doPlayerSendTextMessage(cid, 22, "Você Ganhou Uma Master Boots!.")
			doPlayerAddItem(cid, 6433, 1)
			doPlayerAddItem(cid, 5462, 1)
			setPlayerStorageValue(cid, 90061, 1)
		else
			doPlayerSendTextMessage(cid, 22, "Você ja fez essa quest!")
		end
	else
		return 0
	end
	return 1
end
