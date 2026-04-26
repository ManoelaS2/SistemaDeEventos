use mydb;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

-- ---------------------------------------------------------
-- PROCEDURES INDEPENDENTES DE BENCHMARK
-- ---------------------------------------------------------

-- BLOCO 1
DROP PROCEDURE IF EXISTS comparacao_consulta_1;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_1()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    -- Loop 1: Normal
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select usuario_id from usuario inner join inscricao i on i.usuario_usuario_id = usuario_id inner join eventos on eventos_id = eventos_eventos_id inner join certificados on inscricao_inscricao_id = inscricao_id where i.usuario_usuario_id = 106504 order by certificados_dataDeEmissao desc
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    -- Loop 2: Otimizada (Sem índices novos no bloco 1)
    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select usuario_nome, eventos_nome, eventos_descricao, eventos_dataInicio, eventos_dataFim, certificados_cargaHorariaTotal, certificados_dataDeEmissao from usuario inner join inscricao i on i.usuario_usuario_id = usuario_id inner join eventos on eventos_id = eventos_eventos_id inner join certificados on inscricao_inscricao_id = inscricao_id where i.usuario_usuario_id = 106504 order by certificados_dataDeEmissao desc
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_1();

-- BLOCO 2
DROP PROCEDURE IF EXISTS comparacao_consulta_2;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_2()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE inscricao DROP INDEX idx_inscricao_evento_usuario;
    ALTER TABLE pagamento DROP INDEX idx_pagamento_performance;
    ALTER TABLE usuario DROP INDEX idx_usuario_id_nome;

    -- Loop 1
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select inscricao_id FROM inscricao INNER JOIN pagamento ON inscricao_inscricao_id = inscricao_id INNER JOIN usuario ON usuario_usuario_id = usuario_id WHERE eventos_eventos_id = 1 AND pagamento_status = 'Pago' ORDER BY pagamento_dataHora ASC
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    CREATE INDEX idx_inscricao_evento_usuario ON inscricao (eventos_eventos_id, usuario_usuario_id);
    CREATE INDEX idx_pagamento_performance ON pagamento (inscricao_inscricao_id, pagamento_status, pagamento_dataHora);
    CREATE INDEX idx_usuario_id_nome ON usuario (usuario_id, usuario_nome);

    -- Loop 2
    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT usuario_nome FROM inscricao INNER JOIN pagamento ON inscricao_inscricao_id = inscricao_id INNER JOIN usuario ON usuario_usuario_id = usuario_id WHERE eventos_eventos_id = 1 AND pagamento_status = 'Pago' ORDER BY pagamento_dataHora ASC
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE inscricao DROP INDEX idx_inscricao_evento_usuario;
    ALTER TABLE pagamento DROP INDEX idx_pagamento_performance;
    ALTER TABLE usuario DROP INDEX idx_usuario_id_nome;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_2();

-- BLOCO 3
DROP PROCEDURE IF EXISTS comparacao_consulta_3;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_3()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE programacao DROP INDEX idx_programacao_evento_hora;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select programacao_id from programacao left join imagemprogramacao on programacao_id = programacao_programacao_id left join sublocaEvento on sublocaEvento_sublocaEvento_id = sublocaEvento_id where eventos_eventos_id = 5 order by programacao_horaInicio asc
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    CREATE INDEX idx_programacao_evento_hora ON programacao (eventos_eventos_id, programacao_horaInicio);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select programacao_nome, programacao_horaInicio, programacao_horaFim, programacao_descricao, imagemProgramacao_caminho, imagemProgramacao_descricao, sublocaevento_nome, sublocaevento_descricao from programacao inner join imagemprogramacao on programacao_id = programacao_programacao_id inner join sublocaevento on sublocaevento_sublocaevento_id = sublocaevento_id where eventos_eventos_id = 5 order by programacao_horaInicio asc
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE programacao DROP INDEX idx_programacao_evento_hora;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_3();

