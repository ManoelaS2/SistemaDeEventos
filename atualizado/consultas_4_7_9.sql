USE eventos;

-- ============================================================
-- CONSULTA 04 - SEM OTIMIZACAO
-- ============================================================
SELECT 
    (SELECT c.cidade_nome FROM cidade c WHERE c.cidade_id = en.cep_cidade_id) AS Cidade,
    (SELECT e.estado_nome 
     FROM estado e 
     INNER JOIN cidade c ON e.estado_id = c.cidade_estado_id 
     WHERE c.cidade_id = en.cep_cidade_id 
     LIMIT 1) AS Estado,
    COUNT(DISTINCT en.usuario_id) AS Quantidade_Usuarios
FROM (
    SELECT 
        e.endereco_usuario_id AS usuario_id,
        ce.cep_cidade_id
    FROM endereco e
    INNER JOIN CEP ce ON e.endereco_cep_id = ce.cep_id
) en
GROUP BY en.cep_cidade_id
ORDER BY Quantidade_Usuarios DESC;
-- TEMPO: 0.312 sec

-- EXPLAIN - SEM OTIMIZACAO
EXPLAIN
SELECT 
    (SELECT c.cidade_nome FROM cidade c WHERE c.cidade_id = en.cep_cidade_id) AS Cidade,
    (SELECT e.estado_nome 
     FROM estado e 
     INNER JOIN cidade c ON e.estado_id = c.cidade_estado_id 
     WHERE c.cidade_id = en.cep_cidade_id 
     LIMIT 1) AS Estado,
    COUNT(DISTINCT en.usuario_id) AS Quantidade_Usuarios
FROM (
    SELECT 
        e.endereco_usuario_id AS usuario_id,
        ce.cep_cidade_id
    FROM endereco e
    INNER JOIN CEP ce ON e.endereco_cep_id = ce.cep_id
) en
GROUP BY en.cep_cidade_id
ORDER BY Quantidade_Usuarios DESC;
-- OBSERVACOES: type=ALL em endereco, CEP e cidade, Using temporary, Using filesort, 2 subqueries dependentes

-- EXPLAIN ANALYZE - SEM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    (SELECT c.cidade_nome FROM cidade c WHERE c.cidade_id = en.cep_cidade_id) AS Cidade,
    (SELECT e.estado_nome 
     FROM estado e 
     INNER JOIN cidade c ON e.estado_id = c.cidade_estado_id 
     WHERE c.cidade_id = en.cep_cidade_id 
     LIMIT 1) AS Estado,
    COUNT(DISTINCT en.usuario_id) AS Quantidade_Usuarios
FROM (
    SELECT 
        e.endereco_usuario_id AS usuario_id,
        ce.cep_cidade_id
    FROM endereco e
    INNER JOIN CEP ce ON e.endereco_cep_id = ce.cep_id
) en
GROUP BY en.cep_cidade_id
ORDER BY Quantidade_Usuarios DESC;
-- TEMPO APROXIMADO: 0.31 sec

-- ============================================================
-- CONSULTA 04 - COM OTIMIZACAO
-- ============================================================
CREATE INDEX idx_endereco_cep_user ON endereco(endereco_cep_id, endereco_usuario_id);

SELECT 
    c.cidade_nome AS Cidade,
    e.estado_nome AS Estado,
    COUNT(*) AS Quantidade_Usuarios
FROM (
    SELECT 
        en.endereco_cep_id,
        en.endereco_usuario_id
    FROM endereco en
    GROUP BY en.endereco_cep_id, en.endereco_usuario_id
) en_dedup
INNER JOIN CEP ce ON en_dedup.endereco_cep_id = ce.cep_id
INNER JOIN cidade c ON ce.cep_cidade_id = c.cidade_id
INNER JOIN estado e ON c.cidade_estado_id = e.estado_id
GROUP BY c.cidade_id, c.cidade_nome, e.estado_nome
ORDER BY Quantidade_Usuarios DESC;
-- TEMPO: 0.187 sec

