# Extracao de Invariantes - Ticket - 2026-04-29

## Objetivo

Extrair regras reais do codigo atual do SIS Mobile Flutter antes de criar nova camada de policy ou refactor estrutural.

Esta extracao usa:

- `docs/domain/ticket/STATES.md`
- `docs/domain/ticket/TRANSITIONS.md`
- `docs/domain/ticket/INVARIANTS.md`
- `docs/domain/ticket/SOURCES_OF_TRUTH.md`
- `docs/quality/DOR.md`
- `docs/quality/DOD.md`
- agentes exploradores read-only

## Escopo lido

- `lib/models/glpi_status.dart`
- `lib/state/app_state_ticket_support.dart`
- `lib/state/app_state.dart`
- `lib/state/app_state_solution_support.dart`
- `lib/state/app_state_message_support.dart`
- `lib/state/app_state_attachment_support.dart`
- `lib/screens/ticket_detail_screen.dart`
- `lib/screens/ticket_message_screen.dart`
- `lib/services/glpi_client.dart`
- `test/glpi_status_mapper_test.dart`
- `test/ticket_role_policy_test.dart`
- `test/ticket_message_identity_test.dart`
- `test/ticket_form_summary_test.dart`

## Conclusao executiva

O dominio de ticket ja possui regras relevantes implementadas e testadas para status, acoes tecnicas visiveis, solicitante prevalecendo sobre perfil tecnico, nomes humanos e resumo de formulario.

A lacuna de maior risco esta em acoes criticas que ainda nao revalidam o estado remoto imediatamente antes de mutar:

- aprovar solucao;
- recusar solucao;
- enviar mensagem;
- enviar anexo.

O caminho de mudar status direto ja possui revalidacao remota antes do `PUT`, mas ainda nao tem teste dedicado.

Confianca: alta para lacunas de codigo local; media para comportamento final do GLPI sem reproduzir em API real.

## Regras cobertas

| Regra | Evidencia | Teste atual | Confianca |
| --- | --- | --- | --- |
| Status GLPI `1..6` centralizados | `GlpiStatus` e `GlpiStatusMapper` em `lib/models/glpi_status.dart` | `test/glpi_status_mapper_test.dart` | Alta |
| `Solucionado` e `Fechado` nao sao abertos para interacao comum | `GlpiStatusMapper.isOpenForInteraction()` | `test/glpi_status_mapper_test.dart` | Alta |
| Acoes tecnicas nao aparecem para offline, solucionado, fechado, perfil requester ou solicitante do ticket | `AppStateTicketSupport.canShowTechnicianActions()` | `test/ticket_role_policy_test.dart` | Alta |
| Solicitante prevalece sobre perfil tecnico no mesmo ticket | `AppStateTicketSupport.isLoggedUserRequester()` | `test/ticket_role_policy_test.dart` | Alta |
| Detalhe tenta vencer snapshot local com GLPI | `_rehydrateTicket()` em `TicketDetailScreen` | Sem teste automatizado especifico | Media |
| Mudanca de status revalida remoto antes de mutar | `AppState.updateTicketStatus()` | Sem teste dedicado | Media |
| Conversa bloqueia input quando status fechado conhecido | `_refreshTicketStatus()` e `_buildInputArea()` em `TicketMessageScreen` | Sem widget test dedicado | Media |
| IDs de usuario podem ser normalizados para fallback legivel ou nome hidratado | `GlpiNameFormatter`, `TicketMessage` | `test/glpi_name_formatter_test.dart`, `test/ticket_message_identity_test.dart` | Alta |
| Resumo tecnico do formulario pode ser parseado para apresentacao legivel | `TicketFormSummary` | `test/ticket_form_summary_test.dart` | Alta |

## Regras duplicadas ou hardcoded

| Regra ou valor | Onde aparece | Risco | Confianca |
| --- | --- | --- | --- |
| `Pendente (Offline)` | `GlpiStatusMapper.offlineLabel` e literal em `AppStateTicketSupport.buildOfflineTickets()` | Baixo; pode virar manutencao duplicada | Alta |
| Identidade do solicitante | Central em `AppStateTicketSupport`, mas conversa tem `_isLoggedUserTicketOwner()` proprio | Medio; divergencia de papel em conversa | Alta |
| Status de solucao `1/2/3/4` | `TicketMessageScreen` e `AppStateSolutionSupport` | Medio; sem enum local para semantica de solucao | Alta |
| Botoes `Em Atendimento` e `Solucionado` | Hardcoded em `TicketDetailScreen` | Medio; aceitavel enquanto matriz for pequena | Alta |
| Perfis requester por substring | `AppStateTicketSupport.isRequesterProfile()` | Medio; depende de nomenclatura GLPI | Alta |
| Fallback de status para `1` se parse falhar | `GlpiClient.updateTicketStatus()` | Alto; parse invalido pode virar `Novo` | Alta |

