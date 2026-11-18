"""Regressão dos fluxos locais. Requer Python, playwright e Chrome instalado."""
from pathlib import Path
from functools import partial
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from threading import Thread
from datetime import datetime, timezone
from playwright.sync_api import sync_playwright
import json, base64

# Caminho da raiz calculado a partir do próprio teste; não depende da pasta do terminal.
ROOT = Path(__file__).resolve().parents[1]
# Servidor de arquivos local. O log é reduzido para destacar os resultados dos testes.
class Handler(SimpleHTTPRequestHandler):
    def log_message(self, *args): pass

# Este teste usa um perfil isolado, não o banco do navegador pessoal.
def main():
    # A porta 0 pede ao sistema uma porta livre, evitando conflito com Live Server.
    server = ThreadingHTTPServer(('127.0.0.1', 0), partial(Handler, directory=str(ROOT)))
    Thread(target=server.serve_forever, daemon=True).start()
    base = f'http://127.0.0.1:{server.server_port}/'
    try:
        with sync_playwright() as pw:
            browser = pw.chromium.launch(channel='chrome', headless=True)
            context = browser.new_context(timezone_id='America/Sao_Paulo')
            # Bloqueia CDNs visuais: as regras da aplicação devem funcionar sem esses recursos.
            context.route('https://**/*', lambda route: route.abort())
            page = context.new_page()
            # Data fixa torna previsíveis os prazos e o evento encerrado da demonstração.
            page.clock.install(time=datetime(2026, 11, 14, 15, tzinfo=timezone.utc))
            errors = []
            page.on('pageerror', lambda e: errors.append(str(e)))
            # Navega e aguarda o sinal de inicialização do app, não apenas o download do HTML.
            def goto(path):
                page.goto(base+path, wait_until='domcontentloaded', timeout=60000)
                page.wait_for_function("['sim','erro'].includes(document.documentElement.dataset.easPronto)")
                assert page.locator('html').get_attribute('data-eas-pronto') == 'sim', page.locator('.eas-mensagem').all_text_contents()
            # Chama serviços no navegador para conferir os registros e testar falhas controladas.
            def service(js, arg=None):
                return page.evaluate("async arg => { const b = await import('./assets/js/banco.js'); "+js+" }",arg)
            # Faz login pelos controles reais, verificando o redirecionamento ao catálogo.
            def login(mail):
                goto('login.html')
                page.locator('#usuario').fill(mail)
                page.locator('#senha').fill('Demo123!')
                page.locator('#login-form button[type=submit]').click()
                page.wait_for_url(base+'index.html')
                page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            # O rodapé compartilhado deve abrir uma única cópia de cada modal,
            # inclusive na Central de Ajuda, que antes tinha diálogos próprios.
            def verificar_rodape():
                ids = page.locator('[id]').evaluate_all('(els) => els.map(el => el.id)')
                assert len(ids) == len(set(ids)), f'IDs repetidos em {page.url}'
                endereco = page.url
                for nome, chave in [('Sobre', 'sobre'), ('Contato', 'contato'), ('Termos', 'termos')]:
                    modal = page.locator('#modal-'+chave)
                    assert modal.count() == 1
                    page.locator('.footer-nav').get_by_role('link', name=nome, exact=True).click()
                    modal.wait_for(state='visible')
                    assert modal.get_attribute('open') is not None
                    assert page.url == endereco
                    assert modal.locator('h2').inner_text()
                    modal.get_by_role('button', name='Fechar', exact=True).click()
                    modal.wait_for(state='hidden')
                contato = page.locator('#modal-contato')
                assert contato.locator('a[href^="mailto:"]').get_attribute('href') == 'mailto:equipe.eas10@gmail.com'
                page.locator('.footer-nav').get_by_role('link', name='Contato', exact=True).click()
                page.keyboard.press('Escape')
                contato.wait_for(state='hidden')
                page.locator('.footer-nav').get_by_role('link', name='Contato', exact=True).click()
                contato.wait_for(state='visible')
                page.mouse.click(1, 1)
                contato.wait_for(state='hidden')
                page.locator('.footer-nav').get_by_role('link', name='Contato', exact=True).click()
                contato.get_by_role('link', name='Abrir Central de Ajuda').click()
                page.wait_for_url(base+'central-ajuda.html')
                page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
                assert page.locator('dialog[open]').count() == 0
                print('PASS: modais do rodapé, IDs únicos, fechamento e acesso à ajuda', flush=True)
            # Catálogo, acesso anônimo e autenticação: nenhum dado de senha deve entrar na URL.
            goto('index.html')
            verificar_rodape()
            goto('index.html')
            assert page.locator('.cartao--evento').count() == 2
            capasPublicasIniciais = page.locator('.cartao--evento img').count()
            assert service("return b.hoje()") == '2026-11-14'
            page.goto(base+'gerenciamento-evento.html', wait_until='domcontentloaded')
            page.wait_for_url('**/login.html?retorno=**')
            goto('login.html')
            page.locator('#usuario').fill('organizador@eas.test')
            page.locator('#senha').fill('invalida')
            page.locator('#login-form button[type=submit]').click()
            page.locator('.eas-mensagem--erro').wait_for()
            assert '?' not in page.url
            login('organizador@eas.test')
            assert service("return (await b.ler()).usuarios.every(u => !u.senhaInicial && u.credencial.hash.length === 64)")
            midiasIniciais = service("return (await b.ler()).midias.length")
            capasIniciais = service("return (await b.ler()).eventos.filter(e=>e.capaId).length")
            print('PASS: login e inicialização', flush=True)
            for path in ['gerenciamento-evento','gerenciamento-equipe','programacao-evento','credenciamento','frequencia','cadastrar-palestrante']:
                goto(path+'.html?evento=semana-tecnologia')
            # Cria um evento pelo formulário; testa capa, gravação e vínculo da atividade.
            goto('criar-evento.html')
            for key,value in {'nome-evento':'Evento QA','data-inicio':'2026-11-25','data-termino':'2026-11-25','local-evento':'Sala QA','descricao-evento':'Teste de persistência','prazo-inscricao':'2026-11-24','limite-vagas':'1'}.items():
                page.locator('#'+key).fill(value)
            page.locator('#categoria-evento').select_option('tecnologia')
            imagem={'name':'capa.png','mimeType':'image/png','buffer':base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aX1cAAAAASUVORK5CYII=')}
            page.locator('#imagem-capa').set_input_files(imagem)
            page.wait_for_function("document.querySelector('.eas-upload-previa img').naturalWidth > 0")
            page.locator('button[value=publicar]').click()
            page.wait_for_url('**/gerenciamento-evento.html?evento=*')
            eid=service("return (await b.ler()).eventos.find(e=>e.nome==='Evento QA').id")
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            assert 'Evento salvo!' in page.locator('.eas-mensagem').inner_text()
            assert page.locator('.integrantes-equipe tbody img').count() == capasIniciais + 1
            # Se os dados do evento forem inválidos, a imagem não deve ser gravada sozinha.
            assert service("const antes=(await b.ler()).midias.length; const blob=await (await fetch('data:image/png;base64,'+arg)).blob(); try { await b.salvarEvento({nome:'Inválido',status:'rascunho',vagas:0},null,new File([blob],'capa.png',{type:'image/png'})); return false; } catch(e) { return (await b.ler()).midias.length===antes; }",base64.b64encode(imagem['buffer']).decode())
            goto('adicionar-atividade.html?evento='+eid)
            for key,value in {'nome-atividade':'Atividade QA','data-atividade':'2026-11-25','horario-inicio':'09:00','horario-termino':'10:00','local-atividade':'Sala QA','limite-vagas-atividade':'1'}.items():
                page.locator('#'+key).fill(value)
            page.locator('#tipo-atividade').select_option('palestra')
            page.locator('.botao-novo-palestrante').click()
            page.wait_for_url('**/cadastrar-palestrante.html?evento=*')
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            page.locator('#nome-palestrante').fill('Palestrante QA')
            page.locator('#foto-palestrante').set_input_files(imagem)
            page.locator('#form-cadastrar-palestrante button[type=submit]').click()
            page.wait_for_url('**/adicionar-atividade.html?evento=*')
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            assert page.locator('#nome-atividade').input_value() == 'Atividade QA'
            assert page.locator('[name="palestrantes[]"]:checked').count() == 1
            page.locator('[name="palestrantes[]"]').first.check()
            page.locator('button[value=cadastrar]').click()
            page.wait_for_url('**/programacao-evento.html?evento=*')
            aid=service("return (await b.ler()).atividades.find(a=>a.nome==='Atividade QA').id")
            goto('evento.html?evento='+eid)
            assert page.locator('#event-detail-name').inner_text() == 'Evento QA'
            assert page.locator('.detalhe-evento-capa img').get_attribute('src').startswith('data:image/png;base64,')
            goto('index.html')
            assert page.locator('.cartao--evento img').count() == capasPublicasIniciais + 1
            page.reload()
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            assert page.locator('.cartao--evento',has_text='Evento QA').locator('img').count() == 1
            assert 'Evento A' not in page.locator('main').inner_text()
            for _ in range(3):
                if page.locator('.destaque-imagem img').count(): break
                page.locator('.botao-icone--carrossel').last.click()
            assert page.locator('.destaque-imagem img').count() == 1
            goto('criar-evento.html?evento='+eid)
            assert page.locator('#nome-evento').input_value() == 'Evento QA'
            assert page.locator('.eas-upload-previa img').get_attribute('src').startswith('data:image/png;base64,')
            # Editar uma foto deve preservar o palestrante e trocar somente a referência da imagem.
            pid=service("return (await b.ler()).palestrantes.find(p=>p.nome==='Palestrante QA').id")
            goto('cadastrar-palestrante.html?palestrante='+pid)
            assert page.locator('.eas-upload-previa img').get_attribute('src').startswith('data:image/png;base64,')
            page.get_by_role('button',name='Remover imagem').click()
            page.locator('#form-cadastrar-palestrante button[type=submit]').click()
            page.wait_for_url('**/cadastrar-palestrante.html')
            assert service("return (await b.ler()).palestrantes.find(p=>p.id===arg).fotoId === null",pid)
            goto('cadastrar-palestrante.html?palestrante='+pid)
            page.locator('#foto-palestrante').set_input_files(imagem)
            page.locator('#form-cadastrar-palestrante button[type=submit]').click()
            page.wait_for_url('**/cadastrar-palestrante.html')
            assert service("return Boolean((await b.ler()).palestrantes.find(p=>p.id===arg).fotoId)",pid)
            assert service("try { await b.salvarImagem(new File(['invalida'], 'foto.png', {type:'image/png'})); return false; } catch(e) { return true; }")
            # Alterna o perfil: a mesma base local precisa atender participante e organização.
            login('participante@eas.test')
            goto('inscricao-atividade-evento.html?evento='+eid)
            page.locator('[name=atividades]').check()
            page.locator('#form-inscricao button[type=submit]').click()
            page.wait_for_url('**/meus-eventos.html')
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            iid=service("return (await b.ler()).inscricoes.find(i=>i.eventoId===arg).id",eid)
            assert service("return await b.inscrever(arg.e,[arg.a])",{'e':eid,'a':aid}) == iid
            page.reload()
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            assert 'Evento QA' in page.locator('#meus-eventos').inner_text()
            assert service("try { await b.credenciar(arg); return false; } catch(e) { return e.message.includes('permissão'); }",iid)
            # Uma segunda conta tenta entrar no evento lotado; a operação deve ser recusada.
            goto('cadastro.html')
            for key,value in {'cadastro-nome':'Pessoa QA','cadastro-identificacao':'qa@eas.test','cadastro-senha':'Demo123!','cadastro-confirmar-senha':'Demo123!'}.items():
                page.locator('#'+key).fill(value)
            page.locator('#form-cadastro button[type=submit]').click()
            page.wait_for_url(base+'index.html')
            assert service("try { await b.inscrever(arg.e,[arg.a]); return false; } catch(e) { return e.message.includes('sem vagas'); }",{'e':eid,'a':aid})
            login('organizador@eas.test')
            # Valida chegada, presença e vínculo de equipe pelo fluxo da organização.
            goto('credenciamento.html?evento='+eid)
            page.locator('#busca-participante').fill('participante@eas.test')
            # A confirmação recarrega a página. Aguarde essa navegação antes de
            # consultar o banco: o sinal da página anterior ainda pode estar visível.
            with page.expect_navigation(wait_until='domcontentloaded'):
                page.get_by_role('button', name='Confirmar credenciamento').click()
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            page.wait_for_function("document.querySelectorAll('.tabela-painel tbody tr').length === 1")
            assert service("return (await b.ler()).credenciamentos.some(c=>c.inscricaoId===arg)",iid)
            goto('frequencia.html?evento='+eid)
            page.locator('[data-presenca]').check()
            page.wait_for_function("document.querySelector('#resumo-frequencia').textContent.includes('1 presentes')")
            assert service("return (await b.ler()).presencas.some(p=>p.inscricaoId===arg)",iid)
            goto('gerenciamento-equipe.html?evento='+eid)
            page.locator('.btn-painel').click()
            page.locator('#membro-email').fill('qa@eas.test')
            page.locator('#membro-funcao').select_option('credenciamento')
            page.locator('#membro-horas').fill('2')
            page.locator('#membro-validado').check()
            page.locator('#form-membro button[type=submit]').click()
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim' && !document.querySelector('#eas-membro').open")
            assert service("return (await b.ler()).equipe.some(m=>m.eventoId===arg && m.horas===2 && m.validado)",eid)
            print('PASS: evento, atividade, inscrição, capacidade e frequência', flush=True)
            assert service("try { await b.emitirCertificados(arg); return false; } catch(e) { return e.message.includes('encerramento'); }",eid)
            goto('gerenciamento-evento.html?evento=encontro-web')
            page.get_by_role('button',name='Emitir certificados dos participantes').click()
            page.locator('.eas-mensagem').wait_for()
            assert service("return (await b.ler()).certificados.length") == 1
            assert service("return await b.emitirCertificados('encontro-web')") == 0
            login('participante@eas.test')
            goto('certificados.html')
            with page.expect_download() as dl:
                page.locator('[data-certificado]').click()
            assert dl.value.suggested_filename.endswith('.html')
            goto('gerenciamento-conta.html')
            page.locator('#nome-tela').fill('Apelido QA')
            page.locator('.caixa button[type=submit]').click()
            page.locator('.eas-mensagem').wait_for()
            page.reload(); page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            assert page.locator('#nome-tela').input_value() == 'Apelido QA'
            # Exporta uma cópia e tenta importar versões inválidas: falhas não podem apagar os registros.
            exported=service("return await b.exportar()")
            assert len(exported['colecoes']['midias']) == midiasIniciais + 3
            invalid=json.loads(json.dumps(exported)); invalid['colecoes']['inscricoes'][0]['eventoId']='inexistente'
            assert service("try { await b.importar(arg); return false; } catch(e) { return true; }",invalid)
            assert service("return (await b.ler()).certificados.length") == 1
            malformed=json.loads(json.dumps(exported)); del malformed['colecoes']['eventos'][0]['nome']
            assert service("try { await b.importar(arg); return false; } catch(e) { return true; }",malformed)
            # Unique-index failures also roll back the complete replacement.
            duplicate=json.loads(json.dumps(exported)); duplicate['colecoes']['usuarios'][1]['email']=duplicate['colecoes']['usuarios'][0]['email']
            assert service("try { await b.importar(arg); return false; } catch(e) { return true; }",duplicate)
            assert service("return (await b.ler()).usuarios.length") == len(exported['colecoes']['usuarios'])
            service("await b.importar(arg)",exported)
            assert service("return b.usuarioAtual(await b.ler()) === null")
            login('participante@eas.test')
            # Exercita geração do código demonstrativo e troca efetiva da credencial.
            goto('recuperar-senha.html')
            page.locator('#campo-email').fill('qa@eas.test')
            page.locator('#form-recuperar-senha button[type=submit]').click()
            page.wait_for_url('**/verificar-codigo.html')
            page.wait_for_function("document.documentElement.dataset.easPronto === 'sim'")
            code=page.evaluate("JSON.parse(sessionStorage.getItem('eas-recuperacao')).codigo")
            for i,digit in enumerate(code): page.locator('.campo-codigo').nth(i).fill(digit)
            page.locator('#nova-senha').fill('Nova123!')
            page.locator('#confirmar-nova-senha').fill('Nova123!')
            page.locator('#form-verificar-codigo button[type=submit]').click()
            page.wait_for_url('**/login.html')
            assert service("return await b.entrar('qa@eas.test','Nova123!')") is not None
            print('PASS: certificados, conta, importação e recuperação', flush=True)
            login('organizador@eas.test')
            # Every HTML page initializes without JavaScript exceptions.
            # Abre as páginas para identificar exceções e verifica navegação móvel no final.
            for f in ROOT.glob('*.html'):
                path=f.name
                if path in ['evento.html','inscricao-atividade-evento.html','editar-atividade-evento.html','adicionar-atividade.html','programacao-evento.html','gerenciamento-equipe.html','credenciamento.html','frequencia.html']:
                    path+='?evento=semana-tecnologia'
                if f.name=='verificar-codigo.html': continue
                goto(path)
            goto('index.html')
            page.set_viewport_size({'width':390,'height':844})
            goto('gerenciamento-evento.html?evento='+eid)
            assert page.evaluate('document.documentElement.scrollWidth <= innerWidth+1')
            goto('central-ajuda.html')
            verificar_rodape()
            initial=page.locator('html').get_attribute('data-theme')
            page.locator('#menu-toggle').click()
            page.locator('.theme-button').click()
            assert page.locator('html').get_attribute('data-theme') != initial
            artefatos=ROOT/'.tmp'; artefatos.mkdir(exist_ok=True)
            page.screenshot(path=str(artefatos/'mobile.png'),full_page=True)
            page.set_viewport_size({'width':1440,'height':900})
            goto('gerenciamento-evento.html?evento='+eid)
            page.screenshot(path=str(artefatos/'desktop.png'),full_page=True)
            if errors: raise AssertionError(errors)
            # A interface não pode inventar cartões quando o banco não tem eventos públicos.
            service("const copia=await b.exportar(); copia.colecoes.eventos.forEach(e=>e.visibilidade='privado'); await b.importar(copia);")
            goto('index.html')
            assert page.locator('.cartao--evento').count() == 0
            assert 'Nenhum evento encontrado' in page.locator('.grade--eventos').inner_text()
            print('PASS: autenticação, cadastro, eventos, atividades, inscrições, capacidade, permissões, credenciamento, frequência, certificados, conta, recuperação, importação atômica, persistência e navegação.')
            browser.close()
    # O servidor deve encerrar mesmo se uma asserção falhar.
    finally:
        server.shutdown()
if __name__=='__main__': main()
