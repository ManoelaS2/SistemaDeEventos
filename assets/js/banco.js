/**
 * CAMADA DE DADOS — regras de negócio e persistência local do EAS. IndexedDB guarda objetos em
 * coleções chamadas object stores. Cada registro possui id; campos como eventoId apontam para
 * outros registros. Não há SQL. export torna uma função disponível para outros módulos;
 * funções sem export são auxiliares internas. As telas importam este arquivo em app.js. Trata-
 * se de uma demonstração no navegador, sem sincronização com servidor.
 */
// Persistência local. Todas as alterações de um fluxo usam uma única transação.
// Coleções de negócio. meta é uma coleção separada usada para controlar a inicialização.
const nomes = ['usuarios', 'eventos', 'atividades', 'palestrantes', 'inscricoes',
  'credenciamentos', 'presencas', 'equipe', 'certificados', 'midias'
];
let conexao;
// Converte os eventos success/error do IndexedDB em uma Promise, que pode ser aguardada com await.
const pedido = req => new Promise((resolve, reject) => {
  req.onsuccess = () => resolve(req.result);
  req.onerror = () => reject(req.error);
});
// IDs aleatórios evitam reutilizar chaves; datas de histórico são gravadas em UTC no formato ISO.
const id = () => crypto.randomUUID();
const agora = () => new Date().toISOString();
// Validações falham lançando Error. O chamador mostra a mensagem; uma transação de escrita é abortada.
const exigir = (condicao, mensagem) => {
  if (!condicao) throw new Error(mensagem);
};
// Normaliza a identificação antes de comparar: remove espaços e padroniza e-mail/CPF.
const email = valor => String(valor || '').trim().toLowerCase();
const cpf = valor => String(valor || '').replace(/\D/g, '');
const sessao = 'eas-usuario';
// Para prazos, usa o calendário de São Paulo, evitando mudança de dia causada pelo fuso da máquina.
export const hoje = () => {
  const partes = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'America/Sao_Paulo',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  }).formatToParts(new Date());
  const valor = tipo => partes.find(p => p.type === tipo).value;
  return `${valor('year')}-${valor('month')}-${valor('day')}`;
};

/**
 * Transforma a senha em um hash usando PBKDF2. O salt é um valor aleatório por credencial, não
 * uma senha adicional. A comparação refaz o cálculo; o hash não é descriptografado. Isso não
 * transforma o protótipo local em autenticação de servidor.
 */
async function credencial(senha, salt = crypto.randomUUID()) {
  exigir(senha.length >= 6, 'Use uma senha com pelo menos 6 caracteres.');
  const chave = await crypto.subtle.importKey('raw', new TextEncoder().encode(senha), 'PBKDF2', false, ['deriveBits']);
  const bits = await crypto.subtle.deriveBits({
    name: 'PBKDF2',
    salt: new TextEncoder().encode(salt),
    iterations: 100000,
    hash: 'SHA-256'
  }, chave, 256);
  return {
    salt,
    hash: Array.from(new Uint8Array(bits), x => x.toString(16).padStart(2, '0')).join('')
  };
}

/**
 * Lê e, quando solicitado, grava coleções em uma única transação. Tudo é confirmado junto ou
 * desfeito em caso de erro. alterar deve ser síncrona: aguardar rede ou outras tarefas aqui
 * pode encerrar a transação antes das gravações.
 */
function transacao(db, lojas, alterar) {
  return new Promise((resolve, reject) => {
    const tx = db.transaction(lojas, alterar ? 'readwrite' : 'readonly');
    let resultado, erro;
    // Só confirma a Promise no término da transação, não no sucesso de uma gravação isolada.
    tx.oncomplete = () => resolve(resultado);
    tx.onerror = () => reject(erro || tx.error || new Error('Não foi possível salvar os dados.'));
    tx.onabort = () => reject(erro || tx.error || new Error('Operação cancelada.'));
    Promise.all(lojas.map(n => pedido(tx.objectStore(n).getAll()).then(v => [n, v])))
      .then(pares => {
        const dados = Object.fromEntries(pares);
        if (!alterar) {
          resultado = dados;
          return;
        }
        // Sem await aqui: a regra trabalha na cópia e enfileira as gravações dentro da mesma transação.
        resultado = alterar(dados);
        for (const n of lojas) {
          tx.objectStore(n).clear();
          for (const registro of dados[n]) tx.objectStore(n).put(registro);
        }
      }).catch(e => {
        erro = e;
        tx.abort();
      });
  });
}

/**
 * Abre o IndexedDB eas na versão 1. onupgradeneeded cria coleções e índices na primeira
 * abertura; o marcador meta impede importar os exemplos a cada recarregamento.
 */
