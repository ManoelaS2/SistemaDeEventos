async function carregarComponente(id, arquivo) {
  const destino = document.getElementById(id);
  if (!destino) return;
  const resposta = await fetch(arquivo);
  if (!resposta.ok) throw new Error(`Erro ao carregar ${arquivo}`);
  destino.innerHTML = await resposta.text();
}

async function iniciar() {
  await Promise.all([
    carregarComponente('header-container', 'includes/header.html'),
    carregarComponente('footer-container', 'includes/footer.html')
  ]);

  const menuButton = document.getElementById('menu-toggle');
  const nav = document.getElementById('main-nav');

  menuButton?.addEventListener('click', () => {
    const aberto = menuButton.getAttribute('aria-expanded') === 'true';
    menuButton.setAttribute('aria-expanded', String(!aberto));
    nav?.classList.toggle('open', !aberto);
  });

  const busca = document.querySelector('.header-search input');
  const termo = new URLSearchParams(window.location.search).get('busca');
  if (busca && termo) busca.value = termo;

  document.querySelector('.password-toggle')?.addEventListener('click', function () {
    const senha = document.getElementById('senha');
    if (!senha) return;
    const exibindo = senha.type === 'password';
    senha.type = exibindo ? 'text' : 'password';
    this.setAttribute('aria-label', exibindo ? 'Ocultar senha' : 'Mostrar senha');
    this.querySelector('ion-icon')?.setAttribute('name', exibindo ? 'eye-outline' : 'eye-off-outline');
  });
}

iniciar();

const eventName = document.querySelector('#event-detail-name');
if (eventName) {
  const key = new URLSearchParams(window.location.search).get('evento');
  const eventId = /^[A-F]$/i.test(key || '') ? key.toUpperCase() : 'A';
  eventName.textContent = `Evento ${eventId}:`;
  document.title = `Evento ${eventId} | EAS`;
}

document.querySelectorAll('form[data-demo-redirect]').forEach(form => {
  form.addEventListener('submit', event => {
    event.preventDefault();
    if (form.reportValidity()) window.location.href = form.dataset.demoRedirect;
  });
});
