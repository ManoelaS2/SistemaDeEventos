/* =====================================================
   gerenciamento-conta.js - comportamento SÓ da tela
   Gerenciamento de Conta
   =====================================================
   O tema claro/escuro agora é feito pelo tema.js (igual nas outras
   páginas), então aqui só ficam o lápis e o salvar. */

const formulario = document.getElementById("form-conta");
const mensagem = document.getElementById("mensagem");


/* =====================================================
   1) LÁPIS: LEVA O CURSOR ATÉ O CAMPO
   ===================================================== */

/* querySelectorAll: pega TODOS os lápis da página.
   forEach: repete o código para cada lápis encontrado. */
document.querySelectorAll(".conta-lapis").forEach(function (lapis) {
  lapis.addEventListener("click", function () {
    /* lapis.dataset.campo lê o atributo data-campo do HTML
       (ex.: data-campo="usuario"). Ele guarda o id do campo ligado ao lápis. */
    const campo = document.getElementById(lapis.dataset.campo);

    // focus(): coloca o cursor dentro do campo, pronto para digitar
    campo.focus();
  });
});


/* =====================================================
   2) SALVAR
   ===================================================== */

/* "submit" acontece quando o formulário é enviado
   (clicando no botão ou apertando Enter). */
formulario.addEventListener("submit", function (evento) {
  /* Por padrão, enviar um formulário recarrega a página e apaga o que foi
     digitado. preventDefault() cancela isso, para o JS cuidar de tudo. */
  evento.preventDefault();

  // .value é o texto que está dentro do campo agora
  const usuario = document.getElementById("usuario").value.trim();

  if (usuario === "") {
    mensagem.textContent = "Preencha pelo menos o campo Usuário.";
  } else {
    mensagem.textContent = "Alterações salvas.";
  }
});
