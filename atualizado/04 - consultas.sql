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

explain analyze SELECT * FROM inscricao 
INNER JOIN pagamento 
    ON pagamento_inscricao_id = inscricao_id 
INNER JOIN usuario 
    ON inscricao_usuario_id = usuario_id 
WHERE inscricao_eventos_id = 2 
  AND pagamento_status = 'Pago' 
ORDER BY pagamento_dataHora ASC;


CREATE INDEX idx_inscricao_performance ON inscricao (inscricao_eventos_id, inscricao_usuario_id, inscricao_id);

CREATE INDEX idx_pagamento_status_data ON pagamento (pagamento_status, pagamento_inscricao_id, pagamento_dataHora);

CREATE INDEX idx_usuario_id_nome ON usuario (usuario_id, usuario_nome);
	 
SELECT 
    usuario_nome
FROM inscricao
INNER JOIN pagamento
    ON pagamento_inscricao_id = inscricao_id
INNER JOIN usuario
    ON inscricao_usuario_id = usuario_id
WHERE 
    inscricao_eventos_id = 2 
    AND pagamento_status = 'Pago'
ORDER BY 
    pagamento_dataHora ASC;
	
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
CREATE INDEX idx_cidade_nome ON cidade (cidade_nome);
CREATE INDEX idx_cidade_performance ON cidade (cidade_id, cidade_nome);
CREATE INDEX idx_cep_cidade_id ON cep (cep_cidade_id, cep_id);
CREATE INDEX idx_endereco_cep_usuario ON endereco (endereco_cep_id, endereco_usuario_id);

explain analyze SELECT 
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

explain analyze SELECT 
    cidade_nome AS cidade, 
    COUNT(endereco_usuario_id) AS quantidade_usuarios 
FROM cidade 
INNER JOIN cep 
    ON cidade_id = cep_cidade_id
INNER JOIN endereco 
    ON cep_id = endereco_cep_id
WHERE cidade_nome > ''
GROUP BY cidade_id, cidade_nome
ORDER BY quantidade_usuarios DESC;

-- pesquisa 5

select 
sum(case when pagamento_status = "Pago" then pagamento_valorTotal else 0 end) as Valor_Total_Recebido,
sum(case when pagamento_status != "Pago" then pagamento_valorTotal else 0 end) as Valor_Total_Nao_Recebido,
sum(case when pagamento_status = "Pago" or pagamento_status != "Pago" then pagamento_valorTotal else 0 end) as Valor_Total_Esperado,
sum(case when inscricao_credenciamento = 1 then 1 else 0 end) as Inscricao_Confirmada,
sum(case when inscricao_credenciamento = 0 then 1 else 0 end) as Inscricao_Nao_Confirmada
from pagamento inner join inscricao on pagamento_inscricao_id = inscricao_id
where inscricao_eventos_id = 1;

CREATE INDEX idx_inscricao_evento_cover ON inscricao (inscricao_eventos_id, inscricao_id, inscricao_credenciamento);
CREATE INDEX idx_pagamento_inscricao_cover ON pagamento (pagamento_inscricao_id, pagamento_status, pagamento_valorTotal);                                      

select 
sum(case when pagamento_status = "Pago" then pagamento_valorTotal else 0 end) as Valor_Total_Recebido,
sum(case when pagamento_status != "Pago" then pagamento_valorTotal else 0 end) as Valor_Total_Nao_Recebido,
sum(pagamento_valorTotal) as Valor_Total_Esperado,
coalesce(sum(inscricao_credenciamento = 1), 0) as Inscricao_Confirmada,
coalesce(sum(inscricao_credenciamento = 0) ,0 ) as Incricao_Nao_Confirmada
from pagamento inner join inscricao on inscricao_id = pagamento_inscricao_id
where inscricao_eventos_id = 1;
    
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

explain analyze SELECT 
    eventos_nome,
    (SELECT COUNT(*) 
       FROM voucher 
      WHERE voucher_eventos_id = eventos_id) AS total_vouchers,
    (SELECT COALESCE(SUM(voucher_disponivel = 1), 0) 
       FROM voucher
      WHERE voucher_eventos_id = eventos_id) AS disponiveis,
    (SELECT COALESCE(SUM(voucher_disponivel = 0), 0) 
       FROM voucher
      WHERE voucher_eventos_id = eventos_id) AS usados
FROM eventos
ORDER BY total_vouchers DESC;
	
CREATE INDEX idx_voucher_evento_disp ON voucher (voucher_eventos_id, voucher_disponivel);
CREATE INDEX idx_eventos_id_nome ON eventos (eventos_id, eventos_nome);

explain analyze SELECT 
    eventos_nome,
    COALESCE(total_vouchers, 0) AS total_vouchers,
    COALESCE(disponiveis, 0) AS disponiveis,
    COALESCE(usados, 0) AS usados