async function abrir() {
  exigir(location.protocol !== 'file:', 'Abra o projeto pelo Live Server ou por um servidor HTTP local.');
  exigir('indexedDB' in window, 'Este navegador não oferece IndexedDB.');
  const req = indexedDB.open('eas', 1);
  // Este evento só executa na criação ou ao aumentar a versão do esquema. unique impede duplicidades.
  req.onupgradeneeded = () => {
    for (const nome of [...nomes, 'meta']) {
      const loja = req.result.createObjectStore(nome, {
        keyPath: 'id'
      });
      if (nome === 'usuarios') {
        loja.createIndex('email', 'email', {
          unique: true
        });
        loja.createIndex('cpf', 'cpf', {
          unique: true
        });
      }
      if (nome === 'inscricoes') loja.createIndex('usuarioEvento', ['usuarioId', 'eventoId'], {
        unique: true
      });
      if (nome === 'presencas') loja.createIndex('inscricaoAtividade', ['inscricaoId', 'atividadeId'], {
        unique: true
      });
      if (nome === 'credenciamentos') loja.createIndex('inscricao', 'inscricaoId', {
        unique: true
      });
      if (nome === 'equipe') loja.createIndex('usuarioEvento', ['usuarioId', 'eventoId'], {
        unique: true
      });
    }
  };
  const db = await pedido(req);
  db.onversionchange = () => db.close();
  const estado = await transacao(db, ['meta']);
  // Importa a demonstração uma única vez. Fazer pull do JSON não sobrescreve um banco já inicializado.
  if (!estado.meta.some(x => x.id === 'inicializado')) {
    const resposta = await fetch(new URL('../dados/iniciais/banco.json', import.meta.url));
    exigir(resposta.ok, 'Não foi possível carregar os dados iniciais.');
    const inicial = await resposta.json();
    validarArquivo(inicial);
    for (const u of inicial.colecoes.usuarios) {
      if (u.senhaInicial) {
        u.credencial = await credencial(u.senhaInicial);
        delete u.senhaInicial;
      }
    }
    await transacao(db, [...nomes, 'meta'], d => {
      if (d.meta.some(x => x.id === 'inicializado')) return;
      for (const n of nomes) d[n] = inicial.colecoes[n];
      d.meta.push({
        id: 'inicializado',
        versao: 1
      });
    });
  }
  // Bancos antigos também recebem as imagens dos exemplos, sem reimportar cadastros.
  // Se um arquivo estiver temporariamente indisponível, a aplicação continua e tenta
  // a atualização novamente na próxima abertura, pois o marcador não foi gravado.
  try {
    await aplicarMidiasPadrao(db);
  } catch (erro) {
    console.warn('Não foi possível completar as mídias da demonstração.', erro);
  }
  return db;
}
/**
 * Complemento de dados, sem alterar a versão do esquema. Só preenche campos que
 * ainda não existem nos cinco registros de exemplo. null indica uma remoção
 * intencional e é preservado, assim como qualquer foto ou capa enviada pelo usuário.
 */
async function aplicarMidiasPadrao(db) {
  const marcador = 'midias-demonstracao-v1';
  const lojas = ['eventos', 'palestrantes', 'midias', 'meta'];
  const estado = await transacao(db, lojas);
  if (estado.meta.some(m => m.id === marcador)) return;
  const endereco = new URL('../dados/iniciais/midias-padrao.json', import.meta.url);
  const resposta = await fetch(endereco);
  exigir(resposta.ok, 'Manifesto de imagens indisponível.');
  const manifesto = await resposta.json();
  const pendentes = manifesto.imagens.filter(item => {
    const registro = estado[item.colecao].find(r => r.id === item.registroId);
    return registro && !Object.hasOwn(registro, item.campo);
  });
  const preparadas = await Promise.all(pendentes.map(async item => {
    const imagem = await fetch(new URL(item.arquivo, endereco));
    exigir(imagem.ok, `Imagem indisponível: ${item.registroId}.`);
    const blob = await imagem.blob();
    const arquivo = blob.slice(0, blob.size, 'image/jpeg');
    return {...item, dados: await lerImagem(arquivo)};
  }));
  // Relê os registros dentro da transação para preservar alterações de outra aba
  // que possam ter ocorrido enquanto os arquivos estavam sendo carregados.
  await transacao(db, lojas, d => {
    if (d.meta.some(m => m.id === marcador)) return;
    for (const item of preparadas) {
      const registro = d[item.colecao].find(r => r.id === item.registroId);
      if (!registro || Object.hasOwn(registro, item.campo)) continue;
      if (!d.midias.some(m => m.id === item.midiaId)) d.midias.push({id: item.midiaId, dados: item.dados});
      registro[item.campo] = item.midiaId;
    }
    d.meta.push({id: marcador, versao: 1});
  });
}
/**
 * Reutiliza a promessa de abertura para que chamadas simultâneas compartilhem a conexão. Se a
 * abertura falhar, limpa a referência e permite uma nova tentativa.
 */
