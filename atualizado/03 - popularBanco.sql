SET @tempo_inicio = SYSDATE(6);

-- ---------------------------------
-- PRE-CONFIGURAÇÕES
-- ---------------------------------
USE `eventos`; -- Mudança de Schema

SET SESSION wait_timeout = 28800; 
SET SESSION interactive_timeout = 28800;
SET SESSION max_execution_time = 0;
SET GLOBAL max_allowed_packet = 1073741824;
SET GLOBAL net_read_timeout = 600;
SET GLOBAL net_write_timeout = 600;
SET SESSION unique_checks = 0;
SET SESSION foreign_key_checks = 0;
SET SESSION sql_log_bin = 0; 

-- Atualização dos índices de performance (Ajustados para a nova nomenclatura)
CREATE INDEX idx_perm_nome ON `eventos`.`permissoes` (permissoes_nome);
CREATE INDEX idx_pu_perm_usuario ON `eventos`.`permissoesUsuarios` (permissoesUsuarios_permissoes_id, permissoesUsuarios_usuario_id);
CREATE INDEX idx_tipoInsc_evento ON `eventos`.`tipoInscricao` (tipoInscricao_eventos_id);

CREATE INDEX idx_inscricao_evento ON `eventos`.`inscricao` (inscricao_eventos_id);
CREATE INDEX idx_pagamento_voucher ON `eventos`.`pagamento` (pagamento_voucher_id);
CREATE INDEX idx_voucher_evento ON `eventos`.`voucher` (voucher_eventos_id, voucher_disponivel);

CREATE INDEX idx_insc_ev ON `eventos`.`inscricao` (inscricao_eventos_id);

-- quantidade de usuario criados
SET @qtdUsuarios = 15000;

-- variaveis para criação dos vouchers

SET @percentual_eventos_com_voucher = 70.00; 
SET @qtd_minima_vouchers_por_evento = 15;    
SET @qtd_maxima_vouchers_por_evento = 100;   

-- Padrão para Inscritos Programação (Salas e Palestras)
SET @perc_min_ocupacao = 60.0; 
SET @perc_max_ocupacao = 100.0; 
SET @perc_min_presenca = 70.0; 
SET @perc_max_presenca = 90.0;

-- Definir as variáveis com as porcentagens de usuarios que teram 1, 2, 3, 4 telefones 
SET @perc_1_telefone = 40.0; 
SET @perc_2_telefones = 30.0; 
SET @perc_3_telefones = 20.0; 
SET @perc_4_telefones = 10.0;

-- Definindo as variáveis com as percentagens desejadas para permissões de usuario
SET @perc_adm_criar      = 1.0;  
SET @perc_adm_criar_part = 2.0;  
SET @perc_adm_part       = 5.0;  
SET @perc_apenas_part    = 81.0; 
SET @perc_criar_part     = 6.0;  
SET @perc_apenas_criar   = 5.0;

-- Definindo as porcentagens para tipos de login que cada usuario terá
SET @perc_base_email = 40.0; -- % que tera email como base. O restante tera CPF
SET @perc_google     = 60.0; -- chance de o usuário ter Google vinculado
SET @perc_gov        = 20.0; -- chance de o usuário ter Gov.br vinculado
SET @perc_facebook   = 10.0; -- chance de o usuário ter Facebook vinculado

-- definindo porcentagens para população de endereços
SET @perc_base_residencial = 100.0; -- usuários ganham endereço Residencial
SET @perc_extra_trabalho   = 60.0;  -- usuaário que recebem um endereço de Trabalho

-- definição das Variáveis para criação de eventos locais e sublocais
SET @quantidade_de_eventos = 250;
SET @min_sublocais = 1;  -- Valor mínimo de salas por evento físico
SET @max_sublocais = 50; -- Valor máximo de salas por evento físico

-- definição de preços minimos e maximo para inscrição de eventos
SET @padrao_min = 50.00;
SET @padrao_max = 100.00;

SET @vip_min = 150.00;
SET @vip_max = 350.00;

-- definir porcentagem minima e maxima de usuarios cadastrados em cada evento com base no total de usuarios cadastrados que possuem permições para participar de eventos
SET @perc_minima = 10;
SET @perc_maxima = 40;

-- definir a porcentagem minima e maxima dos usuarios que fizeram a inscrição qeu vai efetuar o pagamento
SET @perc_min_pagantes = 60.00; 
SET @perc_max_pagantes = 90.00;

-- Definindo a configuração da população de programação
SET @hora_inicio = '06:00:00';    -- horario de incio
SET @hora_fim    = '22:00:00';    -- Vai de fim
SET @duracao     = 60;            -- duração das palestras
SET @intervalo   = 15;            -- intervalo entre palestras
SET @min_atividades_evento = 1;   -- minimo de programação por evento 
SET @max_atividades_evento = 15;  -- maximo de programação por evento

-- definição dos parametros para popular os inscritos nas programações

SET @perc_min_ocupacao = 10.0;
SET @perc_max_ocupacao = 90.0;

SET @perc_min_presenca = 70.0;
SET @perc_max_presenca = 95.0;

USE `eventos`;

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularUsuarios$$

