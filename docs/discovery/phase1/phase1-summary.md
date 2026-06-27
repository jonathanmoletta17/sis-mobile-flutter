# Sumario Executivo da Fase 1

## 1. Visao geral

- Data da auditoria: 2026-06-27.
- Repositorio auditado: `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.
- Escopo: Flutter app SIS/DTIC no workspace canonico e Worker SIS em `tool/external-access/workers-vpc/`.
- Entregaveis:
  - `docs/discovery/phase1/worker-current-state.md`
  - `docs/discovery/phase1/flutter-app-current-state.md`
  - `docs/discovery/phase1/gap-matrix.md`
  - `docs/discovery/phase1/phase1-summary.md`

## 2. Regras cumpridas

- Nao foram feitas chamadas ao GLPI real.
- Nao foram feitas chamadas `POST`, `PUT` ou `DELETE` contra GLPI.
- Nao foi lido nem copiado o `.env` real.
- Nao foram alterados arquivos de codigo Flutter, Worker, testes ou configuracao runtime.
- A auditoria se baseou em leitura estatica de codigo, docs e `.env.example`.

## 3. Achados principais

1. Worker existe e ja tem allowlist operacional.
   - Bloqueia metodos destrutivos e rotas orfas conhecidas.
   - Injeta `GLPI_APP_TOKEN` sem expor valor no app.
   - Mantem FormCreator write bloqueado por default.

2. App Flutter ainda opera majoritariamente em semantica GLPI direta.
   - `GlpiConfig` usa `SIS_GLPI_BASE_URL`/`GLPI_BASE_URL`.
   - Se essa base apontar para o Worker, o Worker funciona como pass-through compatível com GLPI.
   - Nao ha API mobile propria para `capabilities`, outbox ou anexo proxy.

3. Offline atual e parcial.
   - Existe fila de criacao de chamados em `SharedPreferences`.
   - Nao existe outbox generica para followup, solucao, status, atribuicao e upload.
   - Nao existe idempotencia local+server-side para impedir duplicidade apos timeout.

4. Anexos estao melhores no upload do que no download.
   - Upload valida `Document_Item` e aborta se nao houver vinculo verificavel.
   - Download ainda usa `/Document/{id}` e abertura local por plataforma.
   - PWA usa `Blob`/anchor, enquanto APK grava arquivo temporario e chama `open_filex`.
   - Isso torna plausivel que PDF/video/documento falhem no PWA mesmo quando APK se comporta diferente.

5. Status e atribuicao existem, mas nao como capability explicita.
   - Mudar para `Em Atendimento` tenta atribuir o tecnico e confirma por read-back.
   - A UX ainda depende de "alterar status" para representar "assumir chamado".

## 4. Riscos criticos

| Risco | Severidade | Confianca | Motivo |
|---|---|---:|---|
| Duplicidade em sincronizacao offline | Alta | Alta | Sem idempotencia persistente no Worker e sem outbox transacional no app. |
| Perda/falha de anexo offline no PWA | Alta | Alta | Bytes grandes sao descartados e path local nao e relivel no Web. |
| Download de documento sem validacao cruzada | Alta | Alta | Worker permite `/Document/{id}` sem provar relacao com o ticket solicitado. |
| UI divergente de permissao real GLPI | Media/Alta | Alta | Nao ha `capabilities` por ticket; regras ficam distribuidas no app. |
| FormCreator especializado cair em fluxo errado | Media/Alta | Media | Existem gates, mas nao matriz runtime completa de suporte por formulario. |

## 5. Decisoes para iniciar a Fase 2

- Confirmar se o Worker SIS sera a rota canonica tambem para APK, ou apenas para PWA/acesso externo.
- Escolher storage de idempotencia do Worker: D1, Durable Object, KV com cautela, ou outro backend persistente.
- Definir schema de `idempotency_registry`: chave, user/session, payload hash, status, glpi result id, erro terminal/retryable e expiracao.
- Definir contrato `/mobile/config/snapshot` para categorias, formularios, status, transicoes e versao de contrato.
- Definir contrato `/mobile/tickets/{id}/capabilities`.
- Definir proxy de anexo com `ticket_id`, `document_id`, JWT/escopo, validacao `GET Ticket` e `Document_Item`.
- Definir se o app usara Drift/sqflite ou outra persistencia para `outbox_actions`.
- Definir politica de anexos offline no PWA: suportar com storage adequado ou bloquear de forma clara antes da perda.
- Definir matriz FormCreator: `unsupported`, `native_supported`, `webview_supported`, `discovery_required`, `specialized_flow_required`, `blocked`.

## 6. Validacoes executadas nesta fase

- Leitura de docs obrigatorios do repo: `BOOTSTRAP.md`, `README.md`, `docs/README.md`, `docs/RUNTIME_CANONICO_E_VALIDACAO.md`.
- Leitura estatica dos principais arquivos Flutter de config, estado, tickets, anexos, status, offline e abertura de arquivo.
- Leitura estatica do Worker SIS e seus testes de allowlist.
- Sem execucao de `flutter analyze`/`flutter test`, porque a alteracao e documental e read-only em relacao ao codigo.

## 7. Aprovacao

- [ ] Desenvolvedor Flutter
- [ ] Desenvolvedor Backend/Worker
- [ ] Arquiteto/Tech Lead
- [ ] Responsavel operacional SIS/GLPI
