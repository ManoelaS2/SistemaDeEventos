/**
 * Tema visual compartilhado: localStorage lembra a preferência entre visitas. data-theme
 * seleciona as variáveis de cor no CSS. A função autoexecutável mantém as variáveis isoladas.
 */

(() => {
  const chave = "eas-tema";
  const html = document.documentElement;

  /**
   * Lê o atributo data-theme do elemento html e devolve um dos dois temas aceitos.
   */
  function temaAtual() {
    return html.getAttribute("data-theme") === "dark" ?
      "dark" :
      "light";
  }

  /**
   * Atualiza o símbolo e o nome acessível do controle. Só troca o texto se ele mudou, evitando
   * que o MutationObserver dispare uma atualização sem fim.
   */
  function atualizarBotao() {
    const botao = document.querySelector(".theme-button");
    if (!botao) return;

    const escuro = temaAtual() === "dark";

    const simbolo = escuro ? "☀" : "☾";
    if (botao.textContent !== simbolo) botao.textContent = simbolo;

    botao.setAttribute(
      "aria-label",
      escuro ? "Ativar tema claro" : "Ativar tema escuro"
    );
  }

  /**
   * Troca o atributo usado pelos seletores CSS e atualiza o botão. As cores são definidas no
   * CSS, sem precisar alterar cada elemento com JavaScript.
   */
  function aplicarTema(tema) {
    html.setAttribute("data-theme", tema);
    atualizarBotao();
  }

  let salvo = "light";

  try {
    salvo = localStorage.getItem(chave) || "light";
  } catch {
    // Se o navegador bloquear o armazenamento, a troca visual continua funcionando nesta visita.
  }

  aplicarTema(salvo === "dark" ? "dark" : "light");

  document.addEventListener("click", (evento) => {
    const botao = evento.target.closest?.(".theme-button");

    if (!botao) return;

    const novoTema = temaAtual() === "dark" ?
      "light" :
      "dark";

    aplicarTema(novoTema);

    try {
      localStorage.setItem(chave, novoTema);
    } catch {
      // Se o navegador bloquear o armazenamento, a troca visual continua funcionando nesta visita.
    }
  });

  /**
   * Observa a inserção assíncrona do cabeçalho. Assim o botão recebe o estado correto mesmo
   * quando o HTML compartilhado termina de carregar depois do tema.
   */
  function observarHeader() {
    const header = document.getElementById("header-container");
    if (!header) return;

    const observador = new MutationObserver(atualizarBotao);

    observador.observe(header, {
      childList: true,
      subtree: true
    });

    atualizarBotao();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", observarHeader);
  } else {
    observarHeader();
  }
})();
