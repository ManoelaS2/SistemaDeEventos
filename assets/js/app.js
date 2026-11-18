/**
 * CAMADA DE APRESENTAÇÃO — liga os elementos HTML às regras de banco.js. DOM é a representação
 * da página em objetos: querySelector procura elementos; addEventListener reage às ações do
 * usuário. async/await permite aguardar o banco sem bloquear a interface. Este módulo é
 * compartilhado por todas as páginas; iniciar escolhe a função adequada pelo nome do arquivo
 * aberto. As funções de tela não substituem as validações dos serviços de persistência.
 */
import * as banco from "./banco.js";

// Impede a navegação nativa dos formulários, inclusive enquanto o banco carrega.
document.addEventListener("submit", (e) => {
  if (e.target.method !== "dialog") e.preventDefault();
});
// $ procura um elemento; $$ devolve uma lista real para usar map e filter.
const $ = (s, raiz = document) => raiz.querySelector(s);
const $$ = (s, raiz = document) => [...raiz.querySelectorAll(s)];
// Protege as strings inseridas nos modelos HTML. Não use innerHTML com texto de usuário sem escapar.
const esc = (v) =>
  String(v ?? "").replace(
    /[&<>"']/g,
    (c) =>
      ({
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;",
      })[c],
  );
// A URL indica qual tela montar e qual evento foi selecionado; encodeURIComponent protege parâmetros.
const pagina = location.pathname.split("/").pop() || "index.html";
const parametros = new URLSearchParams(location.search);
const url = (p, evento) =>
  p + (evento ? `?evento=${encodeURIComponent(evento)}` : "");
const dataBR = (valor) =>
  valor
    ? new Date(valor.slice(0, 10) + "T12:00:00").toLocaleDateString("pt-BR")
    : "A definir";
const horaBR = (valor) =>
  new Date(valor).toLocaleTimeString("pt-BR", {
    hour: "2-digit",
    minute: "2-digit",
  });
const campo = (id) => document.getElementById(id)?.value.trim() || "";
// Estado em memória da tela: atualizar relê os registros persistidos; estas variáveis não são o banco.
let dados, usuario, evento;

/**
 * Exibe avisos dentro da página ou do formulário indicado. O texto é atribuído com
 * textContent; role=status e aria-live permitem que leitores de tela anunciem a alteração.
 */
function mensagem(texto, erro = false, destino = $("main")) {
  if (!destino) return;
  let p = $(".eas-mensagem", destino);
  if (!p) {
    p = document.createElement("p");
    p.className = "eas-mensagem";
    p.setAttribute("role", "status");
    p.setAttribute("aria-live", "polite");
    destino.prepend(p);
  }
  p.textContent = texto;
  p.classList.toggle("eas-mensagem--erro", erro);
  p.scrollIntoView({
    block: "nearest",
  });
}
/**
 * Liga um clique a uma operação. Desativa o controle enquanto aguarda a tarefa, mostra erros
 * na tela e reativa o controle no finally, mesmo quando a operação falha.
 */
function acao(elemento, fn) {
  elemento?.addEventListener("click", async (e) => {
    e.preventDefault();
    elemento.disabled = true;
    try {
      await fn(e);
    } catch (erro) {
      mensagem(erro.message, true);
    } finally {
      elemento.disabled = false;
    }
  });
}
/**
 * Centraliza o envio dos formulários. reportValidity usa as regras HTML, como required; a
 * marca salvando evita dois envios simultâneos. formNoValidate permite salvar rascunhos.
 */
function formulario(seletor, fn) {
  const form = $(seletor);
  if (!form) return;
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    if (form.dataset.salvando) return;
    if (!e.submitter?.formNoValidate && !form.reportValidity()) return;
    form.dataset.salvando = "sim";
    const botoes = $$('button[type="submit"]', form);
    botoes.forEach((b) => (b.disabled = true));
    try {
      await fn(e);
    } catch (erro) {
      mensagem(erro.message, true, form);
    } finally {
      delete form.dataset.salvando;
      botoes.forEach((b) => (b.disabled = false));
    }
  });
}
/**
 * Lê uma fotografia atual dos registros no banco e identifica a conta desta aba. Estas
 * variáveis alimentam a montagem das telas; alterar o HTML sozinho não grava nada.
 */
async function atualizar() {
  dados = await banco.ler();
  usuario = banco.usuarioAtual(dados);
}
/**
 * Cria um botão de ação com type=button para não enviar um formulário por acidente. Reutiliza
 * o tratamento de clique e de erros definido em acao.
 */
function botao(texto, fn, classe = "btn-segundario") {
  const b = document.createElement("button");
  b.type = "button";
  b.className = classe;
  b.textContent = texto;
  acao(b, fn);
  return b;
}
/**
 * Produz a mensagem mostrada quando uma consulta não encontra registros. esc transforma
 * caracteres especiais em texto antes de inserir a mensagem no HTML.
 */
function vazio(texto) {
  return `<p class="eas-vazio">${esc(texto)}</p>`;
}
/**
 * Recebe o identificador de uma imagem e procura o conteúdo na coleção midias. Retorna uma
 * string vazia quando a referência não existe, permitindo mostrar o espaço reservado.
 */
function foto(chave) {
  return dados.midias.find((x) => x.id === chave)?.dados || "";
}
/**
 * Monta uma imagem pequena a partir do banco. O texto alternativo identifica o conteúdo para
 * leitores de tela; loading=lazy adia o carregamento até ela se aproximar da área visível.
 */
function miniatura(chave, nome) {
  const origem = foto(chave);
  return origem
    ? `<img class="eas-miniatura" src="${esc(origem)}" alt="${esc(nome)}" loading="lazy">`
    : "";
}
/**
 * Prepara a seleção, a prévia, a troca e a remoção de uma imagem. A prévia é temporária: o
 * conteúdo só entra no banco quando o usuário salva o formulário.
 */
function uploadImagem(id, chaveAtual) {
  const input = document.getElementById(id),
    area = input.parentElement;
  const previa = document.createElement("div");
  previa.className = "eas-upload-previa";
  const img = document.createElement("img");
  img.alt =
    id === "imagem-capa"
      ? "Prévia da capa do evento"
      : "Prévia da foto do palestrante";
  const estado = document.createElement("p");
  estado.setAttribute("role", "status");
  const remover = botao("Remover imagem", () => {
    sequencia++;
    input.value = "";
    input.dataset.remover = "sim";
    img.removeAttribute("src");
    previa.hidden = true;
    estado.textContent =
      "Imagem removida da seleção. Salve o formulário para confirmar.";
  });
  previa.append(img, remover);
  area.append(previa, estado);
  // URLs de objeto apontam para arquivos em memória; sequencia descarta uma prévia antiga se outra seleção chegou antes.
  let origem,
    sequencia = 0;
  if (foto(chaveAtual)) {
    img.src = foto(chaveAtual);
    estado.textContent =
      "Imagem salva no banco. Selecione outra para substituir.";
  } else previa.hidden = true;
  input.addEventListener("change", async () => {
    const arquivo = input.files[0],
      atual = ++sequencia;
    if (!arquivo) return;
    estado.textContent = "Carregando imagem…";
    try {
      await banco.validarImagem(arquivo);
      if (atual !== sequencia) return;
      if (origem) URL.revokeObjectURL(origem);
      origem = URL.createObjectURL(arquivo);
      img.src = origem;
      previa.hidden = false;
      delete input.dataset.remover;
      estado.textContent = `${arquivo.name} · ${Math.ceil(arquivo.size / 1024)} KB. Salve o formulário para gravar.`;
    } catch (erro) {
      if (atual === sequencia) {
        input.value = "";
        estado.textContent = erro.message;
      }
    }
  });
  area.addEventListener("dragover", (e) => {
    e.preventDefault();
    area.classList.add("eas-arrastando");
  });
  area.addEventListener("dragleave", () =>
    area.classList.remove("eas-arrastando"),
  );
  area.addEventListener("drop", (e) => {
    e.preventDefault();
    area.classList.remove("eas-arrastando");
    if (!e.dataTransfer.files.length) return;
    const transferencia = new DataTransfer();
    transferencia.items.add(e.dataTransfer.files[0]);
    input.files = transferencia.files;
    input.dispatchEvent(
      new Event("change", {
        bubbles: true,
      }),
    );
  });
  window.addEventListener(
    "pagehide",
    () => {
      if (origem) URL.revokeObjectURL(origem);
    },
    {
      once: true,
    },
  );
}
/**
 * Relaciona os IDs dos palestrantes aos seus cadastros e monta as figuras com foto e legenda.
 * Registros não encontrados são descartados para não quebrar a página.
 */