async function banco() {
  if (!conexao) conexao = abrir().catch(e => {
    conexao = null;
    throw e;
  });
  return conexao;
}
/**
 * Devolve uma cópia das coleções em uma transação somente de leitura. Modificar esse objeto na
 * tela não grava alterações no IndexedDB.
 */
export async function ler() {
  return transacao(await banco(), nomes);
}
/**
 * Consulta todas as coleções existentes, inclusive meta, usada na inicialização.
 * objectStoreNames vem da conexão: a página de consulta não precisa manter uma lista
 * paralela de tabelas. A transação é somente de leitura e retorna uma cópia dos dados.
 */
export async function lerCompleto() {
  const db = await banco();
  return transacao(db, [...db.objectStoreNames]);
}
/**
 * Executa uma regra de negócio dentro de uma transação de escrita. Os serviços usam este ponto
 * para validar e gravar alterações relacionadas de forma atômica.
 */
async function mudar(fn) {
  return transacao(await banco(), nomes, fn);
}
/**
 * Obtém a conta ativa indicada na sessão desta aba. Ao contrário de usuarioAtual, lança um
 * erro quando não existe conta conectada, bloqueando operações protegidas.
 */
function atual(d) {
  const u = d.usuarios.find(x => x.id === sessionStorage.getItem(sessao) && x.ativo !== false);
  exigir(u, 'Entre na sua conta para continuar.');
  return u;
}
/**
 * Consulta a sessão sem lançar erro para visitantes. Uma conta desativada deixa de ser
 * considerada conectada mesmo se o identificador ainda estiver salvo na aba.
 */
export function usuarioAtual(d) {
  return d.usuarios.find(x => x.id === sessionStorage.getItem(sessao) && x.ativo !== false) || null;
}
/**
 * Verifica o acesso da conta a um evento: responsável e coordenação gerenciam, enquanto outras
 * funções têm ações limitadas. A verificação também é feita nos serviços de gravação.
 */
export function pode(d, eventoId, acao = 'editar') {
  const u = usuarioAtual(d),
    e = d.eventos.find(x => x.id === eventoId);
  if (!u || !e) return false;
  if (e.organizadorId === u.id) return true;
  const membro = d.equipe.find(x => x.eventoId === eventoId && x.usuarioId === u.id);
  return membro && (membro.funcao === 'coordenacao' ||
    (acao === 'presenca' && ['credenciamento', 'monitoria'].includes(membro.funcao)) || acao === 'consultar');
}
/**
 * Confirma a permissão solicitada antes de devolver o evento. Os serviços chamam esta função
 * para não depender apenas de botões ocultos na interface.
 */
function eventoGerenciavel(d, eventoId, acao) {
  exigir(pode(d, eventoId, acao), 'Você não tem permissão para gerenciar este evento.');
  return d.eventos.find(x => x.id === eventoId);
}
/**
 * Normaliza e valida e-mail e CPF e procura duplicidades. exceto permite que uma conta
 * mantenha seus próprios dados ao editar o perfil. CPF é opcional e recebe somente verificação
 * de formato.
 */
function identidade(d, dados, exceto) {
  const mail = email(dados.email),
    doc = cpf(dados.cpf);
  exigir(mail && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(mail), 'Informe um e-mail válido.');
  exigir(!doc || /^\d{11}$/.test(doc), 'O CPF deve conter 11 dígitos.');
  exigir(!d.usuarios.some(x => x.id !== exceto && (x.email === mail || (doc && x.cpf === doc))), 'E-mail ou CPF já cadastrado.');
  return {
    email: mail,
    ...(doc ? {
      cpf: doc
    } : {})
  };
}
/**
 * Valida a senha antes de abrir a transação e cria uma conta com ID próprio. A checagem de
 * identidade e a gravação ocorrem juntas para evitar cadastros duplicados.
 */
export async function cadastrar(dados) {
  const chave = await credencial(dados.senha);
  return mudar(d => {
    exigir(dados.nome.trim(), 'Informe seu nome.');
    const u = {
      id: id(),
      nome: dados.nome.trim(),
      ...identidade(d, dados),
      credencial: chave,
      ativo: true
    };
    d.usuarios.push(u);
    return u.id;
  });
}
/**
 * Localiza a conta por e-mail ou CPF, recalcula o hash e compara as credenciais. Em caso de
 * sucesso guarda somente o ID na sessionStorage desta aba.
 */
export async function entrar(identificacao, senha) {
  const d = await ler(),
    valor = email(identificacao);
  const u = d.usuarios.find(x => x.email === valor || (x.cpf && x.cpf === cpf(valor)));
  exigir(u && u.ativo !== false && u.credencial, 'Identificação ou senha incorreta.');
  const chave = await credencial(senha, u.credencial.salt);
  exigir(chave.hash === u.credencial.hash, 'Identificação ou senha incorreta.');
  sessionStorage.setItem(sessao, u.id);
  return u.id;
}
/**
 * Remove o identificador da sessão da aba atual. Os registros do banco e a preferência de tema
 * continuam disponíveis no navegador.
 */