-- EXPLAIN - COM OTIMIZACAO
EXPLAIN
SELECT 
    c.cidade_nome AS Cidade,
    e.estado_nome AS Estado,
    COUNT(*) AS Quantidade_Usuarios
FROM (
    SELECT 
        en.endereco_cep_id,
        en.endereco_usuario_id
    FROM endereco en
    GROUP BY en.endereco_cep_id, en.endereco_usuario_id
) en_dedup
INNER JOIN CEP ce ON en_dedup.endereco_cep_id = ce.cep_id
INNER JOIN cidade c ON ce.cep_cidade_id = c.cidade_id
INNER JOIN estado e ON c.cidade_estado_id = e.estado_id
GROUP BY c.cidade_id, c.cidade_nome, e.estado_nome
ORDER BY Quantidade_Usuarios DESC;
-- OBSERVACOES: type=index na subquery dedup, sem subqueries dependentes, indice idx_endereco_cep_user utilizado

-- EXPLAIN ANALYZE - COM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    c.cidade_nome AS Cidade,
    e.estado_nome AS Estado,
    COUNT(*) AS Quantidade_Usuarios
FROM (
    SELECT 
        en.endereco_cep_id,
        en.endereco_usuario_id
    FROM endereco en
    GROUP BY en.endereco_cep_id, en.endereco_usuario_id
) en_dedup
INNER JOIN CEP ce ON en_dedup.endereco_cep_id = ce.cep_id
INNER JOIN cidade c ON ce.cep_cidade_id = c.cidade_id
INNER JOIN estado e ON c.cidade_estado_id = e.estado_id
GROUP BY c.cidade_id, c.cidade_nome, e.estado_nome
ORDER BY Quantidade_Usuarios DESC;
-- TEMPO APROXIMADO: 0.18 sec