function perfis(ids) {
  return ids
    .map((id) => dados.palestrantes.find((p) => p.id === id))
    .filter(Boolean)
    .map(
      (p) =>
        `<figure class="perfil">${foto(p.fotoId) ? `<img class="perfil-foto" src="${esc(foto(p.fotoId))}" alt="${esc(p.nome)}">` : '<span class="perfil-foto perfil-foto--palestrante" aria-hidden="true"></span>'}<figcaption class="perfil-nome">${esc(p.nome)}</figcaption></figure>`,
    )
    .join("");
}
/**
 * Interrompe o fluxo se não houver evento selecionado. Lançar Error permite que o tratamento
 * central apresente uma mensagem compreensível ao usuário.
 */
function exigirEvento() {
  if (!evento)
    throw new Error("Selecione um evento disponível no painel para continuar.");
}
/**
 * Preenche um campo pelo seu id, sem falhar quando ele não existe nesta página. O operador ??
 * troca apenas null ou undefined por uma string vazia.
 */
function colocar(id, valor) {
  const el = document.getElementById(id);
  if (el) el.value = valor ?? "";
}
/**
 * Monta um link de navegação. Texto e endereço passam por esc para que caracteres dos
 * registros não sejam interpretados como marcação HTML.
 */
function link(texto, destino, classe = "btn-segundario") {
  return `<a class="${classe}" href="${esc(destino)}">${esc(texto)}</a>`;
}
/**
 * Descobre quais eventos a conta pode consultar e monta o seletor do painel. O parâmetro
 * evento da URL mantém a seleção ao navegar entre as telas administrativas.
 */
