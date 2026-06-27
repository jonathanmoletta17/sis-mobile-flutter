# Estado Atual do App Flutter

## 1. Stack e configuracao

- Framework: Flutter.
- Estado: `Provider` + `ChangeNotifier`; `AppState` centraliza sessao, tickets, offline, anexos, status e solucoes.
- HTTP: pacote `http`.
- Configuracao runtime: `.env` na raiz, carregado por `flutter_dotenv`. Este documento lista apenas nomes de variaveis.
- URLs GLPI/Worker:
  - `SIS_GLPI_BASE_URL`
  - `GLPI_BASE_URL` como fallback legado
  - `DTIC_GLPI_BASE_URL` para a linha DTIC
  - `SIS_CHECKLISTS_METADATA_URL`
- O app SIS rejeita endpoint DTIC por heuristica local antes de usar a URL.

Evidencias:
- Selecao `SIS_GLPI_BASE_URL`/`GLPI_BASE_URL`: `lib/config/glpi_config.dart:7`.
- Bloqueio contra endpoint DTIC: `lib/config/glpi_config.dart:17`.
- Flag local de submissao checklist: `lib/config/glpi_config.dart:49`.
- Dependencias relevantes: `pubspec.yaml:35`.

## 2. Endpoints consumidos pelo app

O app consome paths GLPI diretamente ou via Worker compativel com GLPI. Nao foi encontrado contrato mobile proprio como `/mobile/tickets/{id}/capabilities`.

| Endpoint | Metodo | Funcao no App | Evidencia |
|---|---:|---|---|
| `/initSession` | GET | Login com Basic Auth | `lib/services/glpi_client.dart:82` |
| `/killSession` | GET | Logout | `lib/services/glpi_client.dart:122` |
| `/getFullSession` | GET | Perfil, usuario, entidade e grupos | `lib/services/glpi_client.dart:152` |
| `/ITILCategory` | GET | Categorias | `lib/services/glpi_client.dart:256` |
| `/search/Ticket` | GET | Listar chamados do usuario por criterios GLPI | `lib/services/glpi_client_support.dart:284` |
| `/Ticket` | POST | Criar chamado | `lib/services/glpi_client.dart:1232` |
| `/Ticket/{id}` | GET | Detalhe/read-back do chamado | `lib/services/glpi_client.dart:493` |
| `/Ticket/{id}` | PUT | Alterar status | `lib/services/glpi_client.dart:847` |
| `/Ticket_User` | POST | Atribuir tecnico ao chamado | `lib/services/glpi_client.dart:1941` |
| `/TicketFollowup` | POST | Enviar acompanhamento e aprovar/recusar solucao via followup | `lib/services/glpi_client.dart:1419` |
| `/ITILSolution` | POST | Enviar solucao formal | `lib/services/glpi_client.dart:1479` |
| `/Ticket/{id}/Document` | POST multipart | Anexar arquivo ao ticket | `lib/services/glpi_client.dart:1018` |
| `/ITILFollowup/{id}/Document` | POST multipart | Anexar arquivo ao followup | `lib/state/app_state_message_support.dart:204` |
| `/ITILSolution/{id}/Document` | POST multipart | Anexar arquivo a solucao | `lib/state/app_state_message_support.dart:204` |
| `/{item}/{id}/Document_Item` | GET | Verificar vinculo de anexo | `lib/services/glpi_client.dart:1142` |
| `/Document/{id}` | GET | Detalhe/download de anexo | `lib/services/glpi_client.dart:1806` |
| `/metadata/mobile/sis/catalog` | GET | Catalogo SIS runtime opcional | `lib/catalog/glpi_metadata_client.dart:26` |

## 3. Modelos de dados e hardcode

- Status: existe contrato embarcado `assets/glpi_rules_sis.json` consumido por `GlpiRulesClient`, mas ha fallback local quando o contrato nao carrega.
- Transicoes: `GlpiRulesClient.allowedStatusTransitions()` usa contrato por perfil quando disponivel; UI ainda tem fallback.
- Categorias/servicos: existe catalogo estatico em `service_data.dart` e catalogo runtime opcional via `GlpiMetadataClient`.
- FormCreator/checklists: existe catalogo de checklists embarcado e flag local de submissao; submissao exige flag do app e gate do Worker.

Evidencias:
- Contrato de regras embarcado: `lib/services/glpi_rules_client.dart:1`.
- Transicoes por perfil: `lib/services/glpi_rules_client.dart:80`.
- Catalogo runtime com cache e fallback estatico: `lib/catalog/glpi_metadata_client.dart:26`.

## 4. Offline e armazenamento

- Ha implementacao offline para criacao de chamados, nao para followups/status/solucoes como outbox generica.
- A fila local fica em `SharedPreferences` na chave `pendingTickets`.
- Sessao, usuario, perfil e entidade tambem sao persistidos em `SharedPreferences`.
- Anexos offline:
  - bytes sao persistidos ate 10 MB por ticket;
  - acima de 10 MB, os bytes sao removidos e o app tenta reler por path no mobile;
  - no Web/PWA, se sobrar apenas path, o arquivo nao pode ser relido e o app adiciona aviso ao chamado sincronizado.
