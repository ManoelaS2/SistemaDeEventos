# Como estudar o projeto EAS

Comece por `index.html`, abra os arquivos CSS que ele importa e depois leia
`assets/js/componente.js`, `assets/js/app.js` e `assets/js/banco.js`, nessa ordem.
Os comentários explicam o objetivo de cada bloco e as decisões que não ficam
evidentes olhando apenas uma linha de código.

## A responsabilidade de cada parte

| Parte | O que faz | Exemplo do projeto |
| --- | --- | --- |
| HTML | Identifica o conteúdo e os controles | Formulário de cadastro |
| CSS | Define apresentação e adaptação da tela | Cores e disposição dos cartões |
| JavaScript de interface | Reage ao usuário e atualiza a página | Ler campos ao clicar em Salvar |
| JavaScript de dados | Valida regras e persiste registros | Conferir vagas antes de inscrever |
| IndexedDB | Guarda os registros naquele navegador | Eventos e suas inscrições |
| JSON | Transporta dados em texto | Banco inicial e cópias exportadas |

Uma alteração visual não significa que o banco mudou. O serviço precisa terminar
com sucesso para o registro ficar salvo. Da mesma forma, esconder um botão não
impede uma operação: o serviço também precisa verificar a permissão.

## HTML5: conteúdo com significado

- `lang="pt-BR"` informa o idioma; UTF-8 permite escrever acentos normalmente.
- `head` reúne metadados e referências; `body` reúne o conteúdo da página.
- `main` identifica o conteúdo principal. `nav` agrupa navegação; `aside` apresenta
  conteúdo complementar. Uma página tem uma região principal visível.
- `h1` identifica o título principal; outros níveis organizam subtítulos. Escolha
  o nível pelo significado, e use CSS para controlar seu tamanho visual.
- `ul` e `ol` são listas; seus itens ficam dentro de `li`, nunca ao contrário.
- `label for="campo"` identifica o controle com `id="campo"`. O placeholder é uma
  dica temporária e não substitui esse rótulo.
- `fieldset` agrupa campos e `legend` identifica esse grupo.
- `button type="submit"` envia o formulário; `type="button"` executa outra ação.
  Links `a` servem para navegar a outro destino.
- `table`, `thead`, `tbody`, `tr`, `th` e `td` descrevem dados tabulares. `scope="col"`
  relaciona um cabeçalho à sua coluna.
- `alt` descreve uma imagem informativa. Imagens decorativas podem ter `alt=""`.
- `details` e `summary` oferecem perguntas expansíveis nativas. `dialog` representa
  uma janela que pode ser aberta com `showModal()`.

Os fragmentos de `includes` são partes de uma página, por isso não precisam ter
`doctype`, `html`, `head` e `body` próprios. `componente.js` os coloca na página.
Referência: [HTML Living Standard](https://html.spec.whatwg.org/multipage/sections.html).

## CSS: como localizar uma regra

`.cartao` seleciona uma classe; `#form-cadastro` seleciona um identificador.
`var(--texto-principal)` lê uma variável de cor definida em `variaveis.css`.
Grid organiza linhas e colunas; Flexbox alinha elementos em uma direção.
`gap` separa os itens; `padding` cria espaço interno; `margin` cria espaço externo.

Os arquivos são complementares: variáveis, base, componentes, layout e estilos
específicos. A ordem de importação importa, mas a especificidade do seletor também
decide qual regra prevalece. `@media` aplica ajustes quando sua condição é atendida.
`:focus-visible` evidencia o controle usado pelo teclado; `:hover` reage ao ponteiro.

## JavaScript: termos usados nos comentários

| Termo | Explicação |
| --- | --- |
| Objeto | Conjunto de campos, como um evento com nome e data |
| Array | Lista de valores ou objetos, como as atividades do evento |
| ID | Identificador estável de um registro; não é a posição na lista |
| DOM | Representação do HTML em objetos que o JavaScript pode consultar e alterar |
| Evento | Ação detectada, como clique, alteração de campo ou envio de formulário |
| Callback | Função entregue a outra função para executar em um momento apropriado |
| Promise | Representa uma tarefa que pode terminar com sucesso ou falhar |
| async / await | Permitem aguardar essa tarefa sem bloquear toda a interface |
| try / catch / finally | Executam uma tarefa, tratam sua falha e finalizam a limpeza |
| import / export | Compartilham funções entre módulos, sem colocar tudo no escopo global |
| map | Transforma cada elemento de uma lista e cria outra lista |
| filter | Cria uma lista apenas com os elementos que atendem à condição |
| find | Obtém o primeiro elemento que atende à condição |
| some / every | Verificam se algum / todos os elementos atendem à condição |
| ... | Copia campos de um objeto ou expande elementos de uma lista |
| ?. | Acessa uma propriedade apenas se o valor anterior existir |
| ?? | Usa um valor alternativo quando o anterior é null ou undefined |

Texto de usuário deve ser inserido com `textContent` ou passar pela função `esc`
antes de entrar nos modelos HTML. Não copie valores diretamente para `innerHTML`.
O escape protege a marcação; não substitui validação de dados ou de destinos.
Referência: [Módulos JavaScript — MDN](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules).

## Acompanhe um cadastro de ponta a ponta

1. `cadastro.html` apresenta os campos e o botão de envio.
2. `acesso`, em `app.js`, conecta o formulário a um evento `submit`.
3. `formulario` cancela o envio nativo com `preventDefault` e usa a validação HTML.
4. A função de cadastro compara as duas senhas e chama `banco.cadastrar`.
5. `banco.js` prepara a credencial e valida identificação duplicada.
6. A transação grava a conta. Se falhar, os registros anteriores são preservados.
7. A interface aguarda o resultado, faz login ou mostra o erro ao usuário.

## Banco, imagens e compartilhamento

As coleções têm objetos com `id`. `eventoId`, `usuarioId` e `fotoId` apontam para
outros objetos; o JavaScript verifica essas referências. A transação confirma
alterações relacionadas juntas. Não aguarde rede ou leitura de arquivo dentro
da função síncrona de alteração: prepare esses resultados antes de gravar.

`sessionStorage` identifica a conta desta aba. `localStorage` guarda a preferência
de tema. Os registros do sistema ficam em IndexedDB; os três têm finalidades
distintas e nenhum deles sincroniza automaticamente com o GitHub.

A prévia de imagem é temporária. O formulário salvo grava o conteúdo em `midias`
e guarda o ID na capa do evento ou na foto do palestrante. Consulte também
`assets/dados/iniciais/README.md` para entender os campos do JSON.

## Arquivos antigos e recursos visuais

`assets/js/frequencia.js` e `assets/js/gerenciamento-conta.js` são exemplos antigos,
identificados no início de cada arquivo. Não são carregados pelas páginas atuais;
para alterar o funcionamento em uso, procure as funções correspondentes em `app.js`.
`assets/css/paginas/frequencia.css` também pertence à estrutura antiga.

PNG é um formato binário: não adicione comentários dentro dele. O inventário em
`assets/img/README.md` explica os recursos. SVG aceita comentários XML, mas os
dados base64 da marca continuam sendo conteúdo gráfico, não código de negócio.

## Como verificar uma alteração

Abra pelo Live Server, teste o fluxo alterado e recarregue a página para conferir
persistência. Os testes em `tests` verificam tanto a estrutura HTML quanto os
fluxos no navegador. Leia `tests/README.md` para executá-los.
