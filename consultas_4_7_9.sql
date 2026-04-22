USE mydb;

-- ============================================================
-- CONSULTA 4: QUANTIDADE DE USUARIOS LIGADOS A CADA CIDADE
-- ============================================================

-- ------------------------------------------------------------
-- CONSULTA 1 - SEM OTIMIZACAO
-- ------------------------------------------------------------
SELECT 
    c.cidade_nome AS cidade,
    COUNT(DISTINCT u.usuario_id) AS quantidade_usuarios
FROM usuario u
INNER JOIN endereco e ON u.usuario_id = e.usuario_usuario_id
INNER JOIN cep ON e.CEP_cep_id = cep.cep_id
INNER JOIN cidade c ON cep.cidade_cidade_id = c.cidade_id
WHERE c.cidade_nome IS NOT NULL AND c.cidade_nome != ''
GROUP BY c.cidade_id, c.cidade_nome
ORDER BY quantidade_usuarios DESC;
-- TEMPO: 3.625 sec

-- EXPLAIN - SEM OTIMIZACAO
EXPLAIN 
SELECT 
    c.cidade_nome AS cidade,
    COUNT(DISTINCT u.usuario_id) AS quantidade_usuarios
FROM usuario u
INNER JOIN endereco e ON u.usuario_id = e.usuario_usuario_id
INNER JOIN cep ON e.CEP_cep_id = cep.cep_id
INNER JOIN cidade c ON cep.cidade_cidade_id = c.cidade_id
WHERE c.cidade_nome IS NOT NULL AND c.cidade_nome != ''
GROUP BY c.cidade_id, c.cidade_nome
ORDER BY quantidade_usuarios DESC;
-- OBSERVACOES: type=ALL em endereco e cep, Using temporary, Using filesort

-- EXPLAIN ANALYZE - SEM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    c.cidade_nome AS cidade,
    COUNT(DISTINCT u.usuario_id) AS quantidade_usuarios
FROM usuario u
INNER JOIN endereco e ON u.usuario_id = e.usuario_usuario_id
INNER JOIN cep ON e.CEP_cep_id = cep.cep_id
INNER JOIN cidade c ON cep.cidade_cidade_id = c.cidade_id
WHERE c.cidade_nome IS NOT NULL AND c.cidade_nome != ''
GROUP BY c.cidade_id, c.cidade_nome
ORDER BY quantidade_usuarios DESC;
-- TEMPO APROXIMADO: 3.6 sec

-- ------------------------------------------------------------
-- CONSULTA 1 - COM OTIMIZACAO (INDICES)
-- ------------------------------------------------------------
CREATE INDEX idx_endereco_usuario ON endereco(usuario_usuario_id);
CREATE INDEX idx_endereco_cep ON endereco(CEP_cep_id);
CREATE INDEX idx_cep_cidade ON cep(cidade_cidade_id);
CREATE INDEX idx_cidade_nome ON cidade(cidade_nome);

SELECT 
    c.cidade_nome AS cidade,
    COUNT(DISTINCT u.usuario_id) AS quantidade_usuarios
FROM usuario u
INNER JOIN endereco e ON u.usuario_id = e.usuario_usuario_id
INNER JOIN cep ON e.CEP_cep_id = cep.cep_id
INNER JOIN cidade c ON cep.cidade_cidade_id = c.cidade_id
WHERE c.cidade_nome IS NOT NULL AND c.cidade_nome != ''
GROUP BY c.cidade_id, c.cidade_nome
ORDER BY quantidade_usuarios DESC;
-- TEMPO: 2.719 sec

-- EXPLAIN - COM OTIMIZACAO
EXPLAIN 
SELECT 
    c.cidade_nome AS cidade,
    COUNT(DISTINCT u.usuario_id) AS quantidade_usuarios
FROM usuario u
INNER JOIN endereco e ON u.usuario_id = e.usuario_usuario_id
INNER JOIN cep ON e.CEP_cep_id = cep.cep_id
INNER JOIN cidade c ON cep.cidade_cidade_id = c.cidade_id
WHERE c.cidade_nome IS NOT NULL AND c.cidade_nome != ''
GROUP BY c.cidade_id, c.cidade_nome
ORDER BY quantidade_usuarios DESC;
-- OBSERVACOES: type=ref em endereco e cep, utilizando os indices criados

-- EXPLAIN ANALYZE - COM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    c.cidade_nome AS cidade,
    COUNT(DISTINCT u.usuario_id) AS quantidade_usuarios
