# Fontes de Verdade do Ticket

## Escopo

Este documento mapeia de onde cada superficie do SIS Mobile Flutter deve obter dados de ticket e quando deve descartar estado local.

Objetivo: evitar que lista, detalhe, conversa e GLPI sustentem verdades diferentes sobre o mesmo chamado.

## Principio geral

- GLPI SIS REST API e a fonte remota para status, solicitante, tecnico, solucao, followups e anexos.
- `AppState` e `GlpiClient` sao a camada local que acessa e distribui esses dados no app.
- A UI pode manter snapshot para renderizar, mas nao deve usar snapshot antigo como autorizacao para acao critica.
- Em divergencia, GLPI vence.

## Mapa por superficie

### Lista Meus Chamados

| Dado | Fonte esperada | Observacao |
| --- | --- | --- |
| status | lista carregada do GLPI via `AppState`/`GlpiClient` | Pode ficar temporariamente defasado ate refresh. |
| titulo/servico | payload de ticket decorado no app | Deve evitar ID cru quando nome existe. |
| badge/offline | estado local | Offline nao deve ser confundido com status GLPI remoto. |

**Risco:** navegar para detalhe passando objeto completo pode carregar snapshot antigo se a tela nao reidratar.

### Detalhe do Ticket

| Dado | Fonte esperada | Observacao |
| --- | --- | --- |
| status | `fetchTicketById()` ao entrar/retornar | Deve refletir GLPI antes de decidir acoes. |
| solicitante | payload do ticket ou resolucao por usuario GLPI | Evitar mostrar apenas ID numerico se resolvivel. |
| tecnico | payload/relacoes GLPI | Evitar confundir tecnico logado com solicitante. |
| resumo do formulario | parser de apresentacao | Nao exibir payload bruto ilegivel. |
| acoes tecnicas | `AppStateTicketSupport.canShowTechnicianActions()` e estado fresco | Nao confiar em snapshot antigo. |

### Conversa do Ticket

| Dado | Fonte esperada | Observacao |
| --- | --- | --- |
| historico | followups/solutions/documentos do GLPI | Deve normalizar nomes e anexos. |
| input habilitado | status remoto conhecido e papel do usuario | Fechado deve bloquear input. |
| aprovacao/recusa | solucao atual do GLPI | Precisa confirmar estado antes de mutar. |

### Criacao de Chamado

| Dado | Fonte esperada | Observacao |
| --- | --- | --- |
| formulario | templates locais em `lib/screens/form_template.dart` e catalogo | Envio ao GLPI nao deve ser alterado sem pedido explicito. |
| anexo | armazenamento/selecionador local ate envio | Validar no Android real quando mudar fluxo. |
| ticket criado | resposta GLPI | Lista/detalhe devem refletir ticket remoto depois da criacao. |

## Eventos que devem invalidar ou reidratar dados

| Evento | Superficies afetadas |
| --- | --- |
| criar ticket | lista, detalhe do novo ticket |
| mudar status | detalhe, lista, conversa |
| propor solucao | conversa, detalhe, lista |
| aprovar solucao | conversa, detalhe, lista |
| recusar solucao | conversa, detalhe, lista |
| enviar mensagem | conversa, lista se houver ultima atividade |
| enviar anexo | conversa, detalhe |
| voltar de conversa para detalhe | detalhe deve reidratar |
| app volta ao foco | superficies abertas devem considerar refresh quando houver ticket ativo |

## Guardas de execucao observadas em 2026-04-29, atualizadas em 2026-05-18

| Acao critica | Guarda local de estado remoto antes de mutar | Observacao |
| --- | --- | --- |
| Mudar status direto | Sim | `AppState.updateTicketStatus()` reconsulta o ticket antes do PUT remoto e bloqueia estados nao interativos. |
| Aprovar solucao | Sim | `AppStateSolutionSupport.approveSolution()` reconsulta o ticket e permite validacao somente quando o estado remoto ainda e `Solucionado`; `Fechado` aborta antes de alterar solucao ou ticket; falha no fechamento e propagada como erro. |
| Recusar solucao | Sim | `AppStateSolutionSupport.rejectSolution()` reconsulta o ticket e permite recusa somente quando o estado remoto ainda e `Solucionado`; depois reabre o ticket para `Novo` antes de registrar o followup de justificativa; falha na reabertura ou no followup e propagada como erro. |
| Enviar mensagem | Sim | `AppStateMessageSupport.sendTicketMessageWithAttachments()` reconsulta o ticket e bloqueia `Solucionado`/`Fechado` para mensagem comum. |
| Enviar anexo | Sim | `AppStateAttachmentSupport.uploadAndLinkImage()` reconsulta o ticket e bloqueia `Solucionado`/`Fechado` para anexo comum. |

Detalhe: `TicketMessageScreen` faz refresh e polling, mas isso nao substitui guarda de execucao para acao critica quando a tela esta stale.

## Anti-padroes

- Autorizar acao critica apenas com status salvo no momento em que a tela abriu.
- Renderizar acoes tecnicas em `Solucionado` ou `Fechado`.
- Tratar perfil tecnico global como permissao tecnica para ticket em que o usuario e solicitante.
- Exibir `Usuario 2039`, `Tecnico 2039` ou ID numerico quando nome real ja foi resolvido.
- Corrigir divergencia com refactor amplo antes de autopsia.

## Perguntas obrigatorias em bugs de estado

1. Qual superficie viu o estado primeiro?
2. Qual superficie ficou stale?
3. O estado remoto do GLPI mudou?
4. A acao chamou API ou morreu localmente?
5. A chamada foi aceita ou rejeitada pelo GLPI?
6. Depois de reabrir a app, qual estado prevaleceu?