export function sair() {
  sessionStorage.removeItem(sessao);
}
/**
 * Atualiza nome, apelido e identificação da conta ativa. Uma senha vazia significa manter a
 * credencial existente, em vez de substituí-la por uma senha vazia.
 */
export async function salvarConta(dados) {
  const chave = dados.senha ? await credencial(dados.senha) : null;
  return mudar(d => {
    const u = atual(d);
    exigir(dados.nome.trim(), 'Informe seu nome.');
    Object.assign(u, identidade(d, {
      ...dados,
      cpf: u.cpf
    }, u.id), {
      nome: dados.nome.trim(),
      apelido: dados.apelido.trim()
    });
    if (chave) u.credencial = chave;
  });
}
/**
 * Desativa a conta e encerra sua sessão. Na exclusão também remove dados pessoais, preservando
 * o ID para não deixar inscrições e históricos sem referência.
 */
export async function encerrarConta(excluir) {
  await mudar(d => {
    const u = atual(d);
    u.ativo = false;
    if (excluir) {
      u.nome = 'Conta excluída';
      delete u.email;
      delete u.cpf;
      delete u.credencial;
      delete u.apelido;
    }
  });
  sair();
}
/**
 * Gera um código demonstrativo de quatro dígitos com validade de dez minutos. O código fica na
 * sessão desta aba; não existe envio de e-mail nesta implementação.
 */
export async function solicitarRecuperacao(mail) {
  const d = await ler(),
    u = d.usuarios.find(x => x.email === email(mail) && x.ativo !== false);
  exigir(u, 'Não há uma conta ativa com esse e-mail nesta demonstração.');
  const numeros = crypto.getRandomValues(new Uint32Array(1));
  const recuperacao = {
    usuarioId: u.id,
    email: u.email,
    codigo: String(numeros[0] % 10000).padStart(4, '0'),
    expira: Date.now() + 600000
  };
  sessionStorage.setItem('eas-recuperacao', JSON.stringify(recuperacao));
  return recuperacao;
}
/**
 * Confere código e validade antes de atualizar a credencial. Ao concluir apaga o pedido de
 * recuperação e encerra a sessão, exigindo um novo login.
 */
export async function redefinirSenha(codigo, senha) {
  const r = JSON.parse(sessionStorage.getItem('eas-recuperacao') || 'null');
  exigir(r && r.codigo === codigo && r.expira > Date.now(), 'Código inválido ou expirado.');
  const chave = await credencial(senha);
  await mudar(d => {
    const u = d.usuarios.find(x => x.id === r.usuarioId && x.ativo !== false);
    exigir(u, 'Conta indisponível.');
    u.credencial = chave;
  });
  sessionStorage.removeItem('eas-recuperacao');
  sair();
}
/**
 * Cria ou atualiza um evento após verificar responsável, datas e capacidade. Não permite
 * reduzir vagas abaixo das inscrições nem mover o período para fora das atividades existentes.
 */
export async function salvarEvento(dados, eventoId, arquivoCapa) {
  // A leitura do arquivo acontece antes da transação. O evento e sua imagem são
  // gravados juntos: se a validação do evento falhar, nenhuma imagem fica solta no banco.
  const imagem = arquivoCapa?.size ? await lerImagem(arquivoCapa) : null;
  return mudar(d => {
    const u = atual(d),
      anterior = eventoId ? eventoGerenciavel(d, eventoId) : null;
    exigir(dados.nome.trim(), 'Dê um nome ao evento antes de salvar.');
    if (dados.status === 'publicado') {
      exigir(dados.categoria && dados.inicio && dados.fim && dados.local && dados.organizador, 'Preencha os dados obrigatórios para publicar.');
    }
    exigir(!dados.inicio || !dados.fim || dados.fim >= dados.inicio, 'O término deve ser igual ou posterior ao início.');
    exigir(!dados.prazo || !dados.inicio || dados.prazo <= dados.inicio, 'O prazo de inscrição deve ser anterior ou igual ao início.');
    exigir(Number.isInteger(dados.vagas) && dados.vagas > 0, 'Informe um número inteiro de vagas maior que zero.');
    exigir(d.inscricoes.filter(x => x.eventoId === eventoId && x.status === 'confirmada').length <= dados.vagas, 'Já existem mais inscritos do que as vagas informadas.');
    const atividades = d.atividades.filter(x => x.eventoId === eventoId);
    exigir(atividades.every(a => (!dados.inicio || a.data >= dados.inicio) && (!dados.fim || a.data <= dados.fim)), 'As novas datas devem incluir todas as atividades cadastradas.');
    const e = {
      ...anterior,
      ...dados,
      id: anterior?.id || id(),
      organizadorId: anterior?.organizadorId || u.id
    };
    if (imagem) {
      e.capaId = id();
      d.midias.push({id: e.capaId, dados: imagem});
    }
    d.eventos = d.eventos.filter(x => x.id !== e.id);
    d.eventos.push(e);
    return e.id;
  });
}
/**
 * Cria um palestrante ou atualiza o cadastro do seu criador. Espalhar o objeto anterior
 * preserva campos não alterados, incluindo a foto quando nenhuma nova imagem foi escolhida.
 */