FROM usuario u
INNER JOIN endereco e ON u.usuario_id = e.usuario_usuario_id
INNER JOIN cep ON e.CEP_cep_id = cep.cep_id
INNER JOIN cidade c ON cep.cidade_cidade_id = c.cidade_id
WHERE c.cidade_nome IS NOT NULL AND c.cidade_nome != ''
GROUP BY c.cidade_id, c.cidade_nome
ORDER BY quantidade_usuarios DESC;
-- TEMPO REAL: ~2.7 sec


-- ============================================================
-- CONSULTA 7: VOUCHERS USADOS E DISPONIVEIS POR EVENTO
-- ============================================================

-- ------------------------------------------------------------
-- CONSULTA 7 - SEM OTIMIZACAO
-- ------------------------------------------------------------
SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    SUM(CASE WHEN v.voucher_disponivel = 1 THEN 1 ELSE 0 END) AS disponiveis,
    SUM(CASE WHEN v.voucher_disponivel = 0 THEN 1 ELSE 0 END) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.eventos_eventos_id
GROUP BY e.eventos_id
ORDER BY total_vouchers DESC;
-- TEMPO: 0.672 sec

-- EXPLAIN - SEM OTIMIZACAO
EXPLAIN 
SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    SUM(CASE WHEN v.voucher_disponivel = 1 THEN 1 ELSE 0 END) AS disponiveis,
    SUM(CASE WHEN v.voucher_disponivel = 0 THEN 1 ELSE 0 END) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.eventos_eventos_id
GROUP BY e.eventos_id
ORDER BY total_vouchers DESC;
-- OBSERVACOES: type=ALL na tabela eventos, Using temporary, Using filesort

-- EXPLAIN ANALYZE - SEM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    SUM(CASE WHEN v.voucher_disponivel = 1 THEN 1 ELSE 0 END) AS disponiveis,
    SUM(CASE WHEN v.voucher_disponivel = 0 THEN 1 ELSE 0 END) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.eventos_eventos_id
GROUP BY e.eventos_id
ORDER BY total_vouchers DESC;
-- TEMPO APROXIMADO: 0.67 sec

-- ------------------------------------------------------------
-- CONSULTA 7 - COM OTIMIZACAO (INDICES)
-- ------------------------------------------------------------
CREATE INDEX idx_voucher_evento_disp ON voucher(eventos_eventos_id, voucher_disponivel);
CREATE INDEX idx_eventos_id_nome ON eventos(eventos_id, eventos_nome);

SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    COALESCE(SUM(v.voucher_disponivel = 1), 0) AS disponiveis,
    COALESCE(SUM(v.voucher_disponivel = 0), 0) AS usados,
    COALESCE(ROUND(SUM(v.voucher_disponivel = 0) * 100.0 / NULLIF(COUNT(*), 0), 2), 0) AS percentual_uso
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.eventos_eventos_id
GROUP BY e.eventos_id, e.eventos_nome
ORDER BY total_vouchers DESC;
-- TEMPO: 0.046 sec

-- EXPLAIN - COM OTIMIZACAO
EXPLAIN 
SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    COALESCE(SUM(v.voucher_disponivel = 1), 0) AS disponiveis,
    COALESCE(SUM(v.voucher_disponivel = 0), 0) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.eventos_eventos_id
GROUP BY e.eventos_id, e.eventos_nome
ORDER BY total_vouchers DESC;
-- OBSERVACOES: type=index na tabela eventos, type=ref na tabela voucher, sem Using filesort

-- EXPLAIN ANALYZE - COM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    COALESCE(SUM(v.voucher_disponivel = 1), 0) AS disponiveis,
    COALESCE(SUM(v.voucher_disponivel = 0), 0) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.eventos_eventos_id
GROUP BY e.eventos_id, e.eventos_nome
ORDER BY total_vouchers DESC;
-- TEMPO REAL: ~0.04 sec


-- ============================================================
-- CONSULTA 9: USUARIOS ENVOLVIDOS EM UMA PROGRAMACAO ESPECIFICA
-- ============================================================

-- ------------------------------------------------------------
-- CONSULTA 9 - SEM OTIMIZACAO
-- ------------------------------------------------------------
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
INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id
INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp ON i.inscricao_id = pp.inscricao_inscricao_id 
    AND p.programacao_id = pp.programacao_programacao_id
