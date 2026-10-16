USE eventos;

-- -----------------------------------------------------
-- Estruturas de Tabelas de Log
-- -----------------------------------------------------

CREATE TABLE IF NOT EXISTS auditoria_inscricao (
    auditoria_inscricao_id INT AUTO_INCREMENT PRIMARY KEY,
    inscricao_id INT,
    credenciamento_antigo TINYINT,
    credenciamento_novo TINYINT,    
    evento_antigo INT,
    evento_novo INT,    
    usuario_antigo INT,
    usuario_novo INT,    
    tipo_inscricao_antigo INT,
    tipo_inscricao_novo INT,    
    auditoria_operacao VARCHAR(10),
    data_auditoria DATETIME,
    mysql_usuario VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS auditoria_usuario (
	auditoria_usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    usuario_nome_antigo VARCHAR(45),
    usuario_nome_novo VARCHAR(45),
    usuario_cpf_antigo VARCHAR(14),
    usuario_cpf_novo VARCHAR(14),
    usuario_email_antigo VARCHAR(150),
    usuario_email_novo  VARCHAR(150),
    usuario_sexo_antigo ENUM('F','M','Outro'),
    usuario_sexo_novo ENUM('F','M','Outro'),
    auditoria_operacao VARCHAR(10),
    data_auditoria DATETIME,
    mysql_usuario VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS auditoria_eventos (
	auditoria_eventos_id INT AUTO_INCREMENT PRIMARY KEY,
    eventos_id INT,
    eventos_nome_antigo VARCHAR(45),
    eventos_nome_novo VARCHAR(45),
    eventos_descricao_antigo VARCHAR(100),
    eventos_descricao_novo VARCHAR(100),
    eventos_dataInicio_antigo DATE,
    eventos_dataInicio_novo DATE,
    eventos_dataFim_antigo DATE,
    eventos_dataFim_novo DATE,
    eventos_dataLimiteInscricao_antigo DATETIME,
    eventos_dataLimiteInscricao_novo DATETIME,
    auditoria_operacao VARCHAR(10),
    data_auditoria DATETIME,
    mysql_usuario VARCHAR(100)
);

DELIMITER $$

-- ==========================================
-- TRIGGERS DE INSCRIÇÃO
-- ==========================================

DROP TRIGGER IF EXISTS trg_auditoria_insert_inscricao$$
CREATE TRIGGER trg_auditoria_insert_inscricao AFTER INSERT ON inscricao FOR EACH ROW
BEGIN
    INSERT INTO auditoria_inscricao (
        inscricao_id, credenciamento_novo, evento_novo, usuario_novo, tipo_inscricao_novo,
        auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
        NEW.inscricao_id, NEW.inscricao_credenciamento, NEW.inscricao_eventos_id, NEW.inscricao_usuario_id, NEW.inscricao_tipoInscricao_id,
        'INSERT', NOW(), USER()
    );
END$$

DROP TRIGGER IF EXISTS trg_auditoria_update_inscricao$$
CREATE TRIGGER trg_auditoria_update_inscricao AFTER UPDATE ON inscricao FOR EACH ROW
BEGIN
    INSERT INTO auditoria_inscricao (
        inscricao_id, credenciamento_antigo, credenciamento_novo, evento_antigo, evento_novo,
        usuario_antigo, usuario_novo, tipo_inscricao_antigo, tipo_inscricao_novo,
        auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
        OLD.inscricao_id, OLD.inscricao_credenciamento, NEW.inscricao_credenciamento,
        OLD.inscricao_eventos_id, NEW.inscricao_eventos_id, OLD.inscricao_usuario_id, NEW.inscricao_usuario_id,
        OLD.inscricao_tipoInscricao_id, NEW.inscricao_tipoInscricao_id,
        'UPDATE', NOW(), USER()
    );
END$$

DROP TRIGGER IF EXISTS trg_auditoria_delete_inscricao$$
CREATE TRIGGER trg_auditoria_delete_inscricao AFTER DELETE ON inscricao FOR EACH ROW
BEGIN
    INSERT INTO auditoria_inscricao (
        inscricao_id, credenciamento_antigo, evento_antigo, usuario_antigo, tipo_inscricao_antigo,
        auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
        OLD.inscricao_id, OLD.inscricao_credenciamento, OLD.inscricao_eventos_id, OLD.inscricao_usuario_id, OLD.inscricao_tipoInscricao_id,
        'DELETE', NOW(), USER()
    );
END$$


-- ==========================================
-- TRIGGERS DE USUÁRIO
-- ==========================================

DROP TRIGGER IF EXISTS trg_auditoria_insert_usuario$$
CREATE TRIGGER trg_auditoria_insert_usuario AFTER INSERT ON usuario FOR EACH ROW
BEGIN
	INSERT INTO auditoria_usuario(
		usuario_id, usuario_nome_novo, usuario_cpf_novo,
		usuario_email_novo, usuario_sexo_novo,
		auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		NEW.usuario_id, NEW.usuario_nome, NEW.usuario_cpf,
        NEW.usuario_email, NEW.usuario_sexo,
        'INSERT', NOW(), USER()
    );
END $$

DROP TRIGGER IF EXISTS trg_auditoria_update_usuario$$
CREATE TRIGGER trg_auditoria_update_usuario AFTER UPDATE ON usuario FOR EACH ROW
BEGIN
	INSERT INTO auditoria_usuario(
		usuario_id, usuario_nome_antigo, usuario_nome_novo, usuario_cpf_antigo, usuario_cpf_novo,
		usuario_email_antigo, usuario_email_novo, usuario_sexo_antigo, usuario_sexo_novo,
		auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		OLD.usuario_id, OLD.usuario_nome, NEW.usuario_nome, OLD.usuario_cpf, NEW.usuario_cpf,
        OLD.usuario_email, NEW.usuario_email, OLD.usuario_sexo, NEW.usuario_sexo,
        'UPDATE', NOW(), USER()
    );
END $$

DROP TRIGGER IF EXISTS trg_auditoria_delete_usuario$$
CREATE TRIGGER trg_auditoria_delete_usuario AFTER DELETE ON usuario FOR EACH ROW
BEGIN
	INSERT INTO auditoria_usuario(
		usuario_id, usuario_nome_antigo, usuario_cpf_antigo,
		usuario_email_antigo, usuario_sexo_antigo,
		auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		OLD.usuario_id, OLD.usuario_nome, OLD.usuario_cpf,
        OLD.usuario_email, OLD.usuario_sexo,
        'DELETE', NOW(), USER()
    );
END $$


-- ==========================================
-- TRIGGERS DE EVENTO
-- ==========================================

DROP TRIGGER IF EXISTS trg_auditoria_insert_eventos$$
CREATE TRIGGER trg_auditoria_insert_eventos AFTER INSERT ON eventos FOR EACH ROW
BEGIN
	INSERT INTO auditoria_eventos(
		eventos_id, eventos_nome_novo, eventos_descricao_novo,
		eventos_dataInicio_novo, eventos_dataFim_novo,
		eventos_dataLimiteInscricao_novo, auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		NEW.eventos_id, NEW.eventos_nome, NEW.eventos_descricao,
        NEW.eventos_dataInicio, NEW.eventos_dataFim, NEW.eventos_dataLimiteInscricao,
        'INSERT', NOW(), USER()
    );
END$$

DROP TRIGGER IF EXISTS trg_auditoria_update_eventos$$
CREATE TRIGGER trg_auditoria_update_eventos AFTER UPDATE ON eventos FOR EACH ROW
BEGIN
	INSERT INTO auditoria_eventos(
		eventos_id, eventos_nome_antigo, eventos_nome_novo, eventos_descricao_antigo, eventos_descricao_novo,
		eventos_dataInicio_antigo, eventos_dataInicio_novo, eventos_dataFim_antigo, eventos_dataFim_novo,
		eventos_dataLimiteInscricao_antigo, eventos_dataLimiteInscricao_novo, auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		OLD.eventos_id, OLD.eventos_nome, NEW.eventos_nome, OLD.eventos_descricao, NEW.eventos_descricao,
        OLD.eventos_dataInicio, NEW.eventos_dataInicio, OLD.eventos_dataFim, NEW.eventos_dataFim,
        OLD.eventos_dataLimiteInscricao, NEW.eventos_dataLimiteInscricao,
        'UPDATE', NOW(), USER()
    );
END$$

DROP TRIGGER IF EXISTS trg_auditoria_delete_eventos$$
CREATE TRIGGER trg_auditoria_delete_eventos AFTER DELETE ON eventos FOR EACH ROW
BEGIN
	INSERT INTO auditoria_eventos(
		eventos_id, eventos_nome_antigo, eventos_descricao_antigo,
		eventos_dataInicio_antigo, eventos_dataFim_antigo,
		eventos_dataLimiteInscricao_antigo, auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		OLD.eventos_id, OLD.eventos_nome, OLD.eventos_descricao,
        OLD.eventos_dataInicio, OLD.eventos_dataFim, OLD.eventos_dataLimiteInscricao,
        'DELETE', NOW(), USER()
    );
END$$

DELIMITER ;