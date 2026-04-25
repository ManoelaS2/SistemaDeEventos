-- consulta 1

select *from usuario inner join inscricao i on i.usuario_usuario_id = usuario_id inner join eventos on eventos_id = eventos_eventos_id inner join certificados on inscricao_inscricao_id = inscricao_idwhere i.usuario_usuario_id = 106504;

CREATE INDEX idx_inscricao_usuario_evento ON inscricao (usuario_usuario_id, eventos_eventos_id, inscricao_id);
CREATE INDEX idx_certificados_inscricao_emissao ON certificados (inscricao_inscricao_id, certificados_dataDeEmissao DESC);
CREATE INDEX idx_eventos_dados ON eventos (eventos_id, eventos_nome, eventos_dataInicio, eventos_dataFim);

select usuario_nome, eventos_nome, eventos_descricao, eventos_dataInicio, eventos_dataFim, certificados_cargaHorariaTotal, certificados_dataDeEmissaofrom usuario inner join inscricao i on i.usuario_usuario_id = usuario_id inner join eventos on eventos_id = eventos_eventos_id inner join certificados on inscricao_inscricao_id = inscricao_idwhere i.usuario_usuario_id = 106504 order by certificados_dataDeEmissao desc;

-- consulta 2

SELECT * FROM inscricao INNER JOIN pagamento ON inscricao_inscricao_id = inscricao_id INNER JOIN usuario ON usuario_usuario_id = usuario_id WHERE eventos_eventos_id = 1 AND pagamento_status = 'Pago' ORDER BY pagamento_dataHora ASC;

CREATE INDEX idx_inscricao_evento_usuario ON inscricao (eventos_eventos_id, usuario_usuario_id);
CREATE INDEX idx_pagamento_performance ON pagamento (inscricao_inscricao_id, pagamento_status, pagamento_dataHora);
CREATE INDEX idx_usuario_id_nome ON usuario (usuario_id, usuario_nome);
 
SELECT usuario_nome FROM inscricao INNER JOIN pagamento ON inscricao_inscricao_id = inscricao_id INNER JOIN usuario ON usuario_usuario_id = usuario_id WHERE eventos_eventos_id = 1 AND pagamento_status = 'Pago' ORDER BY pagamento_dataHora ASC;

-- consulta 3

select * from programacao left join imagemprogramacao on programacao_id = programacao_programacao_id left join sublocaEvento on sublocaEvento_sublocaEvento_id = sublocaEvento_idwhere eventos_eventos_id = 5 order by programacao_horaInicio asc;

CREATE INDEX idx_programacao_evento_hora ON programacao (eventos_eventos_id, programacao_horaInicio);

select programacao_nome, programacao_horaInicio, programacao_horaFim, programacao_descricao, imagemProgramacao_caminho, imagemProgramacao_descricao, sublocaEvento_nome, sublocaEvento_descricaofrom programacao inner join imagemprogramacao on programacao_id = programacao_programacao_id inner join sublocaEvento on sublocaEvento_sublocaEvento_id = sublocaEvento_idwhere eventos_eventos_id = 5 order by programacao_horaInicio asc;

-- pesquisa 4

SELECT cidade_nome AS cidade, COUNT(DISTINCT usuario_id) AS quantidade_usuarios FROM usuario INNER JOIN endereco ON usuario_id = usuario_usuario_id INNER JOIN cep ON CEP_cep_id = cep_id INNER JOIN cidade ON cidade_cidade_id = cidade_id WHERE cidade_nome IS NOT NULL AND cidade_nome != '' GROUP BY cidade_id, cidade_nome ORDER BY quantidade_usuarios DESC;

CREATE INDEX idx_endereco_usuario ON endereco(usuario_usuario_id);
CREATE INDEX idx_endereco_cep ON endereco(CEP_cep_id);
CREATE INDEX idx_cep_cidade ON cep(cidade_cidade_id);
CREATE INDEX idx_cidade_nome ON cidade(cidade_nome);

SELECT cidade_nome AS cidade, COUNT(usuario_id) AS quantidade_usuarios FROM cidade INNER JOIN cep ON cidade_id = cidade_cidade_id INNER JOIN endereco ON cep_id = CEP_cep_id INNER JOIN usuario ON usuario_usuario_id = usuario_id WHERE cidade_nome > '' GROUP BY cidade_id ORDER BY quantidade_usuarios DESC;

-- pesquisa 5

select sum(case when inscricao_credenciamento = 1 and pagamento_status = "Pago" then pagamento_valorpagamento else 0 end) as Valor_total_arrrecadado, sum(case when inscricao_credenciamento = 1 then 1 else 0 end) as Quantidade_Inscritos_confirmados, sum(case when inscricao_credenciamento = 0 then 1 else 0 end) as Quantidade_Inscritos_Nao_confirmados, sum(case when inscricao_credenciamento = 0 then pagamento_valorpagamento else 0 end) as Valor_total_estimado from pagamento left join inscricao on inscricao_inscricao_id = inscricao_id;

