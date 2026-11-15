# Verificação dos fluxos

Primeiro execute `py -3 tests/estrutura_html.py`. Essa verificação usa apenas a
biblioteca padrão do Python e confere doctype, região principal, IDs, listas,
rótulos, botões, imagens, cabeçalhos de tabela, referências locais e o JSON inicial.
É uma conferência das regras usadas pelo projeto, não um validador HTML completo.

Instale Playwright para Python (`py -3 -m pip install playwright`) e mantenha o
Google Chrome instalado. Execute na raiz: `py -3 tests/fluxos_browser.py`.

O teste abre um servidor HTTP temporário e um perfil isolado do Chrome em modo
headless. Não usa nem modifica o banco do navegador pessoal. Bloqueia as CDNs
de apresentação e fixa a data em 14/11/2026 para testar os cenários do banco inicial.

Cobre cadastro, login, criação e edição de evento, atividade, inscrição, vagas,
permissões, credenciamento, presença, certificados, perfil, recuperação de senha,
importação com rollback, persistência após recarregamento, páginas e tema móvel.

Também confere prévia de upload, capa no catálogo e no carrossel, restauração da
imagem ao editar, remoção e substituição de foto e rejeição de arquivos corrompidos.

Execute `py -3 tests/midias_browser.py` para conferir as cinco mídias iniciais e a
atualização de bancos antigos. O teste confirma que uploads, remoções intencionais,
inscrições e presenças são preservados e que repetir a abertura não duplica mídias.
