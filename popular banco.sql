SET @tempo_inicio = SYSDATE(6);

-- ---------------------------------pre configurações -----------------------------
use mydb;

SET SESSION wait_timeout = 28800; 

SET SESSION interactive_timeout = 28800;

SET SESSION max_execution_time = 0;

SET GLOBAL max_allowed_packet = 1073741824;

SET GLOBAL net_read_timeout = 600;

SET GLOBAL net_write_timeout = 600;

SET SESSION unique_checks = 0;

SET SESSION foreign_key_checks = 0;

SET SESSION sql_log_bin = 0; 

CREATE INDEX idx_perm_nome ON `mydb`.`permissoes` (`permissoes_nome`);

CREATE INDEX idx_pu_perm_usuario ON `mydb`.`permissoesUsuarios` (`permissoes_permissoes_id`, `usuario_usuario_id`);

CREATE INDEX idx_tipoInsc_evento ON `mydb`.`tipoInscricao` (`eventos_eventos_id`);

-- valores para controle de tabelas

SET @percentual_eventos_com_voucher = 60.00; 
SET @qtd_minima_vouchers_por_evento = 5;    
SET @qtd_maxima_vouchers_por_evento = 30;   

SET @perc_min_pagantes = 40.0;  
SET @perc_max_pagantes = 80.0;
SET @valor_min_ticket  = 80.00;
SET @valor_max_ticket  = 450.00;

-- Padrão para Inscritos Programação (Salas e Palestras)
SET @perc_min_ocupacao = 5.0; 
SET @perc_max_ocupacao = 70.0; 
SET @perc_min_presenca = 15.0; 
SET @perc_max_presenca = 90.0; 

-- usuario

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularUsuarios$$

