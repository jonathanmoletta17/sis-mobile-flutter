# SIS: plano de fallback web mobile-first

## Decisao

Sim: o canal alternativo correto para a SIS e uma **web mobile-first**.

Nao e uma substituicao definitiva do mobile nativo. E um fallback operacional para:
- computadores da rede interna
- notebooks conectados ao ambiente corporativo
- navegadores mobile quando o acesso de rede estiver resolvido

## Por que isso faz sentido

Hoje o maior bloqueio da SIS no celular nao e a regra de negocio. E o acesso ao GLPI interno.

Uma web mobile-first ajuda porque:
- roda bem em computador da rede interna
- evita depender de APK para cada homologacao
- reaproveita mais facilmente o contrato HTTP atual
- pode servir como caminho estavel enquanto o mobile nativo amadurece

## Regra principal

A web nao pode nascer como um frontend separado com regra propria.

Ela precisa compartilhar:
- mesmo contrato de autenticacao
- mesma regra de entidade
- mesma taxonomia de servicos/categorias/localizacoes
- mesma regra de criacao online/offline, quando aplicavel
- mesma governanca de erros

## Fonte de reaproveitamento

Ja existe uma base web relevante em:
- [hub_dtic_and_sis/web](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web)

Pontos importantes dessa base:
- stack: Next.js
- contrato HTTP ja modelado
- login/contexto real
- modulo SIS existente
- fluxo de ticket real
- testes e smoke em UI

Arquivos particularmente uteis:
- [src/lib/api/httpClient.ts](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\lib\api\httpClient.ts)
- [src/lib/api/glpiService.ts](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\lib\api\glpiService.ts)
- [src/lib/api/ticketService.ts](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\lib\api\ticketService.ts)
- [src/lib/api/ticketWorkflowService.ts](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\lib\api\ticketWorkflowService.ts)
- [src/app/[context]/new-ticket](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\app\[context]\new-ticket)
- [src/app/[context]/ticket](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\app\[context]\ticket)
- [src/hooks/useServiceCatalog.ts](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\hooks\useServiceCatalog.ts)
- [src/lib/auth/contextSessionBootstrap.ts](C:\Users\jonathan-moletta\code\_archive\hub_dtic_and_sis\web\src\lib\auth\contextSessionBootstrap.ts)

## Caminho recomendado

### Fase 1: web como fallback operacional

Objetivo:
- entregar uma interface responsiva para abrir e acompanhar chamados SIS
- priorizar funcionamento em notebook/desktop interno e leitura boa em tela pequena

Escopo minimo:
- login
- seletor de contexto
- catalogo de servicos SIS
- abrir chamado
- meus chamados
- detalhe do ticket
- followup
- anexo

Nao incluir nesta fase:
- offline
- push
- recursos exclusivos de app nativo

### Fase 2: consolidacao mobile-first

Objetivo:
- garantir boa usabilidade em celular no navegador
- tratar layout, densidade, upload de arquivo e navegacao

Escopo:
- responsividade real
- formularios com toque e teclado em foco
- upload de imagem/documento
- feedback de erro e loading

### Fase 3: decisao de produto

Objetivo:
- decidir se a web mobile-first vira:
  - fallback oficial
  - canal principal interno
  - ou companheira do app nativo

## O que deve ser reaproveitado do web existente

Reaproveitar:
- cliente HTTP
- fluxo de autenticacao/contexto
- tipos e contratos
- services de ticket
- bootstrap de sessao por contexto
- smoke tests e validacoes

Nao reaproveitar automaticamente:
- visual pesado ou desktop-first
- modulos nao relacionados a SIS
- areas de analytics, inventario ou gestao de carregadores

## O que nao deve ser repetido

Nao duplicar no novo canal:
- regra de entidade separada
- ids hardcoded espalhados em dois frontends
- contratos divergentes entre mobile e web
- mensagens de erro inconsistentes

## Regras de consistencia obrigatorias

1. A entidade escolhida ou resolvida precisa governar toda mutacao critica.
2. O frontend nao pode depender de entidade implicita de sessao sem validacao explicita.
3. A criacao de ticket precisa usar o mesmo contrato em todos os canais.
4. Categorias e localizacoes precisam ter uma unica fonte de verdade.
5. O fallback web nao pode virar um produto paralelo sem governanca.

## Recomendacao objetiva

Se a meta for garantir operacao enquanto o mobile nativo ainda depende de infraestrutura:

1. use o frontend web existente como base tecnica
2. recorte apenas o modulo SIS necessario
3. trate como **web mobile-first**
4. mantenha um unico contrato de negocio
5. valide primeiro em notebook da rede interna
6. depois refine o uso em navegador mobile

## Proximo passo

Antes de implementar:
- auditar o modulo web SIS atual
- separar o que ja existe e o que esta acoplado ao restante do hub
- definir um escopo minimo de fallback web para SIS
