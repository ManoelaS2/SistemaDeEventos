use mydb;

CREATE TABLE auditoria_inscricao (
    auditoria_inscricao_id INT AUTO_INCREMENT PRIMARY KEY,
    inscricao_id INT,
    credenciamento_antigo VARCHAR(45),
    credenciamento_novo VARCHAR(45),    
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

create table auditoria_usuario (
	auditoria_usuario_id int auto_increment primary key,
    usuario_id int,
    usuario_nome_antigo varchar(45),
    usuario_nome_novo varchar(45),
    usuario_cpf_antigo varchar(14),
    usuario_cpf_novo varchar(14),
    usuario_email_antigo varchar(150),
    usuario_email_novo  varchar(150),
    usuario_sexo_antigo enum('F','M','Outro'),
    usuario_sexo_novo enum('F','M','Outro'),
    auditoria_operacao varchar(10),
    data_auditoria datetime,
    mysql_usuario varchar(100)
);

create table auditoria_eventos (
	auditoria_eventos_id int auto_increment primary key,
    eventos_id int,
    eventos_nome_antigo varchar(45),
    eventos_nome_novo varchar(45),
    eventos_descricao_antigo varchar(100),
    eventos_descricao_novo varchar(100),
    eventos_dataInicio_antigo date,
    eventos_dataInicio_novo date,
    eventos_dataFim_antigo date,
    eventos_dataFim_novo date,
    eventos_dataLimiteIncricao_antigo datetime,
    eventos_dataLimiteIncricao_novo datetime,
    auditoria_operacao varchar(10),
    data_auditoria datetime,
    mysql_usuario varchar(100)
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
        NEW.inscricao_id, NEW.inscricao_credenciamento, NEW.eventos_eventos_id, NEW.usuario_usuario_id, NEW.tipoInscricao_tipoInscricao_id,
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
        OLD.eventos_eventos_id, NEW.eventos_eventos_id, OLD.usuario_usuario_id, NEW.usuario_usuario_id,
        OLD.tipoInscricao_tipoInscricao_id, NEW.tipoInscricao_tipoInscricao_id,
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
        OLD.inscricao_id, OLD.inscricao_credenciamento, OLD.eventos_eventos_id, OLD.usuario_usuario_id, OLD.tipoInscricao_tipoInscricao_id,
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
		usuario_id, usuario_nome_antigo, usuario_nome_novo, usuario_cpf_antigo, usuario_cpf_novo,
		usuario_email_antigo, usuario_email_novo, usuario_sexo_antigo, usuario_sexo_novo,
		auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		new.usuario_id, null, new.usuario_nome, null, new.usuario_cpf,
        null, new.usuario_email, null, new.usuario_sexo,
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
		old.usuario_id, old.usuario_nome, new.usuario_nome, old.usuario_cpf, new.usuario_cpf,
        old.usuario_email, new.usuario_email, old.usuario_sexo, new.usuario_sexo,
        'UPDATE', NOW(), USER()
    );
END $$

DROP TRIGGER IF EXISTS trg_auditoria_delete_usuario$$
CREATE TRIGGER trg_auditoria_delete_usuario AFTER DELETE ON usuario FOR EACH ROW
BEGIN
	INSERT INTO auditoria_usuario(
		usuario_id, usuario_nome_antigo, usuario_nome_novo, usuario_cpf_antigo, usuario_cpf_novo,
		usuario_email_antigo, usuario_email_novo, usuario_sexo_antigo, usuario_sexo_novo,
		auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		old.usuario_id, old.usuario_nome, null, old.usuario_cpf, null,
        old.usuario_email, null, old.usuario_sexo, null,
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
		eventos_id, eventos_nome_antigo, eventos_nome_novo, eventos_descricao_antigo, eventos_descricao_novo,
		eventos_dataInicio_antigo, eventos_dataInicio_novo, eventos_dataFim_antigo, eventos_dataFim_novo,
		eventos_dataLimiteIncricao_antigo, eventos_dataLimiteIncricao_novo, auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		new.eventos_id, null, new.eventos_nome, null, new.eventos_descricao,
        null, new.eventos_dataInicio, null, new.eventos_dataFim, null, new.eventos_dataLimiteInscricao,
        'INSERT', NOW(), USER()
    );
END$$

DROP TRIGGER IF EXISTS trg_auditoria_update_eventos$$
CREATE TRIGGER trg_auditoria_update_eventos AFTER UPDATE ON eventos FOR EACH ROW
BEGIN
	INSERT INTO auditoria_eventos(
		eventos_id, eventos_nome_antigo, eventos_nome_novo, eventos_descricao_antigo, eventos_descricao_novo,
		eventos_dataInicio_antigo, eventos_dataInicio_novo, eventos_dataFim_antigo, eventos_dataFim_novo,
		eventos_dataLimiteIncricao_antigo, eventos_dataLimiteIncricao_novo, auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		old.eventos_id, old.eventos_nome, new.eventos_nome, old.eventos_descricao, new.eventos_descricao,
        old.eventos_dataInicio, new.eventos_dataInicio, old.eventos_dataFim, new.eventos_dataFim,
        old.eventos_dataLimiteInscricao, new.eventos_dataLimiteInscricao,
        'UPDATE', NOW(), USER()
    );
END$$

DROP TRIGGER IF EXISTS trg_auditoria_delete_eventos$$
CREATE TRIGGER trg_auditoria_delete_eventos AFTER DELETE ON eventos FOR EACH ROW
BEGIN
	INSERT INTO auditoria_eventos(
		eventos_id, eventos_nome_antigo, eventos_nome_novo, eventos_descricao_antigo, eventos_descricao_novo,
		eventos_dataInicio_antigo, eventos_dataInicio_novo, eventos_dataFim_antigo, eventos_dataFim_novo,
		eventos_dataLimiteIncricao_antigo, eventos_dataLimiteIncricao_novo, auditoria_operacao, data_auditoria, mysql_usuario
    ) VALUES (
		old.eventos_id, old.eventos_nome, null, old.eventos_descricao, null,
        old.eventos_dataInicio, null, old.eventos_dataFim, null, old.eventos_dataLimiteInscricao, null,
        'DELETE', NOW(), USER()
    );
END$$

DELIMITER ;