# Mídias da demonstração

Imagens criadas com a ferramenta integrada image_gen. As capas representam os temas
dos eventos; os retratos ilustram personagens fictícios e não são fotos das pessoas reais.
Os prompts completos e a identificação da ferramenta estão em [prompts.json](prompts.json).

| Arquivo | Registro de destino |
| --- | --- |
| semana-tecnologia.jpg | Semana de Tecnologia e Inovação 2026 |
| encontro-web.jpg | Encontro de Desenvolvimento Web |
| oficina-robotica.jpg | Oficina de Robótica |
| palestrante-ana.jpg | Ana Paula Ribeiro |
| palestrante-carlos.jpg | Carlos Eduardo Lima |

Os JPEGs mantêm as dimensões das imagens geradas, com codificação otimizada para o
site. Todos têm menos de 2 MB. O JSON inicial inclui seu conteúdo em data URLs na
coleção midias e os IDs correspondentes em capaId e fotoId.

Em bancos já inicializados, `aplicarMidiasPadrao` complementa os registros originais
que ainda não possuem o campo de imagem. Não recria registros excluídos, não altera
inscrições e não substitui imagens personalizadas nem campos removidos com null.
Um marcador em meta evita repetir a atualização. O manifesto usado nesse processo
fica em `assets/dados/iniciais/midias-padrao.json`.
