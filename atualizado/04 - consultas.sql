use eventos;

SELECT * FROM usuario
INNER JOIN inscricao 
    ON inscricao_usuario_id = usuario_id
INNER JOIN eventos 
    ON eventos_id = inscricao_eventos_id
INNER JOIN certificados 
    ON certificados_inscricao_id = inscricao_id
WHERE inscricao_usuario_id = 8
ORDER BY certificados_dataDeEmissao DESC;

SELECT 
    usuario_nome, 
    eventos_nome, 
    eventos_descricao, 
    eventos_dataInicio, 
    eventos_dataFim, 
    certificados_cargaHorariaTotal, 
    certificados_dataDeEmissao 
FROM usuario 
INNER JOIN inscricao 
    ON inscricao_usuario_id = usuario_id 
INNER JOIN eventos 
    ON eventos_id = inscricao_eventos_id 
INNER JOIN certificados 
    ON certificados_inscricao_id = inscricao_id 
WHERE inscricao_usuario_id = 8 
ORDER BY certificados_dataDeEmissao DESC;

-- consulta 2

SELECT * FROM inscricao 
INNER JOIN pagamento 
    ON pagamento_inscricao_id = inscricao_id 
INNER JOIN usuario 
    ON inscricao_usuario_id = usuario_id 
WHERE inscricao_eventos_id = 2 
  AND pagamento_status = 'Pago' 
ORDER BY pagamento_dataHora ASC;

CREATE INDEX idx_inscricao_evento_usuario ON inscricao (inscricao_eventos_id, inscricao_usuario_id);
CREATE INDEX idx_pagamento_performance ON pagamento (pagamento_inscricao_id, pagamento_status, pagamento_dataHora);
CREATE INDEX idx_usuario_id_nome ON usuario (usuario_id, usuario_nome);
	 
SELECT usuario_nome 
FROM inscricao 
INNER JOIN pagamento 
    ON pagamento_inscricao_id = inscricao_id 
INNER JOIN usuario 
    ON inscricao_usuario_id = usuario_id 
WHERE inscricao_eventos_id = 2
  AND pagamento_status = 'Pago' 
ORDER BY pagamento_dataHora ASC;
	
-- consulta 3

SELECT * FROM programacao 
LEFT JOIN imagemprogramacao 
    ON programacao_id = imagemprogramacao_programacao_id 
LEFT JOIN sublocalEvento 
    ON programacao_sublocaEvento_id = sublocalEvento_id 
WHERE programacao_eventos_id = 5 
ORDER BY programacao_horaInicio ASC;

CREATE INDEX idx_programacao_evento_hora ON programacao (programacao_eventos_id, programacao_horaInicio);

SELECT 
    programacao_nome, 
    programacao_horaInicio, 
    programacao_horaFim, 
    programacao_descricao, 
    imagemProgramacao_caminho, 
    imagemProgramacao_descricao, 
    sublocalEvento_nome, 
    sublocalEvento_descricao 
FROM programacao 
INNER JOIN imagemProgramacao 
    ON programacao_id = imagemProgramacao_programacao_id 
INNER JOIN sublocalEvento 
    ON programacao_sublocaEvento_id = sublocalEvento_id 
WHERE programacao_eventos_id = 5 
ORDER BY programacao_horaInicio ASC;

-- pesquisa 4

SELECT 
    cidade_nome AS cidade, 
    COUNT(DISTINCT usuario_id) AS quantidade_usuarios 
FROM usuario 
INNER JOIN endereco 
    ON endereco_usuario_id = usuario_id 
INNER JOIN cep 
    ON endereco_cep_id = cep_id 
INNER JOIN cidade 
    ON cep_cidade_id = cidade_id 
WHERE cidade_nome IS NOT NULL 
  AND cidade_nome != '' 
GROUP BY cidade_id, cidade_nome 
ORDER BY quantidade_usuarios DESC;

CREATE INDEX idx_endereco_usuario ON endereco (endereco_usuario_id);
CREATE INDEX idx_endereco_cep ON endereco (endereco_cep_id);
CREATE INDEX idx_cep_cidade ON cep (cep_cidade_id);
CREATE INDEX idx_cidade_nome ON cidade (cidade_nome);

