# Estados do Ticket

## Escopo

Este documento descreve os estados de chamado que o SIS Mobile Flutter precisa respeitar ao ler, exibir e tentar alterar tickets do GLPI.

Ele nao substitui o codigo atual. A ordem pratica continua:

1. codigo e scripts atuais do repo;
2. `README.md`;
3. `docs/RUNTIME_CANONICO_E_VALIDACAO.md`;
4. docs operacionais especializadas.

Quando este documento divergir do codigo, trate como sinal de investigacao: ou o codigo esta errado, ou esta doc esta desatualizada.

## Fonte de verdade

- A fonte remota dos estados e o GLPI SIS REST API.
- No app Flutter, a normalizacao local vive hoje em `lib/models/glpi_status.dart`, por meio de `GlpiStatus` e `GlpiStatusMapper`.
- O estado offline `Pendente (Offline)` existe apenas no cliente para chamados ainda nao sincronizados.

## Estados canonicos GLPI

| Codigo | Nome no app | Origem | Terminal operacional no app | Observacao |
| --- | --- | --- | --- | --- |
| `1` | Novo | GLPI | Nao | Chamado criado, ainda aberto para atendimento. |
| `2` | Em Atendimento | GLPI | Nao | Chamado em trabalho tecnico. |
| `3` | Planejado | GLPI | Nao | Atendimento agendado ou planejado. |
| `4` | Pendente | GLPI | Nao | Aguardando informacao, terceiro, item ou outra dependencia. |
| `5` | Solucionado | GLPI | Parcial | Solucao proposta; nao deve expor acoes tecnicas comuns. |
| `6` | Fechado | GLPI | Sim | Chamado encerrado; nao deve aceitar acao operacional pelo app. |

## Estados locais

| Nome | Origem | Terminal operacional no app | Observacao |
| --- | --- | --- | --- |
| `Pendente (Offline)` | App | Nao | Chamado criado offline e ainda nao enviado ao GLPI. |

## Regra operacional atual

O app considera abertos para interacao comum os estados `1`, `2`, `3`, `4` e `Pendente (Offline)`.

O app considera nao abertos para interacao comum:

- `5` Solucionado;
- `6` Fechado.

Essa regra esta implementada hoje em `GlpiStatusMapper.isOpenForInteraction()`.

## Estado solucionado

`Solucionado` nao e terminal no GLPI, mas e um estado sensivel no app:

- a solucao ja foi proposta;
- o solicitante pode aprovar ou recusar, conforme regra de negocio real;
- acoes tecnicas comuns, como mudar status por botoes antigos de detalhe, nao devem continuar expostas;
- qualquer acao nesse estado precisa confirmar o estado remoto antes de mutar.

## Estado fechado

`Fechado` e terminal operacional para o SIS Mobile:

- nao enviar nova mensagem pelo app;
- nao anexar novo arquivo pelo app;
- nao propor nova solucao pelo app;
- nao alterar status pelo app;
- nao invalidar solucao ja validada por acao lateral;
- nao executar acao a partir de tela obsoleta aberta antes do fechamento.

Se o GLPI permitir alguma mutacao em fechado, isso deve ser tratado como risco de integridade e investigado com autopsia completa antes de qualquer ajuste.

## Caso real que motivou a formalizacao

Em teste manual, um ticket foi aberto, solucionado pelo tecnico, validado pelo solicitante e fechado. Ao retornar para uma tela de detalhe previamente aberta, botoes antigos de mudanca de status continuaram visiveis. Uma acao lateral gerou estado contraditorio: parte da UI tratava como fechado, outra parte ainda permitia tentativa de alteracao.

Fato observado: inconsistencia entre tela antiga, conversa e estado remoto.

Diagnostico definitivo: depende de autopsia com evidencia. Nao assumir arquitetura quebrada sem reproduzir e capturar estado antes/depois.

## Pontos de codigo relacionados

- `lib/models/glpi_status.dart`
- `lib/state/app_state_ticket_support.dart`
- `lib/state/app_state.dart`
- `lib/state/app_state_solution_support.dart`
- `lib/screens/ticket_detail_screen.dart`
- `lib/screens/ticket_message_screen.dart`
- `test/glpi_status_mapper_test.dart`
- `test/ticket_role_policy_test.dart`
