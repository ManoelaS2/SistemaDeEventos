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
)


DELIMITER $$

create trigger trg_auditoria_insert_eventos
after insert on eventos
for each row
begin
	insert into auditoria_usuario(
		eventos_id,
		eventos_nome_antigo,
		eventos_nome_novo,
		eventos_descricao_antigo,
		eventos_descricao_novo,
		eventos_dataInicio_antigo,
		eventos_dataInicio_novo,
		eventos_dataFim_antigo,
		eventos_dataFim_novo,
		eventos_dataLimiteIncricao_antigo,
		eventos_dataLimiteIncricao_novo,
		auditoria_operacao,
		data_auditoria,
		mysql_usuario
    ) values (
		new.eventos_id,
        null,
        new.eventos_nome,
        null,
        new.eventos_descricao,
        null,
        new.eventos_dataInicio,
        null,
        new.eventos_dataFim,
        null,
        new.eventos_dataLimiteInscricao,
        'INSERT',
        NOW(),
        USER()
    );
end$$

create trigger trg_auditoria_delete_eventos
after delete on eventos
for each row
begin
	insert into auditoria_usuario(
		eventos_id,
		eventos_nome_antigo,
		eventos_nome_novo,
		eventos_descricao_antigo,
		eventos_descricao_novo,
		eventos_dataInicio_antigo,
		eventos_dataInicio_novo,
		eventos_dataFim_antigo,
		eventos_dataFim_novo,
		eventos_dataLimiteIncricao_antigo,
		eventos_dataLimiteIncricao_novo,
		auditoria_operacao,
		data_auditoria,
		mysql_usuario
    ) values (
		old.eventos_id,
        old.eventos_nome,
        null,
        old.eventos_descricao,
        null,
        old.eventos_dataInicio,
        null,
        old.eventos_dataFim,
        null,
        old.eventos_dataLimiteInscricao,
        null,
        'DELETE',
        NOW(),
        USER()
    );
end$$

create trigger trg_auditoria_update_eventos
after update on eventos
for each row
begin
	insert into auditoria_usuario(
		eventos_id,
		eventos_nome_antigo,
		eventos_nome_novo,
		eventos_descricao_antigo,
		eventos_descricao_novo,
		eventos_dataInicio_antigo,
		eventos_dataInicio_novo,
		eventos_dataFim_antigo,
		eventos_dataFim_novo,
		eventos_dataLimiteIncricao_antigo,
		eventos_dataLimiteIncricao_novo,
		auditoria_operacao,
		data_auditoria,
		mysql_usuario
    ) values (
		old.eventos_id,
        old.eventos_nome,
        new.eventos_nome,
        old.eventos_descricao,
        new.eventos_descricao,
        old.eventos_dataInicio,
        new.eventos_dataInicio,
        old.eventos_dataFim,
        new.eventos_dataFim,
        old.eventos_dataLimiteInscricao,
        new.eventos_dataLimiteInscricao,
        'UPDATE',
        NOW(),
        USER()
    );
end$$

DELIMITER ;
