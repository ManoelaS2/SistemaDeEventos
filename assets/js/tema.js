
(() => {
  const chave = "eas-tema";
  const html = document.documentElement;

  function temaAtual() {
    return html.getAttribute("data-theme") === "dark"
      ? "dark"
      : "light";
  }

  function atualizarBotao() {
    const botao = document.querySelector(".theme-button");
    if (!botao) return;

    const escuro = temaAtual() === "dark";

    botao.querySelector("ion-icon")?.setAttribute(
      "name",
      escuro ? "sunny" : "moon"
    );

    botao.setAttribute(
      "aria-label",
      escuro ? "Ativar tema claro" : "Ativar tema escuro"
    );
  }

  function aplicarTema(tema) {
    html.setAttribute("data-theme", tema);
    atualizarBotao();
  }

  let salvo = "light";

  try {
    salvo = localStorage.getItem(chave) || "light";
  } catch {}

  aplicarTema(salvo === "dark" ? "dark" : "light");

  document.addEventListener("click", (evento) => {
    const botao = evento.target.closest?.(".theme-button");

    if (!botao) return;

    const novoTema = temaAtual() === "dark"
      ? "light"
      : "dark";

    aplicarTema(novoTema);

    try {
      localStorage.setItem(chave, novoTema);
    } catch {}
  });

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