create index idx_inscricao_id_credenciamento on inscricao(inscricao_id, inscricao_credenciamento);
create index idx_pagamento_inscricaoId_valorpagamento_status on pagamento(inscricao_inscricao_id, pagamento_valorPagamento, pagamento_status);

select sum(case when inscricao_credenciamento = 1 and pagamento_status = "Pago" then pagamento_valorpagamento else 0 end) as Valor_total_arrrecadado, coalesce(sum(inscricao_credenciamento = 1), 0) as Quantidade_Inscritos_confirmados, coalesce(sum(inscricao_credenciamento = 0), 0) as Quantidade_Inscritos_Nao_confirmados, sum(case when inscricao_credenciamento = 0 then pagamento_valorpagamento else 0 end) as Valor_total_estimado from pagamento left join inscricao on inscricao_inscricao_id = inscricao_id;

-- select 6

SELECT *, CASE WHEN NOW() <= eventos_dataLimiteInscricao THEN 'INSCRIÇÕES ABERTAS' WHEN NOW() BETWEEN eventos_dataInicio AND eventos_dataFim THEN 'EM ANDAMENTO' WHEN NOW() < eventos_dataInicio THEN 'FUTURO' ELSE 'ENCERRADO' END AS status_evento FROM eventos;

CREATE INDEX idx_evento_id_nome_inicio_fim_limetInscricao on eventos(eventos_id,eventos_nome,eventos_dataInicio,eventos_dataFim, eventos_dataLimiteInscricao);

SELECT eventos_id, eventos_nome, eventos_dataInicio, eventos_dataFim, eventos_dataLimiteInscricao, CASE WHEN NOW() <= eventos_dataLimiteInscricao THEN 'INSCRIÇÕES ABERTAS' WHEN NOW() BETWEEN eventos_dataInicio AND eventos_dataFim THEN 'EM ANDAMENTO' WHEN NOW() < eventos_dataInicio THEN 'FUTURO' ELSE 'ENCERRADO' END AS status_evento FROM eventos;

-- pesquisa 7

SELECT eventos_nome, COUNT(voucher_id) AS total_vouchers, SUM(CASE WHEN voucher_disponivel = 1 THEN 1 ELSE 0 END) AS disponiveis, SUM(CASE WHEN voucher_disponivel = 0 THEN 1 ELSE 0 END) AS usados FROM eventos LEFT JOIN voucher ON eventos_id = eventos_eventos_id GROUP BY eventos_id ORDER BY total_vouchers DESC;

CREATE INDEX idx_voucher_evento_disp ON voucher(eventos_eventos_id, voucher_disponivel);
CREATE INDEX idx_eventos_id_nome ON eventos(eventos_id, eventos_nome);

SELECT eventos_nome, COUNT(voucher_id) AS total_vouchers, COALESCE(SUM(voucher_disponivel = 1), 0) AS disponiveis, COALESCE(SUM(voucher_disponivel = 0), 0) AS usados, COALESCE(ROUND(SUM(voucher_disponivel = 0) * 100.0 / NULLIF(COUNT(*), 0), 2), 0) AS percentual_uso FROM eventos LEFT JOIN voucher ON eventos_id = eventos_eventos_id GROUP BY eventos_id, eventos_nome ORDER BY total_vouchers DESC;

-- pesquisa 8

ELECT DISTINCT *, (SELECT CASE WHEN LOWER(permissoes_nome) LIKE '%criar_evento%' THEN 'SIM' ELSE 'NÃO' END FROM permissoes JOIN permissoesusuarios ON permissoes_id = permissoes_permissoes_id WHERE permissoesusuarios.usuario_usuario_id = usuario.usuario_id LIMIT 1) AS pode_criar_evento FROM eventos JOIN usuario ON CONCAT(usuario_id, '') = CONCAT(eventos.usuario_usuario_id, '') LEFT JOIN permissoesusuarios ON permissoesusuarios.usuario_usuario_id = usuario.usuario_id LEFT JOIN permissoes ON permissoes_id = permissoesusuarios.permissoes_permissoes_id ORDER BY RAND();

CREATE INDEX idx_eventos_id_nome_inicio_fim ON eventos(eventos_id,eventos_nome,eventos_dataInicio,eventos_dataFim);
CREATE INDEX idx_usuario_id_nome_email ON usuario(usuario_id,usuario_nome, usuario_email);

