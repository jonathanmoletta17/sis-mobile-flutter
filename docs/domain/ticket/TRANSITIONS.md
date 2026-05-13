# Transicoes do Ticket

## Escopo

Este documento define a matriz operacional de transicoes esperadas no SIS Mobile Flutter para tickets GLPI.

Ele e uma base de validacao e questionamento. Nao deve ser usado para inventar regra sem confronto com:

- comportamento real do GLPI;
- codigo atual do app;
- evidencias de API;
- decisao explicita de negocio.

## Papeis operacionais

| Papel | Descricao | Observacao |
| --- | --- | --- |
| Solicitante | Usuario que abriu o chamado ou aparece como requerente/recipient no GLPI. | Para aquele ticket, prevalece sobre perfil tecnico. |
| Tecnico | Usuario com perfil tecnico e que nao e o solicitante daquele ticket. | Pode atuar tecnicamente quando o estado permite. |
| Tecnico-solicitante | Usuario que tem perfil tecnico, mas tambem e solicitante do mesmo ticket. | Deve ser tratado como solicitante naquele ticket para evitar conflito de papel. |
| Observador | Usuario que acompanha sem ser solicitante nem tecnico responsavel. | Sem acao operacional prevista neste app. |
| Sessao invalida | Usuario sem sessao valida ou token expirado. | Sem acao operacional. |

## Matriz atual de acoes

Legenda:

- `sim`: permitido, desde que o GLPI confirme e a sessao esteja valida;
- `nao`: nao deve aparecer nem executar;
- `via fluxo especifico`: nao e botao tecnico comum; precisa passar pela acao propria.

### Mudar status para Em Atendimento

| Estado origem | Solicitante | Tecnico | Tecnico-solicitante | Observador | Sessao invalida |
| --- | --- | --- | --- | --- | --- |
| Novo | nao | sim | nao | nao | nao |
| Em Atendimento | nao | nao | nao | nao | nao |
| Planejado | nao | sim | nao | nao | nao |
| Pendente | nao | sim | nao | nao | nao |
| Solucionado | nao | nao | nao | nao | nao |
| Fechado | nao | nao | nao | nao | nao |

### Propor solucao

| Estado origem | Solicitante | Tecnico | Tecnico-solicitante | Observador | Sessao invalida |
| --- | --- | --- | --- | --- | --- |
| Novo | nao | a confirmar | nao | nao | nao |
| Em Atendimento | nao | sim | nao | nao | nao |
| Planejado | nao | a confirmar | nao | nao | nao |
| Pendente | nao | sim | nao | nao | nao |
| Solucionado | nao | nao | nao | nao | nao |
| Fechado | nao | nao | nao | nao | nao |

`a confirmar` significa que pode depender de regra operacional do GLPI/SIS e deve ser testado antes de virar contrato forte.

### Aprovar solucao

| Estado origem | Solicitante | Tecnico | Tecnico-solicitante | Observador | Sessao invalida |
| --- | --- | --- | --- | --- | --- |
| Solucionado | sim | nao | sim, exceto se for autor da propria solucao | nao | nao |
| Fechado | nao | nao | nao | nao | nao |

### Recusar solucao

| Estado origem | Solicitante | Tecnico | Tecnico-solicitante | Observador | Sessao invalida |
| --- | --- | --- | --- | --- | --- |
| Solucionado | sim | nao | sim, exceto se a regra real proibir por conflito de autoria | nao | nao |
| Fechado | nao | nao | nao | nao | nao |

### Enviar mensagem ou anexo

| Estado origem | Solicitante | Tecnico | Tecnico-solicitante | Observador | Sessao invalida |
| --- | --- | --- | --- | --- | --- |
| Novo | sim | sim | sim | nao | nao |
| Em Atendimento | sim | sim | sim | nao | nao |
| Planejado | sim | sim | sim | nao | nao |
| Pendente | sim | sim | sim | nao | nao |
| Solucionado | a confirmar | a confirmar | a confirmar | nao | nao |
| Fechado | nao | nao | nao | nao | nao |

`Solucionado` para mensagem/anexo deve ser validado contra a expectativa real do GLPI e do fluxo SIS. Ate haver evidencia, nao tratar como garantia absoluta.

## Regras transversais

1. O GLPI remoto vence o estado local quando houver divergencia.
2. Acao critica precisa revalidar o ticket remoto antes de mutar.
3. Tela antiga nao pode executar transicao com base apenas no snapshot carregado.
4. `Fechado` nao executa acao operacional pelo app.
5. `Solucionado` nao deve expor botoes tecnicos comuns de status.
6. Usuario solicitante prevalece sobre perfil tecnico no mesmo ticket.
7. Sessao invalida bloqueia todas as acoes.
8. Erro de API precisa restaurar a UI para o estado real conhecido, nao para estado otimista.

## Pontos de codigo relacionados

- Exibicao de acoes tecnicas: `AppStateTicketSupport.canShowTechnicianActions()`.
- Revalidacao antes de status: `AppState.updateTicketStatus()`.
- Solucao: `AppStateSolutionSupport.approveSolution()` e `AppStateSolutionSupport.rejectSolution()`.
- Tela de detalhe: `TicketDetailScreen`.
- Tela de conversa: `TicketMessageScreen`.

## Lacunas deliberadas

Este documento nao cria uma nova `TicketPolicy` em Dart. Essa decisao depende de evidencia de duplicacao real e deve ser tomada depois de uma extracao de invariantes no codigo atual.

Extracao feita:

- `docs/domain/ticket/EXTRACAO_INVARIANTES_2026-04-29.md`

Resultado atual: a prioridade antes de uma policy Dart e fechar guardas de execucao para solucao, mensagem e anexo com testes minimos.