SELECT 
    cidade_nome AS cidade, 
    COUNT(usuario_id) AS quantidade_usuarios 
FROM cidade 
INNER JOIN cep 
    ON cidade_id = cep_cidade_id 
INNER JOIN endereco 
    ON cep_id = endereco_cep_id 
INNER JOIN usuario 
    ON endereco_usuario_id = usuario_id 
WHERE cidade_nome > '' 
GROUP BY cidade_id 
ORDER BY quantidade_usuarios DESC;

-- pesquisa 5

SELECT 
    SUM(CASE WHEN inscricao_credenciamento = 1 AND pagamento_status = 'Pago' THEN pagamento_valorTotal ELSE 0 END) AS Valor_total_arrecadado, 
    SUM(CASE WHEN inscricao_credenciamento = 1 THEN 1 ELSE 0 END) AS Quantidade_Inscritos_confirmados, 
    SUM(CASE WHEN inscricao_credenciamento = 0 THEN 1 ELSE 0 END) AS Quantidade_Inscritos_Nao_confirmados, 
    SUM(CASE WHEN inscricao_credenciamento = 0 THEN pagamento_valorTotal ELSE 0 END) AS Valor_total_estimado 
FROM pagamento 
LEFT JOIN inscricao 
    ON pagamento_inscricao_id = inscricao_id;
    
CREATE INDEX idx_inscricao_id_credenciamento ON inscricao (inscricao_id, inscricao_credenciamento);
CREATE INDEX idx_pagamento_inscricaoId_valorpagamento_status ON pagamento (pagamento_inscricao_id, pagamento_valorTotal, pagamento_status);
	
SELECT 
    SUM(CASE WHEN inscricao_credenciamento = 1 AND pagamento_status = 'Pago' THEN pagamento_valorTotal ELSE 0 END) AS Valor_total_arrecadado, 
    COALESCE(SUM(inscricao_credenciamento = 1), 0) AS Quantidade_Inscritos_confirmados, 
    COALESCE(SUM(inscricao_credenciamento = 0), 0) AS Quantidade_Inscritos_Nao_confirmados, 
    SUM(CASE WHEN inscricao_credenciamento = 0 THEN pagamento_valorTotal ELSE 0 END) AS Valor_total_estimado 
FROM pagamento 
LEFT JOIN inscricao 
    ON pagamento_inscricao_id = inscricao_id;
    
-- select 6

SELECT 
    *, 
    CASE 
        WHEN NOW() <= eventos_dataLimiteInscricao THEN 'INSCRIÇÕES ABERTAS' 
        WHEN NOW() BETWEEN eventos_dataInicio AND eventos_dataFim THEN 'EM ANDAMENTO' 
        WHEN NOW() < eventos_dataInicio THEN 'FUTURO' 
        ELSE 'ENCERRADO' 
    END AS status_evento 
FROM eventos;

CREATE INDEX idx_evento_id_nome_inicio_fim_limiteInscricao 
ON eventos (eventos_id, eventos_nome, eventos_dataInicio, eventos_dataFim, eventos_dataLimiteInscricao);

SELECT 
    eventos_id, 
    eventos_nome, 
    eventos_dataInicio, 
    eventos_dataFim, 
    eventos_dataLimiteInscricao, 
    CASE 
        WHEN NOW() <= eventos_dataLimiteInscricao THEN 'INSCRIÇÕES ABERTAS' 
        WHEN NOW() BETWEEN eventos_dataInicio AND eventos_dataFim THEN 'EM ANDAMENTO' 
        WHEN NOW() < eventos_dataInicio THEN 'FUTURO' 
        ELSE 'ENCERRADO' 
    END AS status_evento 
FROM eventos;

-- pesquisa 7

SELECT 
    eventos_nome, 
    COUNT(voucher_id) AS total_vouchers, 
    SUM(CASE WHEN voucher_disponivel = 1 THEN 1 ELSE 0 END) AS disponiveis, 
    SUM(CASE WHEN voucher_disponivel = 0 THEN 1 ELSE 0 END) AS usados 
