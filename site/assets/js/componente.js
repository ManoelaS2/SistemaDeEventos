function carregarComponente(idContainer, caminhoArquivo) {
            fetch(caminhoArquivo)
                .then(resposta => {
                    if (!resposta.ok) throw new Error("Erro ao carregar o arquivo: " + caminhoArquivo);
                    return resposta.text(); // Converte o arquivo carregado em texto/HTML
                })
                .then(conteudoHTML => {
                    // Encontra a DIV na página e joga o HTML dentro dela
                    document.getElementById(idContainer).innerHTML = conteudoHTML;
                })
                .catch(erro => console.error(erro));
        }

carregarComponente('header-container','./assets/componentes/header.html');
carregarComponente('footer-container','./assets/componentes/footer.html');