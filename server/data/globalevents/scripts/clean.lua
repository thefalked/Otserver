function executeClean()
  doCleanMap()
  return true
end

function onThink(interval, lastExecution, thinkInterval)
  doBroadcastMessage("The OT will be cleaned. Pick up your items from the floor.")
  addEvent(executeClean, 50000)
  return true
end
