# Frontend Surface Discovery Flutter

## Objetivo

Este documento fecha o discovery real das superficies Flutter do `sis-mobile-flutter` antes de nova ideacao visual ou implementacao.

Ele traduz:

- a estrutura canonica descrita em `docs/SIS_MOBILE_PRODUTO_UI_CANONICO.md`
- o codigo ativo em `lib/screens/`
- a cobertura atual do laboratorio em `widgetbook/`

em uma leitura operacional unica para o proximo ciclo de frontend.

Escopo: este documento cobre principalmente as superficies SIS em `lib/screens/`.
A matriz entre SIS e DTIC fica em `PADRONIZACAO_APPS_SIS_DTIC.md`.

## Decisao de familia

### Familia dominante do produto

- `operations`

Motivo:

- a tarefa principal do app nao e navegar, buscar ou analisar metricas
- a tarefa principal e operar chamados vivos, estados, conversa, anexos e sincronizacao

### Familias de apoio

- `workspace-shell`
  - `login_screen.dart`
  - `service_catalog_screen.dart`

Regra de interpretacao:

- o produto como um todo e `operations`
- `Login` e `Catalogo` existem para dar entrada, identidade e contexto ao fluxo operacional

## Inventario de superficies

| Superficie | Arquivo principal | Surface intent | O que precisa aparecer primeiro | Acao primaria | Estados reais no codigo | Familia | Cobertura atual no Widgetbook | Risco atual |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Login | `lib/screens/login_screen.dart` | Autenticar o usuario com clareza e baixa ambiguidade | marca SIS, campos, CTA unica | entrar | idle, validacao, loading, falha via `SnackBar`, auto-login debug | `workspace-shell` | bom, com idle/loading/validation/failure | medio |
| Catalogo | `lib/screens/service_catalog_screen.dart` | Dar contexto de entidade e acesso rapido a chamados, conversas e servicos | hero operacional, entidade ativa, pendencias offline, atalhos | abrir servico ou navegar para chamados/conversas | estado carregado, entidade unica, troca de entidade, pendencia de sync, feedback via `SnackBar` | `workspace-shell` | bom, com ready/pending-sync/entity-undefined | medio |
| Meus Chamados | `lib/screens/my_tickets_screen.dart` | Ler e filtrar fila propria por status e sincronizacao | agrupamento por status, filtro, badge offline | abrir detalhe ou sincronizar | loading, error, empty, filtered empty, populated, sync pending | `operations` | bom, mas sem erro e sem offline-focused state | medio |
| Conversas Overview | `lib/screens/chat_overview_screen.dart` | Encontrar tickets abertos com conversa ativa | filtros, status e cards de tickets abertos | abrir conversa do ticket | loading, error, empty, filtered empty, populated | `operations` | bom, mas sem erro | medio |
| Detalhe do chamado | `lib/screens/ticket_detail_screen.dart` | Entender contexto completo do ticket e decidir proxima acao | status, resumo, metadata e CTA para conversa | abrir conversa, atualizar status, revisar anexos | hydrated snapshot, loading linear, offline, anexos loading, anexos empty, anexos error, requester-only, operator-actions | `operations` | bom, com operator/requester/offline/attachments-loading/attachments-error | medio |
| Conversa do chamado | `lib/screens/ticket_message_screen.dart` | Operar followups, solucoes e anexos em fluxo vivo | historico, status implcito, area de composicao | enviar mensagem, anexo ou solucao | loading, empty, sending, attachment preview, closed mode, solution mode; erro inicial nao fica modelado como estado proprio | `operations` | bom, com active/solution-pending/closed/empty/loading/error | alto |
| Formulario de solicitacao | `lib/screens/form_template.dart` | Capturar solicitacao estruturada e contextualizada | secoes, labels, obrigatoriedade e anexo | enviar solicitacao | pristine, validacao, envio, sucesso ou fallback offline via `SnackBar` | `operations` | bom, com pristine/seeded/validation-error/submitting/submitted/offline-fallback | medio |
| Fila offline | `lib/screens/offline_queue_screen.dart` | Tornar legivel o que esta pendente de sincronizacao | contador, ticket `OFFLINE-*`, contexto de entidade | sincronizar ou revisar pendencias | persistencia local, sync success/failure, decoracao de tickets offline e tela dedicada no runtime principal | `operations` | bom, com pending/syncing/error/empty no laboratorio | medio |

## Surface brief por prioridade

### 1. Login

- `surface-intent`: reduzir friccao de autenticacao e comunicar confianca institucional
- `surface-brief`: hoje a tela ja tem direcao visual melhor que o resto do app, mas ainda trata falha apenas por `SnackBar` e usa spinner inline no botao
- `major semantic risk`: falha de autenticacao e indisponibilidade de rede nao ganham estado persistente na superficie

### 2. Catalogo

- `surface-intent`: ser o shell real de entrada operacional do app
- `surface-brief`: a hero area, a entidade ativa e os atalhos para chamados/conversas definem o tom do produto inteiro
- `major semantic risk`: offline, troca de entidade e sincronizacao ainda aparecem mais como sinais auxiliares do que como contexto de trabalho principal

### 3. Meus Chamados

- `surface-intent`: permitir triagem rapida da fila propria
- `surface-brief`: e a superficie mais madura em estados reais e ja conversa bem com `SisLoadingState` e `SisEmptyState`
- `major semantic risk`: o foco entre fila viva, filtros e pendencias offline ainda compete visualmente

