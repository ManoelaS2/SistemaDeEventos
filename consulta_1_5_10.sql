use mydb;

-- Select 1
-- select nao otimizado
select certificados_id from certificados
inner join inscricao ins on certificados.inscricao_inscricao_id = ins.inscricao_id
inner join inscritosprogramacao inp on inp.inscritos_inscritos_id = ins.inscricao_id
where ins.usuario_usuario_id = 12415 and inp.inscritosProgramacao_FrequenciaConfirmada = 1;

-- explain nao otimizado
explain select certificados_id from certificados
inner join inscricao ins on certificados.inscricao_inscricao_id = ins.inscricao_id
inner join inscritosprogramacao inp on inp.inscritos_inscritos_id = ins.inscricao_id
where ins.usuario_usuario_id = 12415 and inp.inscritosProgramacao_FrequenciaConfirmada = 1;

-- analyze nao otimizado
explain analyze select certificados_id from certificados
inner join inscricao ins on certificados.inscricao_inscricao_id = ins.inscricao_id
inner join inscritosprogramacao inp on inp.inscritos_inscritos_id = ins.inscricao_id
where ins.usuario_usuario_id = 12415 and inp.inscritosProgramacao_FrequenciaConfirmada = 1;

-- select otimzada


-- ========================================= --
-- Select 5 

-- select nao otimizado
select sum(case when ins.inscricao_credenciamento = 1 then pagamento_valorpagamento else 0 end) as Valor_total_arrrecadado,
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

-- ============================================ --
-- Select 10
-- select nao otimizado
select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;

-- explain nao otimizado
explain select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;

-- analyze nao otimizado
explain analyze select telefone_ddi, telefone_ddd, telefone_telefone from telefone where usuario_usuario_id = 1;