export async function salvarPalestrante(dados, palestranteId) {
  return mudar(d => {
    const u = atual(d);
    exigir(dados.nome.trim(), 'Informe o nome do palestrante.');
    const anterior = palestranteId && d.palestrantes.find(p => p.id === palestranteId);
    if (palestranteId) exigir(anterior && anterior.criadorId === u.id, 'Você não pode editar este palestrante.');
    const p = {
      ...anterior,
      ...dados,
      id: anterior?.id || id(),
      criadorId: u.id
    };
    d.palestrantes = d.palestrantes.filter(x => x.id !== p.id);
    d.palestrantes.push(p);
    return p.id;
  });
}
/**
 * Valida vínculo com o evento, horários, vagas e palestrantes. Rascunhos podem ficar
 * incompletos; atividades publicadas precisam dos dados usados na programação.
 */
export async function salvarAtividade(dados, atividadeId) {
  return mudar(d => {
    const e = eventoGerenciavel(d, dados.eventoId);
    exigir(dados.nome.trim(), 'Informe o nome da atividade.');
    if (dados.status !== 'rascunho') exigir(dados.data && dados.inicio && dados.fim && dados.tipo, 'Informe tipo, data e horários.');
    exigir(!dados.inicio || !dados.fim || dados.fim > dados.inicio, 'O término deve ser posterior ao início.');
    exigir(!dados.data || ((!e.inicio || dados.data >= e.inicio) && (!e.fim || dados.data <= e.fim)), 'A atividade deve ocorrer dentro do período do evento.');
    exigir(!dados.vagas || (Number.isInteger(dados.vagas) && dados.vagas > 0), 'Informe uma quantidade válida de vagas.');
    exigir((dados.status === 'rascunho' || dados.palestranteIds.length) && dados.palestranteIds.every(p => d.palestrantes.some(x => x.id === p)), 'Selecione pelo menos um palestrante cadastrado.');
    if (atividadeId) exigir(d.atividades.some(x => x.id === atividadeId && x.eventoId === e.id), 'Atividade não encontrada.');
    exigir(d.inscricoes.filter(x => x.status === 'confirmada' && x.atividadeIds.includes(atividadeId)).length <= (dados.vagas || Infinity), 'Já existem mais inscritos do que as vagas informadas.');
    const a = {
      ...dados,
      id: atividadeId || id()
    };
    d.atividades = d.atividades.filter(x => x.id !== a.id);
    d.atividades.push(a);
    return a.id;
  });
}
/**
 * Cria ou atualiza a inscrição única da conta no evento. Dentro da transação verifica prazo,
 * capacidade do evento e das atividades, preservando escolhas com presença registrada.
 */
export async function inscrever(eventoId, atividadeIds) {
  return mudar(d => {
    const u = atual(d),
      e = d.eventos.find(x => x.id === eventoId);
    exigir(e && e.status === 'publicado', 'Este evento não está disponível para inscrição.');
    exigir(!e.prazo || hoje() <= e.prazo, 'O prazo de inscrição terminou.');
    const anterior = d.inscricoes.find(x => x.eventoId === eventoId && x.usuarioId === u.id);
    exigir(atividadeIds.length, 'Selecione pelo menos uma atividade.');
    exigir(d.inscricoes.filter(x => x.eventoId === eventoId && x.status === 'confirmada' && x.id !== anterior?.id).length < e.vagas, 'O evento está sem vagas.');
    const ids = [...new Set(atividadeIds)];
    for (const aid of ids) {
      const a = d.atividades.find(x => x.id === aid && x.eventoId === eventoId && x.status !== 'rascunho');
      exigir(a, 'Atividade indisponível.');
      exigir(d.inscricoes.filter(x => x.status === 'confirmada' && x.id !== anterior?.id && x.atividadeIds.includes(aid)).length < (a.vagas || Infinity), `Não há vagas em ${a.nome}.`);
    }
    const comPresenca = d.presencas.filter(x => x.inscricaoId === anterior?.id);
    exigir(comPresenca.every(p => ids.includes(p.atividadeId)), 'Você não pode remover uma atividade com presença registrada.');
    const inscricao = {
      ...anterior,
      id: anterior?.id || id(),
      usuarioId: u.id,
      eventoId,
      atividadeIds: ids,
      codigo: anterior?.codigo || `EAS-${id().slice(0, 8).toUpperCase()}`,
      status: 'confirmada',
      criadaEm: anterior?.criadaEm || agora()
    };
    d.inscricoes = d.inscricoes.filter(x => x.id !== inscricao.id);
    d.inscricoes.push(inscricao);
    return inscricao.id;
  });
}
/**
 * Cancela uma inscrição pertencente à conta atual, sem apagar o histórico. Inscrições que já
 * possuem credenciamento não podem ser canceladas neste protótipo.
 */