### 4. Conversas Overview

- `surface-intent`: separar tickets com interacao ativa do restante da fila
- `surface-brief`: hoje funciona como lista operacional de entrada para a conversa, com filtro por ID e categoria
- `major semantic risk`: continua parecendo uma variacao de lista, e nao uma fila de comunicacao com urgencia ou necessidade de resposta

### 5. Detalhe do chamado

- `surface-intent`: concentrar contexto, status, anexos e acoes sem perda de legibilidade
- `surface-brief`: e a superficie mais densa do app e hoje carrega muita responsabilidade em uma tela unica
- `major semantic risk`: mistura contexto, historico, anexos e acoes em um fluxo longo; o estado offline existe, mas ainda nao esta isolado como historia visual propria

### 6. Conversa do chamado

- `surface-intent`: sustentar o trabalho vivo de followup, solucao e anexo
- `surface-brief`: e a superficie mais critica e menos protegida por laboratorio hoje
- `major semantic risk`: erro inicial nao gera estado proprio; se a carga falha, a tela pode colapsar para vazio e mascarar problema real

### 7. Formulario

- `surface-intent`: abrir chamado com contexto, obrigatoriedade e possibilidade de fallback offline
- `surface-brief`: a tela esta bem organizada em secoes, mas o comportamento de envio e erro ainda mora em `SnackBar`
- `major semantic risk`: sucesso online, fallback offline e falha de validacao concorrem no mesmo canal de feedback

### 8. Fila offline

- `surface-intent`: dar confianca ao usuario de que o trabalho offline nao sera perdido
- `surface-brief`: agora existe uma superficie propria no runtime principal, ligada ao catalogo e a `Meus Chamados`
- `major semantic risk`: a sincronizacao ainda devolve feedback agregado; falhas por item continuam pouco explicitas

## State inventory consolidado

### Estados bem modelados

- `my_tickets_screen.dart`
  - loading, error, empty, filtered empty, populated
- `chat_overview_screen.dart`
  - loading, error, empty, filtered empty, populated
- `ticket_detail_screen.dart`
  - loading de rehydrate, offline, anexos loading, anexos empty, anexos error

### Estados parcialmente modelados

- `form_template.dart`
  - validacao e resultado existem, mas como feedback transitorio
- `login_screen.dart`
  - loading existe, mas indisponibilidade e falha nao persistem na tela
- `service_catalog_screen.dart`
  - contexto operacional existe, mas estados de vazio/erro nao sao tratados como superficie

### Estados submodelados

- `ticket_message_screen.dart`
  - nao ha erro inicial explicito na propria tela

## Domain glossary

- `entidade`
  - contexto institucional em que novos chamados serao abertos
- `sincronizacao`
  - envio de tickets locais pendentes para o GLPI
- `offline`
  - chamado salvo localmente, ainda sem representacao remota definitiva
- `followup`
  - acompanhamento enviado no fluxo da conversa
- `solucao`
  - resposta formal que pode ser aprovada ou recusada
- `solicitante`
  - usuario dono do chamado
- `tecnico responsavel`
  - operador ou equipe que assume o ticket

## Lacunas do laboratorio atual

### Cobertura atual existente

- `LoginSurface`
- `ServiceCatalogSurface`
- componentes base em `widgetbook/lib/widgetbook_app.dart`
- `MyTicketsSurface`
- `ChatOverviewSurface`
- `TicketDetailSurface`
- `TicketMessageSurface`
- `FormSurface`
- `OfflineQueueSurface`

### Cobertura importante ainda ausente

1. prova de runtime das melhorias mais criticas modeladas no laboratorio

## Sequencia recomendada de trabalho

### Ciclo 1

1. `LoginSurface` modelada no `widgetbook/`
2. `ServiceCatalogSurface` modelada no `widgetbook/`
3. goldens dessas duas superficies geradas e validadas

### Ciclo 2

1. `TicketMessageSurface` modelada no `widgetbook/`
2. erro inicial, empty real, closed mode e solution mode explicitados
3. golden dessa superficie gerada e validada

### Ciclo 3

1. `TicketDetailSurface` expandida
2. offline, anexos loading, anexos error e requester-only cobertos no laboratorio
3. golden dessa superficie atualizada e validada

### Ciclo 4

1. `FormSurface` expandida
2. validacao com erro, envio, sucesso e fallback offline cobertos no laboratorio
3. golden dessa superficie atualizada e validada

### Ciclo 5

1. `OfflineQueueSurface` modelada no `widgetbook/`
2. pending, syncing, error e empty cobertos no laboratorio
3. golden dessa superficie gerada e validada

## Gate minimo por ciclo

Cada ciclo de superficie acima deve fechar com:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1
```

Quando houver mudanca intencional de baseline:

```powershell
powershell -ExecutionPolicy Bypass -File tool\frontend\validate_widgetbook.ps1 -UpdateGoldens
```

## Decisao operacional imediata

Se o objetivo for elevar o frontend para nivel profissional sem repetir vibecoding:

- nao comecar por polimento de detalhe
- nao comecar por tokens novos sem superficie critica modelada
- usar a fila offline fechada no laboratorio como ponte para convergir superficies criticas no app principal e depois provar em runtime

Essas tres superficies definem:

- entrada
- contexto operacional
- trabalho vivo

Se elas nao estiverem protegidas por laboratorio e baseline, o resto do sistema continua sem espinha dorsal.
