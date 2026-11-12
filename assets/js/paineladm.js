async function carregarComponente(id, arquivo) {
  const destino = document.getElementById(id);
  if (!destino) return;
  const resposta = await fetch(arquivo);
  if (!resposta.ok) throw new Error(`Erro ao carregar ${arquivo}`);
  destino.innerHTML = await resposta.text();
}

async function iniciar() {
  await Promise.all([
    carregarComponente('painel-adm', 'includes/painel-adm.html'),
    ]);
const arquivo = window.location.pathname

console.log(arquivo)

const nav = document.querySelectorAll(".link-painel");

console.log(nav)

    nav.forEach(elemento => {
        if (elemento.getAttribute("href") === arquivo){
            elemento.classList.add("painel-selecionado")
        } 
    });

    
}

iniciar();