FROM eventos 
LEFT JOIN voucher 
    ON eventos_id = voucher_eventos_id 
GROUP BY eventos_id, eventos_nome 
ORDER BY total_vouchers DESC;
	
CREATE INDEX idx_voucher_evento_disp ON voucher (voucher_eventos_id, voucher_disponivel);
CREATE INDEX idx_eventos_id_nome ON eventos (eventos_id, eventos_nome);

SELECT 
    eventos_nome, 
    COUNT(voucher_id) AS total_vouchers, 
    COALESCE(SUM(voucher_disponivel = 1), 0) AS disponiveis, 
    COALESCE(SUM(voucher_disponivel = 0), 0) AS usados, 
    COALESCE(ROUND(SUM(voucher_disponivel = 0) * 100.0 / NULLIF(COUNT(voucher_id), 0), 2), 0) AS percentual_uso 
FROM eventos 
LEFT JOIN voucher 
    ON eventos_id = voucher_eventos_id 
GROUP BY eventos_id, eventos_nome 
ORDER BY total_vouchers DESC;

-- pesqisa 8

SELECT DISTINCT 
    *, 
    (SELECT 
        CASE WHEN LOWER(permissoes_nome) LIKE '%criar_evento%' THEN 'SIM' ELSE 'NÃO' END 
     FROM permissoes 
     JOIN permissoesusuarios 
        ON permissoes_id = permissoesusuarios_permissoes_id 
     WHERE permissoesusuarios_usuario_id = usuario_id 
     LIMIT 1
    ) AS pode_criar_evento 
FROM eventos 
JOIN usuario 
    ON usuario_id = eventos_criador_usuario_id 
LEFT JOIN permissoesusuarios 
    ON permissoesusuarios_usuario_id = usuario_id 
LEFT JOIN permissoes 
    ON permissoes_id = permissoesusuarios_permissoes_id 
ORDER BY RAND();

CREATE INDEX idx_eventos_id_nome_inicio_fim ON eventos (eventos_id, eventos_nome, eventos_dataInicio, eventos_dataFim);
CREATE INDEX idx_usuario_id_nome_email ON usuario (usuario_id, usuario_nome, usuario_email);

SELECT 
    eventos_id, 
    eventos_nome, 
    eventos_descricao, 
    eventos_dataInicio, 
    eventos_dataFim, 
    usuario_id, 
    usuario_nome, 
    usuario_email, 
    CASE WHEN permissoes_nome = 'criar_evento' THEN 'SIM' ELSE 'NÃO' END AS pode_criar_evento 
FROM eventos 
JOIN usuario 
    ON usuario_id = eventos_criador_usuario_id 
LEFT JOIN permissoesusuarios 
    ON permissoesusuarios_usuario_id = usuario_id 
LEFT JOIN permissoes 
    ON permissoes_id = permissoesusuarios_permissoes_id;
	
-- pesquisa 9

SELECT 
    (SELECT eventos_nome FROM eventos WHERE eventos_id = programacao_eventos_id) AS EVENTO, 
    programacao_nome AS ATIVIDADE, 
    DATE_FORMAT(programacao_horaInicio, '%d/%m/%Y %H:%i') AS DATA_HORA, 
    COALESCE(
        (SELECT papel_nome 
         FROM papel 
         JOIN papelProgramacao 
            ON papel_id = papelProgramacao_papel_id 
         WHERE papelProgramacao_inscricao_id = inscricao_id 
           AND papelProgramacao_programacao_id = programacao_id 
         LIMIT 1), 
        'Participante'
    ) AS FUNCAO, 
    usuario_nome AS NOME, 
    usuario_email AS EMAIL, 
    CASE 
        WHEN (SELECT inscritosProgramacao_FrequenciaConfirmada 
              FROM inscritosProgramacao 
              WHERE inscritosProgramacao_programacao_id = programacao_id 
                AND inscritosProgramacao_inscritos_id = inscricao_id
              LIMIT 1) = 1 THEN 'Confirmado' 
        WHEN (SELECT inscritosProgramacao_FrequenciaConfirmada 
              FROM inscritosProgramacao 
              WHERE inscritosProgramacao_programacao_id = programacao_id 
                AND inscritosProgramacao_inscritos_id = inscricao_id 
              LIMIT 1) = 0 THEN 'Ausente' 
        ELSE 'Pendente' 
    END AS STATUS_PRESENCA, 
    DATE_FORMAT(
        (SELECT inscritosProgramacao_dataHoraFrequencia 
         FROM inscritosProgramacao 
         WHERE inscritosProgramacao_programacao_id = programacao_id 
           AND inscritosProgramacao_inscritos_id = inscricao_id 
         LIMIT 1), 
        '%d/%m/%Y %H:%i:%s'
    ) AS DATA_CHECKIN 