## Lacunas de guarda

| Fluxo | Guarda/refresh antes de mutar | Lacuna | Confianca |
| --- | --- | --- | --- |
| Mudar status direto | Sim, `AppState.updateTicketStatus()` chama `getTicketById()` antes do `updateTicketStatus()` remoto | Falta teste; papel/requester ainda depende de UI/GLPI | Alta |
| Aprovar solucao | Nao identificado | `AppStateSolutionSupport.approveSolution()` atualiza a solucao e depois tenta fechar sem reconsultar ticket remoto; tambem ignora resultado do fechamento | Alta |
| Recusar solucao | Nao identificado | `rejectSolution()` atualiza solucao, envia followup/anexos e reabre sem reconsultar ticket remoto; falhas intermediarias podem ficar parcialmente aplicadas | Alta |
| Enviar mensagem | Nao identificado | `_sendMessage()` chama `AppState.sendTicketMessageWithAttachments()` sem revalidar estado; helper valida sessao, nao status remoto | Alta |
| Enviar anexo | Nao identificado | Upload valida sessao/arquivo, nao estado remoto; fallback para ticket raiz pode anexar quando vinculo especifico falha | Alta |

## Lacunas de teste por DoD

| DoD | Lacuna |
| --- | --- |
| Nivel 3 - Guarda de execucao | Solucao, mensagem e anexo dependem principalmente da UI ou do GLPI remoto. |
| Nivel 4 - Estado obsoleto | Nao ha teste automatizado de tela aberta antes de mudanca remota. |
| Nivel 5 - Sincronizacao | Nao ha teste integrando lista, detalhe e conversa convergindo para o mesmo estado. |
| Nivel 6 - Papeis e permissoes | Solicitante/tecnico-solicitante cobertos parcialmente; observador, tecnico positivo e sessao invalida ainda faltam. |
| Nivel 7 - Erros e rejeicoes | Fluxos de solucao/mensagem/anexo precisam provar que erro do GLPI restaura ou recarrega estado confiavel. |

## Candidatos a novos testes minimos

1. `updateTicketStatus` com fake `GlpiClient`: remoto retorna `Fechado`; deve falhar e nao chamar PUT.
2. `approveSolution` em ticket remoto `Fechado`: deve abortar antes de `updateSolutionStatus`.
3. `rejectSolution` em ticket remoto `Fechado`: deve abortar antes de `updateSolutionStatus`, followup e reabertura.
4. `sendTicketMessageWithAttachments` em ticket remoto `Fechado`: deve abortar antes de `addTicketMessage`, `addTicketSolution` ou upload.
5. Widget test de `TicketDetailScreen`: tecnico em `Solucionado`/`Fechado` nao ve `Acoes de Status`; tecnico em estado aberto e nao solicitante ve.
6. Widget test de `TicketMessageScreen`: chamado fechado bloqueia input; autor da propria solucao nao ve aprovar/recusar.
7. Expandir `TicketFormSummary` para HTML/texto livre, sem formulario estruturado e multiplos anexos.

## Decisao sobre nova policy Dart

Nao criar ainda.

Motivo:

- ha regras centralizadas o bastante para evitar extrair uma policy por impulso;
- a maior lacuna atual esta em guarda de execucao com estado fresco, nao necessariamente em ausencia total de policy;
- uma policy Dart pode ser util depois, mas precisa nascer de teste e duplicacao comprovada.

Proximo passo antes de qualquer refactor:

1. criar DoR para "guardas de execucao de acoes criticas de ticket";
2. escrever testes minimos;
3. aplicar correcao local menor;
4. so depois reavaliar se a duplicacao remanescente justifica policy.

## Aprendizado de processo

Por que isso poderia passar:

- os fluxos felizes funcionam;
- a UI bloqueia bastante coisa;
- polling reduz a janela de stale state;
- mas UI e polling nao sao garantia de integridade se uma acao velha ainda puder chamar o AppState.

Pergunta que faltava:

> Se a tela estiver obsoleta, a funcao que executa a acao ainda confirma o estado remoto antes de mutar?

Invariante reforcado:

> Estado obsoleto nao executa acao critica. A UI pode orientar, mas a execucao precisa ter guarda propria quando o risco for mutacao remota.

Mudanca no processo:

- novas features ou fixes de ticket passam por `docs/quality/DOR.md`;
- conclusao passa por `docs/quality/DOD.md`;
- bugs de estado usam `docs/AUTOPSIA_COMPLETA.md` e `docs/quality/BUG_AUTOPSY_TEMPLATE.md`;
- nao criar camada nova sem provar por teste que correcao local nao basta.