export async function cancelar(inscricaoId) {
  return mudar(d => {
    const u = atual(d),
      i = d.inscricoes.find(x => x.id === inscricaoId && x.usuarioId === u.id);
    exigir(i, 'Inscrição não encontrada.');
    exigir(!d.credenciamentos.some(x => x.inscricaoId === i.id), 'Não é possível cancelar uma inscrição já credenciada.');
    i.status = 'cancelada';
  });
}
/**
 * Registra a chegada de uma inscrição confirmada depois de verificar a função do operador. Se
 * o registro já existe, não cria uma segunda chegada para a mesma inscrição.
 */
export async function credenciar(inscricaoId) {
  return mudar(d => {
    const i = d.inscricoes.find(x => x.id === inscricaoId && x.status === 'confirmada');
    exigir(i, 'Inscrição não encontrada.');
    eventoGerenciavel(d, i.eventoId, 'presenca');
    if (!d.credenciamentos.some(x => x.inscricaoId === i.id)) d.credenciamentos.push({
      id: id(),
      inscricaoId: i.id,
      horario: agora(),
      metodo: 'Manual',
      validadorId: atual(d).id
    });
  });
}
/**
 * Registra ou remove presença em uma atividade da inscrição. Exige credenciamento prévio e
 * protege registros usados por um certificado já emitido.
 */
export async function marcarPresenca(inscricaoId, atividadeId, presente) {
  return mudar(d => {
    const a = d.atividades.find(x => x.id === atividadeId),
      i = d.inscricoes.find(x => x.id === inscricaoId && x.status === 'confirmada');
    exigir(a && i && i.eventoId === a.eventoId && i.atividadeIds.includes(a.id), 'O participante não está inscrito nesta atividade.');
    eventoGerenciavel(d, a.eventoId, 'presenca');
    exigir(d.credenciamentos.some(x => x.inscricaoId === i.id), 'Confirme primeiro o credenciamento no evento.');
    exigir(presente || !d.certificados.some(x => x.inscricaoId === i.id), 'Um certificado já foi emitido para esta inscrição.');
    d.presencas = d.presencas.filter(x => !(x.inscricaoId === i.id && x.atividadeId === a.id));
    if (presente) d.presencas.push({
      id: id(),
      inscricaoId,
      atividadeId,
      horario: agora(),
      validadorId: atual(d).id
    });
  });
}
/**
 * Associa uma conta existente a uma função no evento. Valida horas e evita dois vínculos da
 * mesma conta no mesmo evento; o responsável já tem acesso sem ser adicionado à equipe.
 */
export async function salvarMembro(eventoId, dados, membroId) {
  return mudar(d => {
    const e = eventoGerenciavel(d, eventoId);
    const u = d.usuarios.find(x => x.email === email(dados.email) && x.ativo !== false);
    exigir(u, 'Cadastre primeiro uma conta com esse e-mail.');
    exigir(u.id !== e.organizadorId, 'O responsável pelo evento já tem acesso total.');
    exigir(['coordenacao', 'credenciamento', 'monitoria', 'consulta'].includes(dados.funcao), 'Função inválida.');
    exigir(Number.isFinite(dados.horas) && dados.horas >= 0, 'Informe uma carga horária válida.');
    exigir(!d.equipe.some(x => x.id !== membroId && x.eventoId === eventoId && x.usuarioId === u.id), 'Esse usuário já faz parte da equipe.');
    if (membroId) exigir(d.equipe.some(x => x.id === membroId && x.eventoId === eventoId), 'Membro não encontrado.');
    const m = {
      id: membroId || id(),
      eventoId,
      usuarioId: u.id,
      funcao: dados.funcao,
      horas: dados.horas,
      validado: dados.validado
    };
    d.equipe = d.equipe.filter(x => x.id !== m.id);
    d.equipe.push(m);
  });
}
/**
 * Remove somente o vínculo indicado no evento que a conta pode gerenciar. A conta do
 * integrante continua existindo para outros eventos e inscrições.
 */
export async function removerMembro(eventoId, membroId) {
  return mudar(d => {
    eventoGerenciavel(d, eventoId);
    d.equipe = d.equipe.filter(x => !(x.id === membroId && x.eventoId === eventoId));
  });
}
/**
 * Soma a duração das atividades com presença registrada e contabilização de certificado
 * habilitada. Converte horários em minutos para calcular frações de hora corretamente.
 */
