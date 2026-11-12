/* =====================================================
   gerenciamento-conta.js - comportamento da tela
   Gerenciamento de Conta
   ===================================================== */

const botaoTema = document.getElementById("btn-tema");
const mensagem = document.getElementById("mensagem");


/* =====================================================
   1) TEMA CLARO / ESCURO
   ===================================================== */

/* localStorage: "gavetinha" do navegador. Guarda um texto mesmo depois
   de fechar a página. Aqui guardamos "escuro" para lembrar o tema.
   Este if roda assim que a página abre. */
if (localStorage.getItem("tema") == "escuro") {
  document.body.classList.add("escuro");
  botaoTema.textContent = "☀️";
}

// Esta função é chamada pelo onclick="trocarTema()" do botão
function trocarTema() {
  /* classList.toggle("escuro"): se o body NÃO tem a classe "escuro",
     coloca; se já tem, tira. No CSS, body.escuro muda as cores. */
  document.body.classList.toggle("escuro");

  // classList.contains: pergunta "o body tem essa classe agora?"
  if (document.body.classList.contains("escuro")) {
    botaoTema.textContent = "☀️";
    localStorage.setItem("tema", "escuro");
  } else {
    botaoTema.textContent = "🌙";
    localStorage.setItem("tema", "claro");
  }
}


/* =====================================================
   2) EDITAR E SALVAR
   ===================================================== */

// Chamada pelo lápis: onclick="editar('usuario')" (o id do campo chega aqui)
function editar(idDoCampo) {
  // focus(): coloca o cursor dentro do campo, pronto para digitar
  document.getElementById(idDoCampo).focus();
}

// Chamada quando o formulário é enviado: onsubmit="salvar(event)"
function salvar(evento) {
  /* Por padrão, enviar um formulário recarrega a página e apaga o que foi
     digitado. preventDefault() cancela isso, para o JS cuidar de tudo. */
  evento.preventDefault();

  // .value é o texto que está dentro do campo agora
  const usuario = document.getElementById("usuario").value;

  if (usuario == "") {
    mensagem.textContent = "Preencha pelo menos o campo Usuário.";
  } else {
    mensagem.textContent = "Alterações salvas.";
  }
}