LEFT JOIN papel pap ON pp.papel_papel_id = pap.papel_id
WHERE p.programacao_id = 41286
ORDER BY 
    FIELD(pap.papel_nome, 'Organizador', 'Coordenador', 'Palestrante', 'Staff', 'Auxiliar', 'Participante'),
    u.usuario_nome;
-- TEMPO: 0.344 sec

-- EXPLAIN - SEM OTIMIZACAO
EXPLAIN 
SELECT 
    e.eventos_nome AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(pap.papel_nome, 'Participante') AS FUNCAO,
    u.usuario_nome AS NOME
FROM programacao p
INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id
INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp ON i.inscricao_id = pp.inscricao_inscricao_id 
    AND p.programacao_id = pp.programacao_programacao_id
LEFT JOIN papel pap ON pp.papel_papel_id = pap.papel_id
WHERE p.programacao_id = 41286;
-- OBSERVACOES: type=ALL ou index em inscritosProgramacao, multiplas linhas examinadas

-- EXPLAIN ANALYZE - SEM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    e.eventos_nome AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(pap.papel_nome, 'Participante') AS FUNCAO,
    u.usuario_nome AS NOME
FROM programacao p
INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id
INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp ON i.inscricao_id = pp.inscricao_inscricao_id 
    AND p.programacao_id = pp.programacao_programacao_id
LEFT JOIN papel pap ON pp.papel_papel_id = pap.papel_id
WHERE p.programacao_id = 41286;
-- TEMPO APROXIMADO: 0.34 sec

-- ------------------------------------------------------------
-- CONSULTA 9 - COM OTIMIZACAO 
-- ------------------------------------------------------------
CREATE INDEX idx_programacao_id_evento ON programacao(programacao_id, eventos_eventos_id);
CREATE INDEX idx_inscritos_prog_programacao ON inscritosProgramacao(programacao_programacao_id, inscritos_inscritos_id);
CREATE INDEX idx_inscricao_id_usuario ON inscricao(inscricao_id, usuario_usuario_id);
CREATE INDEX idx_papel_prog_composto ON papelProgramacao(programacao_programacao_id, inscricao_inscricao_id);

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
FROM programacao p FORCE INDEX (idx_programacao_id_evento)
INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip FORCE INDEX (idx_inscritos_prog_programacao)
    ON p.programacao_id = ip.programacao_programacao_id
INNER JOIN inscricao i FORCE INDEX (idx_inscricao_id_usuario)
    ON ip.inscritos_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp FORCE INDEX (idx_papel_prog_composto)
    ON p.programacao_id = pp.programacao_programacao_id 
    AND i.inscricao_id = pp.inscricao_inscricao_id
LEFT JOIN papel pap ON pp.papel_papel_id = pap.papel_id
WHERE p.programacao_id = 41286
ORDER BY 
    FIELD(pap.papel_nome, 'Organizador', 'Coordenador', 'Palestrante', 'Staff', 'Auxiliar', 'Participante'),
    u.usuario_nome;
-- TEMPO: 0.250 sec

-- EXPLAIN - COM OTIMIZACAO
EXPLAIN 
SELECT 
    e.eventos_nome AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(pap.papel_nome, 'Participante') AS FUNCAO,
    u.usuario_nome AS NOME
FROM programacao p
INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id
INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp ON p.programacao_id = pp.programacao_programacao_id 
    AND i.inscricao_id = pp.inscricao_inscricao_id
LEFT JOIN papel pap ON pp.papel_papel_id = pap.papel_id
WHERE p.programacao_id = 41286;
-- OBSERVACOES: type=ref ou eq_ref em todas as tabelas, utilizando indices compostos

-- EXPLAIN ANALYZE - COM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    e.eventos_nome AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(pap.papel_nome, 'Participante') AS FUNCAO,
    u.usuario_nome AS NOME
FROM programacao p
INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id
INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp ON p.programacao_id = pp.programacao_programacao_id 
    AND i.inscricao_id = pp.inscricao_inscricao_id
LEFT JOIN papel pap ON pp.papel_papel_id = pap.papel_id
WHERE p.programacao_id = 41286;
-- TEMPO REAL: ~0.25 sec

-- ============================================================
-- RESUMO COMPARATIVO DE DESEMPENHO
-- ============================================================
-- CONSULTA 1: 3.625s -> 2.719s (Reducao de 25%)
-- CONSULTA 2: 0.672s -> 0.046s (Reducao de 93%, 14.6x mais rapido)
-- CONSULTA 3: 0.344s -> 0.250s (Reducao de 27%)