export function horasInscricao(d, i) {
  return d.presencas.filter(p => p.inscricaoId === i.id).reduce((total, p) => {
    const a = d.atividades.find(x => x.id === p.atividadeId);
    if (!a || a.certificado === 'nao') return total;
    const minutos = h => Number(h.slice(0, 2)) * 60 + Number(h.slice(3, 5));
    return total + (minutos(a.fim) - minutos(a.inicio)) / 60;
  }, 0);
}
/**
 * Emite certificados depois da data final do evento, usando horas presentes ou horas validadas
 * da equipe. A verificação de registros existentes evita emissões repetidas para o mesmo tipo.
 */
export async function emitirCertificados(eventoId, equipe = false) {
  return mudar(d => {
    const e = eventoGerenciavel(d, eventoId);
    let quantidade = 0;
    exigir(e.certificados !== 'sem-certificado', 'Este evento não emite certificados.');
    exigir(e.fim && hoje() > e.fim, 'Os certificados ficam disponíveis após o encerramento do evento.');
    const aptos = equipe ? d.equipe.filter(x => x.eventoId === eventoId && x.validado && x.horas > 0).map(x => ({
        usuarioId: x.usuarioId,
        horas: x.horas
      })) :
      d.inscricoes.filter(x => x.eventoId === eventoId && x.status === 'confirmada').map(i => ({
        usuarioId: i.usuarioId,
        inscricaoId: i.id,
        horas: horasInscricao(d, i)
      })).filter(x => x.horas > 0);
    const tipo = equipe ? 'Equipe' : 'Participação';
    for (const apto of aptos) {
      if (d.certificados.some(x => x.eventoId === eventoId && x.usuarioId === apto.usuarioId && x.tipo === tipo)) continue;
      d.certificados.push({
        id: id(),
        ...apto,
        eventoId,
        tipo,
        emitidoEm: agora(),
        codigo: `CERT-${id()}`
      });
      quantidade++;
    }
    return quantidade;
  });
}
/**
 * Verifica tipo, limite de 2 MB e se o navegador consegue decodificar a imagem. A URL
 * temporária é liberada no finally, tanto em caso de sucesso quanto de erro.
 */
export async function validarImagem(arquivo) {
  exigir(arquivo?.size, 'Selecione uma imagem.');
  exigir(['image/png', 'image/jpeg', 'image/webp'].includes(arquivo.type), 'Selecione uma imagem PNG, JPG ou WEBP.');
  exigir(arquivo.size <= 2 * 1024 * 1024, 'A imagem deve ter até 2 MB.');
  const origem = URL.createObjectURL(arquivo);
  try {
    await new Promise((resolve, reject) => {
      const img = new Image();
      img.onload = resolve;
      img.onerror = () => reject(new Error('Não foi possível abrir esta imagem. Selecione um arquivo válido.'));
      img.src = origem;
    });
  } finally {
    URL.revokeObjectURL(origem);
  }
}
/**
 * Valida o arquivo e lê seu conteúdo como data URL, uma string que inclui os dados da imagem.
 * Grava esse conteúdo em midias e devolve o ID usado pelo evento ou palestrante.
 */
export async function salvarImagem(arquivo) {
  if (!arquivo?.size) return undefined;
  const dados = await lerImagem(arquivo);
  return mudar(d => {
    atual(d);
    const chave = id();
    d.midias.push({id: chave, dados});
    return chave;
  });
}
/** Prepara a imagem em memória sem gravar. Assim um serviço pode incluí-la na sua transação. */
async function lerImagem(arquivo) {
  await validarImagem(arquivo);
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(r.result);
    r.onerror = () => reject(r.error);
    r.readAsDataURL(arquivo);
  });
}
/**
 * Confere versão, coleções, IDs, tipos e referências do arquivo importado antes de substituir
 * registros. Os índices do IndexedDB também verificam unicidade durante a transação.
 */