function painelContexto() {
  const painel = $("#painel-adm");
  if (!painel) return;
  const gerenciaveis = dados.eventos.filter((e) =>
    banco.pode(dados, e.id, "consultar"),
  );
  const idPedido = parametros.get("evento");
  evento =
    gerenciaveis.find((e) => e.id === idPedido) ||
    (!idPedido ? gerenciaveis[0] : null);
  if (idPedido && !evento && pagina !== "criar-evento.html")
    throw new Error("Evento não encontrado ou acesso não autorizado.");
  const label = document.createElement("label");
  label.className = "eas-contexto";
  label.textContent = "Evento selecionado";
  const select = document.createElement("select");
  select.id = "eas-evento";
  select.innerHTML = gerenciaveis.length
    ? gerenciaveis
        .map(
          (e) =>
            `<option value="${esc(e.id)}" ${e.id === evento?.id ? "selected" : ""}>${esc(e.nome)}</option>`,
        )
        .join("")
    : '<option value="">Crie seu primeiro evento</option>';
  select.addEventListener(
    "change",
    () => (location.href = url(pagina, select.value)),
  );
  label.append(select);
  painel.prepend(label);
  $$("a", painel).forEach((a) => {
    const alvo = a.getAttribute("href").split("?")[0].replace(/^\//, "");
    a.href = url(alvo, alvo === "criar-evento.html" ? null : evento?.id);
  });
}
/**
 * Adapta o cabeçalho à sessão atual. Visitantes recebem opções de acesso; contas conectadas
 * recebem links de inscrições, organização e saída. Esconder links não substitui as regras do
 * banco.
 */
function cabecalho() {
  const nav = $("#main-nav");
  if (!nav) return;
  $$(".home-only, .login-only", nav).forEach((el) => el.remove());
  const bloco = document.createElement("span");
  bloco.className = "eas-nav";
  bloco.innerHTML = usuario
    ? `${link("Meus eventos", "meus-eventos.html", "")}${link("Organizar eventos", "gerenciamento-evento.html", "")}${link("Certificados", "certificados.html", "")}${link(usuario.apelido || usuario.nome, "gerenciamento-conta.html", "")}`
    : `${link("Criar conta", "cadastro.html", "")}${link("Entrar", "login.html", "")}`;
  if (usuario)
    bloco.append(
      botao(
        "Sair",
        () => {
          banco.sair();
          location.href = "index.html";
        },
        "eas-sair",
      ),
    );
  nav.prepend(bloco);
  const local = $(".nav-location");
  if (local) {
    local.textContent = "Todos os lugares";
    local.title = "Busca por local disponível na página inicial";
    acao(local, () => (location.href = "index.html#eventos"));
  }
}
/**
 * Aceita apenas um destino relativo no formato usado pelas páginas do projeto. Assim, o
 * retorno após o login não aponta para um site externo informado pela URL.
 */
function retornoLogin() {
  const valor = parametros.get("retorno");
  return valor && /^[a-z-]+\.html(?:\?[^#]*)?$/.test(valor)
    ? valor
    : "index.html";
}
/**
 * Conecta os formulários de cadastro, login e recuperação aos serviços do banco. O código de
 * recuperação é demonstrativo e aparece na tela; nenhum e-mail é enviado.
 */
function acesso() {
  formulario("#login-form", async () => {
    await banco.entrar(campo("usuario"), campo("senha"));
    location.href = retornoLogin();
  });
  if (pagina === "login.html") {
    const p = document.createElement("p");
    p.className = "texto-auxiliar eas-demo";
    p.textContent =
      "Contas de demonstração: organizador@eas.test ou participante@eas.test. Senha: Demo123!";
    $("#login-form").after(p);
  }
  formulario("#form-cadastro", async () => {
    if (campo("cadastro-senha") !== campo("cadastro-confirmar-senha"))
      throw new Error("As senhas não coincidem.");
    await banco.cadastrar({
      nome: campo("cadastro-nome"),
      email: campo("cadastro-identificacao"),
      cpf: campo("cadastro-cpf"),
      senha: campo("cadastro-senha"),
    });
    await banco.entrar(
      campo("cadastro-identificacao"),
      campo("cadastro-senha"),
    );
    location.href = "index.html";
  });
  formulario("#form-recuperar-senha", async () => {
    await banco.solicitarRecuperacao(campo("campo-email"));
    location.href = "verificar-codigo.html";
  });
  if (pagina === "verificar-codigo.html") {
    const r = JSON.parse(sessionStorage.getItem("eas-recuperacao") || "null");
    if (!r) {
      location.href = "recuperar-senha.html";
      return;
    }
    $(".email-enviado").textContent = r.email;
    mensagem(
      `Demonstração local: use o código ${r.codigo}. Ele expira em 10 minutos. Nenhum e-mail é enviado.`,
    );
    const grupo = document.createElement("div");
    grupo.className = "campo-formulario";
    grupo.innerHTML =
      '<label for="nova-senha">Nova senha</label><input id="nova-senha" type="password" minlength="6" autocomplete="new-password" required><label for="confirmar-nova-senha">Confirme a nova senha</label><input id="confirmar-nova-senha" type="password" minlength="6" autocomplete="new-password" required>';
    $('#form-verificar-codigo button[type="submit"]').before(grupo);
    const digitos = $$(".campo-codigo");
    digitos.forEach((el, i) => {
      el.addEventListener("input", () => {
        el.value = el.value.replace(/\D/g, "").slice(-1);
        if (el.value) digitos[i + 1]?.focus();
      });
      el.addEventListener("paste", (e) => {
        const valor = e.clipboardData
          .getData("text")
          .replace(/\D/g, "")
          .slice(0, 4);
        if (valor.length === 4) {
          e.preventDefault();
          digitos.forEach((d, j) => (d.value = valor[j]));
        }
      });
    });
    formulario("#form-verificar-codigo", async () => {
      if (campo("nova-senha") !== campo("confirmar-nova-senha"))
        throw new Error("As senhas não coincidem.");
      await banco.redefinirSenha(
        digitos.map((d) => d.value).join(""),
        campo("nova-senha"),
      );
      location.href = "login.html";
    });
  }
}
/**
 * Consulta os eventos públicos publicados e monta catálogo, busca, categorias e carrossel.
 * Filtrar a lista apenas muda a apresentação; não altera os eventos salvos.
 */
function home() {
  const grade = $(".grade--eventos"),
    busca = $(".header-search input");
  let categoria = "",
    destaque = 0;
  const eventos = dados.eventos.filter(
    (e) => e.status === "publicado" && e.visibilidade === "publico",
  );
  /**
   * Reconstrói os itens visíveis a partir dos registros e filtros atuais. Esta função é local
   * à tela: é chamada novamente quando o usuário muda uma busca ou seleção.
   */
  function desenhar() {
    const termo = (busca?.value || "").toLocaleLowerCase("pt-BR");
    const lista = eventos.filter(
      (e) =>
        (!categoria || e.categoria === categoria) &&
        `${e.nome} ${e.local} ${e.descricao}`
          .toLocaleLowerCase("pt-BR")
          .includes(termo),
    );
    grade.innerHTML =
      lista
        .map(
          (e) =>
            `<a class="cartao cartao--evento" href="${url("evento.html", e.id)}"><div class="cartao-imagem">${foto(e.capaId) ? `<img class="eas-capa" src="${esc(foto(e.capaId))}" alt="">` : `<span>${esc(e.nome)}</span>`}<span class="etiqueta etiqueta--evento">${e.taxa === "pago" ? "Pago (simulação)" : "Gratuito"}</span></div><div class="cartao-conteudo"><h3 class="cartao-titulo">${esc(e.nome)}</h3><p class="cartao-descricao">${esc(e.local)}</p><span class="cartao-legenda">${dataBR(e.inicio)} a ${dataBR(e.fim)}</span><strong class="cartao-dado">${e.prazo && e.prazo < banco.hoje() ? "Inscrições encerradas" : "Inscrições abertas"}</strong></div></a>`,
        )
        .join("") || vazio("Nenhum evento encontrado.");
  }
  busca?.addEventListener("input", desenhar);
  $(".header-search")?.addEventListener("submit", (e) => {
    e.preventDefault();
    desenhar();
    grade.scrollIntoView();
  });
  // Só oferece categorias que possuem eventos públicos cadastrados no banco.
  const nomesCategorias = {
    tecnologia: "Tecnologia",
    educacao: "Educação",
    ciencia: "Ciência e pesquisa",
    cultura: "Cultura",
    empreendedorismo: "Empreendedorismo",
    esportes: "Esportes",
    outros: "Outros",
  };
  $(".grade--categorias").innerHTML =
    [...new Set(eventos.map((e) => e.categoria))]
      .map(
        (c) =>
          `<button type="button" class="cartao cartao--categoria" data-categoria="${esc(c)}" aria-pressed="false">${esc(nomesCategorias[c] || c)}</button>`,
      )
      .join("") ||
    vazio("As categorias aparecerão quando houver eventos publicados.");
  $$(".cartao--categoria").forEach((a) =>
    acao(a, () => {
      categoria = categoria === a.dataset.categoria ? "" : a.dataset.categoria;
      $$(".cartao--categoria").forEach((b) =>
        b.setAttribute(
          "aria-pressed",
          String(b.dataset.categoria === categoria),
        ),
      );
      desenhar();
      grade.scrollIntoView();
    }),
  );
  $$(".secao-cabecalho .link-destaque, .categorias-proximo").forEach((a) =>
    acao(a, () => {
      categoria = "";
      $$(".cartao--categoria").forEach((b) =>
        b.setAttribute("aria-pressed", "false"),
      );
      if (busca) busca.value = "";
      desenhar();
      grade.scrollIntoView();
    }),
  );
  /**
   * Atualiza o evento em destaque no carrossel, incluindo a capa armazenada no banco. Se não
   * houver eventos disponíveis, apresenta uma mensagem em vez de um link inválido.
   */
  function mostrar() {
    const e = eventos[destaque],
      el = $(".destaque-imagem");
    if (!e) {
      el.textContent = "Novos eventos em breve";
      el.removeAttribute("href");
      return;
    }
    el.href = url("evento.html", e.id);
    el.setAttribute("aria-label", `Conhecer ${e.nome}`);
    // O nome vem antes da capa na estrutura HTML e permanece em uma área própria.
    // Assim a legibilidade do título não depende das cores ou dos detalhes da imagem.
    el.innerHTML = `<div class="destaque-evento-cabecalho"><h2 class="destaque-evento-nome">${esc(e.nome)}</h2><p class="destaque-evento-meta">${esc(e.local)} · ${dataBR(e.inicio)}</p></div><div class="destaque-capa">${foto(e.capaId) ? `<img class="eas-capa" src="${esc(foto(e.capaId))}" alt="Capa de ${esc(e.nome)}">` : "<p>Evento sem imagem de capa.</p>"}</div>`;
  }
  $$(".botao-icone--carrossel").forEach((b, i) =>
    acao(b, () => {
      if (eventos.length)
        destaque = (destaque + (i ? 1 : -1) + eventos.length) % eventos.length;
      mostrar();
    }),
  );
  desenhar();
  mostrar();
  grade.setAttribute("aria-busy", "false");
  $$(".botao-icone--carrossel").forEach(
    (b) => (b.disabled = eventos.length < 2),
  );
}
/**
 * Preenche a página do evento selecionado com descrição, capa e palestrantes. A inscrição
 * existente determina se o botão oferece uma nova inscrição ou a edição dela.
 */
function detalhes() {
  exigirEvento();
  $(".cartao--detalhe-evento").hidden = false;
  document.title = `${evento.nome} | EAS`;
  $("#event-detail-name").textContent = evento.nome;
  $(".detalhe-evento-texto").textContent =
    `${evento.descricao || "Conheça a programação deste evento."}\n${dataBR(evento.inicio)} a ${dataBR(evento.fim)} · ${evento.local} · ${evento.organizador}`;
  $(".detalhe-evento-capa").innerHTML = foto(evento.capaId)
    ? `<img class="eas-capa" src="${esc(foto(evento.capaId))}" alt="Capa de ${esc(evento.nome)}">`
    : vazio("Evento sem imagem de capa.");
  const atividades = dados.atividades.filter(
    (a) => a.eventoId === evento.id && a.status !== "rascunho",
  );
  $(".detalhe-evento-palestrantes").innerHTML = perfis([
    ...new Set(atividades.flatMap((a) => a.palestranteIds)),
  ]);
  const inscrito = dados.inscricoes.some(
    (i) =>
      i.eventoId === evento.id &&
      i.usuarioId === usuario?.id &&
      i.status === "confirmada",
  );
  const b = $(".grupo-acoes--evento .btn-confirmacao");
  b.href = url(
    inscrito
      ? "editar-atividade-evento.html"
      : "inscricao-atividade-evento.html",
    evento.id,
  );
  b.textContent = inscrito ? "Atualizar inscrição" : "Inscrever-se";
  $(".grupo-acoes--evento").insertAdjacentHTML(
    "beforeend",
    link("Ver programação", url("programacao-evento.html", evento.id)),
  );
}
/**
 * Monta as atividades do evento e recupera as escolhas da conta. As opções lotadas ficam
 * indisponíveis; o serviço verifica as vagas novamente no momento da gravação.
 */
function inscricao() {
  exigirEvento();
  const anterior = dados.inscricoes.find(
    (i) => i.eventoId === evento.id && i.usuarioId === usuario.id,
  );
  const atividades = dados.atividades.filter(
    (a) => a.eventoId === evento.id && a.status !== "rascunho",
  );
  $("h1").textContent =
    `${anterior?.status === "confirmada" ? "Atualizar inscrição" : "Inscrever-se"}: ${evento.nome}`;
  $(".lista-opcoes").innerHTML =
    atividades
      .map((a) => {
        const ocupadas = dados.inscricoes.filter(
          (i) => i.status === "confirmada" && i.atividadeIds.includes(a.id),
        ).length;
        const marcado =
          anterior?.status === "confirmada" &&
          anterior.atividadeIds.includes(a.id);
        return `<label class="checkbox-label opcao-selecao"><input class="checkbox-input" type="checkbox" name="atividades" value="${esc(a.id)}" ${marcado ? "checked" : ""} ${!marcado && a.vagas && ocupadas >= a.vagas ? "disabled" : ""}><span class="opcao-info"><strong class="opcao-titulo">${esc(a.nome)}</strong><span>${dataBR(a.data)} · ${esc(a.inicio)}–${esc(a.fim)} · ${esc(a.local)}</span><span>${a.vagas ? `${Math.max(0, a.vagas - ocupadas)} vagas disponíveis` : "Sem limite de vagas"}</span></span></label>`;
      })
      .join("") || vazio("Este evento ainda não tem atividades disponíveis.");
  $(".painel-palestrantes").innerHTML = perfis([
    ...new Set(atividades.flatMap((a) => a.palestranteIds)),
  ]);
  formulario("#form-inscricao", async () => {
    await banco.inscrever(
      evento.id,
      $$('[name="atividades"]:checked').map((el) => el.value),
    );
    location.href = "meus-eventos.html";
  });
  if (!atividades.length)
    $('#form-inscricao button[type="submit"]').disabled = true;
}
/**
 * Mostra somente as inscrições da conta atual, incluindo seus códigos e situações.
 * Cancelamentos exigem confirmação e passam pelas regras do banco antes de atualizar a lista.
 */
function meusEventos() {
  const conteudo = $("#meus-eventos");
  const lista = dados.inscricoes.filter((i) => i.usuarioId === usuario.id);
  conteudo.innerHTML =
    lista
      .map((i) => {
        const e = dados.eventos.find((e) => e.id === i.eventoId);
        return `<article class="cartao eas-registro"><h2>${esc(e.nome)}</h2><p>${dataBR(e.inicio)} · ${esc(e.local)}</p><p>Inscrição ${esc(i.codigo)} · ${esc(i.status)}</p><p>${i.atividadeIds.map((id) => esc(dados.atividades.find((a) => a.id === id)?.nome)).join(" · ")}</p><div class="grupo-acoes">${link("Ver evento", url("evento.html", e.id))}${link("Alterar atividades", url("editar-atividade-evento.html", e.id))}${i.status === "confirmada" ? `<button type="button" class="btn-segundario" data-cancelar="${esc(i.id)}">Cancelar inscrição</button>` : ""}</div></article>`;
      })
      .join("") || vazio("Você ainda não se inscreveu em eventos.");
  $$("[data-cancelar]").forEach((b) =>
    acao(b, async () => {
      if (!confirm("Cancelar esta inscrição?")) return;
      await banco.cancelar(b.dataset.cancelar);
      await atualizar();
      meusEventos();
    }),
  );
}
/**
 * Serve tanto para criar quanto para editar um evento. Na edição carrega os campos e a capa
 * existentes; ao salvar distingue rascunho e publicação.
 */
function editarEvento() {
  const editando = parametros.has("evento");
  if (editando) {
    exigirEvento();
    if (!banco.pode(dados, evento.id))
      throw new Error("Você não pode editar este evento.");
    $("h1").textContent = "Editar evento";
    const campos = {
      "nome-evento": "nome",
      "categoria-evento": "categoria",
      "modalidade-evento": "modalidade",
      "data-inicio": "inicio",
      "data-termino": "fim",
      "local-evento": "local",
      "descricao-evento": "descricao",
      "organizador-evento": "organizador",
      "visibilidade-evento": "visibilidade",
      "limite-vagas": "vagas",
      "prazo-inscricao": "prazo",
      "taxa-inscricao": "taxa",
      "certificados-evento": "certificados",
    };
    Object.entries(campos).forEach(([id, chave]) => colocar(id, evento[chave]));
  } else {
    colocar("organizador-evento", usuario.nome);
  }
  const orientacao = document.createElement("p");
  orientacao.className = "eas-mensagem";
  orientacao.textContent =
    "Preencha os dados e escolha a capa. Publicar evento o exibe no catálogo quando a visibilidade é Público. Salvar rascunho mantém o evento apenas no painel.";
  $("#form-criar-evento").before(orientacao);
  uploadImagem("imagem-capa", editando ? evento.capaId : null);
  const atalho = $(".atalho-programacao a");
  atalho.href = url("adicionar-atividade.html", editando ? evento.id : null);
  acao(atalho, async () => {
    const chave = await salvar(editando ? evento.status : "rascunho");
    location.href = url("adicionar-atividade.html", chave);
  });
  /**
   * Reúne os valores do formulário de evento, salva uma eventual nova capa e chama o serviço
   * responsável por validar e gravar o evento. Uma capa não alterada é preservada.
   */
  async function salvar(status) {
    return banco.salvarEvento(
      {
        nome: campo("nome-evento"),
        categoria: campo("categoria-evento"),
        modalidade: campo("modalidade-evento"),
        inicio: campo("data-inicio"),
        fim: campo("data-termino"),
        local: campo("local-evento"),
        descricao: campo("descricao-evento"),
        organizador: campo("organizador-evento"),
        visibilidade: campo("visibilidade-evento"),
        vagas: Number(campo("limite-vagas")),
        prazo: campo("prazo-inscricao"),
        taxa: campo("taxa-inscricao"),
        certificados: campo("certificados-evento"),
        status,
        ...($("#imagem-capa").dataset.remover
          ? {
              capaId: null,
            }
          : {}),
      },
      editando ? evento.id : null,
      $("#imagem-capa").files[0],
    );
  }
  formulario("#form-criar-evento", async (e) => {
    const chave = await salvar(
      e.submitter?.value === "rascunho" ? "rascunho" : "publicado",
    );
    sessionStorage.setItem("eas-evento-salvo", chave);
    location.href = url("gerenciamento-evento.html", chave);
  });
}
/**
 * Associa uma atividade ao evento selecionado. Um rascunho temporário em sessionStorage
 * preserva os campos quando o usuário abre o cadastro de palestrante e depois retorna.
 */
function atividade() {
  exigirEvento();
  if (!banco.pode(dados, evento.id))
    throw new Error("Você não pode editar atividades deste evento.");
  const chave = parametros.get("atividade"),
    anterior = dados.atividades.find(
      (a) => a.id === chave && a.eventoId === evento.id,
    );
  if (chave && !anterior) throw new Error("Atividade não encontrada.");
  const temporario = `eas-atividade-${evento.id}-${chave || "nova"}`;
  let rascunho;
  try {
    rascunho = JSON.parse(sessionStorage.getItem(temporario) || "null");
  } catch {}
  const a = rascunho || anterior;
  const campos = {
    "nome-atividade": "nome",
    "tipo-atividade": "tipo",
    "modalidade-atividade": "modalidade",
    "data-atividade": "data",
    "horario-inicio": "inicio",
    "horario-termino": "fim",
    "local-atividade": "local",
    "descricao-atividade": "descricao",
    "limite-vagas-atividade": "vagas",
    "inscricao-atividade": "exigeInscricao",
    "certificado-atividade": "certificado",
  };
  if (a) Object.entries(campos).forEach(([id, chave]) => colocar(id, a[chave]));
  $(".grade-opcoes-palestrantes").innerHTML =
    dados.palestrantes
      .map(
        (p) =>
          `<label class="opcao-palestrante"><input type="checkbox" name="palestrantes[]" value="${esc(p.id)}" ${a?.palestranteIds?.includes(p.id) ? "checked" : ""}><span class="dados-opcao"><strong>${esc(p.nome)}</strong><small>${esc(p.cargo)}</small></span></label>`,
      )
      .join("") || vazio("Cadastre um palestrante para continuar.");
  $$(".opcao-palestrante").forEach((label) => {
    const p = dados.palestrantes.find((p) => p.id === $("input", label).value);
    $("input", label).insertAdjacentHTML(
      "afterend",
      miniatura(p.fotoId, p.nome),
    );
  });
  $("#ajuda-palestrantes").textContent = "Escolha pelo menos um palestrante.";
  /**
   * Converte os campos da atividade em um objeto JavaScript. A lista de caixas marcadas vira
   * um array de IDs de palestrantes; o limite de vagas é convertido em número.
   */
  function valores() {
    return {
      ...Object.fromEntries(
        Object.entries(campos).map(([id, chave]) => [chave, campo(id)]),
      ),
      eventoId: evento.id,
      vagas: Number(campo("limite-vagas-atividade")) || null,
      palestranteIds: $$('[name="palestrantes[]"]:checked').map((x) => x.value),
    };
  }
  const novo = $(".botao-novo-palestrante");
  novo.href = url("cadastrar-palestrante.html", evento.id);
  acao(novo, () => {
    sessionStorage.setItem(temporario, JSON.stringify(valores()));
    location.href =
      novo.href + (chave ? `&atividade=${encodeURIComponent(chave)}` : "");
  });
  formulario("#form-adicionar-atividade", async (e) => {
    await banco.salvarAtividade(
      {
        ...valores(),
        status: e.submitter?.value === "rascunho" ? "rascunho" : "publicado",
      },
      chave,
    );
    sessionStorage.removeItem(temporario);
    location.href = url("programacao-evento.html", evento.id);
  });
}
/**
 * Conecta criação e edição de palestrantes, incluindo a foto. Ao retornar para uma atividade,
 * mantém o rascunho e acrescenta o palestrante à seleção.
 */
function palestrante() {
  const editando = parametros.get("palestrante");
  const anterior = dados.palestrantes.find((p) => p.id === editando);
  if (editando && (!anterior || anterior.criadorId !== usuario.id))
    throw new Error("Palestrante não encontrado ou acesso não autorizado.");
  if (anterior) {
    $("h1").textContent = "Editar palestrante";
    for (const chave of [
      "nome",
      "cargo",
      "instituicao",
      "email",
      "biografia",
      "site",
      "linkedin",
    ])
      colocar(`${chave}-palestrante`, anterior[chave]);
  }
  uploadImagem("foto-palestrante", anterior?.fotoId);
  const voltar =
    url("adicionar-atividade.html", evento?.id) +
    (parametros.get("atividade")
      ? `&atividade=${encodeURIComponent(parametros.get("atividade"))}`
      : "");
  $(".acoes-palestrante a").href = evento
    ? voltar
    : "gerenciamento-evento.html";
  formulario("#form-cadastrar-palestrante", async () => {
    const fotoId = await banco.salvarImagem($("#foto-palestrante").files[0]);
    const p = await banco.salvarPalestrante(
      {
        nome: campo("nome-palestrante"),
        cargo: campo("cargo-palestrante"),
        instituicao: campo("instituicao-palestrante"),
        email: campo("email-palestrante"),
        biografia: campo("biografia-palestrante"),
        site: campo("site-palestrante"),
        linkedin: campo("linkedin-palestrante"),
        ...(fotoId
          ? {
              fotoId,
            }
          : $("#foto-palestrante").dataset.remover
            ? {
                fotoId: null,
              }
            : {}),
      },
      editando,
    );
    if (editando) {
      location.href = url(
        "cadastrar-palestrante.html",
        parametros.get("evento"),
      );
      return;
    }
    if (evento) {
      const chave = `eas-atividade-${evento.id}-${parametros.get("atividade") || "nova"}`,
        r = JSON.parse(sessionStorage.getItem(chave) || "{}");
      r.palestranteIds = [...(r.palestranteIds || []), p];
      sessionStorage.setItem(chave, JSON.stringify(r));
      location.href = voltar;
    } else {
      location.href = "cadastrar-palestrante.html";
    }
  });
  const lista = document.createElement("section");
  lista.className = "eas-registro";
  lista.innerHTML =
    '<h2>Palestrantes cadastrados</h2><div class="eas-lista-palestrantes">' +
    dados.palestrantes
      .map(
        (p) =>
          `<article class="cartao eas-registro">${miniatura(p.fotoId, p.nome)}<h3>${esc(p.nome)}</h3><p>${esc(p.cargo)}</p>${p.criadorId === usuario.id ? link("Editar cadastro e foto", url("cadastrar-palestrante.html", evento?.id) + `${evento ? "&" : "?"}palestrante=${encodeURIComponent(p.id)}`) : ""}</article>`,
      )
      .join("") +
    "</div>";
  $("#form-cadastrar-palestrante").after(lista);
}
/**
 * Calcula o painel com os registros que a conta pode consultar. Totais de inscritos e
 * credenciados são derivados das coleções, em vez de números fixos no HTML.
 */
function gerenciarEventos() {
  const salvo = sessionStorage.getItem("eas-evento-salvo");
  if (salvo && salvo === evento?.id) {
    sessionStorage.removeItem("eas-evento-salvo");
    mensagem(
      evento.status === "publicado"
        ? "Evento salvo! A capa e os dados já estão disponíveis na página do evento. Eventos públicos aparecem no catálogo."
        : "Rascunho salvo. Publique o evento para disponibilizá-lo aos participantes.",
    );
  }
  const lista = dados.eventos.filter((e) =>
    banco.pode(dados, e.id, "consultar"),
  );
  const inscricoes = dados.inscricoes.filter(
    (i) => lista.some((e) => e.id === i.eventoId) && i.status === "confirmada",
  );
  const credenciados = dados.credenciamentos.filter((c) =>
    inscricoes.some((i) => i.id === c.inscricaoId),
  ).length;
  const numeros = [
    lista.filter((e) => e.status === "publicado").length,
    inscricoes.length,
    "Simulado",
    credenciados,
  ];
  $$(".card-informacao h2").forEach((el, i) => (el.textContent = numeros[i]));
  $$(".card-informacao h5:last-child").forEach(
    (el) => (el.textContent = "Calculado a partir dos registros locais"),
  );
  $(".integrantes-equipe tbody").innerHTML =
    lista
      .map(
        (e) =>
          `<tr><td>${esc(e.nome)}</td><td>${dataBR(e.inicio)}–${dataBR(e.fim)}</td><td>${dados.inscricoes.filter((i) => i.eventoId === e.id && i.status === "confirmada").length} / ${e.vagas}</td><td>${e.taxa === "pago" ? "Pago (simulação)" : "Gratuito"}</td><td>${esc(e.status)}</td><td>${link("Gerenciar", url("criar-evento.html", e.id), "")}</td></tr>`,
      )
      .join("") ||
    '<tr><td colspan="6">Você ainda não tem eventos. Use “Novo evento” para começar.</td></tr>';
  acao($(".btn-painel"), () => (location.href = "criar-evento.html"));
  // A mesma referência capaId usada no catálogo também identifica a miniatura do painel.
  $$(".integrantes-equipe tbody tr").forEach((linha, i) => {
    if (lista[i])
      $("td", linha).insertAdjacentHTML(
        "afterbegin",
        miniatura(lista[i].capaId, lista[i].nome),
      );
  });
  const bloco = $(".inscricoes");
  bloco.innerHTML = `<h3>Evento selecionado</h3><p>${esc(evento?.nome || "Nenhum")}</p><p>${dados.inscricoes.filter((i) => i.eventoId === evento?.id && i.status === "confirmada").length} inscrições confirmadas</p>${evento ? link("Ver inscritos e credenciar", url("credenciamento.html", evento.id)) : ""}`;
  if (evento)
    bloco.insertAdjacentHTML(
      "beforeend",
      `<div class="grupo-acoes">${link("Ver evento", url("evento.html", evento.id))}${link("Editar evento", url("criar-evento.html", evento.id))}${link("Ver catálogo", "index.html#eventos")}</div>`,
    );
  const mapa = $(".mapa-atividades");
  mapa.innerHTML = `<h3>Programação e certificados</h3><p>${dados.atividades.filter((a) => a.eventoId === evento?.id).length} atividades cadastradas</p>${evento ? `<div class="grupo-acoes">${link("Gerenciar atividades", url("programacao-evento.html", evento.id))}</div>` : vazio("Crie um evento para organizar a programação.")}`;
  if (evento)
    mapa.append(
      botao("Emitir certificados dos participantes", async () => {
        const total = await banco.emitirCertificados(evento.id);
        mensagem(`${total} certificado(s) emitido(s).`);
      }),
    );
}
/**
 * Ordena as atividades por data e horário e separa a agenda por dia. Os controles de edição só
 * são apresentados quando a conta pode gerenciar o evento.
 */
function programacao() {
  exigirEvento();
  const admin = banco.pode(dados, evento.id);
  $(".titulo-evento h3").textContent = evento.nome;
  $(".titulo-evento p").textContent =
    `${dataBR(evento.inicio)} a ${dataBR(evento.fim)} · ${evento.local}`;
  const atividades = dados.atividades
    .filter(
      (a) => a.eventoId === evento.id && (admin || a.status !== "rascunho"),
    )
    .sort((a, b) =>
      `${a.data}${a.inicio}`.localeCompare(`${b.data}${b.inicio}`),
    );
  const datas = [...new Set(atividades.map((a) => a.data))];
  const barra = $(".buttons-titulo");
  barra.innerHTML = "";
  /**
   * Redesenha apenas a lista do dia escolhido. Os nomes dos palestrantes são encontrados pelos
   * IDs das atividades, evitando manter cópias divergentes desses nomes.
   */
  function agenda(dia) {
    $(".agenda-evento").innerHTML =
      `<h3>Agenda · ${dataBR(dia)}</h3>` +
      (atividades
        .filter((a) => a.data === dia)
        .map(
          (a) =>
            `<div class="evento"><span class="horario-evento">${esc(a.inicio)}–${esc(a.fim)}</span><div class="descricao-evento"><h4>${esc(a.nome)}</h4><p>${esc(a.local)} · ${a.palestranteIds.map((id) => esc(dados.palestrantes.find((p) => p.id === id)?.nome)).join(", ")}</p><span>${esc(a.tipo)}${a.status === "rascunho" ? " · Rascunho" : ""}</span>${admin ? link("Editar", url("adicionar-atividade.html", evento.id) + `&atividade=${encodeURIComponent(a.id)}`, "") : ""}</div></div>`,
        )
        .join("") || vazio("Nenhuma atividade cadastrada."));
  }
  datas.forEach((d) => barra.append(botao(dataBR(d), () => agenda(d))));
  if (admin)
    barra.insertAdjacentHTML(
      "beforeend",
      link(
        "Adicionar atividade",
        url("adicionar-atividade.html", evento.id),
        "btn-confirmacao",
      ),
    );
  agenda(datas[0]);
  const locais = [...new Set(atividades.map((a) => a.local).filter(Boolean))];
  $(".mapa").innerHTML =
    locais
      .map((l) => `<span class="elemento-mapa">${esc(l)}</span>`)
      .join("") || esc(evento.local);
  acao($(".btn-extendido"), () =>
    mensagem(`Locais das atividades: ${locais.join("; ") || evento.local}`),
  );
}
/**
 * Busca inscrições confirmadas e registra a chegada de um participante selecionado. A leitura
 * de câmera não está integrada; o código pode ser pesquisado manualmente.
 */
function credenciamento() {
  exigirEvento();
  const inscricoes = dados.inscricoes.filter(
    (i) => i.eventoId === evento.id && i.status === "confirmada",
  );
  const registros = dados.credenciamentos.filter((c) =>
    inscricoes.some((i) => i.id === c.inscricaoId),
  );
  const valores = [
    inscricoes.length,
    registros.length,
    inscricoes.length - registros.length,
    `${inscricoes.length ? Math.round((registros.length / inscricoes.length) * 100) : 0}%`,
  ];
  $$(".cartao-dado").forEach((el, i) => (el.textContent = valores[i]));
  $(".painel-selo").textContent = evento.nome;
  let selecionado;
  /**
   * Filtra as inscrições pelo termo digitado, usando nome, e-mail, CPF ou código. Com vários
   * resultados, o usuário precisa escolher o participante antes de confirmar a chegada.
   */
  function buscar() {
    const termo = campo("busca-participante").toLowerCase();
    const lista = inscricoes.filter((i) => {
      const u = dados.usuarios.find((x) => x.id === i.usuarioId);
      return `${u.nome} ${u.email || ""} ${u.cpf || ""} ${i.codigo}`
        .toLowerCase()
        .includes(termo);
    });
    selecionado = termo && lista.length === 1 ? lista[0] : null;
    const bloco = $(".participante-encontrado");
    bloco.innerHTML = lista.length
      ? lista
          .map(
            (i) =>
              `<label class="eas-participante"><input type="radio" name="inscrito" value="${esc(i.id)}" ${i.id === selecionado?.id ? "checked" : ""}>${esc(dados.usuarios.find((u) => u.id === i.usuarioId)?.nome)} · ${esc(i.codigo)} · ${registros.some((c) => c.inscricaoId === i.id) ? "Credenciado" : "Aguardando"}</label>`,
          )
          .join("")
      : vazio("Nenhum participante encontrado.");
    $$('[name="inscrito"]', bloco).forEach((r) =>
      r.addEventListener(
        "change",
        () => (selecionado = inscricoes.find((i) => i.id === r.value)),
      ),
    );
  }
  $("#busca-participante").addEventListener("input", buscar);
  buscar();
  const b = $("#titulo-manual").closest("section").querySelector("button");
  acao(b, async () => {
    if (!selecionado) throw new Error("Selecione um participante na lista.");
    await banco.credenciar(selecionado.id);
    location.reload();
  });
  const qr = $("#titulo-qr").closest("section");
  $(".leitor-qr", qr).textContent =
    "Nesta demonstração, use o código da inscrição na busca manual.";
  $("button", qr).textContent = "Buscar pelo código";
  acao($("button", qr), () => $("#busca-participante").focus());
  $(".tabela-painel tbody").innerHTML =
    registros
      .sort((a, b) => b.horario.localeCompare(a.horario))
      .map((c) => {
        const i = inscricoes.find((i) => i.id === c.inscricaoId);
        return `<tr><td>${horaBR(c.horario)}</td><td>${esc(dados.usuarios.find((u) => u.id === i.usuarioId)?.nome)}</td><td>${esc(i.codigo)}</td><td>${esc(c.metodo)}</td></tr>`;
      })
      .join("") ||
    '<tr><td colspan="4">Nenhum credenciamento registrado.</td></tr>';
}
/**
 * Organiza a presença por atividade e calcula o resumo a partir dos registros. O
 * credenciamento no evento é obrigatório antes de marcar presença na atividade.
 */
function frequencia() {
  exigirEvento();
  const atividades = dados.atividades.filter(
    (a) => a.eventoId === evento.id && a.status !== "rascunho",
  );
  const select = $("#atividade-frequencia");
  select.innerHTML = atividades
    .map((a) => `<option value="${esc(a.id)}">${esc(a.nome)}</option>`)
    .join("");
  const anterior = parametros.get("atividade");
  if (atividades.some((a) => a.id === anterior)) select.value = anterior;
  /**
   * Reconstrói os itens visíveis a partir dos registros e filtros atuais. Esta função é local
   * à tela: é chamada novamente quando o usuário muda uma busca ou seleção.
   */
  function desenhar() {
    const lista = dados.inscricoes.filter(
      (i) =>
        i.eventoId === evento.id &&
        i.status === "confirmada" &&
        i.atividadeIds.includes(select.value),
    );
    const presentes = lista.filter((i) =>
      dados.presencas.some(
        (p) => p.inscricaoId === i.id && p.atividadeId === select.value,
      ),
    );
    $("#resumo-frequencia").textContent =
      `${lista.length} inscritos · ${presentes.length} presentes · ${lista.length - presentes.length} pendentes`;
    $("#lista-frequencia").innerHTML =
      lista
        .map(
          (i) =>
            `<tr><td>${esc(dados.usuarios.find((u) => u.id === i.usuarioId)?.nome)}</td><td>${esc(i.codigo)}</td><td><label><input type="checkbox" data-presenca="${esc(i.id)}" ${presentes.includes(i) ? "checked" : ""}> Presente</label></td></tr>`,
        )
        .join("") ||
      '<tr><td colspan="3">Nenhum inscrito nesta atividade.</td></tr>';
    $$("[data-presenca]").forEach((c) =>
      c.addEventListener("change", async () => {
        c.disabled = true;
        try {
          await banco.marcarPresenca(
            c.dataset.presenca,
            select.value,
            c.checked,
          );
          await atualizar();
          desenhar();
        } catch (e) {
          c.checked = !c.checked;
          mensagem(e.message, true);
        } finally {
          c.disabled = false;
        }
      }),
    );
  }
  select.addEventListener("change", desenhar);
  desenhar();
}
/**
 * Monta a lista e o diálogo de membros do evento. A tela coleta função e horas; os serviços
 * verificam permissão, conta existente e associação duplicada.
 */
function equipe() {
  exigirEvento();
  const lista = dados.equipe.filter((m) => m.eventoId === evento.id);
  const funcoes = {
    coordenacao: "Coordenação",
    credenciamento: "Credenciamento",
    monitoria: "Monitoria",
    consulta: "Consulta",
  };
  $$(".card-informacao h2").forEach(
    (el, i) =>
      (el.textContent = [
        lista.length,
        new Set(lista.map((m) => m.funcao)).size,
        lista.filter((m) => m.validado).length,
        lista.filter((m) => !m.validado).length,
      ][i]),
  );
  $(".integrantes-equipe tbody").innerHTML =
    lista
      .map(
        (m) =>
          `<tr><td>${esc(dados.usuarios.find((u) => u.id === m.usuarioId)?.nome)}</td><td>${funcoes[m.funcao]}</td><td>${m.horas} h</td><td>${m.validado ? "Validado" : "Pendente"}</td><td><button type="button" data-editar="${esc(m.id)}">Editar</button> <button type="button" data-remover="${esc(m.id)}">Remover</button></td></tr>`,
      )
      .join("") ||
    '<tr><td colspan="5">Nenhum membro adicionado. O responsável pelo evento já tem acesso total.</td></tr>';
  $(".numero-certificado h2").textContent = lista.filter(
    (m) => m.validado && m.horas > 0,
  ).length;
  $(".texto-certificado").textContent =
    "Valide as horas de atuação antes de emitir certificados.";
  $(".funcoes").innerHTML =
    "<h3>Funções e acessos</h3><p>Coordenação: gerencia o evento. Credenciamento e monitoria: registram chegada e presença. Consulta: consulta o painel.</p>";
  const dialog = document.createElement("dialog");
  dialog.className = "modal";
  dialog.id = "eas-membro";
  dialog.innerHTML = `<form id="form-membro" class="eas-registro"><h2>Membro da equipe</h2><div class="campo-formulario"><label for="membro-email">E-mail da conta cadastrada</label><input type="email" id="membro-email" required><label for="membro-funcao">Função</label><select id="membro-funcao">${Object.entries(
    funcoes,
  )
    .map(([v, t]) => `<option value="${v}">${t}</option>`)
    .join(
      "",
    )}</select><label for="membro-horas">Horas de atuação</label><input id="membro-horas" type="number" min="0" step="0.5" value="0" required><label><input id="membro-validado" type="checkbox"> Horas validadas</label></div><div class="grupo-acoes"><button type="submit" class="btn-confirmacao">Salvar</button><button type="button" id="fechar-membro">Cancelar</button></div></form>`;
  document.body.append(dialog);
  let editando;
  /**
   * Preenche o diálogo de membro para criar ou editar um cadastro e usa showModal. O navegador
   * gerencia o foco e impede interação com o fundo enquanto o diálogo está aberto.
   */
  function abrir(m) {
    editando = m?.id;
    colocar(
      "membro-email",
      dados.usuarios.find((u) => u.id === m?.usuarioId)?.email,
    );
    colocar("membro-funcao", m?.funcao || "consulta");
    colocar("membro-horas", m?.horas || 0);
    $("#membro-validado").checked = Boolean(m?.validado);
    dialog.showModal();
  }
  acao($(".btn-painel"), () => abrir());
  acao($("#fechar-membro"), () => dialog.close());
  $$("[data-editar]").forEach((b) =>
    acao(b, () => abrir(lista.find((m) => m.id === b.dataset.editar))),
  );
  $$("[data-remover]").forEach((b) =>
    acao(b, async () => {
      if (!confirm("Remover este membro da equipe?")) return;
      await banco.removerMembro(evento.id, b.dataset.remover);
      location.reload();
    }),
  );
  formulario("#form-membro", async () => {
    await banco.salvarMembro(
      evento.id,
      {
        email: campo("membro-email"),
        funcao: campo("membro-funcao"),
        horas: Number(campo("membro-horas")),
        validado: $("#membro-validado").checked,
      },
      editando,
    );
    location.reload();
  });
  acao($(".btn-cetificado"), async () =>
    mensagem(
      `${await banco.emitirCertificados(evento.id, true)} certificado(s) de equipe emitido(s).`,
    ),
  );
}
/**
 * Cria um arquivo em memória com Blob e inicia o download por um link temporário. Depois
 * libera a URL de objeto para não manter essa referência na memória.
 */
function baixar(nome, texto, tipo) {
  const objeto = URL.createObjectURL(
      new Blob([texto], {
        type: tipo,
      }),
    ),
    a = document.createElement("a");
  a.href = objeto;
  a.download = nome;
  a.click();
  setTimeout(() => URL.revokeObjectURL(objeto), 1000);
}
/**
 * Lista os certificados emitidos para a conta atual. O download gera um documento HTML com
 * texto escapado, que pode ser aberto e impresso como PDF.
 */
function certificados() {
  /**
   * Reconstrói os itens visíveis a partir dos registros e filtros atuais. Esta função é local
   * à tela: é chamada novamente quando o usuário muda uma busca ou seleção.
   */
  function desenhar() {
    const termo = campo("filtro-certificado").toLowerCase();
    const lista = dados.certificados.filter(
      (c) =>
        c.usuarioId === usuario.id &&
        dados.eventos
          .find((e) => e.id === c.eventoId)
          ?.nome.toLowerCase()
          .includes(termo),
    );
    $("#tabela-certificados tbody").innerHTML =
      lista
        .map(
          (c) =>
            `<tr><td>${esc(dados.eventos.find((e) => e.id === c.eventoId)?.nome)}</td><td>${esc(c.tipo)} · ${Number(c.horas).toFixed(1)} h</td><td>${dataBR(c.emitidoEm)}</td><td><button type="button" data-certificado="${esc(c.id)}">Baixar certificado</button></td></tr>`,
        )
        .join("") ||
      '<tr><td colspan="4">Nenhum certificado disponível. A organização emite os certificados após o evento, com base nas presenças.</td></tr>';
    $$("[data-certificado]").forEach((b) =>
      acao(b, () => {
        const c = lista.find((c) => c.id === b.dataset.certificado),
          e = dados.eventos.find((e) => e.id === c.eventoId);
        const html = `<!doctype html><html lang="pt-BR"><meta charset="utf-8"><title>Certificado EAS</title><style>body{font:20px Georgia;text-align:center;padding:70px;border:8px double #078788}h1{font-size:44px}p{line-height:1.8}small{font-size:12px;overflow-wrap:anywhere}@media print{button{display:none}}</style><h1>Certificado de ${esc(c.tipo)}</h1><p>Certificamos que <strong>${esc(usuario.nome)}</strong> participou de <strong>${esc(e.nome)}</strong>, com carga horária de <strong>${Number(c.horas).toFixed(1)} horas</strong>.</p><p>${esc(e.organizador)} · ${dataBR(c.emitidoEm)}</p><small>Código: ${esc(c.codigo)}<br>Documento de demonstração acadêmica.</small><p>Use a opção Imprimir do navegador para salvar como PDF.</p></html>`;
        baixar(`certificado-${c.id}.html`, html, "text/html;charset=utf-8");
      }),
    );
  }
  $("#filtro-certificado").addEventListener("input", desenhar);
  desenhar();
}
/**
 * Carrega e salva o perfil e oferece exportação e importação do banco. A importação substitui
 * todos os registros locais e precisa de confirmação explícita.
 */
function conta() {
  colocar("usuario", usuario.nome);
  colocar("nome-tela", usuario.apelido);
  colocar("email", usuario.email);
  $(".perfil > div:last-child > div").textContent = usuario.nome;
  formulario(".caixa", async () => {
    await banco.salvarConta({
      nome: campo("usuario"),
      apelido: campo("nome-tela"),
      email: campo("email"),
      senha: campo("senha"),
    });
    colocar("senha", "");
    mensagem("Alterações salvas.");
  });
  $$(".btn-lapis").forEach((b) =>
    acao(b, () => b.previousElementSibling.focus()),
  );
  $$(".perigo-linha a").forEach((a, i) =>
    acao(a, async () => {
      if (
        !confirm(
          i
            ? "Excluir seus dados pessoais desta conta? O histórico de participação será preservado sem sua identificação."
            : "Desativar sua conta? Ela não poderá mais fazer login nesta demonstração.",
        )
      )
        return;
      await banco.encerrarConta(Boolean(i));
      location.href = "index.html";
    }),
  );
  acao($(".perfil-link"), () => (location.href = "meus-eventos.html"));
  const caixa = document.createElement("section");
  caixa.className = "eas-registro cartao";
  caixa.innerHTML =
    '<h2>Dados da demonstração</h2><p>Exporte um arquivo JSON para compartilhar pelo GitHub. Importar substitui todos os registros locais e encerra a sessão.</p><div class="grupo-acoes" id="acoes-dados"></div><label for="importar-banco">Importar banco JSON (até 20 MB)</label><input id="importar-banco" type="file" accept="application/json,.json">';
  $("main").append(caixa);
  $("#acoes-dados").append(
    botao("Exportar banco", async () =>
      baixar(
        "eas-banco.json",
        JSON.stringify(await banco.exportar(), null, 2),
        "application/json",
      ),
    ),
  );
  $("#importar-banco").addEventListener("change", async (e) => {
    const arquivo = e.target.files[0];
    if (!arquivo) return;
    try {
      if (arquivo.size > 20 * 1024 * 1024)
        throw new Error("O arquivo excede 20 MB.");
      const json = JSON.parse(await arquivo.text());
      if (
        !confirm(
          "Substituir todos os dados locais pelos registros deste arquivo?",
        )
      )
        return;
      await banco.importar(json);
      location.href = "login.html";
    } catch (erro) {
      mensagem(erro.message, true, caixa);
    } finally {
      e.target.value = "";
    }
  });
}
/**
 * Coordena a abertura da aplicação: aguarda banco e componentes, verifica a sessão, escolhe o
 * evento e executa somente a função da página atual. Erros vão para o tratamento central.
 */
async function iniciar() {
  await atualizar();
  await window.componentesProntos;
  await window.painelPronto;
  // O redirecionamento melhora a navegação. Os serviços ainda validam a conta a cada operação.
  const protegidas = [
    "gerenciamento-conta.html",
    "criar-evento.html",
    "adicionar-atividade.html",
    "cadastrar-palestrante.html",
    "gerenciamento-evento.html",
    "gerenciamento-equipe.html",
    "credenciamento.html",
    "frequencia.html",
    "inscricao-atividade-evento.html",
    "editar-atividade-evento.html",
    "meus-eventos.html",
    "certificados.html",
  ];
  if (protegidas.includes(pagina) && !usuario) {
    location.replace(
      `login.html?retorno=${encodeURIComponent(pagina + location.search)}`,
    );
    return;
  }
  cabecalho();
  const publico = [
    "evento.html",
    "inscricao-atividade-evento.html",
    "editar-atividade-evento.html",
  ];
  if (publico.includes(pagina) || pagina === "programacao-evento.html") {
    evento = dados.eventos.find((e) => e.id === parametros.get("evento"));
    if (
      evento &&
      evento.status !== "publicado" &&
      !banco.pode(dados, evento.id, "consultar")
    )
      evento = null;
    if (
      pagina === "programacao-evento.html" &&
      evento &&
      !banco.pode(dados, evento.id, "consultar")
    )
      $("#painel-adm")?.remove();
  }
  if (
    $("#painel-adm") &&
    !(
      pagina === "programacao-evento.html" &&
      evento &&
      !banco.pode(dados, evento.id, "consultar")
    )
  )
    painelContexto();
  if (["credenciamento.html", "frequencia.html"].includes(pagina)) {
    exigirEvento();
    if (!banco.pode(dados, evento.id, "presenca"))
      throw new Error("Seu perfil não pode registrar presenças neste evento.");
  }
  if (pagina === "gerenciamento-equipe.html") {
    exigirEvento();
    if (!banco.pode(dados, evento.id))
      throw new Error("Seu perfil não pode gerenciar a equipe.");
  }
  // Este mapa associa o arquivo HTML à sua função. Só a rota atual será executada.
  const rotas = {
    "index.html": home,
    "evento.html": detalhes,
    "inscricao-atividade-evento.html": inscricao,
    "editar-atividade-evento.html": inscricao,
    "meus-eventos.html": meusEventos,
    "criar-evento.html": editarEvento,
    "adicionar-atividade.html": atividade,
    "cadastrar-palestrante.html": palestrante,
    "gerenciamento-evento.html": gerenciarEventos,
    "programacao-evento.html": programacao,
    "credenciamento.html": credenciamento,
    "frequencia.html": frequencia,
    "gerenciamento-equipe.html": equipe,
    "certificados.html": certificados,
    "gerenciamento-conta.html": conta,
  };
  acesso();
  rotas[pagina]?.();
  document.documentElement.dataset.easPronto = "sim";
}
// Promessa e atributo data-eas-pronto permitem detectar o fim da inicialização, inclusive nos testes.
window.easPronto = iniciar().catch((e) => {
  console.error(e);
  mensagem(e.message, true);
  $$('form:not([method="dialog"]) button[type="submit"]').forEach(
    (b) => (b.disabled = true),
  );
  document.documentElement.dataset.easPronto = "erro";
});
