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
)

DELIMITER $$

create trigger trg_auditoria_insert_usuario 
after insert on usuario
for each row
begin
	insert into auditoria_usuario(
		usuario_id,
		usuario_nome_antigo,
		usuario_nome_novo,
		usuario_cpf_antigo ,
		usuario_cpf_novo,
		usuario_email_antigo,
		usuario_email_novo ,
		usuario_sexo_antigo,
		usuario_sexo_novo,
		auditoria_operacao,
		data_auditoria,
		mysql_usuario
    ) values (
		new.usuario_id,
        null,
        new.usuario_nome,
        null,
        new.usuario_cpf,
        null,
        new.usuario_email,
        null,
        new.usuario_sexo,
        'INSERT',
        NOW(),
        USER()
    );
end $$

create trigger trg_auditoria_delete_usuario 
after insert on usuario
for each row
begin
	insert into auditoria_usuario(
		usuario_id,
		usuario_nome_antigo,
		usuario_nome_novo,
		usuario_cpf_antigo ,
		usuario_cpf_novo,
		usuario_email_antigo,
		usuario_email_novo ,
		usuario_sexo_antigo,
		usuario_sexo_novo,
		auditoria_operacao,
		data_auditoria,
		mysql_usuario
    ) values (
		old.usuario_id,
        old.usuario_nome,
        null,
		old.usuario_cpf,
        null,
        old.usuario_email,
        null,
        old.usuario_sexo,
        null,
        'DELETE',
        NOW(),
        USER()
    );
end $$

create trigger trg_auditoria_insert_usuario 
after insert on usuario
for each row
begin
	insert into auditoria_usuario(
		usuario_id,
		usuario_nome_antigo,
		usuario_nome_novo,
		usuario_cpf_antigo ,
		usuario_cpf_novo,
		usuario_email_antigo,
		usuario_email_novo ,
		usuario_sexo_antigo,
		usuario_sexo_novo,
		auditoria_operacao,
		data_auditoria,
		mysql_usuario
    ) values (
		old.usuario_id,
        old.usuario_nome,
        new.usuario_nome,
        old.usuario_cpf,
        new.usuario_cpf,
        old.usuario_email,
        new.usuario_email,
        null,
        new.sexo,
        'INSERT',
        NOW(),
        USER()
    );
end $$

