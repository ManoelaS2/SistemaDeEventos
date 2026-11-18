/**
 * Consulta simples do IndexedDB: cada coleção vira uma seção e cada registro vira
 * uma linha. Não usa app.js, não exige login e não oferece edição ou exclusão.
 * textContent apresenta os valores como texto, sem interpretar HTML salvo no banco.
 */
import {lerCompleto} from './banco.js';

const destino = document.getElementById('colecoes-banco');
const indice = document.getElementById('indice-colecoes');
const estado = document.getElementById('estado-consulta');
const atualizar = document.getElementById('atualizar-banco');

/** Cria elementos com texto, mantendo os dados separados da marcação HTML. */
function elemento(tag, texto) {
  const el = document.createElement(tag);
  if (texto !== undefined) el.textContent = texto;
  return el;
}

/**
 * Mostra objetos e arrays como JSON legível, sem perder sua estrutura.
 * Textos extensos ficam em details para a tabela continuar fácil de consultar.
 * O conteúdo completo continua disponível, incluindo os dados das imagens.
 */
function mostrarValor(celula, valor) {
  if (valor === undefined) {
    celula.textContent = '(campo ausente)';
    return;
  }
  if (typeof valor === 'string' && /^data:image\/(png|jpeg|webp);base64,/.test(valor)) {
    const img = elemento('img');
    img.src = valor;
    img.alt = 'Imagem armazenada neste registro';
    img.width = 120;
    img.loading = 'lazy';
    celula.append(img);
  }
  const texto = typeof valor === 'string' ? (valor === '' ? '""' : valor) : JSON.stringify(valor, null, 2);
  if (texto.length > 160) {
    const detalhes = elemento('details');
    detalhes.append(elemento('summary', `Ver conteúdo completo (${texto.length} caracteres)`), elemento('pre', texto));
    celula.append(detalhes);
  } else {
    celula.append(elemento('pre', texto));
  }
}

/**
 * A união das chaves inclui campos opcionais que só existem em alguns registros.
 * A coluna id vem primeiro; os demais campos mantêm a ordem em que foram encontrados.
 */
function montarColecao(nome, registros, numero) {
  const secao = elemento('section');
  secao.id = `colecao-${numero}`;
  secao.append(elemento('h2', `${nome} (${registros.length} registros)`));
  const item = elemento('li');
  const link = elemento('a', `${nome} (${registros.length})`);
  link.href = `#${secao.id}`;
  item.append(link);
  indice.append(item);

  if (!registros.length) {
    secao.append(elemento('p', 'Nenhum registro salvo nesta coleção.'));
    return secao;
  }
  const campos = [...new Set(registros.flatMap(registro => Object.keys(registro)))];
  const posicaoId = campos.indexOf('id');
  if (posicaoId > 0) {
    campos.splice(posicaoId, 1);
    campos.unshift('id');
  }
  const tabela = elemento('table');
  tabela.append(elemento('caption', `Registros da coleção ${nome}`));
  const cabecalho = elemento('thead');
  const titulos = elemento('tr');
  campos.forEach(campo => {
    const th = elemento('th', campo);
    th.scope = 'col';
    titulos.append(th);
  });
  cabecalho.append(titulos);
  const corpo = elemento('tbody');
  registros.forEach(registro => {
    const linha = elemento('tr');
    campos.forEach(campo => {
      const celula = elemento('td');
      mostrarValor(celula, registro[campo]);
      linha.append(celula);
    });
    corpo.append(linha);
  });
  tabela.append(cabecalho, corpo);
  secao.append(tabela);
  return secao;
}

/** Relê o banco ao abrir a página e sempre que o botão Atualizar for acionado. */
async function consultar() {
  atualizar.disabled = true;
  destino.setAttribute('aria-busy', 'true');
  estado.textContent = 'Consultando os registros…';
  try {
    const dados = await lerCompleto();
    destino.replaceChildren();
    indice.replaceChildren();
    const colecoes = Object.entries(dados);
    colecoes.forEach(([nome, registros], i) => destino.append(montarColecao(nome, registros, i)));
    const total = colecoes.reduce((soma, [, registros]) => soma + registros.length, 0);
    estado.textContent = `${colecoes.length} coleções · ${total} registros · Atualizado em ${new Date().toLocaleString('pt-BR')}.`;
    document.documentElement.dataset.easPronto = 'sim';
  } catch (erro) {
    estado.textContent = `Não foi possível consultar o banco: ${erro.message}`;
    document.documentElement.dataset.easPronto = 'erro';
  } finally {
    atualizar.disabled = false;
    destino.setAttribute('aria-busy', 'false');
  }
}

atualizar.addEventListener('click', consultar);
window.easPronto = consultar();
