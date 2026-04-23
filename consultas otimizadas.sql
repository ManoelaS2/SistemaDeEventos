-- 2 
select * from inscricao 
inner join pagamento on inscricao_id = inscricao_inscricao_id inner join eventos on eventos_eventos_id = eventos_id left join usuario on usuario_usuario_id = inscricao_id
where pagamento_status = "pago" and eventos_eventos_id = 5;

-- 1. Índice na tabela inscricao (Acelera o filtro do evento e o JOIN)
CREATE INDEX idx_inscricao_evento 
ON inscricao (eventos_eventos_id);

-- 2. Índice na tabela pagamento (Cobre o JOIN e o filtro de status simultaneamente)
CREATE INDEX idx_pagamento_inscricao_status 
ON pagamento (inscricao_inscricao_id, pagamento_status);

-- 3. Índice na tabela usuario (Cobre o JOIN e já traz o nome para o SELECT)
CREATE INDEX idx_usuario_id_nome 
ON usuario (usuario_usuario_id, usuario_nome);

SELECT 
    eventos.eventos_nome, 
    usuario.usuario_nome
FROM inscricao
INNER JOIN pagamento 
    ON inscricao.inscricao_id = pagamento.inscricao_inscricao_id
INNER JOIN eventos 
    ON inscricao.eventos_eventos_id = eventos.eventos_id
LEFT JOIN usuario 
    ON usuario.usuario_usuario_id = inscricao.inscricao_id 
WHERE pagamento.pagamento_status = 'pago' 
  AND inscricao.eventos_eventos_id = 5;
  
  -- ----------------------------------------------------------------------
  
  -- 3
select * from programacao 
left join imagemprogramacao on programacao_id = programacao_programacao_id left join sublocaEvento on sublocaEvento_sublocaEvento_id = sublocaEvento_id
where eventos_eventos_id = 5 order by programacao_horaInicio asc;

CREATE INDEX idx_programacao_evento_hora ON programacao (eventos_eventos_id, programacao_horaInicio);

select programacao_nome, programacao_horaInicio, programacao_horaFim, programacao_descricao, imagemProgramacao_caminho, imagemProgramacao_descricao, sublocaEvento_nome, sublocaEvento_descricao
from programacao inner join imagemprogramacao on programacao_id = programacao_programacao_id inner join sublocaEvento on sublocaEvento_sublocaEvento_id = sublocaEvento_id
where eventos_eventos_id = 5 order by programacao_horaInicio asc;