# Dados do EAS

Esta pasta reúne os arquivos compartilhados pelo GitHub para preparar o banco
IndexedDB de cada navegador. O banco em uso fica no navegador, e não nesta pasta.

## Organização

```text
dados/
├── esquema/       # Definição das coleções, campos, índices e versão do banco
├── iniciais/      # Dados usados para inicializar a demonstração
├── migracoes/    # Alterações entre versões do banco
└── exportacoes/  # Cópias exportadas para compartilhar cenários de demonstração
```

- `iniciais/banco.json` contém as contas e os cenários fictícios de demonstração.
- `esquema` documenta as coleções, os vínculos e os índices.
- `migracoes` receberá as mudanças necessárias para atualizar bancos já criados.
- `exportacoes` pode guardar os arquivos JSON exportados em Minha Conta.
- Os arquivos `.gitkeep` permitem versionar as pastas ainda vazias no Git.

## Integração com as páginas

Os scripts de acesso ao banco devem ficar em `assets/js`, seguindo a organização
atual do projeto. As imagens enviadas ficam na coleção `midias`: cada registro
tem `id` e `dados` (uma data URL com o conteúdo da imagem). O campo `capaId` do
evento e o campo `fotoId` do palestrante referenciam esse `id`. Assim, o JSON
exportado inclui as imagens e pode ser importado pelos demais integrantes.

Os formulários aceitam PNG, JPG e WEBP de até 2 MB, mostram uma prévia e permitem
arrastar um arquivo, substituir ou remover a imagem. A alteração só é confirmada
ao salvar o formulário. Ao editar, a prévia vem do registro salvo no banco.

A persistência está implementada em `assets/js/banco.js`. Os formulários são
conectados por `assets/js/app.js`. Em Minha Conta é possível importar e exportar
o banco, incluindo as imagens.

Na implementação, os dados iniciais devem ser importados somente na primeira
execução. Abrir uma página ou atualizar o repositório não deve sobrescrever os
registros existentes no navegador. Importações e restaurações devem ser ações
explícitas do usuário.

## Compartilhamento pelo GitHub

1. Atualize os dados fictícios em `iniciais/banco.json` ou adicione uma exportação
   de demonstração em `exportacoes`.
2. Faça commit e push dos arquivos.
3. Os demais integrantes fazem pull e usam Minha Conta para importar a versão
   desejada no navegador.

O GitHub compartilha esses arquivos. Alterações feitas no IndexedDB de um
integrante não são sincronizadas automaticamente com os demais.
