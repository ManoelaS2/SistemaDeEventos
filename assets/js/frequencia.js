/**
 * ARQUIVO LEGADO, mantido como exemplo de estudo. Não é carregado pelas páginas atuais. O
 * comportamento em uso fica em app.js, a persistência em banco.js e o tema compartilhado em
 * tema.js. Os exemplos abaixo usam estruturas antigas e não consultam o IndexedDB. Não
 * adicione este script às páginas atuais: ele depende de outros IDs e temas.
 */
/* =====================================================
   frequencia.js - comportamento SÓ da tela Frequência nas
   atividades (frequencia.html)
   O tema claro/escuro agora é feito pelo tema.js (igual nas outras
   páginas), por isso não tem mais código de tema aqui.
   ===================================================== */

/* =====================================================
   1) LISTA DE PARTICIPANTES
   ===================================================== */

const tabela = document.getElementById("tabela-participantes");
const mensagem = document.getElementById("mensagem");

/* Os dados ficam em um ARRAY (lista) de OBJETOS.
   Cada objeto é um participante com nome, e-mail e status.
   A tela é "desenhada" a partir dessa lista: se a lista muda,
   chamamos desenharTabela() e a tela se atualiza. */
const participantes = [
  { nome: "Fulaniho", email: "fulaninho@email.com", status: "presente" },
  { nome: "Alguem", email: "alguem2@email.com", status: "pendente" },
  { nome: "Cidadão", email: "cidadao@email.com", status: "presente" }
];

// Números dos cartões (começam iguais ao protótipo)
const totais = {
  inscritos: 128,
  presentes: 94,
  ausentes: 34
};

function desenharTabela() {
  tabela.innerHTML = ""; // limpa as linhas antigas antes de desenhar de novo

  participantes.forEach(function(p) {
    // Cria os elementos pelo JS (createElement) em vez de montar texto HTML.
    // Usar textContent (e não innerHTML) com nomes digitados pelo usuário
    // é mais seguro: o navegador trata tudo como texto comum.
    const linha = document.createElement("tr");

    const colunaNome = document.createElement("td");
    colunaNome.textContent = p.nome;
    colunaNome.style.fontWeight = "700";

    const colunaStatus = document.createElement("td");
    const etiqueta = document.createElement("span");
    etiqueta.className = p.status === "presente" ? "etiqueta" : "etiqueta freq-pendente";
    etiqueta.textContent = p.status === "presente" ? "Presente" : "Pendente";
    colunaStatus.appendChild(etiqueta);

    const colunaAcao = document.createElement("td");
    const botaoAcao = document.createElement("button");
    botaoAcao.className = "freq-btn-acao";

    if (p.status === "presente") {
      botaoAcao.textContent = "Ver registro";
    } else {
      botaoAcao.textContent = "Validar →";
      // Clicar em "Validar" confirma a presença desse participante
      botaoAcao.addEventListener("click", function() {
        validarParticipante(p);
      });
    }
    colunaAcao.appendChild(botaoAcao);

    // appendChild coloca um elemento dentro de outro
    linha.appendChild(colunaNome);
    linha.appendChild(colunaStatus);
    linha.appendChild(colunaAcao);
    tabela.appendChild(linha);
  });
}

function atualizarContadores() {
  document.getElementById("total-inscritos").textContent = totais.inscritos;
  document.getElementById("total-presentes").textContent = totais.presentes;
  document.getElementById("total-ausentes").textContent = totais.ausentes;
}

function validarParticipante(p) {
  if (p.status === "presente") {
    // já estava presente: só avisa, sem somar de novo nos contadores
    mensagem.textContent = p.nome + " já estava presente.";
    return;
  }

  p.status = "presente";
  totais.presentes++; // ++ soma 1
  totais.ausentes--; // -- subtrai 1

  desenharTabela();
  atualizarContadores();
  mensagem.textContent = p.nome + " foi validado(a).";
}

/* =====================================================
   2) VALIDAÇÃO MANUAL E INSCRIÇÃO RÁPIDA
   ===================================================== */

