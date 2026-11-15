/**
 * Componentes compartilhados: evita repetir cabeçalho e rodapé em cada HTML. Use um servidor
 * HTTP, pois fetch não funciona de forma confiável em file://.
 */
/**
 * Busca um fragmento HTML local e coloca o conteúdo no contêiner indicado. Verifica a resposta
 * HTTP antes de usar o texto; o fragmento é código confiável do próprio projeto.
 */
async function carregarComponente(id, arquivo) {
  const destino = document.getElementById(id);
  if (!destino) return;
  const resposta = await fetch(arquivo);
  if (!resposta.ok) throw new Error(`Erro ao carregar ${arquivo}`);
  destino.innerHTML = await resposta.text();
}

/**
 * Carrega cabeçalho e rodapé em paralelo e depois conecta menu e alternância de senha. A
 * promessa componentesProntos permite que app.js aguarde a criação desses elementos.
 */
async function iniciar() {
  await Promise.all([
    carregarComponente("header-container", "includes/header.html"),
    carregarComponente("footer-container", "includes/footer.html"),
  ]);

  const menuButton = document.getElementById("menu-toggle");
  const nav = document.getElementById("main-nav");

  menuButton?.addEventListener("click", () => {
    const aberto = menuButton.getAttribute("aria-expanded") === "true";
    menuButton.setAttribute("aria-expanded", String(!aberto));
    nav?.classList.toggle("open", !aberto);
  });

  const busca = document.querySelector(".header-search input");
  const termo = new URLSearchParams(window.location.search).get("busca");
  if (busca && termo) busca.value = termo;

  document
    .querySelector(".password-toggle")
    ?.addEventListener("click", function() {
      const senha = document.getElementById("senha");
      if (!senha) return;
      const exibindo = senha.type === "password";
      senha.type = exibindo ? "text" : "password";
      this.setAttribute(
        "aria-label",
        exibindo ? "Ocultar senha" : "Mostrar senha",
      );
      this.querySelector("ion-icon")?.setAttribute(
        "name",
        exibindo ? "eye-outline" : "eye-off-outline",
      );
    });
}

window.componentesProntos = iniciar();

document.querySelectorAll("form[data-demo-redirect]").forEach((form) => {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    if (form.reportValidity()) window.location.href = form.dataset.demoRedirect;
  });
});
