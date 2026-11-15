# Cópias exportadas do banco

Esta pasta pode receber arquivos JSON baixados pela ação Exportar banco, em Minha
Conta. Guardar uma cópia aqui e fazer commit permite compartilhar um cenário de
demonstração com a equipe. O sistema não importa todos os arquivos desta pasta
automaticamente: cada integrante escolhe o arquivo na ação Importar banco.

Use nomes que expliquem o cenário, como `evento-com-inscricoes.json`. Preserve
`versao`, `colecoes` e as referências entre IDs. Não acrescente comentários dentro
do JSON: explique o cenário em um arquivo Markdown separado. Imagens exportadas
ficam dentro de `midias`, por isso uma cópia pode ser maior que um cadastro textual.

Importar substitui todos os registros locais após confirmação; exportar apenas
lê o banco e não altera os registros. Para estudar a estrutura dos campos, consulte
`../iniciais/README.md`.
