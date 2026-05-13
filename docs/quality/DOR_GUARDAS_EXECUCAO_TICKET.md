# DoR - Guardas de Execucao de Acoes Criticas de Ticket

## 1. Tipo

- [ ] Feature
- [x] Correcao de bug
- [x] Evolucao de fluxo existente
- [ ] Ajuste operacional/runtime

## 2. Fato ou objetivo

A extracao de invariantes de 2026-04-29 mostrou que mudar status direto revalida o ticket remoto antes de mutar, mas aprovar solucao, recusar solucao, enviar mensagem e enviar anexo ainda nao tem guarda local equivalente de estado fresco.

## 3. Entidades envolvidas

- Primaria: Ticket
- Secundarias: ITILSolution, TicketFollowup, Document, User

## 4. Estados tocados

- Le: `1` Novo, `2` Em Atendimento, `3` Planejado, `4` Pendente, `5` Solucionado, `6` Fechado
- Altera: `5 -> 6` ao aprovar solucao; `5 -> aberto` ao recusar solucao, conforme regra real a confirmar
- Estados invalidos que precisam ser bloqueados: `6` Fechado para qualquer acao operacional; `5` Solucionado para acoes tecnicas comuns fora do fluxo de validacao

## 5. Papeis envolvidos

- Quem dispara: solicitante, tecnico, tecnico-solicitante
- Quem e afetado: solicitante, tecnico responsavel, lista, detalhe e conversa
- Existe caso tecnico-solicitante? Sim
- Existe sessao expirada ou usuario sem permissao? Sim

## 6. Fonte de verdade

- Origem remota: GLPI SIS REST API
- Origem local: `AppState`, telas Flutter e modelos locais
- Quando reidrata: antes de acao critica; ao voltar de conversa para detalhe; por polling/refresh na conversa
- Quem vence em divergencia: GLPI remoto

## 7. Invariantes aplicaveis

- I-1: Fechado e terminal operacional no app.
- I-2: Solucionado nao expoe acao tecnica comum.
- I-3: GLPI vence cache ou snapshot local.
- I-4: Estado obsoleto nao executa acao critica.
- I-5: Solicitante prevalece sobre perfil tecnico no mesmo ticket.

## 8. Cenarios de borda obrigatorios

1. Tela de conversa aberta com solucao pendente; ticket e fechado por outro caminho antes do clique em aprovar.
2. Tela de conversa aberta com input habilitado; ticket e fechado antes do envio de mensagem/anexo.
3. Usuario tecnico-solicitante tenta executar acao que conflita com autoria ou solicitacao do proprio ticket.
4. GLPI rejeita a mutacao depois da guarda local por mudanca concorrente.

## 9. Fora de escopo

- Nao criar uma `TicketPolicy` Dart neste slice sem evidencia adicional.
- Nao redesenhar telas.
- Nao alterar payload enviado ao GLPI na abertura do chamado.
- Nao mudar regra de acesso externo, build Android ou `.env`.
- Nao resolver todos os papeis possiveis do GLPI; focar nos papeis observados no app.

## 10. Validacao planejada

- Teste unitario: fake/stub de cliente GLPI para provar que acao critica aborta quando ticket remoto esta `Fechado`.
- Teste unitario: `approveSolution` e `rejectSolution` nao chamam `updateSolutionStatus` quando estado remoto invalida a acao.
- Teste unitario: mensagem/anexo nao chamam `addTicketMessage`, `addTicketSolution` ou upload quando estado remoto invalida a acao.
- Teste Widgetbook/visual: nao obrigatorio se a mudanca ficar em guarda de execucao sem alterar UI.
- Teste Android/emulador: obrigatorio antes de declarar fechamento operacional do bug; reproduzir fluxo de tela stale.
- Teste API/GLPI: validar que o app recarrega estado real depois de rejeicao ou abort local.
- Evidencia manual: screenshot/UI tree ou log do fluxo stale bloqueado.

## 11. Criterio de pronto preliminar

Nenhuma acao critica de ticket deve executar mutacao remota a partir de estado local obsoleto quando o GLPI remoto ja indica `Fechado` ou estado incompativel com a acao.