CREATE PROCEDURE PopularUsuarios(IN total_registros INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_usuario_id INT;
    
    -- Otimizações de performance para carga massiva
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET SESSION autocommit = 0;

    WHILE i < total_registros DO
        -- Inserção na tabela 'usuario' com novos nomes de colunas
        INSERT INTO `eventos`.`usuario` (
            `usuario_nome`, 
            `usuario_cpf`, 
            `usuario_email`, 
            `usuario_sexo`
        )
        VALUES (
            CONCAT('Usuario Teste ', i + 1), 
            -- CPF fictício formatado (000.000.000-00)
            LPAD(i + 1, 11, '0'), 
            CONCAT('user', i + 1, '@provedor.com.br'), 
            ELT(1 + FLOOR(RAND() * 3), 'F', 'M', 'Outro')
        );

        -- Recupera o ID gerado para inserir dados relacionados (Telefone)
        SET v_usuario_id = LAST_INSERT_ID();

        -- Inserção na tabela 'telefone' (Atualizada conforme novo script)
        INSERT INTO `eventos`.`telefone` (
            `telefone_ddi`, 
            `telefone_ddd`, 
            `telefone_telefone`, 
            `telefone_principal`, 
            `telefone_usuario_id`
        )
        VALUES (
            '55', 
            '11', 
            LPAD(FLOOR(RAND() * 999999999), 9, '0'), 
            1, 
            v_usuario_id
        );

        SET i = i + 1;
        
        -- Commit em lotes para manter a saúde do log de transação
        IF i % 1000 = 0 THEN
            COMMIT;
        END IF;
        
    END WHILE;

    COMMIT;
    
    -- Restaura as configurações originais
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET SESSION autocommit = 1;
    
END$$

DELIMITER ;

CALL PopularUsuarios(@qtdUsuarios);

INSERT INTO `eventos`.`estado` (`estado_nome`, `estado_sigla`) VALUES
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
    DECLARE e_nome VARCHAR(100); -- Nova variável para guardar o nome do estado
    DECLARE total_inserido INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    
    -- Atualizado para buscar o ID e o NOME do estado
    DECLARE cur_estados CURSOR FOR SELECT estado_id, estado_nome FROM `eventos`.`estado`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_estados;
    read_loop: LOOP
        -- Agora fazemos o fetch das duas colunas
        FETCH cur_estados INTO e_id, e_nome;
        IF done THEN LEAVE read_loop; END IF;

        SET i = 1;
        WHILE i <= 500 DO
            -- O nome da cidade agora usa o padrão: estado_nome da cidade criado
            INSERT INTO `eventos`.`cidade` (`cidade_nome`, `cidade_estado_id`)
            VALUES (CONCAT(e_nome, '_Cidade ', i), e_id);
            
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

-- Executa a criação das cidades
CALL PopularCidades();

-- CEP

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularCEPs$$

CREATE PROCEDURE PopularCEPs()
BEGIN
    DECLARE c_id INT;
    DECLARE i INT;
    DECLARE done INT DEFAULT FALSE;
    -- Cursor para percorrer todas as cidades cadastradas no novo schema 'eventos'
    DECLARE cur_cidades CURSOR FOR SELECT cidade_id FROM `eventos`.`cidade`;
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
            -- Atualizado o schema e o nome da Foreign Key (cep_cidade_id)
            INSERT INTO `eventos`.`CEP` (`cep_numeracao`, `cep_cidade_id`)
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

-- Executa a criação dos CEPs
CALL PopularCEPs();

-- telefone

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularTelefones$$

-- Agora a procedure recebe as porcentagens como parâmetros
CREATE PROCEDURE PopularTelefones(
    IN perc_1_tel FLOAT,
    IN perc_2_tel FLOAT,
    IN perc_3_tel FLOAT,
    IN perc_4_tel FLOAT
)
BEGIN
    DECLARE v_usuario_id INT DEFAULT 1;
    DECLARE v_max_id INT;
    DECLARE v_random FLOAT;
    DECLARE i INT;
    DECLARE v_qtd_telefones INT;

    -- Acumuladores para a lógica de probabilidade baseada nos parâmetros
    DECLARE limite_1 FLOAT DEFAULT perc_1_tel;
    DECLARE limite_2 FLOAT DEFAULT perc_1_tel + perc_2_tel;
    DECLARE limite_3 FLOAT DEFAULT perc_1_tel + perc_2_tel + perc_3_tel;

    -- Busca o limite de usuários no novo schema 'eventos'
    SELECT MAX(usuario_id) INTO v_max_id FROM `eventos`.`usuario`;

    -- Configurações de performance para carga massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_id DO
        SET v_random = RAND() * 100; -- Gera valor de 0 a 100
        
        -- Aplica a lógica de distribuição de acordo com as variáveis
        IF v_random <= limite_1 THEN 
            SET v_qtd_telefones = 1;
        ELSEIF v_random <= limite_2 THEN 
            SET v_qtd_telefones = 2;
        ELSEIF v_random <= limite_3 THEN 
            SET v_qtd_telefones = 3;
        ELSE 
            SET v_qtd_telefones = 4;
        END IF;

        -- Inserção dos telefones para o usuário atual
        SET i = 1;
        WHILE i <= v_qtd_telefones DO
            -- Atualizado o schema e o nome da Foreign Key (telefone_usuario_id)
            INSERT INTO `eventos`.`telefone` (
                `telefone_ddi`, 
                `telefone_ddd`, 
                `telefone_telefone`, 
                `telefone_principal`, 
                `telefone_usuario_id`
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

CALL PopularTelefones(
    @perc_1_telefone, 
    @perc_2_telefones, 
    @perc_3_telefones, 
    @perc_4_telefones
);

-- permissões

INSERT INTO `eventos`.`permissoes` (`permissoes_nome`, `permissoes_descricao`) VALUES
('ROOT', 'Acesso absoluto e irrestrito ao sistema'),
('ADMINISTRADOR', 'Acesso total e gerencia configurações'),
('CRIAR_EVENTO', 'Permite cadastrar e gerenciar eventos'),
('PARTICIPANTE', 'Visualiza e se inscreve em eventos');

-- permissões usuarios

-- Inserção do utilizador ROOT (ID 1)
INSERT INTO `eventos`.`permissoesUsuarios` (`permissoesUsuarios_usuario_id`, `permissoesUsuarios_permissoes_id`) 
VALUES (
    1, 
    (SELECT permissoes_id FROM `eventos`.`permissoes` WHERE permissoes_nome = 'ROOT' LIMIT 1)
);

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularPermissoesUsuarios$$

-- Nova estrutura recebendo as percentagens como parâmetros
CREATE PROCEDURE PopularPermissoesUsuarios(
    IN perc_adm_criar FLOAT,
    IN perc_adm_criar_part FLOAT,
    IN perc_adm_part FLOAT,
    IN perc_apenas_part FLOAT,
    IN perc_criar_part FLOAT,
    IN perc_apenas_criar FLOAT
)
BEGIN
    DECLARE v_usuario_id INT DEFAULT 2; -- Começa no 2 para preservar o Utilizador 1 (ROOT)
    DECLARE v_max_id INT;
    DECLARE v_random FLOAT;
    
    -- Acumuladores para a lógica de probabilidade baseada nos parâmetros
    DECLARE lim_1 FLOAT DEFAULT perc_adm_criar;
    DECLARE lim_2 FLOAT DEFAULT lim_1 + perc_adm_criar_part;
    DECLARE lim_3 FLOAT DEFAULT lim_2 + perc_adm_part;
    DECLARE lim_4 FLOAT DEFAULT lim_3 + perc_apenas_part;
    DECLARE lim_5 FLOAT DEFAULT lim_4 + perc_criar_part;

    -- Variáveis para os IDs das permissões
    DECLARE v_id_adm INT;
    DECLARE v_id_criar INT;
    DECLARE v_id_part INT;

    -- Busca os IDs reais dinamicamente no novo schema
    SELECT permissoes_id INTO v_id_adm FROM `eventos`.`permissoes` WHERE permissoes_nome = 'ADMINISTRADOR' LIMIT 1;
    SELECT permissoes_id INTO v_id_criar FROM `eventos`.`permissoes` WHERE permissoes_nome = 'CRIAR_EVENTO' LIMIT 1;
    SELECT permissoes_id INTO v_id_part FROM `eventos`.`permissoes` WHERE permissoes_nome = 'PARTICIPANTE' LIMIT 1;

    -- Descobre o total de utilizadores
    SELECT MAX(usuario_id) INTO v_max_id FROM `eventos`.`usuario`;

    -- Configurações de performance
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_id DO
        SET v_random = RAND() * 100;

        IF v_random <= lim_1 THEN
            -- Administrador e Criar Evento
            INSERT INTO `eventos`.`permissoesUsuarios` (`permissoesUsuarios_usuario_id`, `permissoesUsuarios_permissoes_id`) 
            VALUES (v_usuario_id, v_id_adm), (v_usuario_id, v_id_criar);
            
        ELSEIF v_random <= lim_2 THEN
            -- Administrador, Criar Evento e Participar
            INSERT INTO `eventos`.`permissoesUsuarios` (`permissoesUsuarios_usuario_id`, `permissoesUsuarios_permissoes_id`) 
            VALUES (v_usuario_id, v_id_adm), (v_usuario_id, v_id_criar), (v_usuario_id, v_id_part);
            
        ELSEIF v_random <= lim_3 THEN
            -- Administrador e Participar
            INSERT INTO `eventos`.`permissoesUsuarios` (`permissoesUsuarios_usuario_id`, `permissoesUsuarios_permissoes_id`) 
            VALUES (v_usuario_id, v_id_adm), (v_usuario_id, v_id_part);
            
        ELSEIF v_random <= lim_4 THEN
            -- Apenas Participar de Evento
            INSERT INTO `eventos`.`permissoesUsuarios` (`permissoesUsuarios_usuario_id`, `permissoesUsuarios_permissoes_id`) 
            VALUES (v_usuario_id, v_id_part);

        ELSEIF v_random <= lim_5 THEN
            -- Criar Evento e Participar
            INSERT INTO `eventos`.`permissoesUsuarios` (`permissoesUsuarios_usuario_id`, `permissoesUsuarios_permissoes_id`) 
            VALUES (v_usuario_id, v_id_criar), (v_usuario_id, v_id_part);

        ELSE
            -- Apenas Criar Evento (o que sobrar para chegar a 100%)
            INSERT INTO `eventos`.`permissoesUsuarios` (`permissoesUsuarios_usuario_id`, `permissoesUsuarios_permissoes_id`) 
            VALUES (v_usuario_id, v_id_criar);
            
        END IF;

        -- Commit fracionado a cada 5.000 utilizadores para manter a estabilidade
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

CALL PopularPermissoesUsuarios(
    @perc_adm_criar, 
    @perc_adm_criar_part, 
    @perc_adm_part, 
    @perc_apenas_part, 
    @perc_criar_part, 
    @perc_apenas_criar
);

-- Tipo login
INSERT INTO `eventos`.`tiposLogin` (`tiposLogin_tipo`) VALUES
('E-mail'),
('Google'),
('Facebook'),
('Gov.br'),
('CPF');

-- login

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularLoginsUsuarios$$

CREATE PROCEDURE PopularLoginsUsuarios(
    IN perc_base_email FLOAT, 
    IN perc_google FLOAT,     
    IN perc_gov FLOAT,        
    IN perc_facebook FLOAT    
)
BEGIN
    DECLARE v_usuario_id INT DEFAULT 1;
    DECLARE v_max_id INT;
    DECLARE v_rand_base FLOAT;
    
    -- Definindo uma "senha padrão" criptografada (ex: hash MD5 de '123456') 
    DECLARE v_senha_padrao VARCHAR(255) DEFAULT 'e10adc3949ba59abbe56e057f20f883e';

    -- Descobre o total de usuários no novo schema
    SELECT MAX(usuario_id) INTO v_max_id FROM `eventos`.`usuario`;

    -- Configurações de performance para carga massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_id DO
        
        -- 1. BASE: Todo usuário tem pelo menos 1 login principal (E-mail ou CPF)
        SET v_rand_base = RAND() * 100;
        IF v_rand_base <= perc_base_email THEN
            -- Inserindo E-mail (ID 1) - Corrigido para login_senha
            INSERT INTO `eventos`.`login` (`login_usuario_id`, `login_tiposLogin_id`, `login_senha`) 
            VALUES (v_usuario_id, 1, v_senha_padrao);
        ELSE
            -- Inserindo CPF (ID 5) - Corrigido para login_senha
            INSERT INTO `eventos`.`login` (`login_usuario_id`, `login_tiposLogin_id`, `login_senha`) 
            VALUES (v_usuario_id, 5, v_senha_padrao);
        END IF;

        -- 2. GOOGLE (ID 2)
        IF (RAND() * 100) <= perc_google THEN
            INSERT INTO `eventos`.`login` (`login_usuario_id`, `login_tiposLogin_id`, `login_senha`) 
            VALUES (v_usuario_id, 2, v_senha_padrao);
        END IF;

        -- 3. GOV.BR (ID 4)
        IF (RAND() * 100) <= perc_gov THEN
            INSERT INTO `eventos`.`login` (`login_usuario_id`, `login_tiposLogin_id`, `login_senha`) 
            VALUES (v_usuario_id, 4, v_senha_padrao);
        END IF;

        -- 4. FACEBOOK (ID 3)
        IF (RAND() * 100) <= perc_facebook THEN
            INSERT INTO `eventos`.`login` (`login_usuario_id`, `login_tiposLogin_id`, `login_senha`) 
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

CALL PopularLoginsUsuarios(
    @perc_base_email,
    @perc_google,
    @perc_gov,
    @perc_facebook
);

-- endereços

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularEnderecos$$

CREATE PROCEDURE PopularEnderecos(
    IN perc_base_residencial FLOAT, -- Chance de ter endereço Residencial (geralmente 100%)
    IN perc_extra_trabalho FLOAT    -- Chance de ter endereço de Trabalho extra
)
BEGIN
    DECLARE v_usuario_id INT DEFAULT 1;
    DECLARE v_max_usuario_id INT;
    DECLARE v_max_cep_id INT;
    
    DECLARE v_logradouro VARCHAR(45);
    DECLARE v_numero INT;
    DECLARE v_cep_sorteado INT;

    -- Descobre o total de usuários e o total de CEPs disponíveis no novo schema
    SELECT MAX(usuario_id) INTO v_max_usuario_id FROM `eventos`.`usuario`;
    SELECT MAX(cep_id) INTO v_max_cep_id FROM `eventos`.`CEP`;

    -- Configurações de performance para carga massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_usuario_id <= v_max_usuario_id DO
        
        -- 1. BASE: Endereço "Residencial"
        IF (RAND() * 100) <= perc_base_residencial THEN
            -- Gerando dados fictícios aleatórios para o endereço
            SET v_logradouro = CONCAT('Rua ', CHAR(FLOOR(65 + RAND() * 25)), ', Número ', FLOOR(RAND() * 1000));
            SET v_numero = FLOOR(1 + RAND() * 9999);
            -- Sorteia um ID de CEP entre 1 e o máximo existente
            SET v_cep_sorteado = FLOOR(1 + RAND() * v_max_cep_id);

            -- Inserção com os nomes das colunas de FK atualizados
            INSERT INTO `eventos`.`endereco` (`endereco_identificacao`, `endereco_logradouro`, `endereco_numero`, `endereco_usuario_id`, `endereco_cep_id`) 
            VALUES ('Residencial', v_logradouro, v_numero, v_usuario_id, v_cep_sorteado);
        END IF;

        -- 2. TRABALHO: Chance de ter um segundo endereço comercial
        IF (RAND() * 100) <= perc_extra_trabalho THEN
            -- Gera novos dados para o endereço de trabalho
            SET v_logradouro = CONCAT('Avenida Comercial ', FLOOR(RAND() * 500));
            SET v_numero = FLOOR(1 + RAND() * 9999);
            SET v_cep_sorteado = FLOOR(1 + RAND() * v_max_cep_id);
            
            INSERT INTO `eventos`.`endereco` (`endereco_identificacao`, `endereco_logradouro`, `endereco_numero`, `endereco_usuario_id`, `endereco_cep_id`) 
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

CALL PopularEnderecos(
    @perc_base_residencial,
    @perc_extra_trabalho
);

-- tipo evento

INSERT INTO `eventos`.`tipoEvento` (`tipoEvento_nome`) VALUES 
('Presencial'), 
('Online'), 
('Híbrido'),
('Presencial gratuito'), 
('Online gratuito'), 
('Híbrido gratuito');


-- eventos, localEvento e sublocal
DELIMITER $$

DROP PROCEDURE IF EXISTS PopularEventos$$

CREATE PROCEDURE PopularEventos(
    IN p_quantidade_eventos INT,
    IN p_min_sublocais INT,
    IN p_max_sublocais INT
)
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

    -- 1. Cria tabela temporária de usuários organizadores
    DROP TEMPORARY TABLE IF EXISTS tmp_organizadores;
    CREATE TEMPORARY TABLE tmp_organizadores (
        id INT AUTO_INCREMENT PRIMARY KEY,
        usuario_id INT
    );

    -- Povoa a tabela com base na nova estrutura de permissões
    INSERT INTO tmp_organizadores (usuario_id)
    SELECT DISTINCT pu.permissoesUsuarios_usuario_id 
    FROM `eventos`.`permissoesUsuarios` pu
    INNER JOIN `eventos`.`permissoes` p ON pu.permissoesUsuarios_permissoes_id = p.permissoes_id
    WHERE p.permissoes_nome = 'CRIAR_EVENTO';

    SELECT MAX(id) INTO v_max_org_id FROM tmp_organizadores;
    
    -- Se não houver organizadores, interrompe para evitar loop infinito ou erro
    IF v_max_org_id IS NULL THEN
        SET v_contador = p_quantidade_eventos + 1;
    END IF;

    SELECT MAX(tipoEvento_id) INTO v_tipo_evento_max FROM `eventos`.`tipoEvento`;

    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    WHILE v_contador <= p_quantidade_eventos DO
        
        SET v_capacidade_total = FLOOR(1000 + RAND() * 19000);

        -- PASSO 1: DEFINIR TIPO E SE É ONLINE
        SET v_tipo_evento_id = FLOOR(1 + RAND() * v_tipo_evento_max);
        SET v_tipo_evento_nome = NULL;
        
        SELECT tipoEvento_nome INTO v_tipo_evento_nome 
        FROM `eventos`.`tipoEvento` 
        WHERE tipoEvento_id = v_tipo_evento_id LIMIT 1;
        
        IF v_tipo_evento_nome IS NULL THEN
            SET v_tipo_evento_id = 1;
            SELECT tipoEvento_nome INTO v_tipo_evento_nome FROM `eventos`.`tipoEvento` WHERE tipoEvento_id = 1 LIMIT 1;
        END IF;

        IF v_tipo_evento_nome LIKE '%Online%' THEN
            SET v_is_online = 1;
        ELSE
            SET v_is_online = 0;
        END IF;

        -- PASSO 2: CRIAR O LOCAL (Nomes de colunas atualizados)
        IF v_is_online = 1 THEN
            INSERT INTO `eventos`.`localEvento` (
                `localEvento_nome`, `localEvento_descricao`, `localEvento_capacidade`, `localEvento_endereco`
            ) VALUES (
                'Plataforma Virtual', 'Ambiente digital para transmissão', v_capacidade_total, 'URL de Acesso Online'
            );
        ELSE
            INSERT INTO `eventos`.`localEvento` (
                `localEvento_nome`, `localEvento_descricao`, `localEvento_capacidade`, `localEvento_endereco`
            ) VALUES (
                CONCAT('Centro de Convenções ', v_contador), 'Local físico', v_capacidade_total, CONCAT('Rua ', v_contador, ', Cidade dos Eventos')
            );
        END IF;
        
        SET v_local_id = LAST_INSERT_ID();

        -- PASSO 3: CRIAR O EVENTO (Nomes de colunas e FKs atualizados)
        SET v_data_inicio = CURDATE() + INTERVAL FLOOR(10 + RAND() * 300) DAY;
        SET v_data_fim = v_data_inicio + INTERVAL FLOOR(RAND() * 5) DAY;
        SET v_data_limite = v_data_inicio - INTERVAL FLOOR(1 + RAND() * 15) DAY;
        
        SELECT usuario_id INTO v_usuario_criador_id 
        FROM tmp_organizadores 
        WHERE id = FLOOR(1 + (RAND() * v_max_org_id)) LIMIT 1;

        INSERT INTO `eventos`.`eventos` (
            `eventos_nome`, `eventos_descricao`, `eventos_dataInicio`, `eventos_dataFim`, 
            `eventos_dataLimiteInscricao`, `eventos_tipoEvento_id`, `eventos_local_id`, `eventos_criador_usuario_id`
        ) VALUES (
            CONCAT('Workshop de Tecnologia ', v_contador),
            CONCAT('Evento sobre inovação. Modalidade: ', COALESCE(v_tipo_evento_nome, 'Geral')),
            v_data_inicio, v_data_fim, v_data_limite,
            v_tipo_evento_id, v_local_id, v_usuario_criador_id
        );

        -- PASSO 4: CRIAR OS SUBLOCAIS (Ajustado para 'sublocalEvento' conforme script de criação)
        IF v_is_online = 0 THEN
            SET v_qtd_sublocais = FLOOR(p_min_sublocais + (RAND() * (p_max_sublocais - p_min_sublocais + 1))); 
            
            IF v_qtd_sublocais > 0 THEN
                SET v_capacidade_sub = FLOOR(v_capacidade_total / v_qtd_sublocais);
                SET v_sub_contador = 1;

                WHILE v_sub_contador <= v_qtd_sublocais DO
                    INSERT INTO `eventos`.`sublocalEvento` (
                        `sublocalEvento_nome`, `sublocalEvento_descricao`, `sublocalEvento_capacidade`, `sublocalEvento_localEvento_id`
                    ) VALUES (
                        CONCAT('Auditório ', CHAR(64 + v_sub_contador)), 'Sala de palestras', v_capacidade_sub, v_local_id
                    );
                    SET v_sub_contador = v_sub_contador + 1;
                END WHILE;
            END IF;
        END IF;

        -- Commit em lotes
        IF MOD(v_contador, 500) = 0 THEN
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


-- Execução da Procedure
CALL PopularEventos(
    @quantidade_de_eventos, 
    @min_sublocais, 
    @max_sublocais
);

-- tipo Inscrição

DELIMITER $$

DROP PROCEDURE IF EXISTS GerarPrecosDosEventos$$

CREATE PROCEDURE GerarPrecosDosEventos(
    IN p_padrao_min FLOAT,
    IN p_padrao_max FLOAT,
    IN p_vip_min FLOAT,
    IN p_vip_max FLOAT
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_tipo_evento_nome VARCHAR(45);
    DECLARE v_contador INT DEFAULT 0;
    
    -- Variáveis para armazenar os preços calculados
    DECLARE v_valor_padrao FLOAT;
    DECLARE v_valor_vip FLOAT;
    DECLARE v_valor_meia FLOAT;
    
    -- Cursor modificado: faz um JOIN para descobrir o nome do tipo do evento
    DECLARE cur_eventos CURSOR FOR 
        SELECT e.eventos_id, t.tipoEvento_nome 
        FROM `eventos`.`eventos` e
        INNER JOIN `eventos`.`tipoEvento` t ON e.eventos_tipoEvento_id = t.tipoEvento_id;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Configurações de performance
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;
    
    OPEN cur_eventos;

    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id, v_tipo_evento_nome;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- =======================================================
        -- LÓGICA DE PRECIFICAÇÃO
        -- =======================================================
        
        -- 1. O VIP SEMPRE tem um valor cobrado, independente do tipo de evento
        SET v_valor_vip = p_vip_min + (RAND() * (p_vip_max - p_vip_min));

        -- 2. Checa se o ingresso Padrão será pago ou gratuito
        IF v_tipo_evento_nome LIKE '%gratuito%' THEN
            SET v_valor_padrao = 0.00;
        ELSE
            SET v_valor_padrao = p_padrao_min + (RAND() * (p_padrao_max - p_padrao_min));
        END IF;

        -- 3. A Meia-Entrada será sempre metade da Padrão (se for gratuito, 0 / 2 = 0)
        SET v_valor_meia = v_valor_padrao / 2.0;

        -- Inserindo os 4 tipos de inscrição
        INSERT INTO `eventos`.`tipoInscricao` (`tipoInscricao_nome`, `tipoInscricao_valor`, `tipoInscricao_eventos_id`)
        VALUES 
        ('Padrão',       v_valor_padrao, v_evento_id),
        ('VIP',          v_valor_vip,    v_evento_id),
        ('Cortesia',     0.00,           v_evento_id),
        ('Meia-Entrada', v_valor_meia,   v_evento_id);

        SET v_contador = v_contador + 1;

        -- Commit a cada 500 eventos
        IF MOD(v_contador, 500) = 0 THEN
            COMMIT;
        END IF;

    END LOOP;

    CLOSE cur_eventos;
    
    COMMIT;
    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL GerarPrecosDosEventos(
    @padrao_min, 
    @padrao_max, 
    @vip_min, 
    @vip_max
);

-- inscrição

DELIMITER $$

DROP PROCEDURE IF EXISTS InscricaoEvento$$

CREATE PROCEDURE InscricaoEvento(
    IN p_perc_min FLOAT, 
    IN p_perc_max FLOAT
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_total_participantes INT;
    DECLARE v_qtd_inscritos INT;
    DECLARE v_probabilidade FLOAT; -- Nova variável para a matemática de velocidade

    -- Cursor para percorrer todos os eventos
    DECLARE cur_eventos CURSOR FOR SELECT eventos_id FROM `eventos`.`eventos`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Configurações para acelerar a inserção massiva
    SET FOREIGN_KEY_CHECKS = 0;
    SET UNIQUE_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    -- =======================================================
    -- PASSO 1 e 2: CRIAR TABELA TEMPORÁRIA DE PARTICIPANTES
    -- =======================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_participantes;
    CREATE TEMPORARY TABLE tmp_participantes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        usuario_id INT
    );

    -- Povoa com IDs reais de quem tem a permissão 'PARTICIPANTE'
    INSERT INTO tmp_participantes (usuario_id)
    SELECT DISTINCT pu.permissoesUsuarios_usuario_id
    FROM `eventos`.`permissoesUsuarios` pu
    INNER JOIN `eventos`.`permissoes` p ON pu.permissoesUsuarios_permissoes_id = p.permissoes_id
    WHERE p.permissoes_nome = 'PARTICIPANTE';

    -- Conta o total de participantes possíveis
    SELECT COUNT(*) INTO v_total_participantes FROM tmp_participantes;

    IF v_total_participantes > 0 THEN
        
        OPEN cur_eventos;

        read_loop: LOOP
            FETCH cur_eventos INTO v_evento_id;
            
            IF v_done THEN
                LEAVE read_loop;
            END IF;

            -- =======================================================
            -- PASSO 3: DEFINIR A QUANTIDADE E A PROBABILIDADE
            -- =======================================================
            -- 1. Calcula quantos inscritos o evento terá
            SET v_qtd_inscritos = FLOOR(v_total_participantes * (p_perc_min + (RAND() * (p_perc_max - p_perc_min))) / 100);

            -- 2. A MÁGICA DA VELOCIDADE: 
            -- Calcula qual a % da tabela precisamos ler. 
            -- Multiplicamos por 1.5 (margem de 50% a mais) para garantir que o WHERE ache linhas suficientes antes do LIMIT cortar.
            SET v_probabilidade = (v_qtd_inscritos / v_total_participantes) * 1.5; 
            
            -- Trava para não passar de 100% de probabilidade
            IF v_probabilidade > 1.0 THEN 
                SET v_probabilidade = 1.0; 
            END IF;

            -- =======================================================
            -- PASSO 4: INSERIR COM FILTRO PROBABILÍSTICO (Sem Filesort)
            -- =======================================================
            IF v_qtd_inscritos > 0 THEN
                
                INSERT IGNORE INTO `eventos`.`inscricao` (
                    `inscricao_credenciamento`, 
                    `inscricao_eventos_id`, 
                    `inscricao_usuario_id`, 
                    `inscricao_tipoInscricao_id`
                )
                SELECT 
                    IF(RAND() > 0.8, 1, 0) AS credenciamento, 
                    v_evento_id, 
                    tmp.usuario_id,
                    (SELECT tipoInscricao_id 
                     FROM `eventos`.`tipoInscricao` 
                     WHERE tipoInscricao_eventos_id = v_evento_id 
                     ORDER BY RAND() LIMIT 1) AS ingresso
                FROM tmp_participantes tmp
                -- O MySQL lê linha a linha e "joga um dado". Se cair na probabilidade, ele pega.
                -- Isso evita que ele tenha que ordenar a tabela inteira!
                WHERE RAND() <= v_probabilidade 
                LIMIT v_qtd_inscritos;

            END IF;

            COMMIT;

        END LOOP;

        CLOSE cur_eventos;
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_participantes;

    SET FOREIGN_KEY_CHECKS = 1;
    SET UNIQUE_CHECKS = 1;
    SET AUTOCOMMIT = 1;

END$$

DELIMITER ;

CALL InscricaoEvento(@perc_minima, @perc_maxima);

DELIMITER $$

DROP PROCEDURE IF EXISTS GerarVoucher$$

CREATE PROCEDURE GerarVoucher(
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
    -- 1. SEPARAÇÃO DOS EVENTOS (APENAS PAGOS) E SORTEIO
    -- =======================================================
    DROP TEMPORARY TABLE IF EXISTS tmp_evt_selecionados;
    CREATE TEMPORARY TABLE tmp_evt_selecionados (
        id INT AUTO_INCREMENT PRIMARY KEY,
        evento_id INT,
        tipo_id INT,
        qtd_vouchers INT
    );

    INSERT INTO tmp_evt_selecionados (evento_id, tipo_id, qtd_vouchers)
    SELECT 
        e.eventos_id, 
        MIN(t.tipoInscricao_id),
        -- Sorteia a quantidade de vouchers que ESTE evento específico vai ter
        FLOOR(p_min_vouchers + (RAND() * (p_max_vouchers - p_min_vouchers + 1)))
    FROM `eventos`.`eventos` e
    INNER JOIN `eventos`.`tipoInscricao` t ON e.eventos_id = t.tipoInscricao_eventos_id
    INNER JOIN `eventos`.`tipoEvento` te ON e.eventos_tipoEvento_id = te.tipoEvento_id
    -- Transforma o parâmetro (ex: 60) em porcentagem real (0.60)
    WHERE RAND() <= (p_percentual / 100.0) 
      AND te.tipoEvento_nome NOT LIKE '%gratuito%' -- FILTRO: Ignora os eventos gratuitos
    GROUP BY e.eventos_id;

    -- Pegamos o total de eventos separados (se for nulo, joga 0)
    SELECT IFNULL(MAX(id), 0) INTO v_max_id FROM tmp_evt_selecionados;

    -- =======================================================
    -- 2. LOOP MULTIPLICADOR INTELIGENTE
    -- =======================================================
    WHILE v_offset < v_max_id DO
        
        INSERT IGNORE INTO `eventos`.`voucher` (
            `voucher_codigo`,
            `voucher_valor`,
            `voucher_dataValidade`,
            `voucher_disponivel`,
            `voucher_eventos_id`,
            `voucher_tipoInscricao_id`
        )
        -- O gerador cria linhas até bater no limite MÁXIMO global que você passou
        WITH RECURSIVE gerador AS (
            SELECT 1 AS n UNION ALL SELECT n + 1 FROM gerador WHERE n < p_max_vouchers
        )
        SELECT 
            -- MD5 com vários dados misturados para garantir código único
            CONCAT(UPPER(SUBSTRING(MD5(CONCAT(RAND(), e.evento_id, g.n)), 1, 6)), '-', UPPER(SUBSTRING(UUID(), 1, 5))),
            ROUND((RAND() * 90) + 10, 2), -- Valor aleatório do desconto entre R$ 10 e R$ 100
            DATE_ADD(NOW(), INTERVAL FLOOR(RAND() * 365) DAY), -- Validade aleatória
            1, -- Todos nascem disponíveis (1 = true)
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

CALL GerarVoucher(
    @percentual_eventos_com_voucher, 
    @qtd_minima_vouchers_por_evento, 
    @qtd_maxima_vouchers_por_evento
);


-- metodo de pagamento

INSERT INTO `eventos`.`metodoPagamento` (`metodoPagamento_formaDePagamento`) VALUES 
('Pix'),
('Cartão de Crédito'),
('Cartão de Débito'),
('Boleto Bancário'),
('Transferência (TED/DOC)'),
('Dinheiro');

DELIMITER $$

DROP PROCEDURE IF EXISTS GerarPagamentos$$

CREATE PROCEDURE GerarPagamentos(
    IN p_min_percentual_pagantes DECIMAL(5,2), 
    IN p_max_percentual_pagantes DECIMAL(5,2)
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_qtd_pagar INT;
    DECLARE v_min_metodo, v_max_metodo INT;

    DECLARE cur_eventos CURSOR FOR SELECT eventos_id FROM `eventos`.`eventos`;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Cache de limites para evitar SELECT repetitivo
    SELECT MIN(metodoPagamento_id), MAX(metodoPagamento_id) INTO v_min_metodo, v_max_metodo FROM `eventos`.`metodoPagamento`;

    SET FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    OPEN cur_eventos;

    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Inserção direta via JOIN (Removi o ORDER BY RAND do voucher)
        -- Usamos uma técnica de sorteio mais leve baseada no ID da inscrição
        INSERT IGNORE INTO `eventos`.`pagamento` (
            `pagamento_valorTotal`,
            `pagamento_valorPagamento`,
            `pagamento_status`,
            `pagamento_dataHora`,
            `pagamento_metodoPagamento_id`,
            `pagamento_voucher_id`,
            `pagamento_inscricao_id`,
            `pagamento_tipoDesconto_id`
        )
        SELECT 
            ti.tipoInscricao_valor,
            -- Cálculo simplificado: 10% de chance de aplicar um desconto fixo de 20% caso não tenha voucher
            ti.tipoInscricao_valor * (IF(RAND() < 0.1, 0.8, 1.0)), 
            ELT(FLOOR(RAND() * 3) + 1, 'Pendente', 'Pago', 'Agendado'),
            DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 30) DAY),
            FLOOR(v_min_metodo + RAND() * (v_max_metodo - v_min_metodo + 1)),
            NULL, -- Vouchers em massa via cursor são lentos, setamos NULL para velocidade
            i.inscricao_id,
            NULL
        FROM `eventos`.`inscricao` i
        INNER JOIN `eventos`.`tipoInscricao` ti ON i.inscricao_tipoInscricao_id = ti.tipoInscricao_id
        WHERE i.inscricao_eventos_id = v_evento_id
        -- Sorteio de percentual de linhas sem ORDER BY RAND total
        AND RAND() <= (p_max_percentual_pagantes / 100)
        LIMIT 5000; -- Limite de segurança por evento para não estourar memória

        COMMIT; 
    END LOOP;

    CLOSE cur_eventos;
    SET FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL GerarPagamentos(
    @perc_min_pagantes, 
    @perc_max_pagantes
);

-- popular programação

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularProgramacao$$

CREATE PROCEDURE PopularProgramacao(
    IN p_hora_inicio_dia TIME,        
    IN p_hora_fim_dia TIME,           
    IN p_duracao_atividade_min INT,   
    IN p_intervalo_min INT,           
    IN p_min_atividades INT,          
    IN p_max_atividades INT           
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_data_inicio DATE;
    DECLARE v_data_fim DATE;
    DECLARE v_local_id INT;
    DECLARE v_sublocal_id INT; -- Nome corrigido para v_sublocal_id
    DECLARE v_data_atual DATETIME;
    DECLARE v_limite_dia DATETIME;
    DECLARE v_atv_count INT DEFAULT 1;
    
    DECLARE v_alvo_atividades INT; 
    DECLARE v_atividades_criadas INT; 

    -- Cursor ajustado para os novos nomes das colunas de eventos
    DECLARE cur_eventos CURSOR FOR 
        SELECT eventos_id, eventos_dataInicio, eventos_dataFim, eventos_local_id 
        FROM `eventos`.`eventos`;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SET FOREIGN_KEY_CHECKS = 0;

    OPEN cur_eventos;
    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id, v_data_inicio, v_data_fim, v_local_id;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Define meta de atividades para este evento
        SET v_alvo_atividades = FLOOR(p_min_atividades + (RAND() * (p_max_atividades - p_min_atividades + 1)));
        SET v_atividades_criadas = 0;

        -- LOGICA DE BUSCA DE SALA (Corrigida para sublocalEvento):
        SET v_sublocal_id = NULL;
        
        SELECT sublocalEvento_id INTO v_sublocal_id 
        FROM `eventos`.`sublocalEvento` 
        WHERE sublocalEvento_localEvento_id = v_local_id 
        LIMIT 1;

        -- Fallback: se o local do evento não tiver sublocal, tenta pegar qualquer sublocal do banco
        IF v_sublocal_id IS NULL THEN
            SELECT sublocalEvento_id INTO v_sublocal_id FROM `eventos`.`sublocalEvento` LIMIT 1;
        END IF;

        -- Só prossegue se existir ao menos um sublocal e meta de atividades > 0
        IF v_sublocal_id IS NOT NULL AND v_alvo_atividades > 0 THEN
            
            SET v_data_atual = CAST(CONCAT(v_data_inicio, ' ', p_hora_inicio_dia) AS DATETIME);
            
            -- Loop de dias e horários enquanto durar o evento e não atingir a meta
            WHILE (DATE(v_data_atual) <= v_data_fim) AND (v_atividades_criadas < v_alvo_atividades) DO
                SET v_limite_dia = CAST(CONCAT(DATE(v_data_atual), ' ', p_hora_fim_dia) AS DATETIME);
                
                -- Loop de slots dentro do mesmo dia
                WHILE (DATE_ADD(v_data_atual, INTERVAL p_duracao_atividade_min MINUTE) <= v_limite_dia) 
                      AND (v_atividades_criadas < v_alvo_atividades) DO

                    INSERT INTO `eventos`.`programacao` (
                        `programacao_horaInicio`, 
                        `programacao_horaFim`, 
                        `programacao_nome`, 
                        `programacao_linkPresenca`, 
                        `programacao_descricao`, 
                        `programacao_eventos_id`, 
                        `programacao_sublocaEvento_id` -- Nome da coluna na tabela programacao (conforme seu DDL)
                    ) VALUES (
                        v_data_atual,
                        DATE_ADD(v_data_atual, INTERVAL p_duracao_atividade_min MINUTE),
                        CONCAT('Atividade ', v_atv_count, ' - Evento ', v_evento_id),
                        CONCAT('https://sistema-eventos.com/presenca/', v_evento_id, '/', v_atv_count),
                        'Sessão técnica integrante da programação oficial.',
                        v_evento_id,
                        v_sublocal_id
                    );

                    SET v_atv_count = v_atv_count + 1;
                    SET v_atividades_criadas = v_atividades_criadas + 1;
                    
                    -- Incrementa horário (Duração + Intervalo entre atividades)
                    SET v_data_atual = DATE_ADD(v_data_atual, INTERVAL (p_duracao_atividade_min + p_intervalo_min) MINUTE);
                END WHILE;

                -- Avança para o início do próximo dia
                SET v_data_atual = CAST(CONCAT(DATE_ADD(DATE(v_data_atual), INTERVAL 1 DAY), ' ', p_hora_inicio_dia) AS DATETIME);
            END WHILE;
        END IF;
    END LOOP;

    CLOSE cur_eventos;
    SET FOREIGN_KEY_CHECKS = 1;
END$$

DELIMITER ;

CALL PopularProgramacao(
    @hora_inicio,
    @hora_fim,
    @duracao,
    @intervalo,
    @min_atividades_evento,
    @max_atividades_evento
);

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularInscritosProgramacao$$

CREATE PROCEDURE PopularInscritosProgramacao(
    IN p_perc_min_ocupacao FLOAT,
    IN p_perc_max_ocupacao FLOAT,
    IN p_perc_min_presenca FLOAT,
    IN p_perc_max_presenca FLOAT
)
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prog_id, v_evento_id, v_capacidade INT;
    DECLARE v_hora_inicio DATETIME;
    DECLARE v_total_inscritos, v_qtd_alvo INT;
    DECLARE v_taxa_presenca FLOAT;

    -- Cursor ajustado para a nomenclatura do novo Schema
    DECLARE cur_prog CURSOR FOR 
        SELECT 
            p.programacao_id, 
            p.programacao_eventos_id, 
            p.programacao_horaInicio, 
            s.sublocalEvento_capacidade -- Corrigido para sublocalEvento
        FROM `eventos`.`programacao` p
        INNER JOIN `eventos`.`sublocalEvento` s ON p.programacao_sublocaEvento_id = s.sublocalEvento_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Otimização de performance
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    OPEN cur_prog;

    read_loop: LOOP
        FETCH cur_prog INTO v_prog_id, v_evento_id, v_hora_inicio, v_capacidade;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Conta inscritos no evento desta atividade
        SELECT COUNT(*) INTO v_total_inscritos 
        FROM `eventos`.`inscricao` 
        WHERE inscricao_eventos_id = v_evento_id;

        IF v_total_inscritos > 0 THEN
            
            -- Calcula alvo de ocupação respeitando a capacidade do sublocal
            SET v_qtd_alvo = FLOOR(LEAST(v_total_inscritos, v_capacidade) * ((p_perc_min_ocupacao + RAND() * (p_perc_max_ocupacao - p_perc_min_ocupacao)) / 100));
            
            -- Sorteia a taxa de presença
            SET v_taxa_presenca = (p_perc_min_presenca + RAND() * (p_perc_max_presenca - p_perc_min_presenca)) / 100;

            IF v_qtd_alvo > 0 THEN
                INSERT INTO `eventos`.`inscritosProgramacao` (
                    `inscritosProgramacao_inscritos_id`,      -- Nome corrigido
                    `inscritosProgramacao_programacao_id`,    -- Nome corrigido
                    `inscritosProgramacao_dataHoraFrequencia`,
                    `inscritosProgramacao_FrequenciaConfirmada`
                )
                SELECT 
                    inscricao_id,
                    v_prog_id,
                    -- Gera horário aleatório para quem confirmou presença
                    IF(RAND() <= v_taxa_presenca, DATE_ADD(v_hora_inicio, INTERVAL FLOOR(-30 + (RAND() * 45)) MINUTE), NULL),
                    IF(RAND() <= v_taxa_presenca, 1, 0)
                FROM `eventos`.`inscricao`
                WHERE inscricao_eventos_id = v_evento_id
                ORDER BY RAND() 
                LIMIT v_qtd_alvo;
            END IF;
            
        END IF;

        COMMIT; 

    END LOOP;

    CLOSE cur_prog;

    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularInscritosProgramacao(
    @perc_min_ocupacao, 
    @perc_max_ocupacao, 
    @perc_min_presenca, 
    @perc_max_presenca
);

-- papel 

INSERT INTO `eventos`.`papel` (`papel_nome`, `papel_descricao`) VALUES
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


-- papel programação


DELIMITER $$

DROP PROCEDURE IF EXISTS PopularPapelProgramacaoTotal$$

CREATE PROCEDURE PopularPapelProgramacaoTotal()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prog_id, v_evento_id INT;
    
    -- Cursor percorre cada atividade da programação
    DECLARE cur_prog CURSOR FOR 
        SELECT programacao_id, programacao_eventos_id FROM `eventos`.`programacao`;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- OTIMIZAÇÃO DE SESSÃO
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    OPEN cur_prog;

    read_loop: LOOP
        FETCH cur_prog INTO v_prog_id, v_evento_id;
        IF v_done THEN LEAVE read_loop; END IF;

        -- INSERÇÃO EM MASSA: 
        -- Atribui um papel para CADA inscrito que pertence ao evento desta atividade
        INSERT INTO `eventos`.`papelProgramacao` (
            `papelProgramacao_programacao_id`,
            `papelProgramacao_inscricao_id`,
            `papelProgramacao_papel_id`
        )
        SELECT 
            v_prog_id,
            i.inscricao_id,
            -- Lógica de Rodízio: Distribui os IDs de 1 a 11 uniformemente
            ( (i.inscricao_id % 11) + 1 ) 
        FROM `eventos`.`inscricao` i
        WHERE i.inscricao_eventos_id = v_evento_id;

        -- Commit a cada 20 atividades para manter a performance estável
        IF v_prog_id % 20 = 0 THEN
            COMMIT;
        END IF;

    END LOOP;

    COMMIT;
    CLOSE cur_prog;

    -- Restaura padrões
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularPapelProgramacaoTotal();

-- popular imagem evento

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularImagemEvento$$

CREATE PROCEDURE PopularImagemEvento()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_evento_nome VARCHAR(255);
    DECLARE v_caminho_limpo VARCHAR(255);

    -- Cursor para buscar os eventos atuais
    DECLARE cur_eventos CURSOR FOR 
        SELECT eventos_id, eventos_nome FROM `eventos`.`eventos`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Configurações de Performance
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    -- Tabela temporária para gerar múltiplas linhas por evento (Bulk)
    DROP TEMPORARY TABLE IF EXISTS tmp_num_evt;
    CREATE TEMPORARY TABLE tmp_num_evt (n INT PRIMARY KEY);
    INSERT INTO tmp_num_evt VALUES (1), (2), (3), (4), (5), (6), (7), (8);

    OPEN cur_eventos;
    
    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id, v_evento_nome;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Formata o nome do evento para o path da imagem (ex: "Workshop Tech" -> "workshop_tech")
        SET v_caminho_limpo = REPLACE(LOWER(v_evento_nome), ' ', '_');

        INSERT INTO `eventos`.`imagemEvento` (
            `imagemEvento_caminho`, 
            `imagemEvento_descricao`, 
            `imagemEvento_eventos_id`
        )
        SELECT 
            CONCAT('/assets/eventos/', v_caminho_limpo, '/foto_', t.n, '.jpg'),
            CONCAT('Galeria de fotos do evento - Registro ', t.n),
            v_evento_id
        FROM tmp_num_evt t
        -- Sorteia entre 2 e 5 imagens por evento para não sobrecarregar
        WHERE t.n <= (2 + FLOOR(RAND() * 4)); 

        -- Commit por evento para manter o log de transação leve
        IF v_evento_id % 10 = 0 THEN
            COMMIT;
        END IF;

    END LOOP read_loop;
    
    COMMIT;
    CLOSE cur_eventos;
    DROP TEMPORARY TABLE IF EXISTS tmp_num_evt;

    -- Restaura padrões
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularImagemEvento();

-- popular imagem programação

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularImagemProgramacao$$

CREATE PROCEDURE PopularImagemProgramacao()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_prog_id INT;
    DECLARE v_prog_nome VARCHAR(255);
    DECLARE v_caminho_limpo VARCHAR(255);

    -- Cursor agora focado na tabela de programação (atividades)
    DECLARE cur_prog CURSOR FOR 
        SELECT programacao_id, programacao_nome FROM `eventos`.`programacao`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Configurações de Performance
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    -- Tabela temporária para gerar até 5 imagens por atividade
    DROP TEMPORARY TABLE IF EXISTS tmp_num_prog;
    CREATE TEMPORARY TABLE tmp_num_prog (n INT PRIMARY KEY);
    INSERT INTO tmp_num_prog VALUES (1), (2), (3), (4), (5);

    OPEN cur_prog;
    
    read_loop: LOOP
        FETCH cur_prog INTO v_prog_id, v_prog_nome;
        IF v_done THEN LEAVE read_loop; END IF;

        -- Formata o nome da atividade para o path da imagem
        SET v_caminho_limpo = REPLACE(LOWER(v_prog_nome), ' ', '_');

        INSERT INTO `eventos`.`imagemProgramacao` (
            `imagemProgramacao_caminho`, 
            `imagemProgramacao_descricao`, 
            `imagemProgramacao_programacao_id`
        )
        SELECT 
            CONCAT('/assets/programacao/', v_caminho_limpo, '/foto_atv_', t.n, '.jpg'),
            CONCAT('Registro visual da atividade: ', v_prog_nome, ' - Foto ', t.n),
            v_prog_id
        FROM tmp_num_prog t
        -- Sorteia entre 1 e 4 imagens por atividade
        WHERE t.n <= (1 + FLOOR(RAND() * 4)); 

        -- Commit periódico para gerenciar memória
        IF v_prog_id % 50 = 0 THEN
            COMMIT;
        END IF;

    END LOOP read_loop;
    
    COMMIT;
    CLOSE cur_prog;
    DROP TEMPORARY TABLE IF EXISTS tmp_num_prog;

    -- Restaura padrões
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularImagemProgramacao();

-- popular certificados

DELIMITER $$

DROP PROCEDURE IF EXISTS PopularCertificado$$

CREATE PROCEDURE PopularCertificado()
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_evento_id INT;
    DECLARE v_evento_data_fim DATE;

    -- Cursor para processar um evento por vez
    DECLARE cur_eventos CURSOR FOR 
        SELECT eventos_id, eventos_dataFim 
        FROM `eventos`.`eventos`;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- Performance Turbo
    SET SESSION UNIQUE_CHECKS = 0;
    SET SESSION FOREIGN_KEY_CHECKS = 0;
    SET AUTOCOMMIT = 0;

    OPEN cur_eventos;

    read_loop: LOOP
        FETCH cur_eventos INTO v_evento_id, v_evento_data_fim;
        IF v_done THEN LEAVE read_loop; END IF;

        -- BULK INSERT: Gera certificados para todos os presentes no evento
        INSERT INTO `eventos`.`certificados` (
            `certificados_codigoDeValidacao`,
            `certificados_cargaHorariaTotal`,
            `certificados_dataDeEmissao`,
            `certificados_urlArquivo`,
            `certificados_inscricao_id`,
            `certificados_status` -- Adicionado para garantir o padrão 'valido'
        )
        SELECT 
            -- Código Único Hexadecimal de 16 dígitos
            UPPER(SUBSTRING(MD5(CONCAT(i.inscricao_id, UUID(), RAND())), 1, 16)),
            
            -- Soma a carga horária das atividades onde houve presença confirmada
            SUM(TIMESTAMPDIFF(MINUTE, p.programacao_horaInicio, p.programacao_horaFim)) / 60.0 AS total_horas,
            
            -- Data de emissão (fim do evento às 18h)
            CAST(CONCAT(v_evento_data_fim, ' 18:00:00') AS DATETIME),
            
            -- URL amigável para o arquivo
            CONCAT('/storage/certificados/ev_', v_evento_id, '/user_', i.inscricao_id, '.pdf'),
            
            i.inscricao_id,
            'valido'
        FROM `eventos`.`inscricao` i
        -- Liga a inscrição às atividades participadas (Nomes de colunas atualizados)
        INNER JOIN `eventos`.`inscritosProgramacao` ip ON i.inscricao_id = ip.inscritosProgramacao_inscritos_id
        INNER JOIN `eventos`.`programacao` p ON ip.inscritosProgramacao_programacao_id = p.programacao_id
        WHERE i.inscricao_eventos_id = v_evento_id
          AND ip.inscritosProgramacao_FrequenciaConfirmada = 1 -- Regra: só quem confirmou presença
        GROUP BY i.inscricao_id
        HAVING total_horas > 0;

        -- Commit por lote de evento para não sobrecarregar o buffer
        IF v_evento_id % 5 = 0 THEN
            COMMIT;
        END IF;

    END LOOP read_loop;

    COMMIT;
    CLOSE cur_eventos;

    -- Restaura segurança
    SET SESSION UNIQUE_CHECKS = 1;
    SET SESSION FOREIGN_KEY_CHECKS = 1;
    SET AUTOCOMMIT = 1;
END$$

DELIMITER ;

CALL PopularCertificado();


-- redefine predefinições

SET SESSION unique_checks = 1;

SET SESSION foreign_key_checks = 1;

SET SESSION sql_log_bin = 1; 

-- Remove índices da tabela permissoes e permissoesUsuarios
DROP INDEX idx_perm_nome ON `eventos`.`permissoes`;
DROP INDEX idx_pu_perm_usuario ON `eventos`.`permissoesUsuarios`;

-- Remove índice da tabela tipoInscricao
DROP INDEX idx_tipoInsc_evento ON `eventos`.`tipoInscricao`;

-- Remove índice da tabela inscricao
DROP INDEX idx_inscricao_evento ON `eventos`.`inscricao`;

-- Remove índice da tabela pagamento
DROP INDEX idx_pagamento_voucher ON `eventos`.`pagamento`;

-- Remove índice da tabela voucher
DROP INDEX idx_voucher_evento ON `eventos`.`voucher`;

-- Captura o tempo exato de fim

SET @tempo_fim = SYSDATE(6);



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
    ) AS 'Tempo total:';