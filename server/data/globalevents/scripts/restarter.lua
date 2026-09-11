local message = {
    "O servidor vai desligar em 5 minutos. Por favor, deslogue com segurança.",
    "O servidor vai desligar em 2 minutos, por favor deslogue.",
    "O servidor está desligando...",
}
local class = 21

function shutDown()
    doBroadcastMessage(message[3], class)
    doSetGameState(GAMESTATE_SHUTDOWN)
    return true
end

function broadcast()
    doBroadcastMessage(message[2], class)
    return true
end

function onThink(interval, lastExecution)
    local result_plr = db.getResult("SELECT * FROM `z_shut` WHERE `id` = 1;")
    if result_plr:getID() == -1 then
        return true
    end

    if tonumber(result_plr:getDataInt("shutdown")) == 1 then
        db.query("UPDATE `z_shut` SET `shutdown` = '0' WHERE `id` = '1';")
        if tonumber(result_plr:getDataInt("long")) == 0 then
            doBroadcastMessage(message[3], class)
            doSetGameState(GAMESTATE_SHUTDOWN)
        else
            doBroadcastMessage(message[1], class)
            addEvent(broadcast, 3 * 60 * 1000)
            addEvent(shutDown, 5 * 60 * 1000)
        end
    end

    result_plr:free()
    return true
end