function validarArquivo(arquivo) {
  exigir(arquivo?.versao === 1 && arquivo.colecoes, 'Formato ou versão do banco incompatível.');
  for (const n of nomes) {
    const linhas = arquivo.colecoes[n];
    exigir(Array.isArray(linhas) && linhas.every(x => x && typeof x.id === 'string' && x.id), `Coleção inválida: ${n}.`);
    exigir(new Set(linhas.map(x => x.id)).size === linhas.length, `IDs duplicados em ${n}.`);
  }
  const d = arquivo.colecoes,
    existe = (n, chave) => d[n].some(x => x.id === chave);
  const texto = valor => typeof valor === 'string';
  const data = valor => texto(valor) && /^\d{4}-\d{2}-\d{2}$/.test(valor) && !Number.isNaN(Date.parse(valor));
  const horario = valor => texto(valor) && /^([01]\d|2[0-3]):[0-5]\d$/.test(valor);
  for (const u of d.usuarios) {
    exigir(texto(u.nome) && u.nome.trim(), 'Nome de usuário inválido.');
    if (u.ativo !== false) {
      exigir(texto(u.email) && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(u.email), 'E-mail de usuário inválido.');
      exigir((texto(u.senhaInicial) && u.senhaInicial.length >= 6) || (texto(u.credencial?.salt) && /^[a-f0-9]{64}$/.test(u.credencial?.hash)), 'Credencial de usuário inválida.');
    }
    exigir(u.cpf === undefined || (texto(u.cpf) && /^\d{11}$/.test(u.cpf)), 'CPF inválido.');
  }
  for (const e of d.eventos) {
    exigir(texto(e.nome) && e.nome.trim() && texto(e.local) && texto(e.organizador), 'Dados do evento incompletos.');
    exigir(['rascunho', 'publicado'].includes(e.status) && ['publico', 'privado'].includes(e.visibilidade), 'Situação de evento inválida.');
    exigir(Number.isInteger(e.vagas) && e.vagas > 0, 'Vagas do evento inválidas.');
    exigir((!e.inicio || data(e.inicio)) && (!e.fim || data(e.fim)) && (!e.prazo || data(e.prazo)), 'Data de evento inválida.');
    exigir(e.status !== 'publicado' || (data(e.inicio) && data(e.fim) && e.fim >= e.inicio), 'Período do evento inválido.');
    exigir(!e.capaId || existe('midias', e.capaId), 'Capa de evento inexistente.');
  }
  for (const p of d.palestrantes) exigir(texto(p.nome) && (!p.fotoId || existe('midias', p.fotoId)), 'Palestrante inválido.');
  for (const a of d.atividades) {
    exigir(texto(a.nome) && ['rascunho', 'publicado'].includes(a.status), 'Atividade inválida.');
    exigir(a.status === 'rascunho' || (data(a.data) && horario(a.inicio) && horario(a.fim) && a.fim > a.inicio), 'Data ou horário de atividade inválido.');
    exigir(!a.vagas || (Number.isInteger(a.vagas) && a.vagas > 0), 'Vagas da atividade inválidas.');
  }
  for (const i of d.inscricoes) exigir(texto(i.codigo) && ['confirmada', 'cancelada'].includes(i.status), 'Inscrição inválida.');
  for (const m of d.equipe) exigir(['coordenacao', 'credenciamento', 'monitoria', 'consulta'].includes(m.funcao) && Number.isFinite(m.horas) && m.horas >= 0, 'Função ou horas de equipe inválidas.');
  for (const c of d.certificados) exigir(Number.isFinite(c.horas) && c.horas > 0 && texto(c.emitidoEm) && texto(c.codigo) && ['Participação', 'Equipe'].includes(c.tipo), 'Certificado inválido.');
  for (const e of d.eventos) exigir(existe('usuarios', e.organizadorId), 'Organizador inexistente.');
  for (const a of d.atividades) exigir(existe('eventos', a.eventoId) && Array.isArray(a.palestranteIds) && a.palestranteIds.every(p => existe('palestrantes', p)), 'Vínculo de atividade inválido.');
  for (const i of d.inscricoes) exigir(existe('usuarios', i.usuarioId) && existe('eventos', i.eventoId) && Array.isArray(i.atividadeIds) && i.atividadeIds.every(a => d.atividades.some(x => x.id === a && x.eventoId === i.eventoId)), 'Vínculo de inscrição inválido.');
  for (const c of d.credenciamentos) exigir(existe('inscricoes', c.inscricaoId), 'Credenciamento sem inscrição.');
  for (const p of d.presencas) exigir(d.inscricoes.some(i => i.id === p.inscricaoId && i.atividadeIds.includes(p.atividadeId)), 'Presença sem inscrição na atividade.');
  for (const m of d.equipe) exigir(existe('eventos', m.eventoId) && existe('usuarios', m.usuarioId), 'Membro sem usuário ou evento.');
  for (const c of d.certificados) exigir(existe('usuarios', c.usuarioId) && existe('eventos', c.eventoId), 'Certificado sem usuário ou evento.');
  for (const m of d.midias) exigir(typeof m.dados === 'string' && /^data:image\/(png|jpeg|webp);base64,[A-Za-z0-9+/=]+$/.test(m.dados), 'Imagem inválida na importação.');
}
/**
 * Monta um documento de intercâmbio com versão, data de exportação e cópia das coleções. As
 * imagens também fazem parte dos registros exportados.
 */
export async function exportar() {
  return {
    versao: 1,
    exportadoEm: agora(),
    colecoes: await ler()
  };
}
/**
 * Valida a cópia recebida, prepara credenciais de exemplos e substitui as coleções em uma
 * transação. Se algo falhar, o banco anterior permanece; o sucesso encerra a sessão atual.
 */
export async function importar(arquivo) {
  validarArquivo(arquivo);
  for (const u of arquivo.colecoes.usuarios) {
    if (u.senhaInicial) {
      u.credencial = await credencial(u.senhaInicial);
      delete u.senhaInicial;
    }
  }
  await mudar(d => {
    atual(d);
    for (const n of nomes) d[n] = arquivo.colecoes[n];
  });
  sair();
}
