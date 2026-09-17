function onThink(interval, lastExecution)
  -- Configurações
  local cor = 22 -- Defina a cor da mensagem (22 = branco)
  local mensagens = {
    "MANUTEN\199\195O HOJE AS 18:30 AT\201 AS 19:00\nNO M\193XIMO",
  }

  -- Fim de Configurações

  doBroadcastMessage(mensagens[math.random(1, table.maxn(mensagens))], cor)
  return TRUE
end
