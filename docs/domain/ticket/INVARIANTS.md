# Invariantes do Ticket

## Escopo

Invariante e uma regra que deve permanecer verdadeira em qualquer caminho de execucao do SIS Mobile Flutter.

Uma regra so deve ser tratada como invariante operacional forte quando houver:

- enunciado claro;
- ponto de aplicacao no codigo;
- teste automatizado ou evidencia manual recorrente;
- relacao com bug real, regra GLPI ou decisao de negocio.

## I-1 - Fechado e terminal operacional no app

**Regra:** se o ticket esta em `Fechado` (`status = 6`), o app nao executa acao operacional sobre ele.

**Aplica em:**

- mudanca de status;
- envio de mensagem;
- anexo;
- proposta de solucao;
- aprovacao ou recusa tardia;
- acao disparada por tela antiga.

**Codigo relacionado:**

- `GlpiStatusMapper.isClosed()`
- `GlpiStatusMapper.isOpenForInteraction()`
- `AppStateTicketSupport.canShowTechnicianActions()`
- `AppState.updateTicketStatus()`

**Teste atual relacionado:**

- `test/glpi_status_mapper_test.dart`
- `test/ticket_role_policy_test.dart`
- `test/app_state_solution_guard_test.dart`
- `test/app_state_reject_solution_guard_test.dart`
- `test/app_state_message_guard_test.dart`

**Estado atual:** `approveSolution()`, `rejectSolution()`, envio de mensagem e anexos reconsultam o ticket remoto antes de mutar. Aprovacao/recusa de solucao usam politica propria: so prosseguem quando o estado remoto e `Solucionado`; `Fechado` aborta antes de qualquer mutacao. Falhas nas mutacoes encadeadas de fechar/reabrir/registrar justificativa sao propagadas como erro, evitando sucesso local mentiroso.

## I-2 - Solucionado nao expõe acao tecnica comum

**Regra:** ticket `Solucionado` (`status = 5`) nao deve expor botoes tecnicos comuns de mudanca de status na tela de detalhe.

**Motivo:** nesse estado, a acao relevante passa pelo fluxo de validacao/recusa de solucao, nao por botoes antigos de status.

**Codigo relacionado:**

- `GlpiStatusMapper.isOpenForInteraction()`
- `AppStateTicketSupport.canShowTechnicianActions()`
- `TicketDetailScreen`

**Teste atual relacionado:**

- `test/ticket_role_policy_test.dart`

## I-3 - GLPI vence cache ou snapshot local

**Regra:** quando estado remoto do GLPI divergir do estado local do app, o estado remoto prevalece.

**Aplica em:**

- retorno para detalhe;
- retorno para lista;
- conversa/polling;
- acao de status;
- aprovacao/recusa de solucao;
- envio de mensagem em ticket que pode ter sido fechado por outra sessao.

**Codigo relacionado:**

- `AppState.fetchTicketById()`
- `_rehydrateTicket()` em `TicketDetailScreen`
- `_refreshTicketStatus()` em `TicketMessageScreen`

**Lacuna:** mapear se todos os caminhos de retorno e acao realmente chamam refresh antes de permitir mutacao.

## I-4 - Estado obsoleto nao executa acao critica

**Regra:** antes de qualquer acao critica, o app deve confirmar o estado remoto atual do ticket ou operar por caminho que ja faca essa confirmacao.

**Acoes criticas:**

- mudar status;
- aprovar solucao;
- recusar solucao;
- propor solucao;
- enviar mensagem;
- enviar anexo.

**Codigo atual com evidencia parcial:**

- `AppState.updateTicketStatus()` reconsulta o ticket antes de mudar status.

**Lacunas conhecidas para investigacao:**

- `AppStateSolutionSupport.approveSolution()`;
- `AppStateSolutionSupport.rejectSolution()`;
- `_sendMessage()` em `TicketMessageScreen`;
- upload/anexo em ticket que muda de estado durante o envio.

**Extracao 2026-04-29:** a lacuna foi confirmada como alta confianca no codigo local para solucao, mensagem e anexo. Ver `docs/domain/ticket/EXTRACAO_INVARIANTES_2026-04-29.md`.

## I-5 - Solicitante prevalece sobre perfil tecnico no mesmo ticket

**Regra:** se o usuario logado e solicitante do ticket, ele nao deve receber visao/acoes tecnicas para aquele mesmo ticket apenas por ter perfil tecnico no GLPI.

**Codigo relacionado:**

- `AppStateTicketSupport.isLoggedUserRequester()`
- `AppStateTicketSupport.canShowTechnicianActions()`

**Teste atual relacionado:**

- `test/ticket_role_policy_test.dart`

## I-6 - IDs tecnicos nao devem vazar como nome humano quando resolviveis

**Regra:** quando o app possuir ou puder resolver nome de usuario/tecnico/solicitante, a UI nao deve exibir apenas ID numerico como texto final para usuario.

**Codigo relacionado:**

- `GlpiClient`
- `GlpiNameFormatter`
- `TicketMessage`
- telas de detalhe e conversa

**Testes relacionados:**

- `test/glpi_name_formatter_test.dart`
- `test/ticket_message_identity_test.dart`

## I-7 - Resumo tecnico enviado ao GLPI nao precisa ser exibido cru

**Regra:** payload de descricao/formulario enviado ao GLPI pode conter estrutura tecnica, mas a UI de detalhe deve renderizar uma versao legivel ou suprimir o bloco bruto quando ele nao for util ao usuario.

**Codigo relacionado:**

- `lib/utils/ticket_form_summary.dart`
- `TicketDetailScreen`

**Teste relacionado:**

- `test/ticket_form_summary_test.dart`

## Como adicionar novo invariante

1. Criar ou concluir autopsia do caso.
2. Descrever o fato observado e a evidencia.
3. Formular a regra como invariante.
4. Apontar onde a regra se aplica no codigo atual.
5. Adicionar ou planejar teste automatizado.
6. Atualizar `STATES.md`, `TRANSITIONS.md` ou `SOURCES_OF_TRUTH.md` se necessario.

Regra pratica: invariante sem teste ou evidencia e candidato, nao contrato final.

## Extracoes registradas

- `docs/domain/ticket/EXTRACAO_INVARIANTES_2026-04-29.md`