FROM programacao 
INNER JOIN inscritosProgramacao 
    ON programacao_id = inscritosProgramacao_programacao_id 
INNER JOIN inscricao 
    ON inscritosProgramacao_inscritos_id = inscricao_id 
INNER JOIN usuario 
    ON inscricao_usuario_id = usuario_id 
WHERE programacao_id = 3 
ORDER BY usuario_nome ASC;


		
CREATE INDEX idx_programacao_id_evento ON programacao(programacao_id, programacao_eventos_id);
CREATE INDEX idx_inscritos_prog_programacao ON inscritosProgramacao(inscritosProgramacao_programacao_id, inscritosProgramacao_inscritos_id);
CREATE INDEX idx_inscricao_id_usuario ON inscricao(inscricao_id, inscricao_usuario_id);
CREATE INDEX idx_papel_prog_composto ON papelProgramacao(papelProgramacao_programacao_id, papelProgramacao_inscricao_id);


SELECT 
    e.eventos_nome AS EVENTO, 
    p.programacao_nome AS ATIVIDADE, 
    DATE_FORMAT(p.programacao_horaInicio, '%d/%m/%Y %H:%i') AS DATA_HORA, 
    COALESCE(pap.papel_nome, 'Participante') AS FUNCAO, 
    u.usuario_nome AS NOME, 
    u.usuario_email AS EMAIL, 
    CASE 
        WHEN ip.inscritosProgramacao_FrequenciaConfirmada = 1 THEN 'Confirmado' 
        WHEN ip.inscritosProgramacao_FrequenciaConfirmada = 0 THEN 'Ausente' 
        ELSE 'Pendente' 
    END AS STATUS_PRESENCA, 
    DATE_FORMAT(ip.inscritosProgramacao_dataHoraFrequencia, '%d/%m/%Y %H:%i:%s') AS DATA_CHECKIN 
FROM programacao p 
INNER JOIN eventos e 
    ON p.programacao_eventos_id = e.eventos_id 
INNER JOIN inscritosProgramacao ip 
    ON p.programacao_id = ip.inscritosProgramacao_programacao_id 
INNER JOIN inscricao i 
    ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id 
INNER JOIN usuario u 
    ON i.inscricao_usuario_id = u.usuario_id 
LEFT JOIN papelProgramacao pp 
    ON i.inscricao_id = pp.papelProgramacao_inscricao_id 
    AND p.programacao_id = pp.papelProgramacao_programacao_id 
LEFT JOIN papel pap 
    ON pp.papelProgramacao_papel_id = pap.papel_id 
WHERE p.programacao_id = 3 
ORDER BY 
    FIELD(pap.papel_nome, 'Organizador', 'Coordenador', 'Palestrante', 'Staff', 'Auxiliar', 'Participante'), 
    u.usuario_nome ASC;
	-- consulata 10

	select * from telefone where telefone_usuario_id = 1;

	create index idx_telefone_ddi_ddd_telefone_usuario on telefone(telefone_ddi,telefone_ddd, telefone_telefone, telefone_usuario_id);

	select telefone_ddi, telefone_ddd, telefone_telefone from telefone where telefone_usuario_id = 1;