document.getElementById("btn-validar").addEventListener("click", function() {
  const campoBusca = document.getElementById("busca-manual");

  /* trim() tira espaços das pontas; toLowerCase() deixa tudo em minúsculas.
     Assim "ANA" e "ana" são tratados como iguais na busca. */
  const termo = campoBusca.value.trim().toLowerCase();

  if (termo === "") {
    mensagem.textContent = "Digite um nome ou e-mail para buscar.";
    return;
  }

  /* find: percorre a lista e devolve o PRIMEIRO item que passar no teste.
     includes: verifica se um texto contém o outro. */
  const encontrado = participantes.find(function(p) {
    return p.nome.toLowerCase().includes(termo) ||
      p.email.toLowerCase().includes(termo);
  });

  if (encontrado) {
    validarParticipante(encontrado);
  } else {
    mensagem.textContent = "Nenhum participante encontrado.";
  }
});

document.getElementById("btn-rapida").addEventListener("click", function() {
  // prompt abre uma caixinha pedindo um texto (simples, só para o exemplo)
  const nome = prompt("Nome do participante:");
  if (!nome) return; // cancelou ou deixou vazio

  participantes.push({
    nome: nome.trim(),
    email: "",
    status: "presente" // quem se inscreve na hora já entra como presente
  });
  totais.inscritos++;
  totais.presentes++;

  desenharTabela();
  atualizarContadores();
  mensagem.textContent = "Inscrição rápida feita para " + nome.trim() + ".";
});

desenharTabela(); // primeira vez que a tabela aparece
atualizarContadores();

/* =====================================================
   3) QR CODE DESENHADO NO <canvas>
   =====================================================
   ATENÇÃO: é só uma IMAGEM DE EXEMPLO parecida com um QR Code, para
   a tela ficar igual ao protótipo. Ele NÃO pode ser lido por leitores
   de verdade. Para um QR real, use uma biblioteca (ex.: qrcode.js)
   e gere a partir de um texto/link da atividade. */

const canvas = document.getElementById("qr");

/* getContext("2d"): devolve o "pincel" do canvas.
   Com ele usamos fillStyle (cor) e fillRect(x, y, largura, altura)
   para pintar retângulos. */
const pincel = canvas.getContext("2d");

const QUADRADOS = 25; // o QR é uma grade 25 x 25
const tamanho = canvas.width / QUADRADOS; // tamanho de cada quadradinho em pixels

// Desenha um "olho" do QR (os 3 quadrados grandes dos cantos): 7x7 quadradinhos
function desenharOlho(coluna, linha) {
  pincel.fillStyle = "#000";
  pincel.fillRect(coluna * tamanho, linha * tamanho, 7 * tamanho, 7 * tamanho);

  pincel.fillStyle = "#fff";
  pincel.fillRect((coluna + 1) * tamanho, (linha + 1) * tamanho, 5 * tamanho, 5 * tamanho);

  pincel.fillStyle = "#000";
  pincel.fillRect((coluna + 2) * tamanho, (linha + 2) * tamanho, 3 * tamanho, 3 * tamanho);
}

// Confere se a posição (coluna, linha) cai dentro de um dos 3 cantos
// (para não pintar quadradinhos aleatórios por cima dos "olhos")
function estaNoCanto(coluna, linha) {
  const noTopoEsquerdo = coluna < 8 && linha < 8;
  const noTopoDireito = coluna >= QUADRADOS - 8 && linha < 8;
  const noFundoEsquerdo = coluna < 8 && linha >= QUADRADOS - 8;
  return noTopoEsquerdo || noTopoDireito || noFundoEsquerdo;
}

function gerarQrCode() {
  // Fundo branco (também apaga o desenho anterior)
  pincel.fillStyle = "#fff";
  pincel.fillRect(0, 0, canvas.width, canvas.height);

  // Percorre a grade inteira: um laço dentro de outro laço
  // (o de fora anda pelas linhas, o de dentro pelas colunas)
  pincel.fillStyle = "#000";
  for (let linha = 0; linha < QUADRADOS; linha++) {
    for (let coluna = 0; coluna < QUADRADOS; coluna++) {
      if (estaNoCanto(coluna, linha)) continue; // pula os cantos

      // Math.random() sorteia um número entre 0 e 1.
      // Se for maior que 0.5 (50% de chance), pinta o quadradinho de preto.
      if (Math.random() > 0.5) {
        pincel.fillRect(coluna * tamanho, linha * tamanho, tamanho, tamanho);
      }
    }
  }

  desenharOlho(0, 0); // canto de cima à esquerda
  desenharOlho(QUADRADOS - 7, 0); // canto de cima à direita
  desenharOlho(0, QUADRADOS - 7); // canto de baixo à esquerda
}

document.getElementById("btn-qr").addEventListener("click", gerarQrCode);
gerarQrCode(); // desenha um QR assim que a página abre
