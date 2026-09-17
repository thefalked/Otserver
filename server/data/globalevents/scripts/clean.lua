function executeClean()
  doCleanMap()
  doBroadcastMessage("Clear")
  return true
end

function onThink(interval, lastExecution, thinkInterval)
  doBroadcastMessage("Retirando Lixo Do Ot, Retire Seus Itens Do Ch\227o")
  addEvent(executeClean, 50000)
  return true
end
