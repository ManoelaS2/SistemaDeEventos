DELIMITER $$
CREATE TRIGGER trg_auditoria_update_inscricao
AFTER UPDATE ON inscricao
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_inscricao (
        inscricao_id,
        credenciamento_antigo, 
        credenciamento_novo,
        evento_antigo, 
        evento_novo,
        usuario_antigo, 
        usuario_novo,
        tipo_inscricao_antigo, 
        tipo_inscricao_novo,
        operacao, 
        data_evento, 
        usuario_db
    ) VALUES (
        OLD.inscricao_id,
        OLD.inscricao_credenciamento, 
        NEW.inscricao_credenciamento,
        OLD.eventos_eventos_id, 
        NEW.eventos_eventos_id,
        OLD.usuario_usuario_id, 
        NEW.usuario_usuario_id,
        OLD.tipoInscricao_tipoInscricao_id, 
        NEW.tipoInscricao_tipoInscricao_id,
        'UPDATE', 
        NOW(), 
        USER()
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_auditoria_insert_inscricao
AFTER INSERT ON inscricao
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_inscricao (
        inscricao_id,
        credenciamento_novo,
        evento_novo,
        usuario_novo,
        tipo_inscricao_novo,
        operacao, data_evento, usuario_db
    ) VALUES (
        NEW.inscricao_id,
        NEW.inscricao_credenciamento,
        NEW.eventos_eventos_id,
        NEW.usuario_usuario_id,
        NEW.tipoInscricao_tipoInscricao_id,
        'INSERT', 
        NOW(), 
        USER()
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_auditoria_delete_inscricao
AFTER DELETE ON inscricao
FOR EACH ROW
BEGIN
    INSERT INTO auditoria_inscricao (
        inscricao_id,
        credenciamento_antigo,
        evento_antigo,
        usuario_antigo,
        tipo_inscricao_antigo,
        operacao, data_evento, usuario_db
    ) VALUES (
        OLD.inscricao_id,
        OLD.inscricao_credenciamento,
        OLD.eventos_eventos_id,
        OLD.usuario_usuario_id,
        OLD.tipoInscricao_tipoInscricao_id,
        'DELETE', 
        NOW(), 
        USER()
    );
END$$
DELIMITER ;