SELECT eventos_id, eventos_nome, eventos_descricao, eventos_dataInicio, eventos_dataFim, usuario_id, usuario_nome, usuario_email, CASE WHEN permissoes_nome = 'criar_evento' THEN 'SIM' ELSE 'NÃO' END AS pode_criar_evento FROM eventos JOIN usuario ON usuario.usuario_id = eventos.usuario_usuario_id LEFT JOIN permissoesusuarios ON permissoesusuarios.usuario_usuario_id = usuario.usuario_id LEFT JOIN permissoes ON permissoes.permissoes_id = permissoesusuarios.permissoes_permissoes_id;

-- execucao 9

SELECT (SELECT e.eventos_nome FROM eventos e WHERE e.eventos_id = p.eventos_eventos_id) AS EVENTO, p.programacao_nome AS ATIVIDADE, DATE_FORMAT(p.programacao_horaInicio, '%d/%m/%Y %H:%i') AS DATA_HORA, COALESCE((SELECT pap.papel_nome FROM papel pap JOIN papelProgramacao pp ON pap.papel_id = pp.papel_papel_id WHERE pp.inscricao_inscricao_id = i.inscricao_id AND pp.programacao_programacao_id = p.programacao_id LIMIT 1), 'Participante') AS FUNCAO, u.usuario_nome AS NOME, u.usuario_email AS EMAIL, CASE WHEN (SELECT ip2.inscritosProgramacao_FrequenciaConfirmada FROM inscritosProgramacao ip2 WHERE ip2.programacao_programacao_id = p.programacao_id AND ip2.inscritos_inscritos_id = i.inscricao_id LIMIT 1) = 1 THEN 'Confirmado' WHEN (SELECT ip2.inscritosProgramacao_FrequenciaConfirmada FROM inscritosProgramacao ip2 WHERE ip2.programacao_programacao_id = p.programacao_id AND ip2.inscritos_inscritos_id = i.inscricao_id LIMIT 1) = 0 THEN 'Ausente' ELSE 'Pendente' END AS STATUS_PRESENCA, DATE_FORMAT((SELECT ip3.inscritosProgramacao_dataHoraFrequencia FROM inscritosProgramacao ip3 WHERE ip3.programacao_programacao_id = p.programacao_id AND ip3.inscritos_inscritos_id = i.inscricao_id LIMIT 1), '%d/%m/%Y %H:%i:%s') AS DATA_CHECKIN FROM programacao p INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id WHERE p.programacao_id = 41286 ORDER BY (SELECT 1) DESC, u.usuario_nome ASC;
    
CREATE INDEX idx_programacao_id_evento ON programacao(programacao_id, eventos_eventos_id);
CREATE INDEX idx_inscritos_prog_programacao ON inscritosProgramacao(programacao_programacao_id, inscritos_inscritos_id);
CREATE INDEX idx_inscricao_id_usuario ON inscricao(inscricao_id, usuario_usuario_id);
CREATE INDEX idx_papel_prog_composto ON papelProgramacao(programacao_programacao_id, inscricao_inscricao_id);

SELECT e.eventos_nome AS EVENTO, p.programacao_nome AS ATIVIDADE, DATE_FORMAT(p.programacao_horaInicio, '%d/%m/%Y %H:%i') AS DATA_HORA, COALESCE(pap.papel_nome, 'Participante') AS FUNCAO, u.usuario_nome AS NOME, u.usuario_email AS EMAIL, CASE WHEN ip.inscritosProgramacao_FrequenciaConfirmada = 1 THEN 'Confirmado' WHEN ip.inscritosProgramacao_FrequenciaConfirmada = 0 THEN 'Ausente' ELSE 'Pendente' END AS STATUS_PRESENCA, DATE_FORMAT(ip.inscritosProgramacao_dataHoraFrequencia, '%d/%m/%Y %H:%i:%s') AS DATA_CHECKIN FROM programacao p INNER JOIN eventos e ON p.eventos_eventos_id = e.eventos_id INNER JOIN inscritosProgramacao ip ON p.programacao_id = ip.programacao_programacao_id INNER JOIN inscricao i ON ip.inscritos_inscritos_id = i.inscricao_id INNER JOIN usuario u ON i.usuario_usuario_id = u.usuario_id LEFT JOIN papelProgramacao pp ON i.inscricao_id = pp.inscricao_inscricao_id AND p.programacao_id = pp.programacao_programacao_id LEFT JOIN papel pap ON pp.papel_papel_id = pap.papel_id WHERE p.programacao_id = 41286 ORDER BY FIELD(pap.papel_nome, 'Organizador', 'Coordenador', 'Palestrante', 'Staff', 'Auxiliar', 'Participante'), u.usuario_nome;

-- consulata 10

select * from telefone where usuario_usuario_id = 1;

create index idx_telefone_ddi_ddd_telefone_usuario on telefone(telefone_ddi,telefone_ddd, telefone_telefone,usuario_usuario_id);

select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;