-- ============================================================
-- CONSULTA 7 - SEM OTIMIZACAO
-- ============================================================
SELECT 
    e.eventos_nome,
    (SELECT COUNT(*) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS total_vouchers,
    (SELECT COALESCE(SUM(v.voucher_disponivel = 1), 0) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS disponiveis,
    (SELECT COALESCE(SUM(v.voucher_disponivel = 0), 0) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS usados
FROM eventos e
ORDER BY total_vouchers DESC;
-- TEMPO: 0.031 sec

-- EXPLAIN - SEM OTIMIZACAO
EXPLAIN
SELECT 
    e.eventos_nome,
    (SELECT COUNT(*) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS total_vouchers,
    (SELECT COALESCE(SUM(v.voucher_disponivel = 1), 0) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS disponiveis,
    (SELECT COALESCE(SUM(v.voucher_disponivel = 0), 0) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS usados
FROM eventos e
ORDER BY total_vouchers DESC;
-- OBSERVACOES: type=ALL na tabela eventos, 3 subqueries dependentes, Using filesort

-- EXPLAIN ANALYZE - SEM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    e.eventos_nome,
    (SELECT COUNT(*) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS total_vouchers,
    (SELECT COALESCE(SUM(v.voucher_disponivel = 1), 0) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS disponiveis,
    (SELECT COALESCE(SUM(v.voucher_disponivel = 0), 0) 
       FROM voucher v 
      WHERE v.voucher_eventos_id = e.eventos_id) AS usados
FROM eventos e
ORDER BY total_vouchers DESC;
-- TEMPO APROXIMADO: 0.03 sec

-- ============================================================
-- CONSULTA 7 - COM OTIMIZACAO
-- ============================================================
CREATE INDEX idx_eventos_id_nome ON eventos(eventos_id, eventos_nome);
CREATE INDEX idx_voucher_ev_disp ON voucher(voucher_eventos_id, voucher_disponivel);

SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    COALESCE(SUM(v.voucher_disponivel = 1), 0) AS disponiveis,
    COALESCE(SUM(v.voucher_disponivel = 0), 0) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.voucher_eventos_id
GROUP BY e.eventos_id, e.eventos_nome
ORDER BY total_vouchers DESC;
-- TEMPO: 0.0 sec

-- EXPLAIN - COM OTIMIZACAO
EXPLAIN
SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    COALESCE(SUM(v.voucher_disponivel = 1), 0) AS disponiveis,
    COALESCE(SUM(v.voucher_disponivel = 0), 0) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.voucher_eventos_id
GROUP BY e.eventos_id, e.eventos_nome
ORDER BY total_vouchers DESC;
-- OBSERVACOES: type=index em eventos (idx_eventos_id_nome), type=ref em voucher (idx_voucher_ev_disp), sem subqueries

-- EXPLAIN ANALYZE - COM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    e.eventos_nome,
    COUNT(v.voucher_id) AS total_vouchers,
    COALESCE(SUM(v.voucher_disponivel = 1), 0) AS disponiveis,
    COALESCE(SUM(v.voucher_disponivel = 0), 0) AS usados
FROM eventos e
LEFT JOIN voucher v ON e.eventos_id = v.voucher_eventos_id
GROUP BY e.eventos_id, e.eventos_nome
ORDER BY total_vouchers DESC;
-- TEMPO APROXIMADO: 0.00 sec

-- ============================================================
-- CONSULTA 9 - SEM OTIMIZACAO
-- ============================================================
SET @id_programacao = 1;

SELECT 
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
-- TEMPO: 0.062 sec

-- EXPLAIN - SEM OTIMIZACAO
EXPLAIN
SELECT 
    (SELECT e.eventos_nome FROM eventos e WHERE e.eventos_id = p.programacao_eventos_id) AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(
        (SELECT pap.papel_nome 
         FROM papelProgramacao pp
         INNER JOIN papel pap ON pp.papelProgramacao_papel_id = pap.papel_id
         WHERE pp.papelProgramacao_programacao_id = p.programacao_id 
           AND pp.papelProgramacao_inscricao_id = i.inscricao_id
         LIMIT 1),
        'Participante'
    ) AS FUNCAO,
    (SELECT u.usuario_nome FROM usuario u WHERE u.usuario_id = i.inscricao_usuario_id) AS NOME
FROM programacao p
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.inscritosProgramacao_programacao_id
INNER JOIN inscricao i ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id
WHERE p.programacao_id = @id_programacao;
-- OBSERVACOES: type=ALL em inscritosProgramacao, 4 subqueries dependentes (3 no SELECT + 1 no ORDER BY)

-- EXPLAIN ANALYZE - SEM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    (SELECT e.eventos_nome FROM eventos e WHERE e.eventos_id = p.programacao_eventos_id) AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(
        (SELECT pap.papel_nome 
         FROM papelProgramacao pp
         INNER JOIN papel pap ON pp.papelProgramacao_papel_id = pap.papel_id
         WHERE pp.papelProgramacao_programacao_id = p.programacao_id 
           AND pp.papelProgramacao_inscricao_id = i.inscricao_id
         LIMIT 1),
        'Participante'
    ) AS FUNCAO,
    (SELECT u.usuario_nome FROM usuario u WHERE u.usuario_id = i.inscricao_usuario_id) AS NOME
FROM programacao p
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.inscritosProgramacao_programacao_id
INNER JOIN inscricao i ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id
WHERE p.programacao_id = @id_programacao;
-- TEMPO APROXIMADO: 0.06 sec

-- ============================================================
-- CONSULTA 9 - COM OTIMIZACAO
-- ============================================================
CREATE INDEX idx_prog_id_evento ON programacao(programacao_id, programacao_eventos_id, programacao_nome, programacao_horaInicio);
CREATE INDEX idx_ip_prog_inscrito_freq ON inscritosProgramacao(inscritosProgramacao_programacao_id, inscritosProgramacao_inscritos_id, inscritosProgramacao_FrequenciaConfirmada, inscritosProgramacao_dataHoraFrequencia);
CREATE INDEX idx_insc_id_usuario ON inscricao(inscricao_id, inscricao_usuario_id);
CREATE INDEX idx_usuario_id_nome_email ON usuario(usuario_id, usuario_nome, usuario_email);
CREATE INDEX idx_pp_prog_insc_papel ON papelProgramacao(papelProgramacao_programacao_id, papelProgramacao_inscricao_id, papelProgramacao_papel_id);
CREATE INDEX idx_papel_id_nome ON papel(papel_id, papel_nome);
CREATE INDEX idx_eventos_id_nome ON eventos(eventos_id, eventos_nome);

SET @id_programacao = 1;

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
FROM programacao p FORCE INDEX (idx_prog_id_evento)
INNER JOIN eventos e FORCE INDEX (idx_eventos_id_nome)
    ON p.programacao_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip FORCE INDEX (idx_ip_prog_inscrito_freq)
    ON p.programacao_id = ip.inscritosProgramacao_programacao_id
INNER JOIN inscricao i FORCE INDEX (idx_insc_id_usuario)
    ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id
INNER JOIN usuario u FORCE INDEX (idx_usuario_id_nome_email)
    ON i.inscricao_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp FORCE INDEX (idx_pp_prog_insc_papel)
    ON p.programacao_id = pp.papelProgramacao_programacao_id 
    AND i.inscricao_id = pp.papelProgramacao_inscricao_id
LEFT JOIN papel pap FORCE INDEX (idx_papel_id_nome)
    ON pp.papelProgramacao_papel_id = pap.papel_id
WHERE p.programacao_id = @id_programacao
ORDER BY 
    FIELD(COALESCE(pap.papel_nome, 'Participante'), 
          'Organizador', 'Coordenador', 'Palestrante', 'Staff', 'Auxiliar', 'Participante'),
    u.usuario_nome;
-- TEMPO: 0.0 sec

-- EXPLAIN - COM OTIMIZACAO
EXPLAIN
SELECT 
    e.eventos_nome AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(pap.papel_nome, 'Participante') AS FUNCAO,
    u.usuario_nome AS NOME
FROM programacao p
INNER JOIN eventos e ON p.programacao_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.inscritosProgramacao_programacao_id
INNER JOIN inscricao i ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.inscricao_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp 
    ON p.programacao_id = pp.papelProgramacao_programacao_id 
    AND i.inscricao_id = pp.papelProgramacao_inscricao_id
LEFT JOIN papel pap ON pp.papelProgramacao_papel_id = pap.papel_id
WHERE p.programacao_id = @id_programacao;
-- OBSERVACOES: type=const ou ref em todas as tabelas, 7 indices de cobertura, sem subqueries

-- EXPLAIN ANALYZE - COM OTIMIZACAO
EXPLAIN ANALYZE
SELECT 
    e.eventos_nome AS EVENTO,
    p.programacao_nome AS ATIVIDADE,
    COALESCE(pap.papel_nome, 'Participante') AS FUNCAO,
    u.usuario_nome AS NOME
FROM programacao p
INNER JOIN eventos e ON p.programacao_eventos_id = e.eventos_id
INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.inscritosProgramacao_programacao_id
INNER JOIN inscricao i ON ip.inscritosProgramacao_inscritos_id = i.inscricao_id
INNER JOIN usuario u ON i.inscricao_usuario_id = u.usuario_id
LEFT JOIN papelProgramacao pp 
    ON p.programacao_id = pp.papelProgramacao_programacao_id 
    AND i.inscricao_id = pp.papelProgramacao_inscricao_id
LEFT JOIN papel pap ON pp.papelProgramacao_papel_id = pap.papel_id
WHERE p.programacao_id = @id_programacao;
-- TEMPO APROXIMADO: 0.00 sec

-- ============================================================
-- RESUMO COMPARATIVO DE DESEMPENHO
-- ============================================================
-- CONSULTA 04: 0.312s -> 0.187s (Reducao de 40%)
-- CONSULTA 07: 0.031s -> 0.000s (Reducao de 100%, zerou)
-- CONSULTA 09: 0.062s -> 0.000s (Reducao de 100%, zerou)

