# Entendendo o banco inicial

`banco.json` é um arquivo JSON estrito. Não aceita comentários `//` ou `/* */`,
aspas simples nem vírgula depois do último item. Por isso a explicação fica aqui,
sem acrescentar campos fictícios ou quebrar o importador.

`versao` identifica o formato de intercâmbio, atualmente 1. `colecoes` agrupa listas
de registros. Uma lista vazia (`[]`) significa que não há exemplos daquela coleção.
Cada registro tem `id`, uma string que permite encontrá-lo sem depender da ordem.

| Coleção | Campos principais e seu significado |
| --- | --- |
| usuarios | `nome`: identificação visual; `email` e `cpf`: acesso; `ativo`: permite login. `senhaInicial` é apenas a senha fictícia de demonstração e é transformada em `credencial` antes de gravar. |
| eventos | `organizadorId`: conta responsável; `nome`, `descricao`, `organizador` e `local`: apresentação; `inicio`, `fim` e `prazo`: calendário; `vagas`: capacidade; `status`: rascunho ou publicado; `visibilidade`: público ou privado; `categoria`, `modalidade`, `taxa` e `certificados`: configurações; `capaId`: referência de imagem opcional. |
| atividades | `eventoId`: evento de origem; `palestranteIds`: lista de IDs; `data`, `inicio` e `fim`: agenda; `nome`, `tipo`, `local` e `descricao`: apresentação; `modalidade`, `vagas`, `exigeInscricao`, `certificado` e `status`: configurações. |
| palestrantes | `criadorId`: conta que pode editar; `nome`, `cargo`, `instituicao`, `email`, `biografia`, `site` e `linkedin`: perfil; `fotoId`: imagem opcional. |
| inscricoes | `usuarioId` e `eventoId`: quem participa de qual evento; `atividadeIds`: escolhas; `codigo`: consulta; `status`: confirmada ou cancelada; `criadaEm`: histórico. |
| credenciamentos | `inscricaoId`: inscrição cuja chegada foi confirmada; `horario`, `metodo` e `validadorId`: quando, como e por quem foi registrada. |
| presencas | `inscricaoId` e `atividadeId`: vínculo da presença; `horario` e `validadorId`: histórico da confirmação. |
| equipe | `usuarioId` e `eventoId`: vínculo; `funcao`: nível de acesso; `horas`: carga horária; `validado`: informa se a organização confirmou as horas. |
| certificados | `usuarioId`, `eventoId` e eventualmente `inscricaoId`: vínculos; `tipo`: participação ou equipe; `horas`: carga horária; `emitidoEm` e `codigo`: emissão. |
| midias | `dados`: conteúdo PNG/JPEG/WEBP em data URL. Seu `id` é usado por `capaId` ou `fotoId`. O arquivo exportado inclui esse conteúdo. |

Datas de calendário usam `AAAA-MM-DD`; horários de atividade usam `HH:MM`.
Registros de histórico usam a data completa ISO em UTC, por exemplo
`2026-11-10T17:00:00.000Z`. A tela faz a formatação para apresentar ao usuário.

Os exemplos incluem um evento encerrado com presença registrada, um evento aberto
e um rascunho. Eles permitem estudar vários estados sem preencher tudo do zero.
Não altere o ID de um evento sem atualizar também as atividades e inscrições que
apontam para ele. O importador recusa referências inconsistentes.

Este arquivo é importado apenas ao inicializar um banco novo. Fazer pull de uma
alteração não substitui o banco já criado. Para carregar outra cópia, use Importar
banco em Minha Conta, confirmando a substituição dos registros locais.
