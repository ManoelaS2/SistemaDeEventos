# Esquema 1 — IndexedDB `eas`

Para começar: uma coleção é uma lista de objetos do mesmo assunto. A chave primária
identifica cada objeto; um índice facilita localizar registros e, quando marcado
como único, impede que dois registros tenham a mesma identificação. A seta na
tabela significa que um campo aponta para o ID de um registro em outra coleção.

Cada coleção usa `id` como chave primária. `assets/js/banco.js` cria o esquema
no evento `onupgradeneeded`, na versão 1.

| Coleção | Vínculos / índices únicos |
| --- | --- |
| usuarios | E-mail e CPF únicos; CPF opcional, não salvo vazio |
| eventos | organizadorId → usuarios |
| atividades | eventoId → eventos; palestranteIds → palestrantes |
| palestrantes | criadorId → usuarios |
| inscricoes | Par único usuarioId + eventoId; atividadeIds → atividades |
| credenciamentos | inscricaoId único → inscricoes |
| presencas | Par único inscricaoId + atividadeId |
| equipe | Par único usuarioId + eventoId |
| certificados | usuarioId → usuarios; eventoId → eventos |
| midias | Imagens PNG/JPEG/WEBP como data URLs, até 2 MB por upload |
| meta | Marcador de inicialização e versão |

As referências são verificadas pelos serviços. Cada operação é gravada em uma
transação; um erro desfaz a operação inteira. A versão do arquivo JSON também é 1.
