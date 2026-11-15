"""Verificações locais de estrutura e referências; não substituem um validador HTML completo."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
from collections import Counter
import json

ROOT = Path(__file__).resolve().parents[1]
VAZIOS = {'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link',
          'meta', 'param', 'source', 'track', 'wbr'}

class Estrutura(HTMLParser):
    """Registra elementos e seus pais para conferir as regras usadas no projeto."""
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.elementos = []
        self.pilha = []

    def handle_starttag(self, tag, attrs):
        self.elementos.append((tag, dict(attrs), list(self.pilha)))
        if tag not in VAZIOS:
            self.pilha.append(tag)

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        if tag not in VAZIOS:
            self.handle_endtag(tag)

    def handle_endtag(self, tag):
        # Recupera o contexto quando o HTML usa uma tag de fechamento opcional.
        if tag in self.pilha:
            posicao = len(self.pilha) - 1 - self.pilha[::-1].index(tag)
            del self.pilha[posicao:]


def verificar():
    erros = []
    arquivos = sorted(ROOT.glob('*.html')) + sorted((ROOT / 'includes').glob('*.html'))
    for arquivo in arquivos:
        parser = Estrutura()
        texto = arquivo.read_text(encoding='utf-8')
        parser.feed(texto)
        elementos = parser.elementos
        ids = Counter(attrs['id'] for _, attrs, _ in elementos if 'id' in attrs)
        def exigir(condicao, mensagem):
            if not condicao:
                erros.append(f'{arquivo.name}: {mensagem}')
        exigir(all(qtd == 1 for qtd in ids.values()), 'há IDs repetidos')
        if arquivo.parent == ROOT:
            exigir(texto.lstrip().lower().startswith('<!doctype html>'), 'falta o doctype HTML5')
            exigir(sum(tag == 'main' for tag, _, _ in elementos) == 1, 'deve existir um main')
            exigir(any(tag == 'h1' and 'main' in pais for tag, _, pais in elementos), 'main precisa de título principal')
            exigir(any(tag == 'html' and a.get('lang') == 'pt-BR' for tag, a, _ in elementos), 'falta o idioma')
        for tag, attrs, pais in elementos:
            if tag == 'li':
                exigir(bool(pais) and pais[-1] in {'ul', 'ol', 'menu'}, 'li fora de uma lista')
            if tag in {'ul', 'ol'}:
                # A relação inversa ul dentro de li pode ser válida para uma sublista.
                # Por isso não proibimos listas aninhadas, apenas conferimos os itens.
                pass
            if tag == 'button':
                exigir(attrs.get('type') in {'button', 'submit', 'reset'}, 'botão sem tipo explícito')
            if tag == 'img':
                exigir('alt' in attrs, 'imagem sem alternativa textual')
            if tag == 'th' and 'thead' in pais:
                exigir(attrs.get('scope') == 'col', 'cabeçalho de coluna sem scope')
            if tag == 'label' and attrs.get('for'):
                exigir(attrs['for'] in ids, 'label aponta para um campo inexistente')
            exigir(not any(k.startswith('on') for k in attrs), 'evento JavaScript inline no HTML')
            for chave in ('src', 'href'):
                valor = attrs.get(chave, '')
                partes = urlsplit(valor)
                if not valor or partes.scheme or partes.netloc or not partes.path:
                    continue
                # Fragmentos includes são carregados em páginas da raiz.
                destino = ROOT / unquote(partes.path.lstrip('/'))
                exigir(destino.exists(), f'recurso local inexistente: {valor}')
    # JSON não recebe comentários: a explicação fica no README da mesma pasta.
    json.loads((ROOT / 'assets/dados/iniciais/banco.json').read_text(encoding='utf-8'))
    if erros:
        raise AssertionError('\n'.join(erros))
    print(f'PASS: estrutura e referências de {len(arquivos)} HTMLs; JSON inicial válido.')

if __name__ == '__main__':
    verificar()
