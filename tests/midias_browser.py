"""Confere mídias de demonstração em banco novo e atualização não destrutiva de banco antigo."""
from pathlib import Path
from functools import partial
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from threading import Thread
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parents[1]
class Quiet(SimpleHTTPRequestHandler):
    def log_message(self,*args): pass

def main():
    servidor=ThreadingHTTPServer(('127.0.0.1',0),partial(Quiet,directory=str(ROOT)))
    Thread(target=servidor.serve_forever,daemon=True).start()
    try:
        with sync_playwright() as pw:
            navegador=pw.chromium.launch(channel='chrome',headless=True)
            contexto=navegador.new_context()
            contexto.route('https://**/*',lambda r:r.abort())
            pagina=contexto.new_page()
            erros=[]
            pagina.on('pageerror',lambda e:erros.append(str(e)))
            base=f'http://127.0.0.1:{servidor.server_port}/'
            def abrir(alvo):
                pagina.goto(base+alvo,wait_until='domcontentloaded')
                pagina.wait_for_function("document.documentElement.dataset.easPronto==='sim'")
            def banco(js):
                return pagina.evaluate("async()=>{const b=await import('./assets/js/banco.js');"+js+"}")
            abrir('index.html')
            assert banco("const d=await b.ler();return d.midias.length") == 5
            assert banco("const d=await b.ler();return d.eventos.every(e=>d.midias.some(m=>m.id===e.capaId)) && d.palestrantes.every(p=>d.midias.some(m=>m.id===p.fotoId))")
            assert pagina.locator('.cartao--evento img').count()==2
            pagina.wait_for_function("[...document.querySelectorAll('.cartao--evento img')].every(i=>i.complete&&i.naturalWidth>0)")
            abrir('evento.html?evento=semana-tecnologia')
            assert pagina.locator('.detalhe-evento-palestrantes img').count()==2
            pagina.wait_for_function("[...document.querySelectorAll('.detalhe-evento-palestrantes img')].every(i=>i.complete&&i.naturalWidth>0)")
            # Simula um banco anterior às mídias. Um upload e uma remoção explícita
            # devem ser mantidos; registros removidos não devem ser recriados.
            banco("""
                const d=await b.ler();
                const personalizada={id:'capa-personalizada',dados:d.midias[0].dados};
                for(const e of d.eventos) delete e.capaId;
                d.eventos.find(e=>e.id==='encontro-web').capaId=personalizada.id;
                d.eventos=d.eventos.filter(e=>e.id!=='oficina-robotica');
                d.palestrantes.find(p=>p.id==='palestrante-ana').fotoId=null;
                delete d.palestrantes.find(p=>p.id==='palestrante-carlos').fotoId;
                d.midias=[personalizada];
                await new Promise((resolve,reject)=>{
                    const req=indexedDB.open('eas',1);
                    req.onerror=()=>reject(req.error);
                    req.onsuccess=()=>{
                        const db=req.result;
                        const tx=db.transaction(['eventos','palestrantes','midias','meta'],'readwrite');
                        for(const nome of ['eventos','palestrantes','midias']){
                            tx.objectStore(nome).clear();
                            d[nome].forEach(r=>tx.objectStore(nome).put(r));
                        }
                        tx.objectStore('meta').delete('midias-demonstracao-v1');
                        tx.oncomplete=()=>{db.close();resolve();};
                        tx.onabort=()=>reject(tx.error);
                    };
                });
            """)
            abrir('index.html')
            assert banco("const d=await b.ler();return d.eventos.find(e=>e.id==='semana-tecnologia').capaId")=='midia-demo-semana-tecnologia'
            assert banco("const d=await b.ler();return d.eventos.find(e=>e.id==='encontro-web').capaId")=='capa-personalizada'
            assert banco("const d=await b.ler();return d.palestrantes.find(p=>p.id==='palestrante-ana').fotoId") is None
            assert banco("const d=await b.ler();return d.palestrantes.find(p=>p.id==='palestrante-carlos').fotoId")=='midia-demo-palestrante-carlos'
            assert banco("const d=await b.ler();return d.eventos.some(e=>e.id==='oficina-robotica')") is False
            assert banco("const d=await b.ler();return d.inscricoes.length===1 && d.presencas.length===1")
            assert banco("const d=await b.lerCompleto();return d.meta.some(m=>m.id==='midias-demonstracao-v1')")
            quantidade=banco("return (await b.ler()).midias.length")
            abrir('index.html')
            assert banco("return (await b.ler()).midias.length")==quantidade
            assert not erros,erros
            print('PASS: 5 mídias novas, imagens decodificadas, atualização de banco antigo, uploads e remoções preservados, registros não recriados e migração idempotente.')
            navegador.close()
    finally:
        servidor.shutdown()
if __name__=='__main__': main()