-- BLOCO 4
DROP PROCEDURE IF EXISTS comparacao_consulta_4;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_4()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE endereco DROP INDEX idx_endereco_usuario;
    ALTER TABLE endereco DROP INDEX idx_endereco_cep;
    ALTER TABLE cep DROP INDEX idx_cep_cidade;
    ALTER TABLE cidade DROP INDEX idx_cidade_nome;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT cidade_nome FROM usuario INNER JOIN endereco ON usuario_id = usuario_usuario_id INNER JOIN cep ON CEP_cep_id = cep_id INNER JOIN cidade ON cidade_cidade_id = cidade_id WHERE cidade_nome IS NOT NULL AND cidade_nome != '' GROUP BY cidade_id, cidade_nome ORDER BY COUNT(DISTINCT usuario_id) DESC
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    CREATE INDEX idx_endereco_usuario ON endereco(usuario_usuario_id);
    CREATE INDEX idx_endereco_cep ON endereco(CEP_cep_id);
    CREATE INDEX idx_cep_cidade ON cep(cidade_cidade_id);
    CREATE INDEX idx_cidade_nome ON cidade(cidade_nome);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT cidade_nome FROM cidade INNER JOIN cep ON cidade_id = cidade_cidade_id INNER JOIN endereco ON cep_id = CEP_cep_id INNER JOIN usuario ON usuario_usuario_id = usuario_id WHERE cidade_nome > '' GROUP BY cidade_id ORDER BY COUNT(usuario_id) DESC
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE endereco DROP INDEX idx_endereco_usuario;
    ALTER TABLE endereco DROP INDEX idx_endereco_cep;
    ALTER TABLE cep DROP INDEX idx_cep_cidade;
    ALTER TABLE cidade DROP INDEX idx_cidade_nome;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_4();

-- BLOCO 5
DROP PROCEDURE IF EXISTS comparacao_consulta_5;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_5()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE inscricao DROP INDEX idx_inscricao_id_credenciamento;
    ALTER TABLE pagamento DROP INDEX idx_pagamento_inscricaoId_valorpagamento_status;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select sum(case when inscricao_credenciamento = 1 and pagamento_status = "Pago" then pagamento_valorpagamento else 0 end) from pagamento left join inscricao on inscricao_inscricao_id = inscricao_id
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    create index idx_inscricao_id_credenciamento on inscricao(inscricao_id, inscricao_credenciamento);
    create index idx_pagamento_inscricaoId_valorpagamento_status on pagamento(inscricao_inscricao_id, pagamento_valorPagamento, pagamento_status);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select sum(case when inscricao_credenciamento = 1 and pagamento_status = "Pago" then pagamento_valorpagamento else 0 end) from pagamento left join inscricao on inscricao_inscricao_id = inscricao_id
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE inscricao DROP INDEX idx_inscricao_id_credenciamento;
    ALTER TABLE pagamento DROP INDEX idx_pagamento_inscricaoId_valorpagamento_status;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_5();

-- BLOCO 6
DROP PROCEDURE IF EXISTS comparacao_consulta_6;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_6()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE eventos DROP INDEX idx_evento_id_nome_inicio_fim_limetInscricao;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT eventos_id FROM eventos
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    CREATE INDEX idx_evento_id_nome_inicio_fim_limetInscricao on eventos(eventos_id,eventos_nome,eventos_dataInicio,eventos_dataFim, eventos_dataLimiteInscricao);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT eventos_id FROM eventos
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE eventos DROP INDEX idx_evento_id_nome_inicio_fim_limetInscricao;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_6();

-- BLOCO 7
DROP PROCEDURE IF EXISTS comparacao_consulta_7;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_7()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE voucher DROP INDEX idx_voucher_evento_disp;
    ALTER TABLE eventos DROP INDEX idx_eventos_id_nome;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT eventos_id FROM eventos LEFT JOIN voucher ON eventos_id = eventos_eventos_id GROUP BY eventos_id
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    CREATE INDEX idx_voucher_evento_disp ON voucher(eventos_eventos_id, voucher_disponivel);
    CREATE INDEX idx_eventos_id_nome ON eventos(eventos_id, eventos_nome);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT eventos_id FROM eventos LEFT JOIN voucher ON eventos_id = eventos_eventos_id GROUP BY eventos_id, eventos_nome
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE voucher DROP INDEX idx_voucher_evento_disp;
    ALTER TABLE eventos DROP INDEX idx_eventos_id_nome;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_7();

