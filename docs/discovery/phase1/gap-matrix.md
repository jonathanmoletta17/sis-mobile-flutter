# Matriz de Lacunas

## Escopo

Auditoria read-only feita no workspace canonico `/home/jonathan/projects/work/mobile/sis-mobile-flutter`.
Nao houve chamada ao GLPI real, nao houve leitura de `.env` real e nao houve alteracao de codigo Flutter/Worker.

## Gaps principais

| ID | Categoria | Lacuna atual | Impacto atual | Solucao proposta | Fase sugerida | Evidencia |
|---|---|---|---|---|---|---|
| G1 | Idempotencia | Worker nao possui registry persistente por `X-Idempotency-Key`. | Timeouts podem gerar duplicidade em criacao/followup/status/anexo. | `idempotency_registry` com hash de payload, resultado GLPI e classificacao terminal/retryable. | Fase 2/5 | `tool/external-access/workers-vpc/src/index.js:31` |
| G2 | Offline | App possui fila apenas para criacao de ticket em `SharedPreferences`. | Nao suporta cadeia offline de followup, status, atribuicao, solucao e anexos dependentes. | Outbox local transacional com dependencias e retry controlado. | Fase 5 | `lib/state/app_state_storage.dart:30`, `lib/state/app_state.dart:919` |
| G3 | Offline/anexos | Bytes acima de 10 MB sao removidos da fila; no Web/PWA path local nao pode ser relido. | Anexos grandes podem ser perdidos ou virar chamado sincronizado com aviso. | Politica explicita por plataforma: persistir em store adequada, limitar antes do envio, ou bloquear offline com anexo grande no PWA. | Fase 5 | `lib/state/app_state_storage.dart:32`, `lib/state/app_state.dart:946` |
| G4 | Anexos/seguranca | Download de documento usa `/Document/{id}` sem proxy proprio validando `ticket_id` + `document_id`. | Risco de acesso cruzado se alguem obtiver/forcar ID de documento com sessao valida. | Proxy `/mobile/tickets/{ticket_id}/documents/{document_id}/download` com JWT e checagem `Document_Item`. | Fase 4 | `lib/services/glpi_client.dart:1722`, `tool/external-access/workers-vpc/src/index.js:9` |
| G5 | Anexos/PWA | PWA abre arquivo via `Blob` e anchor, com inline em nova aba para PDF/video/texto/imagem. | Comportamento depende do navegador mobile; pode falhar apos "download iniciado". | Fluxo web dedicado: download com nome/MIME correto, fallback visivel, logs e proxy com headers adequados. | Fase 4 | `lib/utils/platform_attachment_opener_web.dart:20` |
| G6 | Acoes | Nao ha endpoint de `capabilities` por ticket. | UI pode oferecer acao que o GLPI vai negar, ou esconder acao valida. | Worker calcula capabilities por perfil, ticket, status, atribuicoes e regras GLPI. | Fase 3 | `lib/state/app_state.dart:723`, `lib/services/glpi_rules_client.dart:80` |
| G7 | Status/atribuicao | "Assumir chamado" existe como efeito de mudar status para `Em Atendimento`. | Operador pode nao descobrir o fluxo ou interpretar followup como inicio de atendimento. | Capability e CTA explicitos para `claim_ticket`/`start_progress`, com read-back padronizado. | Fase 3 | `lib/state/app_state.dart:796` |
| G8 | FormCreator | Submissao FormCreator esta gated, mas matriz de status operacional ainda nao e contrato runtime completo. | Risco de criar ticket padrao para formulario que exige fluxo especializado. | Publicar status por formulario: `unsupported`, `native_supported`, `webview_supported`, `discovery_required`, `specialized_flow_required`, `blocked`. | Fase 2/3 | `lib/config/glpi_config.dart:49`, `tool/external-access/workers-vpc/src/index.js:186` |
| G9 | Metadados | Existe catalogo runtime, mas nao snapshot unificado de regras/categorias/capabilities. | App ainda mistura fallback local, contrato embarcado e metadata opcional. | `/mobile/config/snapshot` versionado com ETag, hash e compatibilidade. | Fase 2 | `lib/catalog/glpi_metadata_client.dart:26`, `lib/services/glpi_rules_client.dart:37` |
| G10 | Observabilidade | Fluxos mutaveis nao tem trilha unica correlacionando app, Worker, GLPI e outbox. | Dificil diferenciar falha terminal, retryable, timeout e sucesso remoto sem confirmacao. | Correlation ID, idempotency key e resultado normalizado por acao. | Fase 2/5 | `lib/state/app_state.dart:977`, `tool/external-access/workers-vpc/src/index.js:105` |

## Gaps que nao sao bloqueadores imediatos

| ID | Tema | Observacao | Confianca |
|---|---|---|---:|
| N1 | Allowlist Worker | O Worker ja bloqueia `DELETE`, `POST /Document` e `POST /Document_Item`. Isto reduz risco de proxy aberto. | Alta |
| N2 | Upload de anexo | O app ja valida vinculo `Document_Item` apos upload direto. Isto e uma guarda boa e deve ser preservada. | Alta |
| N3 | Ticket fechado/stale state | O app reconsulta ticket antes de status/mensagem/anexo e bloqueia terminalidade. | Alta |
| N4 | Metadata SIS | Ja existe endpoint read-only de catalogo e cliente Flutter com cache/ETag. | Alta |

## Ordem recomendada

1. Definir contrato Worker mobile: auth, `capabilities`, config snapshot, anexo proxy, idempotencia.
2. Implementar idempotencia server-side antes de ampliar offline.
3. Introduzir outbox local com storage apropriado e dependencias de acoes.
4. Mover download de anexos para proxy validado e testar PWA/APK separadamente.
5. Transformar FormCreator em contrato por status de suporte, bloqueando criacao padrao quando exigido.
