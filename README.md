# EAS — demonstração local

Para estudar o código, leia o [guia para iniciantes](docs/GUIA-PARA-INICIANTES.md).
Os HTMLs, scripts e estilos contêm comentários por responsabilidade. O JSON inicial
tem documentação própria em `assets/dados/iniciais/README.md`, pois JSON não aceita
comentários internos. Os recursos gráficos estão descritos em `assets/img/README.md`.

Aplicação em HTML, CSS e JavaScript com persistência no IndexedDB do navegador.
Use dados fictícios: autenticação e permissões são simulações locais, sem backend.

## Executar

Abra a raiz no Live Server ou execute `py -3 -m http.server 8000 --bind 127.0.0.1`
e acesse `http://127.0.0.1:8000`. Mantenha o mesmo endereço e porta para acessar
o mesmo banco. Abrir os HTMLs por `file://` não carrega os componentes e módulos.

## Contas iniciais

Para visualizar todas as coleções e registros locais em tabelas simples, abra
`consultar-banco.html` pelo mesmo servidor e navegador usados no sistema. A página
não exige login e permite apenas consulta; Atualizar dados relê o banco. Objetos e
listas aparecem como JSON e conteúdos extensos podem ser expandidos.

| Perfil | E-mail | Senha |
| --- | --- | --- |
| Organizador | organizador@eas.test | Demo123! |
| Participante | participante@eas.test | Demo123! |

As senhas fictícias do JSON são convertidas em hashes PBKDF2 com salt antes de
gravar no IndexedDB. A sessão usa sessionStorage. Contas novas também podem criar
eventos; o criador é o responsável pelo evento.

## Fluxos disponíveis

- Cadastro, login por e-mail ou CPF, saída e edição da conta.
- Recuperação local com código exibido na tela, validade de 10 minutos e nova senha.
- Catálogo com busca; criação/edição de eventos, rascunho e publicação.
- As telas de eventos têm apenas contêineres HTML. Catálogo, categorias, capas,
  detalhes, agenda e painel são preenchidos por JavaScript a partir do IndexedDB.
  Use Criar evento, escolha uma imagem e publique com visibilidade Público para
  aparecer no catálogo. Rascunhos e eventos privados ficam fora da lista pública.
  O evento e sua nova capa são gravados juntos, em uma única transação.
- Cadastro de palestrantes e imagens; criação/edição de atividades e programação.
- Inscrição, atualização de atividades e cancelamento antes do credenciamento.
- Credenciamento manual por nome, e-mail, CPF ou código; presença por atividade.
- Equipe por evento com funções e validação de horas.
- Certificados após a data final do evento, com base nas horas presentes ou nas
  horas validadas da equipe. Download em HTML, imprimível como PDF.
- Exportação e importação do banco na página Minha Conta.

O evento de demonstração encerrado permite testar a emissão imediatamente.
Para eventos novos, a emissão só é liberada no dia seguinte ao término.
O leitor de QR e o login Google não estão integrados. Eventos pagos apenas
demonstram a classificação; não há cobrança nem confirmação de pagamento.

## Compartilhar os dados

O banco inicial em `assets/dados/iniciais/banco.json` é importado somente uma vez.
As três capas e os dois retratos ilustrativos de demonstração já fazem parte dele.
Ao recarregar um banco antigo, o sistema complementa apenas os campos de imagem
ausentes dos registros de exemplo, sem substituir uploads ou remoções intencionais.
Os arquivos e os prompts estão em `assets/img/demonstracao`.
Fazer pull não apaga os registros existentes. Em Minha Conta, exporte o JSON,
versione a cópia em `assets/dados/exportacoes` e compartilhe pelo GitHub.
Use Importar banco na mesma página para carregar outra cópia. A substituição
exige confirmação, é atômica e encerra a sessão. Limite: 20 MB por arquivo.
As imagens fazem parte da exportação. Não há sincronização online.

## Conferir a demonstração

1. Entre como participante, inscreva-se no evento aberto e confira Minhas inscrições.
2. Entre como organizador na mesma aba (ou em outra aba) e abra o credenciamento.
3. Confirme a chegada e marque a presença em Frequência.
4. Recarregue as páginas e confira a persistência e os contadores.
5. No evento encerrado, emita os certificados; entre como participante e baixe o documento.
6. Exporte o banco e importe a cópia para conferir a restauração.

O projeto usa ícones e fontes de CDN. A lógica e os dados não dependem de APIs
externas; os arquivos do site precisam estar sendo servidos por HTTP.
