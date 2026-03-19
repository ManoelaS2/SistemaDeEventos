use mydb;
SELECT 'usuario' AS tabela, COUNT(*) AS total FROM usuario
UNION ALL
SELECT 'telefone', COUNT(*) FROM telefone
UNION ALL
SELECT 'estado', COUNT(*) FROM estado
UNION ALL
SELECT 'cidade', COUNT(*) FROM cidade
UNION ALL
SELECT 'CEP', COUNT(*) FROM CEP
UNION ALL
SELECT 'endereco', COUNT(*) FROM endereco
UNION ALL
SELECT 'tipoEvento', COUNT(*) FROM tipoEvento
UNION ALL
SELECT 'localEvento', COUNT(*) FROM localEvento
UNION ALL
SELECT 'eventos', COUNT(*) FROM eventos
UNION ALL
SELECT 'tipoInscricao', COUNT(*) FROM tipoInscricao
UNION ALL
SELECT 'inscricao', COUNT(*) FROM inscricao
UNION ALL
SELECT 'sublocaEvento', COUNT(*) FROM sublocaEvento
UNION ALL
SELECT 'programacao', COUNT(*) FROM programacao
UNION ALL
SELECT 'certificados', COUNT(*) FROM certificados
UNION ALL
SELECT 'tiposLogin', COUNT(*) FROM tiposLogin
UNION ALL
SELECT 'login', COUNT(*) FROM login
UNION ALL
SELECT 'permissoes', COUNT(*) FROM permissoes
UNION ALL
SELECT 'papel', COUNT(*) FROM papel
UNION ALL
SELECT 'voucher', COUNT(*) FROM voucher
UNION ALL
SELECT 'metodoPagamento', COUNT(*) FROM metodoPagamento
UNION ALL
SELECT 'tipoDesconto', COUNT(*) FROM tipoDesconto
UNION ALL
SELECT 'pagamento', COUNT(*) FROM pagamento
UNION ALL
SELECT 'permissoesUsuarios', COUNT(*) FROM permissoesUsuarios
UNION ALL
SELECT 'inscritosProgramacao', COUNT(*) FROM inscritosProgramacao
UNION ALL
SELECT 'imagemEvento', COUNT(*) FROM imagemEvento
UNION ALL
SELECT 'papelProgramacao', COUNT(*) FROM papelProgramacao
UNION ALL
SELECT 'imagemProgramacao', COUNT(*) FROM imagemProgramacao;