# Migrações

Uma migração adapta um banco já existente a uma nova estrutura. Ela é diferente
de importar exemplos: deve preservar os registros que a pessoa já cadastrou.

A versão atual é 1, criada em `assets/js/banco.js`. Ainda não existem versões
anteriores para migrar. Ao mudar o esquema, incremente a versão de abertura do
IndexedDB e acrescente o tratamento em `onupgradeneeded`, preservando os registros.
Alterar apenas o JSON inicial não atualiza os bancos já inicializados.

As mídias dos registros de exemplo usam uma atualização de conteúdo separada:
`aplicarMidiasPadrao`, em banco.js, consulta `iniciais/midias-padrao.json` e preenche
apenas campos de imagem ausentes. O marcador `midias-demonstracao-v1` em meta
impede repetições. Essa operação não muda a versão do esquema nem reimporta contas.