CREATE PROCEDURE PopularUsuarios(IN total_registros INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    
    -- Otimizações de performance para evitar gargalos de disco e CPU
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET SESSION autocommit = 0;

    -- 1. LOOP DE ALTA PERFORMANCE (Blocos de 100 em 100)
    -- Este loop roda enquanto houver pelo menos 100 registros para inserir
    WHILE (i + 100) <= total_registros DO
        INSERT INTO `mydb`.`usuario` (`usuario_nome`, `usuario_cpf`, `usuario_email`, `usuario_sexo`)
        VALUES 
        (CONCAT('User ', i+1), LPAD(i+1, 11, '0'), CONCAT('u', i+1, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+2), LPAD(i+2, 11, '0'), CONCAT('u', i+2, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+3), LPAD(i+3, 11, '0'), CONCAT('u', i+3, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+4), LPAD(i+4, 11, '0'), CONCAT('u', i+4, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+5), LPAD(i+5, 11, '0'), CONCAT('u', i+5, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+6), LPAD(i+6, 11, '0'), CONCAT('u', i+6, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+7), LPAD(i+7, 11, '0'), CONCAT('u', i+7, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+8), LPAD(i+8, 11, '0'), CONCAT('u', i+8, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+9), LPAD(i+9, 11, '0'), CONCAT('u', i+9, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+10), LPAD(i+10, 11, '0'), CONCAT('u', i+10, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+11), LPAD(i+11, 11, '0'), CONCAT('u', i+11, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+12), LPAD(i+12, 11, '0'), CONCAT('u', i+12, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+13), LPAD(i+13, 11, '0'), CONCAT('u', i+13, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+14), LPAD(i+14, 11, '0'), CONCAT('u', i+14, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+15), LPAD(i+15, 11, '0'), CONCAT('u', i+15, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+16), LPAD(i+16, 11, '0'), CONCAT('u', i+16, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+17), LPAD(i+17, 11, '0'), CONCAT('u', i+17, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+18), LPAD(i+18, 11, '0'), CONCAT('u', i+18, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+19), LPAD(i+19, 11, '0'), CONCAT('u', i+19, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+20), LPAD(i+20, 11, '0'), CONCAT('u', i+20, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+21), LPAD(i+21, 11, '0'), CONCAT('u', i+21, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+22), LPAD(i+22, 11, '0'), CONCAT('u', i+22, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+23), LPAD(i+23, 11, '0'), CONCAT('u', i+23, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+24), LPAD(i+24, 11, '0'), CONCAT('u', i+24, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+25), LPAD(i+25, 11, '0'), CONCAT('u', i+25, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+26), LPAD(i+26, 11, '0'), CONCAT('u', i+26, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+27), LPAD(i+27, 11, '0'), CONCAT('u', i+27, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+28), LPAD(i+28, 11, '0'), CONCAT('u', i+28, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+29), LPAD(i+29, 11, '0'), CONCAT('u', i+29, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+30), LPAD(i+30, 11, '0'), CONCAT('u', i+30, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+31), LPAD(i+31, 11, '0'), CONCAT('u', i+31, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+32), LPAD(i+32, 11, '0'), CONCAT('u', i+32, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+33), LPAD(i+33, 11, '0'), CONCAT('u', i+33, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+34), LPAD(i+34, 11, '0'), CONCAT('u', i+34, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+35), LPAD(i+35, 11, '0'), CONCAT('u', i+35, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+36), LPAD(i+36, 11, '0'), CONCAT('u', i+36, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+37), LPAD(i+37, 11, '0'), CONCAT('u', i+37, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+38), LPAD(i+38, 11, '0'), CONCAT('u', i+38, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+39), LPAD(i+39, 11, '0'), CONCAT('u', i+39, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+40), LPAD(i+40, 11, '0'), CONCAT('u', i+40, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+41), LPAD(i+41, 11, '0'), CONCAT('u', i+41, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+42), LPAD(i+42, 11, '0'), CONCAT('u', i+42, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+43), LPAD(i+43, 11, '0'), CONCAT('u', i+43, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+44), LPAD(i+44, 11, '0'), CONCAT('u', i+44, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+45), LPAD(i+45, 11, '0'), CONCAT('u', i+45, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+46), LPAD(i+46, 11, '0'), CONCAT('u', i+46, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+47), LPAD(i+47, 11, '0'), CONCAT('u', i+47, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+48), LPAD(i+48, 11, '0'), CONCAT('u', i+48, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+49), LPAD(i+49, 11, '0'), CONCAT('u', i+49, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+50), LPAD(i+50, 11, '0'), CONCAT('u', i+50, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+51), LPAD(i+51, 11, '0'), CONCAT('u', i+51, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+52), LPAD(i+52, 11, '0'), CONCAT('u', i+52, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+53), LPAD(i+53, 11, '0'), CONCAT('u', i+53, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+54), LPAD(i+54, 11, '0'), CONCAT('u', i+54, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+55), LPAD(i+55, 11, '0'), CONCAT('u', i+55, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+56), LPAD(i+56, 11, '0'), CONCAT('u', i+56, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+57), LPAD(i+57, 11, '0'), CONCAT('u', i+57, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+58), LPAD(i+58, 11, '0'), CONCAT('u', i+58, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+59), LPAD(i+59, 11, '0'), CONCAT('u', i+59, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+60), LPAD(i+60, 11, '0'), CONCAT('u', i+60, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+61), LPAD(i+61, 11, '0'), CONCAT('u', i+61, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+62), LPAD(i+62, 11, '0'), CONCAT('u', i+62, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+63), LPAD(i+63, 11, '0'), CONCAT('u', i+63, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+64), LPAD(i+64, 11, '0'), CONCAT('u', i+64, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+65), LPAD(i+65, 11, '0'), CONCAT('u', i+65, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+66), LPAD(i+66, 11, '0'), CONCAT('u', i+66, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+67), LPAD(i+67, 11, '0'), CONCAT('u', i+67, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+68), LPAD(i+68, 11, '0'), CONCAT('u', i+68, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+69), LPAD(i+69, 11, '0'), CONCAT('u', i+69, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+70), LPAD(i+70, 11, '0'), CONCAT('u', i+70, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+71), LPAD(i+71, 11, '0'), CONCAT('u', i+71, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+72), LPAD(i+72, 11, '0'), CONCAT('u', i+72, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+73), LPAD(i+73, 11, '0'), CONCAT('u', i+73, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+74), LPAD(i+74, 11, '0'), CONCAT('u', i+74, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+75), LPAD(i+75, 11, '0'), CONCAT('u', i+75, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+76), LPAD(i+76, 11, '0'), CONCAT('u', i+76, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+77), LPAD(i+77, 11, '0'), CONCAT('u', i+77, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+78), LPAD(i+78, 11, '0'), CONCAT('u', i+78, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+79), LPAD(i+79, 11, '0'), CONCAT('u', i+79, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+80), LPAD(i+80, 11, '0'), CONCAT('u', i+80, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+81), LPAD(i+81, 11, '0'), CONCAT('u', i+81, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+82), LPAD(i+82, 11, '0'), CONCAT('u', i+82, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+83), LPAD(i+83, 11, '0'), CONCAT('u', i+83, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+84), LPAD(i+84, 11, '0'), CONCAT('u', i+84, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+85), LPAD(i+85, 11, '0'), CONCAT('u', i+85, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+86), LPAD(i+86, 11, '0'), CONCAT('u', i+86, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+87), LPAD(i+87, 11, '0'), CONCAT('u', i+87, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+88), LPAD(i+88, 11, '0'), CONCAT('u', i+88, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+89), LPAD(i+89, 11, '0'), CONCAT('u', i+89, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+90), LPAD(i+90, 11, '0'), CONCAT('u', i+90, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+91), LPAD(i+91, 11, '0'), CONCAT('u', i+91, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+92), LPAD(i+92, 11, '0'), CONCAT('u', i+92, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+93), LPAD(i+93, 11, '0'), CONCAT('u', i+93, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+94), LPAD(i+94, 11, '0'), CONCAT('u', i+94, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+95), LPAD(i+95, 11, '0'), CONCAT('u', i+95, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+96), LPAD(i+96, 11, '0'), CONCAT('u', i+96, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+97), LPAD(i+97, 11, '0'), CONCAT('u', i+97, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+98), LPAD(i+98, 11, '0'), CONCAT('u', i+98, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+99), LPAD(i+99, 11, '0'), CONCAT('u', i+99, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro')),
        (CONCAT('User ', i+100), LPAD(i+100, 11, '0'), CONCAT('u', i+100, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro'));

        SET i = i + 100;
        
        -- Commit intermediário para manter a saúde do servidor
        IF MOD(i, 10000) = 0 THEN
            COMMIT;
        END IF;
    END WHILE;

    -- 2. LOOP DE RECAPITULAÇÃO (Para os registros restantes)
    -- Se você pediu 198.563, este loop insere os últimos 63 um a um.
    WHILE i < total_registros DO
        SET i = i + 1;
        INSERT INTO `mydb`.`usuario` (`usuario_nome`, `usuario_cpf`, `usuario_email`, `usuario_sexo`)
        VALUES (CONCAT('User ', i), LPAD(i, 11, '0'), CONCAT('u', i, '@mail.com'), ELT(1+FLOOR(RAND()*3), 'F','M','Outro'));
    END WHILE;

    COMMIT;
    
    -- Restaura as chaves e índices
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET SESSION autocommit = 1;
END$$

DELIMITER ;

CALL PopularUsuarios(150000);

-- estado

INSERT INTO `mydb`.`estado` (`estado_nome`, `estado_sigla`) VALUES
('Acre', 'AC'), ('Alagoas', 'AL'), ('Amapá', 'AP'), ('Amazonas', 'AM'), ('Bahia', 'BA'),
('Ceará', 'CE'), ('Distrito Federal', 'DF'), ('Espírito Santo', 'ES'), ('Goiás', 'GO'),
('Maranhão', 'MA'), ('Mato Grosso', 'MT'), ('Mato Grosso do Sul', 'MS'), ('Minas Gerais', 'MG'),
('Pará', 'PA'), ('Paraíba', 'PB'), ('Paraná', 'PR'), ('Pernambuco', 'PE'), ('Piauí', 'PI'),
('Rio de Janeiro', 'RJ'), ('Rio Grande do Norte', 'RN'), ('Rio Grande do Sul', 'RS'),
('Rondônia', 'RO'), ('Roraima', 'RR'), ('Santa Catarina', 'SC'), ('São Paulo', 'SP'),
('Sergipe', 'SE'), ('Tocantins', 'TO');

-- cidade

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularCidades$$

CREATE PROCEDURE PopularCidades()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE e_id INT;
    DECLARE total_inserido INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE cur_estados CURSOR FOR SELECT estado_id FROM `mydb`.`estado`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_estados;
    read_loop: LOOP
        FETCH cur_estados INTO e_id;
        IF done THEN LEAVE read_loop; END IF;

        SET i = 1;
        WHILE i <= 500 DO
            INSERT INTO `mydb`.`cidade` (`cidade_nome`, `estado_estado_id`)
            VALUES (CONCAT('Cidade ', i, ' Est ', e_id), e_id);
            
            SET i = i + 1;
            SET total_inserido = total_inserido + 1;

            -- COMMIT a cada 1.000 cidades inseridas
            IF MOD(total_inserido, 1000) = 0 THEN
                COMMIT;
            END IF;
        END WHILE;
    END LOOP;

    CLOSE cur_estados;
    COMMIT;
END$$

DELIMITER ;

CALL PopularCidades();

-- CEP

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularCEPs$$

CREATE PROCEDURE PopularCEPs()
BEGIN
    DECLARE c_id INT;
    DECLARE i INT;
    DECLARE done INT DEFAULT FALSE;
    -- Cursor para percorrer todas as cidades cadastradas
    DECLARE cur_cidades CURSOR FOR SELECT cidade_id FROM `mydb`.`cidade`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Otimização de performance
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    OPEN cur_cidades;
    
    read_loop: LOOP
        FETCH cur_cidades INTO c_id;
        IF done THEN 
            LEAVE read_loop; 
        END IF;

        -- Inserindo 15 CEPs por cidade
        SET i = 1;
        WHILE i <= 15 DO
            INSERT INTO `mydb`.`CEP` (`cep_numeracao`, `cidade_cidade_id`)
            VALUES (LPAD((c_id * 1000 + i), 11, '0'), c_id);
            
            SET i = i + 1;
        END WHILE;

        -- Commit imediato após processar uma cidade (15 linhas)
        -- Isso mantém a conexão "viva" e o buffer vazio
        COMMIT; 
        
    END LOOP;

    CLOSE cur_cidades;
    
    -- Restaura as configurações originais
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

-- Tefefone

CALL PopularCEPs();

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularTelefonesLogica$$

CREATE PROCEDURE PopularTelefonesLogica()
BEGIN
    DECLARE v_usuario_id INT DEFAULT 1;
    DECLARE v_max_id INT;
    DECLARE v_random FLOAT;
    DECLARE i INT;
    DECLARE v_qtd_telefones INT;

    -- Busca o limite de usuários
    SELECT MAX(usuario_id) INTO v_max_id FROM `mydb`.`usuario`;

    -- Configurações de performance para carga massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_id DO
        SET v_random = RAND() * 100; -- Gera valor de 0 a 100
        
        -- Aplica sua nova lógica de distribuição
        IF v_random <= 50 THEN 
            SET v_qtd_telefones = 1; -- 50%
        ELSEIF v_random <= 80 THEN 
            SET v_qtd_telefones = 2; -- 30% (50 a 80)
        ELSEIF v_random <= 95 THEN 
            SET v_qtd_telefones = 3; -- 15% (80 a 95)
        ELSE 
            SET v_qtd_telefones = 4; -- 5% (95 a 100)
        END IF;

        -- Inserção dos telefones para o usuário atual
        SET i = 1;
        WHILE i <= v_qtd_telefones DO
            INSERT INTO `mydb`.`telefone` (
                `telefone_ddi`, 
                `telefone_ddd`, 
                `telefone_telefone`, 
                `telefone_principal`, 
                `usuario_usuario_id`
            ) VALUES (
                '55', 
                LPAD(FLOOR(11 + (RAND() * 88)), 2, '0'), -- DDDs variados (11 a 99)
                CONCAT('9', LPAD(FLOOR(RAND() * 99999999), 8, '0')), 
                IF(i = 1, 1, 0), -- Primeiro telefone sempre é o principal (TINYINT 1)
                v_usuario_id
            );
            SET i = i + 1;
        END WHILE;

        -- Commit a cada 5.000 usuários para manter a conexão estável
        IF MOD(v_usuario_id, 5000) = 0 THEN
            COMMIT;
        END IF;

        SET v_usuario_id = v_usuario_id + 1;
    END WHILE;

    COMMIT; -- Finaliza o restante
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularTelefonesLogica();

-- permissões

INSERT INTO `mydb`.`permissoes` (`permissoes_nome`, `permissoes_descricao`) VALUES
('ROOT', 'Acesso absoluto e irrestrito ao sistema'),
('ADMINISTRADOR', 'Acesso total e gerencia configurações'),
('CRIAR_EVENTO', 'Permite cadastrar e gerenciar eventos'),
('PARTICIPANTE', 'Visualiza e se inscreve em eventos');

-- permissões usuarios

INSERT INTO `mydb`.`permissoesUsuarios` (`usuario_usuario_id`, `permissoes_permissoes_id`) 
VALUES (
    1, -- O ID do seu primeiro usuário
    (SELECT permissoes_id FROM `mydb`.`permissoes` WHERE permissoes_nome = 'ROOT' LIMIT 1)
);

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularPermissoesUsuariosLogica$$

CREATE PROCEDURE PopularPermissoesUsuariosLogica()
BEGIN
    DECLARE v_usuario_id INT DEFAULT 2; -- Começa no 2 para preservar o Usuário 1 (ROOT)
    DECLARE v_max_id INT;
    DECLARE v_random FLOAT;
    
    -- Variáveis para os IDs das permissões
    DECLARE v_id_adm INT;
    DECLARE v_id_criar INT;
    DECLARE v_id_part INT;

    -- Busca os IDs reais dinamicamente
    SELECT permissoes_id INTO v_id_adm FROM `mydb`.`permissoes` WHERE permissoes_nome = 'ADMINISTRADOR' LIMIT 1;
    SELECT permissoes_id INTO v_id_criar FROM `mydb`.`permissoes` WHERE permissoes_nome = 'CRIAR_EVENTO' LIMIT 1;
    SELECT permissoes_id INTO v_id_part FROM `mydb`.`permissoes` WHERE permissoes_nome = 'PARTICIPANTE' LIMIT 1;

    -- Descobre o total de usuários
    SELECT MAX(usuario_id) INTO v_max_id FROM `mydb`.`usuario`;

    -- Configurações de performance
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_id DO
        SET v_random = RAND() * 100;

        IF v_random <= 2 THEN
            -- 2% (0 a 2): Administrador e Criar Evento
            INSERT INTO `mydb`.`permissoesUsuarios` (`usuario_usuario_id`, `permissoes_permissoes_id`) 
            VALUES (v_usuario_id, v_id_adm), (v_usuario_id, v_id_criar);
            
        ELSEIF v_random <= 3 THEN
            -- 1% (2 a 3): Administrador, Criar Evento e Participar
            INSERT INTO `mydb`.`permissoesUsuarios` (`usuario_usuario_id`, `permissoes_permissoes_id`) 
            VALUES (v_usuario_id, v_id_adm), (v_usuario_id, v_id_criar), (v_usuario_id, v_id_part);
            
        ELSEIF v_random <= 8 THEN
            -- 5% (3 a 8): Administrador e Participar
            INSERT INTO `mydb`.`permissoesUsuarios` (`usuario_usuario_id`, `permissoes_permissoes_id`) 
            VALUES (v_usuario_id, v_id_adm), (v_usuario_id, v_id_part);
            
        ELSEIF v_random <= 95 THEN
            -- 87% (8 a 95): Apenas Participar de Evento
            INSERT INTO `mydb`.`permissoesUsuarios` (`usuario_usuario_id`, `permissoes_permissoes_id`) 
            VALUES (v_usuario_id, v_id_part);

        ELSEIF v_random <= 98 THEN
            -- 3% (95 a 98): Criar Evento e Participar
            INSERT INTO `mydb`.`permissoesUsuarios` (`usuario_usuario_id`, `permissoes_permissoes_id`) 
            VALUES (v_usuario_id, v_id_criar), (v_usuario_id, v_id_part);

        ELSE
            -- 2% (98 a 100): Apenas Criar Evento
            INSERT INTO `mydb`.`permissoesUsuarios` (`usuario_usuario_id`, `permissoes_permissoes_id`) 
            VALUES (v_usuario_id, v_id_criar);
            
        END IF;

        -- Commit fracionado a cada 5.000 usuários para manter o Workbench estável
        IF MOD(v_usuario_id, 5000) = 0 THEN
            COMMIT;
        END IF;

        SET v_usuario_id = v_usuario_id + 1;
    END WHILE;

    COMMIT;
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularPermissoesUsuariosLogica();

-- Tipo login

INSERT INTO `mydb`.`tiposLogin` (`tiposLogin_tipo`) VALUES
('E-mail'),
('Google'),
('Facebook'),
('Gov.br'),
('CPF');

-- login

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularLoginsUsuarios$$

CREATE PROCEDURE PopularLoginsUsuarios()
BEGIN
    DECLARE v_usuario_id INT DEFAULT 1;
    DECLARE v_max_id INT;
    DECLARE v_rand_base FLOAT;
    
    -- Definindo uma "senha padrão" criptografada (ex: hash MD5 de '123456') 
    -- para preencher o campo NOT NULL de forma rápida e realista.
    DECLARE v_senha_padrao VARCHAR(255) DEFAULT 'e10adc3949ba59abbe56e057f20f883e';

    -- Descobre o total de usuários
    SELECT MAX(usuario_id) INTO v_max_id FROM `mydb`.`usuario`;

    -- Configurações de performance para carga massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_id DO
        
        -- 1. BASE: 100% dos usuários (~50% E-mail [ID 1] e ~50% CPF [ID 5])
        SET v_rand_base = RAND() * 100;
        IF v_rand_base <= 50 THEN
            INSERT INTO `mydb`.`login` (`usuario_usuario_id`, `tiposLogin_tiposLogin_id`, `senha`) 
            VALUES (v_usuario_id, 1, v_senha_padrao);
        ELSE
            INSERT INTO `mydb`.`login` (`usuario_usuario_id`, `tiposLogin_tiposLogin_id`, `senha`) 
            VALUES (v_usuario_id, 5, v_senha_padrao);
        END IF;

        -- 2. GOOGLE: 40% de chance (ID 2)
        IF (RAND() * 100) <= 40 THEN
            INSERT INTO `mydb`.`login` (`usuario_usuario_id`, `tiposLogin_tiposLogin_id`, `senha`) 
            VALUES (v_usuario_id, 2, v_senha_padrao);
        END IF;

        -- 3. GOV.BR: 20% de chance (ID 4)
        IF (RAND() * 100) <= 20 THEN
            INSERT INTO `mydb`.`login` (`usuario_usuario_id`, `tiposLogin_tiposLogin_id`, `senha`) 
            VALUES (v_usuario_id, 4, v_senha_padrao);
        END IF;

        -- 4. FACEBOOK: 10% de chance (ID 3)
        IF (RAND() * 100) <= 10 THEN
            INSERT INTO `mydb`.`login` (`usuario_usuario_id`, `tiposLogin_tiposLogin_id`, `senha`) 
            VALUES (v_usuario_id, 3, v_senha_padrao);
        END IF;

        -- Commit a cada 5.000 registros para otimizar a memória
        IF MOD(v_usuario_id, 5000) = 0 THEN
            COMMIT;
        END IF;

        SET v_usuario_id = v_usuario_id + 1;
    END WHILE;

    COMMIT;
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularLoginsUsuarios();

-- endereços

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularEnderecos$$

CREATE PROCEDURE PopularEnderecos()
BEGIN
    DECLARE v_usuario_id INT DEFAULT 1;
    DECLARE v_max_usuario_id INT;
    DECLARE v_max_cep_id INT;
    
    DECLARE v_logradouro VARCHAR(45);
    DECLARE v_numero INT;
    DECLARE v_cep_sorteado INT;

    -- Descobre o total de usuários e o total de CEPs disponíveis
    SELECT MAX(usuario_id) INTO v_max_usuario_id FROM `mydb`.`usuario`;
    SELECT MAX(cep_id) INTO v_max_cep_id FROM `mydb`.`CEP`;

    -- Configurações de performance para carga massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_usuario_id DO
        
        -- Gerando dados fictícios aleatórios para o endereço
        SET v_logradouro = CONCAT('Rua ', CHAR(FLOOR(65 + RAND() * 25)), ', Número ', FLOOR(RAND() * 1000));
        SET v_numero = FLOOR(1 + RAND() * 9999);
        -- Sorteia um ID de CEP entre 1 e o máximo existente
        SET v_cep_sorteado = FLOOR(1 + RAND() * v_max_cep_id);

        -- 1. BASE: 100% dos usuários ganham um endereço "Residencial"
        INSERT INTO `mydb`.`endereco` (`endereco_identificacao`, `endereco_logradouro`, `endereco_numero`, `usuario_usuario_id`, `CEP_cep_id`) 
        VALUES ('Residencial', v_logradouro, v_numero, v_usuario_id, v_cep_sorteado);

        -- 2. TRABALHO: 20% de chance de ter um segundo endereço comercial
        IF (RAND() * 100) <= 20 THEN
            -- Gera novos dados para o endereço de trabalho
            SET v_logradouro = CONCAT('Avenida Comercial ', FLOOR(RAND() * 500));
            SET v_numero = FLOOR(1 + RAND() * 9999);
            SET v_cep_sorteado = FLOOR(1 + RAND() * v_max_cep_id);
            
            INSERT INTO `mydb`.`endereco` (`endereco_identificacao`, `endereco_logradouro`, `endereco_numero`, `usuario_usuario_id`, `CEP_cep_id`) 
            VALUES ('Trabalho', v_logradouro, v_numero, v_usuario_id, v_cep_sorteado);
        END IF;

        -- Commit fracionado a cada 5.000 registros para evitar travamento
        IF MOD(v_usuario_id, 5000) = 0 THEN
            COMMIT;
        END IF;

        SET v_usuario_id = v_usuario_id + 1;
    END WHILE;

    COMMIT;
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularEnderecos();

-- tipo evento

INSERT INTO `mydb`.`tipoEvento` (`tipoEvento_nome`) VALUES 
('Presencial'), 
('Online'), 
('Híbrido');

-- eventos, localEvento e sublocal
DELIMITER $$

DROP PROCEDURE IF EXISTS PopularEventosComplexos$$

CREATE PROCEDURE PopularEventosComplexos(IN p_quantidade_eventos INT)
BEGIN
    DECLARE v_contador INT DEFAULT 1;
    DECLARE v_sub_contador INT;
    DECLARE v_qtd_sublocais INT;
    
    -- Variáveis de IDs
    DECLARE v_local_id INT;
    DECLARE v_usuario_criador_id INT;
    DECLARE v_tipo_evento_max INT;
    DECLARE v_tipo_evento_id INT;
    DECLARE v_max_org_id INT;
    
    -- Variáveis de Dados
    DECLARE v_tipo_evento_nome VARCHAR(45);
    DECLARE v_is_online BOOLEAN;
    DECLARE v_capacidade_total INT;
    DECLARE v_capacidade_sub INT;
    DECLARE v_data_inicio DATE;
    DECLARE v_data_fim DATE;
    DECLARE v_data_limite DATETIME;

    -- 1. Cria tabela temporária de usuários que PODEM criar eventos
    DROP TEMPORARY TABLE IF EXISTS tmp_organizadores;
    CREATE TEMPORARY TABLE tmp_organizadores (
        id INT AUTO_INCREMENT PRIMARY KEY,
        usuario_id INT
    );

    -- Povoa a tabela EXATAMENTE com quem tem a permissão CRIAR_EVENTO
    INSERT INTO tmp_organizadores (usuario_id)
    SELECT DISTINCT pu.usuario_usuario_id 
    FROM `mydb`.`permissoesUsuarios` pu
    INNER JOIN `mydb`.`permissoes` p ON pu.permissoes_permissoes_id = p.permissoes_id
    WHERE p.permissoes_nome = 'CRIAR_EVENTO';

    -- Pega o total de organizadores encontrados
    SELECT MAX(id) INTO v_max_org_id FROM tmp_organizadores;
    
    -- TRAVA DE SEGURANÇA: Se não existir NINGUÉM com a permissão 'CRIAR_EVENTO',
    -- encerra a procedure para não violar a regra de negócio e não dar erro 1048.
    IF v_max_org_id IS NULL THEN
        SET v_contador = p_quantidade_eventos + 1; -- Força a saída do WHILE
    END IF;

    -- Descobre o ID máximo dos tipos de evento cadastrados
    SELECT MAX(tipoEvento_id) INTO v_tipo_evento_max FROM `mydb`.`tipoEvento`;

    -- Configurações de performance para a carga massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_contador <= p_quantidade_eventos DO
        
        SET v_capacidade_total = FLOOR(1000 + RAND() * 19000);

        -- =======================================================
        -- PASSO 1: DESCOBRIR O TIPO DO EVENTO
        -- =======================================================
        SET v_tipo_evento_id = FLOOR(1 + RAND() * v_tipo_evento_max);
        SET v_tipo_evento_nome = NULL;
        
        SELECT tipoEvento_nome INTO v_tipo_evento_nome 
        FROM `mydb`.`tipoEvento` 
        WHERE tipoEvento_id = v_tipo_evento_id LIMIT 1;
        
        -- Proteção caso sorteie um tipo que foi apagado
        IF v_tipo_evento_nome IS NULL THEN
            SET v_tipo_evento_id = 1;
            SELECT tipoEvento_nome INTO v_tipo_evento_nome FROM `mydb`.`tipoEvento` WHERE tipoEvento_id = 1 LIMIT 1;
        END IF;

        IF v_tipo_evento_nome LIKE '%Online%' OR v_tipo_evento_nome LIKE '%Virtual%' THEN
            SET v_is_online = 1;
        ELSE
            SET v_is_online = 0;
        END IF;

        -- =======================================================
        -- PASSO 2: CRIAR O LOCAL
        -- =======================================================
        IF v_is_online = 1 THEN
            INSERT INTO `mydb`.`localEvento` (
                `localEvento_nome`, `localEvento_descricao`, `localEvento_capacidade`, `localEvento_endereco`
            ) VALUES (
                'Plataforma Virtual / Streaming', 'Ambiente 100% digital', v_capacidade_total, 'Link da Transmissão'
            );
        ELSE
            INSERT INTO `mydb`.`localEvento` (
                `localEvento_nome`, `localEvento_descricao`, `localEvento_capacidade`, `localEvento_endereco`
            ) VALUES (
                CONCAT('Espaço do Evento ', v_contador), 'Local físico criado para o evento.', v_capacidade_total, CONCAT('Rua dos Eventos, ', FLOOR(1 + RAND() * 9999))
            );
        END IF;
        
        SET v_local_id = LAST_INSERT_ID();

        -- =======================================================
        -- PASSO 3: CRIAR O EVENTO
        -- =======================================================
        SET v_data_inicio = CURDATE() + INTERVAL FLOOR(10 + RAND() * 300) DAY;
        SET v_data_fim = v_data_inicio + INTERVAL FLOOR(RAND() * 5) DAY;
        SET v_data_limite = v_data_inicio - INTERVAL FLOOR(1 + RAND() * 15) DAY;
        
        -- Sorteia o criador APENAS entre os que têm a permissão CRIAR_EVENTO
        SET v_usuario_criador_id = NULL;
        SELECT usuario_id INTO v_usuario_criador_id 
        FROM tmp_organizadores 
        WHERE id = FLOOR(1 + (RAND() * (v_max_org_id - 1))) LIMIT 1;
        
        -- Prevenção final de falha no RAND()
        IF v_usuario_criador_id IS NULL THEN
            SELECT usuario_id INTO v_usuario_criador_id FROM tmp_organizadores LIMIT 1;
        END IF;

        INSERT INTO `mydb`.`eventos` (
            `eventos_nome`, `eventos_descricao`, `eventos_dataInicio`, `eventos_dataFim`, 
            `eventos_dataLimiteInscricao`, `tipoEvento_tipoEvento_id`, `local_local_id`, `usuario_usuario_id`
        ) VALUES (
            CONCAT('Super Evento ', v_contador),
            CONCAT('Descrição detalhada do evento (Modalidade: ', IFNULL(v_tipo_evento_nome, 'Geral'), ').'),
            v_data_inicio,
            v_data_fim,
            v_data_limite,
            v_tipo_evento_id,
            v_local_id,
            v_usuario_criador_id
        );

        -- =======================================================
        -- PASSO 4: CRIAR OS SUBLOCAIS (SE NÃO FOR ONLINE)
        -- =======================================================
        IF v_is_online = 0 THEN
            SET v_qtd_sublocais = FLOOR(5 + RAND() * 16);
            SET v_capacidade_sub = FLOOR(v_capacidade_total / v_qtd_sublocais);
            SET v_sub_contador = 1;

            WHILE v_sub_contador <= v_qtd_sublocais DO
                INSERT INTO `mydb`.`sublocaEvento` (
                    `sublocaEvento_nome`, `sublocaEvento_descricao`, `sublocaEvento_capacidade`, `localEvento_localEvento_id`
                ) VALUES (
                    CONCAT('Setor ', CHAR(64 + v_sub_contador)), 'Setor do evento físico', v_capacidade_sub, v_local_id
                );
                SET v_sub_contador = v_sub_contador + 1;
            END WHILE;
        END IF;

        IF MOD(v_contador, 1000) = 0 THEN
            COMMIT;
        END IF;

        SET v_contador = v_contador + 1;
    END WHILE;

    COMMIT;
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
    DROP TEMPORARY TABLE IF EXISTS tmp_organizadores;
END$$

DELIMITER ;

CALL PopularEventosComplexos(1500);

-- tipo Inscrição

DELIMITER $$

DROP PROCEDURE IF EXISTS GerarPrecosDosEventos$$

CREATE PROCEDURE GerarPrecosDosEventos()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    
    -- Cursor para pegar todos os eventos existentes
    DECLARE cur_eventos CURSOR FOR SELECT eventos_id FROM `mydb`.`eventos`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SET FOREIGN_KEY_CHECKS = 0;
    OPEN cur_eventos;

    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Criando 4 tipos de inscrição para CADA evento com valores aleatórios
        INSERT INTO `mydb`.`tipoInscricao` (`tipoInscricao_nome`, `tipoInscricao_valor`, `eventos_eventos_id`)
        VALUES 
        ('Padrão', 50.00 + (RAND() * 50), v_evento_id),
        ('VIP', 150.00 + (RAND() * 200), v_evento_id),
        ('Cortesia', 0.00, v_evento_id),
        ('Meia-Entrada', 25.00 + (RAND() * 25), v_evento_id);

    END LOOP;

    CLOSE cur_eventos;
    SET FOREIGN_KEY_CHECKS = 1;
    COMMIT;
END$$

DELIMITER ;

CALL GerarPrecosDosEventos();

-- inscrição

DELIMITER $$

DROP PROCEDURE IF EXISTS InscricaoEvento$$

CREATE PROCEDURE InscricaoEvento(IN p_total INT)
BEGIN
    DECLARE v_inseridos INT DEFAULT 0;
    DECLARE v_user_id INT;
    DECLARE v_evento_id INT;
    DECLARE v_tipo_id INT;
    DECLARE v_max_user INT;
    DECLARE v_max_evento INT;
    DECLARE v_is_participante INT DEFAULT 0;

    -- Pega o maior ID possível para sabermos o limite do "chute"
    SELECT MAX(usuario_id) INTO v_max_user FROM `mydb`.`usuario`;
    SELECT MAX(eventos_id) INTO v_max_evento FROM `mydb`.`eventos`;

    -- Desliga travas para acelerar
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_inseridos < p_total DO
        
        -- 1. CHUTA UM USUÁRIO ALEATÓRIO (Matemática simples, custo zero pro banco)
        SET v_user_id = FLOOR(1 + RAND() * v_max_user);

        -- Pergunta ao banco se ele é PARTICIPANTE (Busca indexada ultra rápida)
        SET v_is_participante = 0;
        SELECT 1 INTO v_is_participante
        FROM `mydb`.`permissoesUsuarios` pu
        INNER JOIN `mydb`.`permissoes` p ON pu.permissoes_permissoes_id = p.permissoes_id
        WHERE pu.usuario_usuario_id = v_user_id AND p.permissoes_nome = 'PARTICIPANTE'
        LIMIT 1;

        -- Se acertamos no chute (ele é participante), prosseguimos
        IF v_is_participante = 1 THEN
            
            -- 2. CHUTA UM EVENTO ALEATÓRIO
            SET v_evento_id = FLOOR(1 + RAND() * v_max_evento);

            -- 3. PEGA O INGRESSO DESSE EVENTO
            SET v_tipo_id = NULL;
            SELECT tipoInscricao_id INTO v_tipo_id 
            FROM `mydb`.`tipoInscricao` 
            WHERE eventos_eventos_id = v_evento_id 
            LIMIT 1;

            -- Se o evento tem ingresso, faz a inscrição!
            IF v_tipo_id IS NOT NULL THEN
                INSERT IGNORE INTO `mydb`.`inscricao` (
                    `inscricao_credenciamento`, 
                    `eventos_eventos_id`, 
                    `usuario_usuario_id`, 
                    `tipoInscricao_tipoInscricao_id`
                ) VALUES (
                    IF(RAND() > 0.8, 1, 0), 
                    v_evento_id, 
                    v_user_id, 
                    v_tipo_id
                );

                SET v_inseridos = v_inseridos + 1;
                
                -- Salva no disco a cada 1.000 registros para não pesar
                IF MOD(v_inseridos, 1000) = 0 THEN
                    COMMIT;
                END IF;
            END IF;
        END IF;
        
    END WHILE;

    COMMIT;
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;

END$$

DELIMITER ;

CALL InscricaoEvento(110000);

-- voucher

DELIMITER $$

DROP PROCEDURE IF EXISTS GerarVouchersDinamicos$$

CREATE PROCEDURE GerarVouchersDinamicos(
    IN p_percentual DECIMAL(5,2), -- Ex: 60 para 60%
    IN p_min_vouchers INT,        -- Ex: 5
    IN p_max_vouchers INT         -- Ex: 20
)
BEGIN
    DECLARE v_offset INT DEFAULT 0;
    DECLARE v_lote INT DEFAULT 1000; -- Processa 1.000 eventos por vez para não pesar
    DECLARE v_max_id INT;

    -- Previne erro caso o máximo de vouchers seja um número muito grande
    SET SESSION cte_max_recursion_depth = 1000000;
    
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    -- =======================================================
    -- 1. SEPARAÇÃO DOS EVENTOS E SORTEIO DA QUANTIDADE
    -- =======================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_evt_selecionados;
    CREATE TEMPORARY TABLE tmp_evt_selecionados (
        id INT AUTO_INCREMENT PRIMARY KEY,
        evento_id INT,
        tipo_id INT,
        qtd_vouchers INT -- <-- Nova coluna para guardar o sorteio de cada evento
    );

    INSERT INTO tmp_evt_selecionados (evento_id, tipo_id, qtd_vouchers)
    SELECT 
        e.eventos_id, 
        MIN(t.tipoInscricao_id),
        -- Sorteia a quantidade de vouchers que ESTE evento específico vai ter
        FLOOR(p_min_vouchers + (RAND() * (p_max_vouchers - p_min_vouchers + 1)))
    FROM `mydb`.`eventos` e
    INNER JOIN `mydb`.`tipoInscricao` t ON e.eventos_id = t.eventos_eventos_id
    -- Transforma o parâmetro (ex: 60) em porcentagem real (0.60)
    WHERE RAND() <= (p_percentual / 100.0) 
    GROUP BY e.eventos_id;

    -- Pegamos o total de eventos separados (se for nulo, joga 0)
    SELECT IFNULL(MAX(id), 0) INTO v_max_id FROM tmp_evt_selecionados;

    -- =======================================================
    -- 2. LOOP MULTIPLICADOR INTELIGENTE
    -- =======================================================
    WHILE v_offset < v_max_id DO
        
        INSERT IGNORE INTO `mydb`.`voucher` (
            `voucher_codigo`,
            `voucher_valor`,
            `voucher_dataValidade`,
            `voucher_disponivel`,
            `eventos_eventos_id`,
            `tipoInscricao_tipoInscricao_id`
        )
        -- O gerador cria linhas até bater no limite MÁXIMO global que você passou
        WITH RECURSIVE gerador AS (
            SELECT 1 AS n UNION ALL SELECT n + 1 FROM gerador WHERE n < p_max_vouchers
        )
        SELECT 
            -- MD5 com vários dados misturados para garantir código único
            CONCAT(UPPER(SUBSTRING(MD5(CONCAT(RAND(), e.evento_id, g.n)), 1, 6)), '-', UPPER(SUBSTRING(UUID(), 1, 5))),
            ROUND((RAND() * 90) + 10, 2), -- Valor entre R$ 10 e R$ 100
            DATE_ADD(NOW(), INTERVAL FLOOR(RAND() * 365) DAY), -- Validade aleatória
            1, -- Todos nascem disponíveis
            e.evento_id,
            e.tipo_id
        FROM tmp_evt_selecionados e
        CROSS JOIN gerador g
        -- O pulo do gato: Ele só cria a linha se o número do gerador (g.n) 
        -- for menor ou igual à quantidade sorteada para esse evento (e.qtd_vouchers)
        WHERE e.id > v_offset 
          AND e.id <= (v_offset + v_lote)
          AND g.n <= e.qtd_vouchers;

        SET v_offset = v_offset + v_lote;
        COMMIT;
        
    END WHILE;

    -- =======================================================
    -- 3. FINALIZAÇÃO
    -- =======================================================
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
    
    DROP TEMPORARY TABLE IF EXISTS tmp_evt_selecionados;

END$$

DELIMITER ;

CALL GerarVouchersDinamicos(
    @percentual_eventos_com_voucher, 
    @qtd_minima_vouchers_por_evento, 
    @qtd_maxima_vouchers_por_evento
);

-- metodo de pagamento

INSERT INTO `mydb`.`metodoPagamento` (`formaDePagamento`) VALUES 
('Pix'),
('Cartão de Crédito'),
('Cartão de Débito'),
('Boleto Bancário'),
('Transferência (TED/DOC)'),
('Dinheiro');

-- tipo de desconto

INSERT INTO `mydb`.`tipoDesconto` (`tipoDesconto_nome`, `tipoDesconto_descricao`) VALUES 
('Voucher', 'Desconto aplicado via código promocional alfanumérico'),
('Lote Antecipado', 'Desconto automático por compra no primeiro lote'),
('Membro/Sócio', 'Desconto para usuários com assinatura ativa'),
('Cortesia', 'Isenção total de valor para convidados especiais'),
('Cupom Evento', 'Desconto específico para uma categoria de evento');

-- pagamento

DELIMITER $$

DROP PROCEDURE IF EXISTS GerarPagamentosDinamicosV2$$

CREATE PROCEDURE GerarPagamentosDinamicosV2(
    IN p_min_percentual_pagantes DECIMAL(5,2), 
    IN p_max_percentual_pagantes DECIMAL(5,2), 
    IN p_min_valor_ingresso DECIMAL(9,2),      
    IN p_max_valor_ingresso DECIMAL(9,2)       
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_total_inscritos INT;
    DECLARE v_qtd_pagar INT;
    DECLARE v_valor_evento DECIMAL(9,2);
    
    DECLARE v_min_metodo, v_max_metodo INT;
    DECLARE v_min_tipo_desc, v_max_tipo_desc INT;

    DECLARE cur_eventos CURSOR FOR SELECT eventos_id FROM `mydb`.`eventos`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SELECT MIN(metodoPagamento_id), MAX(metodoPagamento_id) INTO v_min_metodo, v_max_metodo FROM `mydb`.`metodoPagamento`;
    SELECT MIN(tipoDesconto_id), MAX(tipoDesconto_id) INTO v_min_tipo_desc, v_max_tipo_desc FROM `mydb`.`tipoDesconto`;

    SET FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    OPEN cur_eventos;

    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        SET v_valor_evento = ROUND(p_min_valor_ingresso + (RAND() * (p_max_valor_ingresso - p_min_valor_ingresso)), 2);

        SELECT COUNT(*) INTO v_total_inscritos FROM `mydb`.`inscricao` WHERE eventos_eventos_id = v_evento_id;
        
        SET v_qtd_pagar = FLOOR(v_total_inscritos * ( (p_min_percentual_pagantes + (RAND() * (p_max_percentual_pagantes - p_min_percentual_pagantes))) / 100 ));

        IF v_qtd_pagar > 0 THEN
            -- 1. Inserção dos pagamentos
            INSERT INTO `mydb`.`pagamento` (
                `pagamento_valorTotal`,
                `pagamento_valorPagamento`,
                `pagamento_status`,
                `pagamento_dataHora`,
                `metodoPagamento_metodoPagamento_id`,
                `voucher_voucher_id`,
                `inscricao_inscricao_id`,
                `tipoDesconto_tipoDesconto_id`
            )
            SELECT 
                v_valor_evento,
                -- Busca o valor do voucher diretamente na subquery para garantir o cálculo correto
                GREATEST(v_valor_evento - IFNULL((SELECT valor FROM (SELECT voucher_id, voucher_valor as valor FROM `mydb`.`voucher`) as v_temp WHERE v_temp.voucher_id = rand_voucher.v_id), 0), 0),
                ELT(FLOOR(RAND() * 3) + 1, 'Pendente', 'Pago', 'Agendado'),
                DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 60) DAY),
                FLOOR(v_min_metodo + RAND() * (v_max_metodo - v_min_metodo + 1)),
                rand_voucher.v_id,
                i.inscricao_id,
                IF(RAND() < 0.3, FLOOR(v_min_tipo_desc + RAND() * (v_max_tipo_desc - v_min_tipo_desc + 1)), NULL)
            FROM `mydb`.`inscricao` i
            -- Subquery lateral para sortear o voucher disponível UMA vez por linha
            LEFT JOIN (
                SELECT voucher_id as v_id 
                FROM `mydb`.`voucher` 
                WHERE eventos_eventos_id = v_evento_id 
                AND voucher_disponivel = 1 
                ORDER BY RAND() 
            ) AS rand_voucher ON RAND() < 0.3 -- 30% de chance de aplicar um voucher
            WHERE i.eventos_eventos_id = v_evento_id
            ORDER BY RAND()
            LIMIT v_qtd_pagar;

            -- 2. UPDATE nos vouchers que acabaram de ser vinculados a um pagamento
            -- Atualiza para 0 (indisponível) apenas os vouchers que estão na tabela de pagamento
            UPDATE `mydb`.`voucher` v
            INNER JOIN `mydb`.`pagamento` p ON v.voucher_id = p.voucher_voucher_id
            SET v.voucher_disponivel = 0
            WHERE v.eventos_eventos_id = v_evento_id 
            AND v.voucher_disponivel = 1;

        END IF;

        COMMIT; 

    END LOOP;

    CLOSE cur_eventos;
    SET FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL GerarPagamentosDinamicosV2(
    @perc_min_pagantes, 
    @perc_max_pagantes, 
    @valor_min_ticket, 
    @valor_max_ticket
);

-- Programação

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularProgramacaoMassiva$$

CREATE PROCEDURE PopularProgramacaoMassiva()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_data_inicio DATE;
    DECLARE v_data_fim DATE;
    DECLARE v_subloca_id INT;
    DECLARE v_data_atual DATETIME;
    DECLARE v_hora_fim_dia DATETIME;
    DECLARE v_atv_count INT DEFAULT 1;

    -- Cursor para pegar todos os eventos
    DECLARE cur_eventos CURSOR FOR 
        SELECT eventos_id, eventos_dataInicio, eventos_dataFim FROM `mydb`.`eventos`;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Otimizações
    SET FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    OPEN cur_eventos;

    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id, v_data_inicio, v_data_fim;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Para cada evento, vamos iterar pelos seus sublocais (salas)
        -- Usamos um bloco interno para gerenciar as salas do evento atual
        BLOCK2: BEGIN
            DECLARE v_done_sub INT DEFAULT FALSE;
            DECLARE cur_subs CURSOR FOR 
                SELECT s.sublocaEvento_id 
                FROM `mydb`.`sublocaEvento` s
                INNER JOIN `mydb`.`eventos` e ON s.localEvento_localEvento_id = e.local_local_id
                WHERE e.eventos_id = v_evento_id;
            
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done_sub = TRUE;

            OPEN cur_subs;
            sub_loop: LOOP
                FETCH cur_subs INTO v_subloca_id;
                IF v_done_sub THEN LEAVE sub_loop; END IF;

                -- Agora preenchemos os dias do evento para esta sala específica
                SET v_data_atual = CAST(CONCAT(v_data_inicio, ' 08:00:00') AS DATETIME);
                
                WHILE DATE(v_data_atual) <= v_data_fim DO
                    -- Define o limite do dia (18h)
                    SET v_hora_fim_dia = CAST(CONCAT(DATE(v_data_atual), ' 18:00:00') AS DATETIME);
                    
                    -- Enquanto houver tempo no dia, cria palestras de 2 horas
                    WHILE v_data_atual < v_hora_fim_dia DO
                        INSERT INTO `mydb`.`programacao` (
                            `programacao_horaInicio`, 
                            `programacao_horaFim`, 
                            `programacao_nome`, 
                            `programacao_linkPresenca`, 
                            `programacao_descricao`, 
                            `eventos_eventos_id`, 
                            `sublocaEvento_sublocaEvento_id`
                        ) VALUES (
                            v_data_atual,
                            DATE_ADD(v_data_atual, INTERVAL 2 HOUR),
                            CONCAT('Atividade ', v_atv_count, ' - Evento ', v_evento_id),
                            CONCAT('https://presenca.evento.com/atv', v_atv_count),
                            CONCAT('Descrição detalhada da atividade acadêmica número ', v_atv_count),
                            v_evento_id,
                            v_subloca_id
                        );

                        SET v_atv_count = v_atv_count + 1;
                        -- Pula para a próxima atividade (2h de palestra + 15min de intervalo)
                        SET v_data_atual = DATE_ADD(v_data_atual, INTERVAL 135 MINUTE);
                    END WHILE;

                    -- Vai para o próximo dia às 08:00
                    SET v_data_atual = CAST(CONCAT(DATE_ADD(DATE(v_data_atual), INTERVAL 1 DAY), ' 08:00:00') AS DATETIME);
                END WHILE;
            END LOOP sub_loop;
            CLOSE cur_subs;
        END BLOCK2;

        -- Commit por evento para não sobrecarregar
        COMMIT;
    END LOOP;

    CLOSE cur_eventos;
    SET FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularProgramacaoMassiva();

-- incritos programção

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularInscritosProgramacaoOtimizada$$

CREATE PROCEDURE PopularInscritosProgramacaoOtimizada(
    IN p_perc_min_ocupacao FLOAT,
    IN p_perc_max_ocupacao FLOAT,
    IN p_perc_min_presenca FLOAT,
    IN p_perc_max_presenca FLOAT
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prog_id INT;
    DECLARE v_evento_id INT;
    DECLARE v_capacidade INT;
    DECLARE v_hora_inicio DATETIME;
    
    DECLARE v_total_inscritos INT;
    DECLARE v_qtd_alvo INT;
    DECLARE v_probabilidade FLOAT;
    DECLARE v_taxa_presenca FLOAT;
    
    -- Variaveis locais que receberao os valores convertidos para decimal
    DECLARE v_min_ocupacao FLOAT;
    DECLARE v_max_ocupacao FLOAT;
    DECLARE v_min_presenca FLOAT;
    DECLARE v_max_presenca FLOAT;

    DECLARE cur_prog CURSOR FOR 
        SELECT 
            p.programacao_id, 
            p.eventos_eventos_id, 
            p.programacao_horaInicio, 
            s.sublocaEvento_capacidade
        FROM `mydb`.`programacao` p
        INNER JOIN `mydb`.`sublocaEvento` s ON p.sublocaEvento_sublocaEvento_id = s.sublocaEvento_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- =========================================================================
    -- CONVERTE AS PORCENTAGENS RECEBIDAS NO 'CALL' PARA DECIMAL (Ex: 5.0 -> 0.05)
    -- =========================================================================
    SET v_min_ocupacao = p_perc_min_ocupacao / 100.0;
    SET v_max_ocupacao = p_perc_max_ocupacao / 100.0;
    SET v_min_presenca = p_perc_min_presenca / 100.0;
    SET v_max_presenca = p_perc_max_presenca / 100.0;

    -- TURBO LIGADO
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET SESSION autocommit = 0;

    OPEN cur_prog;

    read_loop: LOOP
        FETCH cur_prog INTO v_prog_id, v_evento_id, v_hora_inicio, v_capacidade;
        IF v_done THEN LEAVE read_loop; END IF;

        SELECT COUNT(inscricao_id) INTO v_total_inscritos 
        FROM `mydb`.`inscricao` 
        WHERE eventos_eventos_id = v_evento_id;

        IF v_total_inscritos > 0 THEN
            
            -- Usa as variaveis convertidas para calcular a quantidade alvo
            SET v_qtd_alvo = FLOOR(LEAST(v_total_inscritos, v_capacidade) * (v_min_ocupacao + (RAND() * (v_max_ocupacao - v_min_ocupacao))));
            
            IF v_qtd_alvo > 0 THEN
                
                SET v_probabilidade = (v_qtd_alvo / v_total_inscritos) * 1.2;
                
                -- Usa as variaveis de presenca convertidas (ex: entre 0.60 e 0.90)
                SET v_taxa_presenca = v_min_presenca + (RAND() * (v_max_presenca - v_min_presenca));

                INSERT INTO `mydb`.`inscritosProgramacao` (
                    `inscritos_inscritos_id`,
                    `programacao_programacao_id`,
                    `inscritosProgramacao_dataHoraFrequencia`,
                    `inscritosProgramacao_FrequenciaConfirmada`
                )
                SELECT 
                    id_inscricao,
                    v_prog_id,
                    IF(confirmou = 1, DATE_ADD(v_hora_inicio, INTERVAL FLOOR(-30 + (RAND() * 45)) MINUTE), NULL),
                    confirmou
                FROM (
                    SELECT 
                        inscricao_id AS id_inscricao,
                        IF(RAND() <= v_taxa_presenca, 1, 0) AS confirmou
                    FROM `mydb`.`inscricao`
                    WHERE eventos_eventos_id = v_evento_id
                    AND RAND() <= v_probabilidade 
                    LIMIT v_qtd_alvo
                ) AS temp_inscritos;
            
            END IF;
            
        END IF;

        COMMIT;

    END LOOP read_loop;

    CLOSE cur_prog;

    -- TURBO DESLIGADO
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET SESSION autocommit = 1;
END$$

DELIMITER ;

CALL PopularInscritosProgramacaoOtimizada(
    @perc_min_ocupacao, 
    @perc_max_ocupacao, 
    @perc_min_presenca, 
    @perc_max_presenca
);

-- papel 

INSERT INTO `mydb`.`papel` (`papel_nome`, `papel_descricao`) VALUES
('Participante', 'Pessoa inscrita para assistir ou participar das atividades do evento.'),
('Staff', 'Membro da equipe geral de apoio, credenciamento e organizacao do evento.'),
('Palestrante', 'Especialista convidado para ministrar palestras, cursos ou workshops.'),
('Auxiliar', 'Pessoa responsavel por auxiliar na logistica das salas, microfones e equipamentos.'),
('Organizador', 'Responsavel pela coordenacao geral de atividades especificas ou do proprio evento.'),
('Moderador', 'Responsavel por mediar mesas redondas, debates, paineis e interacao com o publico.'),
('Expositor', 'Representante de marca ou empresa patrocinadora com estande no evento.'),
('Convidado VIP', 'Participante com acesso a areas exclusivas, assentos reservados ou convite especial.'),
('Avaliador', 'Especialista responsavel por avaliar submissoes de trabalhos academicos ou projetos.'),
('Mestre de Cerimonias', 'Responsavel pela conducao, abertura e apresentacao oficial do evento ao publico.'),
('Responsavel pelo Local', 'Profissional encarregado da infraestrutura, controle de acesso, seguranca e manutencao do espaco fisico.');

-- Papel programação

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularPapelProgramacaoOtimizada$$

CREATE PROCEDURE PopularPapelProgramacaoOtimizada()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prog_id INT;
    DECLARE v_evento_id INT;
    
    DECLARE v_total_inscritos INT;
    DECLARE v_probabilidade FLOAT;

    -- Cursor leve apenas para ler as atividades
    DECLARE cur_prog CURSOR FOR 
        SELECT programacao_id, eventos_eventos_id
        FROM `mydb`.`programacao`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- OTIMIZACAO EXTREMA: Desliga travas de disco e verificacoes de integridade
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET SESSION autocommit = 0;

    OPEN cur_prog;

    read_loop: LOOP
        FETCH cur_prog INTO v_prog_id, v_evento_id;
        IF v_done THEN LEAVE read_loop; END IF;

        -- 1. Verifica quantas pessoas estao no evento
        SELECT COUNT(inscricao_id) INTO v_total_inscritos 
        FROM `mydb`.`inscricao` 
        WHERE eventos_eventos_id = v_evento_id;

        IF v_total_inscritos > 0 THEN
            
            -- 2. Probabilidade inflada para garantir que o LIMIT 5 seja atingido rapidamente.
            -- Pede uma amostra de umas 50 pessoas para o banco, e depois corta em 5.
            SET v_probabilidade = LEAST(1.0, 50.0 / v_total_inscritos);

            -- 3. BULK INSERT: Associa 5 papeis diferentes para 5 pessoas diferentes na mesma atividade
            INSERT INTO `mydb`.`papelProgramacao` (
                `programacao_programacao_id`,
                `inscricao_inscricao_id`,
                `papel_papel_id`
            )
            SELECT 
                v_prog_id,
                id_inscricao,
                -- A funcao ELT transforma a linha (1, 2, 3...) no ID real do papel na sua tabela
                ELT(row_num, 3, 2, 4, 5, 11) 
                -- 3=Palestrante, 2=Staff, 4=Auxiliar, 5=Organizador, 11=Responsavel pelo Local
            FROM (
                -- Subquery geradora de sequencia ultrarrapida
                SELECT 
                    inscricao_id AS id_inscricao,
                    (@rn := @rn + 1) AS row_num
                FROM `mydb`.`inscricao`
                CROSS JOIN (SELECT @rn := 0) var
                WHERE eventos_eventos_id = v_evento_id
                AND RAND() <= v_probabilidade
                LIMIT 5
            ) AS temp_papeis
            WHERE row_num <= 5; 
            
        END IF;

        -- Commit a cada atividade para nao sobrecarregar a memoria RAM do servidor
        COMMIT;

    END LOOP read_loop;

    CLOSE cur_prog;

    -- Restaura a seguranca do banco de dados
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET SESSION autocommit = 1;
END$$

DELIMITER ;

CALL PopularPapelProgramacaoOtimizada();

-- imagens evento

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularImagemEventoOtimizada$$

CREATE PROCEDURE PopularImagemEventoOtimizada()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_evento_nome VARCHAR(255);
    DECLARE v_caminho_limpo VARCHAR(255);

    DECLARE cur_eventos CURSOR FOR 
        SELECT eventos_id, eventos_nome FROM `mydb`.`eventos`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Otimizacao de performance
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET SESSION autocommit = 0;

    -- Tabela de numeros para o Bulk Insert (ate 8 imagens)
    DROP TEMPORARY TABLE IF EXISTS tmp_num_evt;
    CREATE TEMPORARY TABLE tmp_num_evt (n INT PRIMARY KEY);
    INSERT INTO tmp_num_evt VALUES (1), (2), (3), (4), (5), (6), (7), (8);

    OPEN cur_eventos;
    
    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id, v_evento_nome;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Limpa o nome do evento para o formato de pasta de servidor
        SET v_caminho_limpo = REPLACE(LOWER(v_evento_nome), ' ', '_');

        INSERT INTO `mydb`.`imagemEvento` (
            `imagemEvento_caminho`, 
            `imagemEvento_descricao`, 
            `eventos_eventos_id`
        )
        SELECT 
            CONCAT('/imagens/', v_caminho_limpo, '/img', t.n, '.jpg'),
            CONCAT('Imagem de divulgacao ', t.n, ' do evento'),
            v_evento_id
        FROM tmp_num_evt t
        -- Aleatorio entre 3 e 8
        WHERE t.n <= (3 + FLOOR(RAND() * 6)); 

        COMMIT;
    END LOOP read_loop;
    
    CLOSE cur_eventos;

    DROP TEMPORARY TABLE IF EXISTS tmp_num_evt;

    -- Restaura seguranca
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET SESSION autocommit = 1;
END$$

DELIMITER ;

CALL PopularImagemEventoOtimizada();

-- IMAGEM PROGRAMAÇÃO

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularImagemProgramacaoOtimizada$$

CREATE PROCEDURE PopularImagemProgramacaoOtimizada()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prog_id INT;
    DECLARE v_prog_nome VARCHAR(255);
    DECLARE v_evento_nome VARCHAR(255);
    DECLARE v_caminho_pasta VARCHAR(500);

    DECLARE cur_prog CURSOR FOR 
        SELECT 
            p.programacao_id, 
            p.programacao_nome,
            e.eventos_nome
        FROM `mydb`.`programacao` p
        INNER JOIN `mydb`.`eventos` e ON p.eventos_eventos_id = e.eventos_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Otimizacao de performance
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET SESSION autocommit = 0;

    -- Tabela de numeros para o Bulk Insert (ate 5 imagens)
    DROP TEMPORARY TABLE IF EXISTS tmp_num_prog;
    CREATE TEMPORARY TABLE tmp_num_prog (n INT PRIMARY KEY);
    INSERT INTO tmp_num_prog VALUES (1), (2), (3), (4), (5);

    OPEN cur_prog;
    
    read_loop: LOOP
        FETCH cur_prog INTO v_prog_id, v_prog_nome, v_evento_nome;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Constroi o caminho: /imagens/evento_nome/programacao_nome/
        SET v_caminho_pasta = CONCAT(
            '/imagens/', 
            REPLACE(LOWER(v_evento_nome), ' ', '_'), 
            '/', 
            REPLACE(LOWER(v_prog_nome), ' ', '_')
        );

        INSERT INTO `mydb`.`imagemProgramacao` (
            `imagemProgramacao_caminho`, 
            `imagemProgramacao_descricao`, 
            `programacao_programacao_id`
        )
        SELECT 
            CONCAT(v_caminho_pasta, '/img', t.n, '.jpg'),
            CONCAT('Registro fotografico ', t.n, ' da atividade'),
            v_prog_id
        FROM tmp_num_prog t
        -- Aleatorio entre 1 e 5
        WHERE t.n <= (1 + FLOOR(RAND() * 5)); 

        COMMIT;
    END LOOP read_loop;
    
    CLOSE cur_prog;

    DROP TEMPORARY TABLE IF EXISTS tmp_num_prog;

    -- Restaura seguranca
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET SESSION autocommit = 1;
END$$

DELIMITER ;

CALL PopularImagemProgramacaoOtimizada();

-- certificado

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularCertificadosOtimizada$$

CREATE PROCEDURE PopularCertificadosOtimizada()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_evento_data_fim DATE;

    -- Cursor para processar um evento por vez (protege a memoria RAM)
    DECLARE cur_eventos CURSOR FOR 
        SELECT eventos_id, eventos_dataFim 
        FROM `mydb`.`eventos`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Otimizacao de performance para Bulk Insert
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET SESSION autocommit = 0;

    OPEN cur_eventos;

    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id, v_evento_data_fim;
        IF v_done THEN LEAVE read_loop; END IF;

        -- BULK INSERT: Calcula e insere todos os certificados deste evento de uma so vez
        INSERT INTO `mydb`.`certificados` (
            `certificados_codigoDeValidacao`,
            `certificados_cargaHorariaTotal`,
            `certificados_dataDeEmissao`,
            `certificados_urlArquivo`,
            `inscricao_inscricao_id`
        )
        SELECT 
            -- Gera um codigo de validacao unico de 16 caracteres (Ex: 8A4F1B3E9D2C7F5A)
            UPPER(SUBSTRING(MD5(CONCAT(i.inscricao_id, UUID(), RAND())), 1, 16)),
            
            -- Calcula a diferenca em minutos de cada palestra e divide por 60 para ter as horas
            SUM(TIMESTAMPDIFF(MINUTE, p.programacao_horaInicio, p.programacao_horaFim)) / 60.0 AS total_horas,
            
            -- Usa a data final do evento como data de emissao
            CAST(CONCAT(v_evento_data_fim, ' 18:00:00') AS DATETIME),
            
            -- Monta a URL padronizada para o PDF do certificado
            CONCAT('/certificados/evento_', v_evento_id, '/cert_', i.inscricao_id, '.pdf'),
            
            i.inscricao_id
        FROM `mydb`.`inscricao` i
        INNER JOIN `mydb`.`inscritosProgramacao` ip ON i.inscricao_id = ip.inscritos_inscritos_id
        INNER JOIN `mydb`.`programacao` p ON ip.programacao_programacao_id = p.programacao_id
        WHERE i.eventos_eventos_id = v_evento_id
          AND ip.inscritosProgramacao_FrequenciaConfirmada = 1 -- Apenas quem tem check-in
        GROUP BY i.inscricao_id
        HAVING total_horas > 0; -- Garante que so emite se tiver pelo menos 1 hora de participacao

        -- Commit fracionado a cada evento
        COMMIT;
    END LOOP read_loop;

    CLOSE cur_eventos;

    -- Restaura as configuracoes de seguranca
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET SESSION autocommit = 1;
END$$

DELIMITER ;

CALL PopularCertificadosOtimizada();

-- redefine predefinições

SET SESSION unique_checks = 1;

SET SESSION foreign_key_checks = 1;

SET SESSION sql_log_bin = 1; 

-- Captura o tempo exato de fim

SET @tempo_fim = SYSDATE(6);

ALTER TABLE `mydb`.`permissoes` DROP INDEX idx_perm_nome;

ALTER TABLE `mydb`.`permissoesUsuarios` DROP INDEX idx_pu_perm_usuario;

ALTER TABLE `mydb`.`tipoInscricao` DROP INDEX idx_tipoInsc_evento;

-- Exibe o relatorio final de performance na sua tela

SELECT +
    @tempo_inicio AS 'Inicio da Execucao',
    @tempo_fim AS 'Fim da Execucao',
    -- Calcula os segundos exatos com decimais (ex: 1.453 segundos)
    ROUND(TIMESTAMPDIFF(MICROSECOND, @tempo_inicio, @tempo_fim) / 1000000.0, 3) AS 'Duracao (Segundos)',
    -- Formata bonitinho para leitura humana (ex: 0 min e 45 seg)
    CONCAT(
        FLOOR(TIMESTAMPDIFF(SECOND, @tempo_inicio, @tempo_fim) / 60), ' min e ',
        MOD(TIMESTAMPDIFF(SECOND, @tempo_inicio, @tempo_fim), 60), ' seg'
    ) AS 'Tempo toal:';
    