FROM eventos
LEFT JOIN (
    SELECT 
        voucher_eventos_id,
        COUNT(*) AS total_vouchers,
        SUM(CASE WHEN voucher_disponivel = 1 THEN 1 ELSE 0 END) AS disponiveis,
        SUM(CASE WHEN voucher_disponivel = 0 THEN 1 ELSE 0 END) AS usados
    FROM voucher
    GROUP BY voucher_eventos_id
) AS resumo ON eventos_id = voucher_eventos_id
ORDER BY total_vouchers DESC;

-- pesqisa 8

explain analyze SELECT DISTINCT 
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

explain analyze SELECT 
    eventos_nome, 
    eventos_descricao, 
    eventos_dataInicio, 
    eventos_dataFim, 
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

SET @id_programacao = 1;

explain analyze SELECT 
    (SELECT e.eventos_nome FROM eventos e WHERE e.eventos_id = p.programacao_eventos_id) AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    DATE_FORMAT(p.programacao_horaInicio, '%d/%m/%Y %H:%i') AS DATA_HORA,
    COALESCE(
        (SELECT pap.papel_nome 
         FROM papelProgramacao pp
         INNER JOIN papel pap ON pp.papelProgramacao_papel_id = pap.papel_id
         WHERE pp.papelProgramacao_programacao_id = p.programacao_id 
           AND pp.papelProgramacao_inscricao_id = i.inscricao_id
         LIMIT 1),
        'Participante'
    ) AS FUNCAO,
    (SELECT u.usuario_nome FROM usuario u WHERE u.usuario_id = i.inscricao_usuario_id) AS NOME,
    (SELECT u.usuario_email FROM usuario u WHERE u.usuario_id = i.inscricao_usuario_id) AS EMAIL,
    CASE 
        WHEN ip.inscritosProgramacao_FrequenciaConfirmada = 1 THEN 'Confirmado'
        WHEN ip.inscritosProgramacao_FrequenciaConfirmada = 0 THEN 'Ausente'
        ELSE 'Pendente'
    END AS STATUS_PRESENCA,
    DATE_FORMAT(ip.inscritosProgramacao_dataHoraFrequencia, '%d/%m/%Y %H:%i:%s') AS DATA_CHECKIN
FROM programacao p
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.inscritosProgramacao_programacao_id
INNER JOIN inscricao i ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id
WHERE p.programacao_id = @id_programacao
ORDER BY 
    FIELD(
        COALESCE(
            (SELECT pap.papel_nome 
             FROM papelProgramacao pp
             INNER JOIN papel pap ON pp.papelProgramacao_papel_id = pap.papel_id
             WHERE pp.papelProgramacao_programacao_id = p.programacao_id 
               AND pp.papelProgramacao_inscricao_id = i.inscricao_id
             LIMIT 1),
            'Participante'
        ),
        'Organizador', 'Coordenador', 'Palestrante', 'Staff', 'Auxiliar', 'Participante'),
    (SELECT u.usuario_nome FROM usuario u WHERE u.usuario_id = i.inscricao_usuario_id);


CREATE INDEX idx_ip_prog_inscrito 
ON inscritosProgramacao (inscritosProgramacao_programacao_id, inscritosProgramacao_inscritos_id);

CREATE INDEX idx_pp_prog_inscricao_papel 
ON papelProgramacao (papelProgramacao_programacao_id, papelProgramacao_inscricao_id, papelProgramacao_papel_id);

CREATE INDEX idx_inscricao_usuario 
ON inscricao (inscricao_usuario_id);

CREATE INDEX idx_prog_evento 
ON programacao (programacao_eventos_id);

-- atualização

SET @id_programacao = 1;

explain analyze SELECT 
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
INNER JOIN inscritosProgramacao ip 
    ON p.programacao_id = ip.inscritosProgramacao_programacao_id
INNER JOIN inscricao i 
    ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id
INNER JOIN eventos e 
    ON e.eventos_id = p.programacao_eventos_id
INNER JOIN usuario u 
    ON u.usuario_id = i.inscricao_usuario_id
LEFT JOIN papelProgramacao pp 
    ON pp.papelProgramacao_programacao_id = p.programacao_id 
    AND pp.papelProgramacao_inscricao_id = i.inscricao_id
LEFT JOIN papel pap 
    ON pp.papelProgramacao_papel_id = pap.papel_id
WHERE p.programacao_id = @id_programacao
ORDER BY 
    FIELD(
        COALESCE(pap.papel_nome, 'Participante'),
        'Organizador', 'Coordenador', 'Palestrante', 'Staff', 'Auxiliar', 'Participante'
    ),
    u.usuario_nome;

-- consulata 10

select * from telefone left join usuario on usuario_id = telefone_usuario_id where usuario_id = 1;

CREATE INDEX idx_telefone_cover ON telefone (telefone_usuario_id, telefone_ddi, telefone_ddd, telefone_telefone);
CREATE INDEX idx_usuario_cover ON usuario (usuario_id, usuario_nome);

select usuario_nome, telefone_ddi, telefone_ddd, telefone_telefone from usuario inner join telefone on usuario_id = telefone_usuario_id where usuario_id = 1;
