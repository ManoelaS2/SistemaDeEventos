/**
 * Menu do organizador: esta função autoexecutável cria um escopo próprio, evitando nomes
 * globais em conflito. painelPronto informa ao app.js quando os links já existem no DOM.
 */
(() => {
  window.painelPronto = (async () => {
    const painel = document.getElementById('painel-adm');
    if (!painel) return;
    const resposta = await fetch('includes/painel-adm.html');
    if (!resposta.ok) throw new Error('Não foi possível carregar o painel.');
    painel.innerHTML = await resposta.text();
    const pagina = location.pathname.split('/').pop();
    painel.querySelectorAll('a').forEach(a => {
      if (a.getAttribute('href') === pagina) {
        a.classList.add('painel-selecionado');
        a.setAttribute('aria-current', 'page');
      }
    });
  })();
})();