- Nao ha idempotency key por acao offline.
- A sincronizacao itera a fila e chama `createTicket`; se sucesso, remove da fila. Se falha, preserva o item.
- Risco: se o GLPI criar o ticket mas a confirmacao local falhar antes de remover da fila, a proxima tentativa pode duplicar chamado.

Evidencias:
- Chave local `pendingTickets`: `lib/state/app_state_storage.dart:30`.
- Limite de 10 MB: `lib/state/app_state_storage.dart:32`.
- Persistencia/remocao de bytes grandes: `lib/state/app_state_storage.dart:54`.
- Fallback para offline na criacao: `lib/state/app_state.dart:525`.
- Loop de sincronizacao: `lib/state/app_state.dart:919`.
- Web nao reabre path local: `lib/state/app_state.dart:946`.

## 5. Anexos no Flutter

- Upload: multipart GLPI direto para `/{itemType}/{itemId}/Document`, com parte `uploadManifest` e arquivo `filename[0]`.
- Verificacao de upload: o app compara vinculos `Document_Item` antes/depois ou documentos embutidos do ticket.
- Anexo sem texto:
  - se o usuario envia somente anexo, o app nao cria followup vazio;
  - o documento fica vinculado ao ticket e deve aparecer pela busca de documentos.
- Anexo com mensagem/solucao:
  - cria a interacao (`TicketFollowup` ou `ITILSolution`);
  - tenta anexar no item criado;
  - em caso de falha, cai para anexo no ticket raiz.
- Download:
  - imagens sao exibidas em memoria.
  - documentos usam `openAttachmentBytes`.
  - Android/IO grava arquivo temporario e usa `open_filex`.
  - Web/PWA cria `Blob` e dispara anchor; PDF/video/texto/imagem tentam abrir inline em nova aba.

Evidencias:
- Multipart e `uploadManifest`: `lib/services/glpi_client.dart:1063`.
- Confirmacao por `Document_Item`: `lib/services/glpi_client.dart:1107`.
- Abort se nao houver vinculo verificavel: `lib/services/glpi_client.dart:1135`.
- Anexo-only sem followup vazio: `lib/state/app_state_message_support.dart:148`.
- Fallback de interacao para ticket raiz: `lib/state/app_state_message_support.dart:204`.
- Download via bytes autenticados: `lib/services/glpi_client.dart:1993`.
- Abrir no Android/IO: `lib/utils/platform_attachment_opener_io.dart:10`.
- Abrir no PWA/Web: `lib/utils/platform_attachment_opener_web.dart:10`.

## 6. Status, atribuicao e acoes tecnicas

- A mudanca de status faz read-back antes de executar, bloqueando ticket ja solucionado/fechado.
- Ao mover para `Em Atendimento`, o app tenta atribuir o usuario logado como tecnico via `Ticket_User`.
- Existe confirmacao posterior de status e atribuicao.
- A UX ainda tende a comunicar isso como "alterar status", nao como uma capacidade independente de "assumir chamado".
- Nao foi encontrado consumo de endpoint `capabilities` por ticket; decisoes continuam distribuidas entre contrato embarcado, perfil ativo, role local e fallback.

Evidencias:
- Guard contra estado fechado/solucionado: `lib/state/app_state.dart:739`.
- Status update: `lib/state/app_state.dart:769`.
- Autoatribuicao ao mover para `Em Atendimento`: `lib/state/app_state.dart:796`.
- Read-back de status + tecnico: `lib/state/app_state.dart:844`.

## 7. Lacunas identificadas no Flutter

- [x] Nao possui outbox generica para `create_ticket`, `followup`, `solution`, `status_change`, `assign_ticket` e `upload_attachment`.
- [x] Nao possui idempotency key por acao offline.
- [x] Persistencia offline usa `SharedPreferences`, fragil para anexos grandes e dependencias entre acoes.
- [x] PWA depende de `Blob` + nova aba/download; comportamento de PDF/video/documento varia por navegador.
- [x] Nao consulta `capabilities` por ticket antes de montar todas as acoes.
- [x] Nao possui proxy de anexo com token proprio e validacao cruzada por ticket/documento.
- [x] FormCreator ainda nao implementa matriz completa `unsupported/native_supported/webview_supported/discovery_required/specialized_flow_required/blocked`.
- [ ] Possui guardas locais importantes para ticket fechado, permissao, upload verificavel e autoatribuicao com read-back.

## 8. Riscos e decisoes

| Item | Risco | Confianca | Decisao necessaria |
|---|---|---:|---|
| F1 | Duplicidade de chamados offline apos timeout ou queda entre criacao remota e remocao local. | Alta | Introduzir outbox com idempotency key e registry server-side. |
| F2 | Perda de anexo offline no PWA quando bytes nao foram persistidos e so existe path. | Alta | Definir estrategia PWA para anexos offline ou bloquear explicitamente casos nao suportados. |
| F3 | Falha de abertura de PDF/video/documento pode ser especifica do PWA por `Blob`/nova aba. | Media | Validar em navegador mobile e decidir proxy/download dedicado. |
| F4 | Botoes/acoes podem divergir do GLPI real sem `capabilities` server-side. | Alta | Definir endpoint de capabilities por ticket. |
| F5 | FormCreator especializado pode cair em fluxo padrao se catalogo/status nao estiver completo. | Media | Definir matriz de formulario e bloqueios antes da Fase 2. |
