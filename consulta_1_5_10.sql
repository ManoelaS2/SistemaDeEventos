use mydb;

-- Select 1
-- select nao otimizado
select certificados_cargaHorariaTotal, certificados_codigoDeValidacao from certificados
inner join inscricao ins on certificados.inscricao_inscricao_id = ins.inscricao_id
inner join inscritosProgramacao inp on inp.inscritos_inscritos_id = ins.inscricao_id
where ins.usuario_usuario_id = 12415 and inp.inscritosProgramacao_FrequenciaConfirmada = 1;

-- explain nao otimizado
explain select certificados_cargaHorariaTotal, certificados_codigoDeValidacao from certificados
inner join inscricao ins on certificados.inscricao_inscricao_id = ins.inscricao_id
inner join inscritosProgramacao inp on inp.inscritos_inscritos_id = ins.inscricao_id
where ins.usuario_usuario_id = 12415 and inp.inscritosProgramacao_FrequenciaConfirmada = 1;

-- analyze nao otimizado
explain analyze select certificados_cargaHorariaTotal, certificados_codigoDeValidacao from certificados
inner join inscricao ins on certificados.inscricao_inscricao_id = ins.inscricao_id
inner join inscritosProgramacao inp on inp.inscritos_inscritos_id = ins.inscricao_id
where ins.usuario_usuario_id = 12415 and inp.inscritosProgramacao_FrequenciaConfirmada = 1;


-- select otimzada
create index idx_inscricao_id on inscricao(inscricao_id);
create index idx_inscritosProgramacao_id_frequencia on inscricaoProgramacao(inscritos_inscritos_id, iscritosProgramacao_FrequenciaConfirmada);
create index idx_certificado_carga_codigo on certificados(certificados_certificado_cargaHorariaTotal, certificados_codigoDeValidacao);

select certifcados_cargaHorariaTotal, certificados_codigoDeValidacao from certificados
inner join inscricao ins on certificados.inscricao_inscricao_id = ins.inscricao_id
inner join inscritosProgramacao inp on inp.inscritos_inscritos_id = ins.inscricao_id
where ins.usuario_usuario_id = 12415 and inp.inscritosProgramacao_FrequenciaConfirmada = 1;

-- ========================================= --
-- Select 5 

-- select nao otimizado
select 
sum(case when ins.inscricao_credenciamento = 1 and pagamento_status = "Pago" then pagamento_valorpagamento else 0 end) as Valor_total_arrrecadado,
sum(case when ins.inscricao_credenciamento = 1 then 1 else 0 end) as Quantidade_Inscritos_confirmados ,
sum(case when ins.inscricao_credenciamento = 0 then 1 else 0 end) as Quantidade_Inscritos_Nao_confirmados,
sum(case when ins.inscricao_credenciamento = 0 then pagamento_valorpagamento else 0 end) as Valor_total_estimado
from pagamento left join inscricao ins on  inscricao_inscricao_id = ins.inscricao_id;

-- explain nao otimizado
explain select sum(case when ins.inscricao_credenciamento = 1 then pagamento_valorpagamento else 0 end) as Valor_total_arrrecadado,
sum(case when ins.inscricao_credenciamento = 1 then 1 else 0 end) as Quantidade_Inscritos_confirmados ,
sum(case when ins.inscricao_credenciamento = 0 then 1 else 0 end) as Quantidade_Inscritos_Nao_confirmados,
sum(case when ins.inscricao_credenciamento = 0 then pagamento_valorpagamento else 0 end) as Valor_total_estimado
from pagamento left join inscricao ins on  inscricao_inscricao_id = ins.inscricao_id;

-- analyze nao otimizado
explain analyze select sum(case when ins.inscricao_credenciamento = 1 then pagamento_valorpagamento else 0 end) as Valor_total_arrrecadado,
sum(case when ins.inscricao_credenciamento = 1 then 1 else 0 end) as Quantidade_Inscritos_confirmados ,
sum(case when ins.inscricao_credenciamento = 0 then 1 else 0 end) as Quantidade_Inscritos_Nao_confirmados,
sum(case when ins.inscricao_credenciamento = 0 then pagamento_valorpagamento else 0 end) as Valor_total_estimado
from pagamento left join inscricao ins on  inscricao_inscricao_id = ins.inscricao_id;

-- select otmizado
create index idx_inscricao_id_credenciamento on inscricao(inscricao_id, inscricao_credenciamento);
create index idx_pagamento_inscricaoId_valorpagamento_status on pagamento(inscricao_inscricao_id, pagamento_valorPagamento, pagamento_status);

select 
sum(case when ins.inscricao_credenciamento = 1 and pagamento_status = "Pago" then pagamento_valorpagamento else 0 end) as Valor_total_arrrecadado,
coalesce(sum(inscricao_credenciamento = 1), 0) as Quantidade_Inscritos_confirmados ,
coalesce(sum(ins.inscricao_credenciamento = 0)) as Quantidade_Inscritos_Nao_confirmados,
sum(case when ins.inscricao_credenciamento = 0 and then pagamento_valorpagamento else 0 end) as Valor_total_estimado
from pagamento left join inscricao ins on  inscricao_inscricao_id = ins.inscricao_id;

-- ============================================ --
-- Select 10
-- select nao otimizado
select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;

-- explain nao otimizado
explain select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;

-- analyze nao otimizado
explain analyze select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;

-- select otimizado
create index idx_telefone_ddi_ddd_telefone_usuario on telefone(telefone_ddi,telefone_ddd, telefone_telefone,usuario_usuario_id);
select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;