-- BLOCO 8
DROP PROCEDURE IF EXISTS comparacao_consulta_8;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_8()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE eventos DROP INDEX idx_eventos_id_nome_inicio_fim;
    ALTER TABLE usuario DROP INDEX idx_usuario_id_nome_email;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT eventos_id FROM eventos JOIN usuario ON CONCAT(usuario_id, '') = CONCAT(eventos.usuario_usuario_id, '')
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    CREATE INDEX idx_eventos_id_nome_inicio_fim ON eventos(eventos_id,eventos_nome,eventos_dataInicio,eventos_dataFim);
    CREATE INDEX idx_usuario_id_nome_email ON usuario(usuario_id,usuario_nome, usuario_email);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT eventos_id FROM eventos JOIN usuario ON usuario.usuario_id = eventos.usuario_usuario_id
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE eventos DROP INDEX idx_eventos_id_nome_inicio_fim;
    ALTER TABLE usuario DROP INDEX idx_usuario_id_nome_email;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_8();

-- BLOCO 9
DROP PROCEDURE IF EXISTS comparacao_consulta_9;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_9()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE programacao DROP INDEX idx_programacao_id_evento;
    ALTER TABLE inscritosProgramacao DROP INDEX idx_inscritos_prog_programacao;
    ALTER TABLE inscricao DROP INDEX idx_inscricao_id_usuario;
    ALTER TABLE papelProgramacao DROP INDEX idx_papel_prog_composto;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT p.programacao_id FROM programacao p INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id WHERE p.programacao_id = 41286
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    CREATE INDEX idx_programacao_id_evento ON programacao(programacao_id, eventos_eventos_id);
    CREATE INDEX idx_inscritos_prog_programacao ON inscritosProgramacao(programacao_programacao_id, inscritos_inscritos_id);
    CREATE INDEX idx_inscricao_id_usuario ON inscricao(inscricao_id, usuario_usuario_id);
    CREATE INDEX idx_papel_prog_composto ON papelProgramacao(programacao_programacao_id, inscricao_inscricao_id);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            SELECT p.programacao_id FROM programacao p INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id WHERE p.programacao_id = 41286
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE programacao DROP INDEX idx_programacao_id_evento;
    ALTER TABLE inscritosProgramacao DROP INDEX idx_inscritos_prog_programacao;
    ALTER TABLE inscricao DROP INDEX idx_inscricao_id_usuario;
    ALTER TABLE papelProgramacao DROP INDEX idx_papel_prog_composto;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_9();

-- BLOCO 10
DROP PROCEDURE IF EXISTS comparacao_consulta_10;
DELIMITER $$
CREATE PROCEDURE comparacao_consulta_10()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE start_time DATETIME(6);
    DECLARE CONTINUE HANDLER FOR 1091 BEGIN END;
    CREATE TEMPORARY TABLE temp_tempos_execucao (versao VARCHAR(50), execucao INT, tempo_ms DECIMAL(10,3));
    
    ALTER TABLE telefone DROP INDEX idx_telefone_ddi_ddd_telefone_usuario;

    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select telefone_id from telefone where usuario_usuario_id = 1
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('1. Normal', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    create index idx_telefone_ddi_ddd_telefone_usuario on telefone(telefone_ddi,telefone_ddd, telefone_telefone,usuario_usuario_id);

    SET i = 1;
    WHILE i <= 50 DO
        SET start_time = SYSDATE(6);
        SELECT COUNT(*) INTO @dummy FROM ( 
            select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1
        ) AS t;
        INSERT INTO temp_tempos_execucao VALUES ('2. Otimizada', i, TIMESTAMPDIFF(MICROSECOND, start_time, SYSDATE(6)) / 1000.0);
        SET i = i + 1;
    END WHILE;

    SELECT versao AS "Versão da Consulta", AVG(tempo_ms) AS "Tempo Médio (ms)", MIN(tempo_ms) AS "Tempo Mínimo (ms)", MAX(tempo_ms) AS "Tempo Máximo (ms)" FROM temp_tempos_execucao GROUP BY versao;
    ALTER TABLE telefone DROP INDEX idx_telefone_ddi_ddd_telefone_usuario;
    DROP TEMPORARY TABLE temp_tempos_execucao;
END $$
DELIMITER ;
CALL comparacao_consulta_10();

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
