// Abre os modais da Ajuda ao clicar nos links do footer (Sobre, Contato, Termos).
(function () {
  var modais = {
    "#sobre": "modal-sobre",
    "#contato": "modal-contato",
    "#termos": "modal-termos"
  };

  // Delegação no document: o footer é injetado depois pelo componente.js.
  document.addEventListener("click", function (evento) {
    var link = evento.target.closest(".site-footer a[href]");
    var id = link && modais[link.hash];

    if (id) {
      evento.preventDefault();
      document.getElementById(id).showModal();
      return;
    }

    // Clique no fundo escurecido (o alvo é o próprio <dialog>) fecha o modal.
    if (evento.target.classList.contains("modal")) {
      evento.target.close();
    }
  });
})();