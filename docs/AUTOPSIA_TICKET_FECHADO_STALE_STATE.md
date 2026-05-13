# Autopsia tecnica - ticket fechado com tela obsoleta

## Objetivo

Investigar, com evidencia concreta, o caso em que um chamado ja fechado pelo GLPI continua expondo acoes antigas em telas previamente abertas, permitindo interacoes inconsistentes.

Esta autopsia nao deve comecar por refactor. O objetivo e separar fato observado, hipoteses, causa raiz provavel e correcao minima.

## Regra epistemologica do caso

- O comportamento relatado prova a inconsistencia observada, nao a causa.
- A hipotese de arquitetura de estados quebrada so deve ser aceita se a evidencia mostrar que uma correcao local de guarda, refresh ou origem de dados nao basta.
- Cada hipotese abaixo deve ser validada ou refutada com estado remoto antes/depois, UI antes/depois e resposta da API ou ausencia comprovada de chamada.
- A conclusao precisa declarar confianca alta, media ou baixa.

## Nivel de investigacao

Este caso usa o protocolo completo, porque envolve divergencia entre estado remoto, detalhe, conversa e acao critica.

Referencias:

- `docs/AUTOPSIA_RAPIDA.md`
- `docs/AUTOPSIA_COMPLETA.md`
- `docs/quality/BUG_AUTOPSY_TEMPLATE.md`
- `docs/domain/ticket/STATES.md`
- `docs/domain/ticket/TRANSITIONS.md`
- `docs/domain/ticket/INVARIANTS.md`
- `docs/domain/ticket/SOURCES_OF_TRUTH.md`

## Timebox

- Reproducao controlada: 20 min
- Captura de estado remoto e UI: 30 min
- Leitura/instrumentacao do codigo: 30 min
- Decisao de causa raiz provavel: 15 min
- Correcao minima e validacao focada: 45 min

Se o caso ultrapassar o timebox, registrar a hipotese mais provavel com confianca estimada e decidir entre corrigir minimamente, instrumentar ou abrir nova etapa.

## Fato observado

Fluxo relatado:

1. Ticket foi aberto.
2. Tecnico registrou solucao.
3. Usuario validou a solucao.
4. Ticket passou a fechado.
5. Ao voltar para tela anterior de detalhe, a tela ainda exibia botoes de alteracao de status.
6. Clicar em `Em Atendimento` aparentemente nao produziu efeito.
7. Clicar em `Solucionado` gerou inconsistencia: a solucao validada foi invalidada ou o estado ficou contraditorio.
8. A conversa permaneceu bloqueada como ticket fechado.

O fato confirmado ate aqui e comportamental. A causa ainda precisa ser provada.

## Hipoteses a separar

### H1 - UI stale

A tela de detalhe manteve snapshot local antigo mesmo depois de o GLPI fechar o chamado.

Evidencia esperada:

- API mostra ticket fechado.
- UI ainda mostra acoes de status.
- Reabrir a tela do zero remove os botoes.

### H2 - Cache ou invalidacao incompleta

Uma tela ou provider atualizou parte do estado, mas outra superficie continuou usando cache antigo.

Evidencia esperada:

- Conversa sabe que esta fechado.
- Detalhe ainda pensa que esta aberto.
- As duas telas usam origens diferentes ou momentos diferentes de fetch.

### H3 - Mutacao local otimista sem confirmacao real

O app muda estado local antes da API confirmar ou nao desfaz corretamente quando a API rejeita.

Evidencia esperada:

- UI muda mesmo quando resposta da API falha.
- Reabrir o app mostra outro estado real.

### H4 - API GLPI permissiva

O GLPI aceita alterar status ou solucao mesmo depois de fechado.

Evidencia esperada:

- PUT de status ou solucao retorna sucesso em ticket fechado.
- Estado real do GLPI muda depois da chamada.

### H5 - Guarda incompleta no app

A UI pode esconder a acao em alguns caminhos, mas a funcao de acao ainda permite executar se chamada por uma tela obsoleta.

Evidencia esperada:

- Codigo de exibicao bloqueia fechado.
- Codigo de execucao nao revalida o estado remoto antes da mutacao.

### H6 - Corrida entre refresh e navegacao

O usuario retorna ou clica enquanto um refresh ainda esta em andamento.

Evidencia esperada:

- Ha indicador de loading ou fetch pendente.
- A acao fica disponivel antes da conclusao do fetch remoto.
- Repetindo com espera maior o bug desaparece.

## Mapa preliminar do codigo atual

Este mapa reflete o codigo lido durante a autopsia. Ele pode representar uma versao ja alterada depois do bug original.

### Tela de detalhe

- `lib/screens/ticket_detail_screen.dart`
- `_rehydrateTicket()` busca o ticket remoto via `AppState.fetchTicketById`.
- `_buildStatusButton()` desabilita botoes se `_isClosedForInteraction` for verdadeiro.
- `showTechnicianActions` usa `AppStateTicketSupport.canShowTechnicianActions`.
- Ao voltar da conversa, a tela chama `_rehydrateTicket()`.

### Politica de acoes tecnicas

- `lib/state/app_state_ticket_support.dart`
- `canShowTechnicianActions()` bloqueia:
  - ticket offline;
  - status sem interacao aberta;
  - perfil solicitante;
  - usuario que e solicitante do chamado.

### Alteracao de status

- `lib/state/app_state.dart`
- `updateTicketStatus()` reconsulta o ticket antes de mutar.
- Se o status remoto nao esta aberto para interacao, retorna falha antes do PUT.

### Solucao

- `lib/state/app_state_solution_support.dart`
- `approveSolution()` altera a solucao para aprovada e depois fecha o ticket.
- `rejectSolution()` altera a solucao para recusada, envia followup e depois reabre o ticket.
- No codigo atual, este caminho ainda precisa ser investigado porque nao ha, neste arquivo, uma revalidacao explicita do estado remoto antes de alterar a solucao.

### Conversa

- `lib/screens/ticket_message_screen.dart`
- `_refreshTicketStatus()` busca o ticket remoto.
- Ha polling a cada 3 segundos.
- `_buildInputArea()` bloqueia input quando `_isTicketClosed` e verdadeiro.
- `_sendMessage()` depende do estado da tela para nao ser chamado em ticket fechado; precisa ser verificado se ha guarda de execucao fora da UI.

## Protocolo de reproducao controlada

### Pre-condicao

Usar somente ticket de teste criado para autopsia. Nao usar ticket operacional real.

Registrar:

- ID do ticket.
- Usuario solicitante.
- Usuario tecnico.
- Endpoint usado.
- APK/build usado.
- Hash ou timestamp do APK.

### Evidencias obrigatorias por ponto

Para cada ponto T0-T9, capturar:

- screenshot do app;
- UI tree do app quando houver tela envolvida;
- estado remoto do ticket via API;
- solucoes via API;
- logcat filtrado do app, quando a acao for executada no Android.

### Comandos de captura Android

Substituir `SERIAL` e `LABEL`:

```bash
adb -s SERIAL exec-out screencap -p > /tmp/sis-autopsia/LABEL.png
adb -s SERIAL exec-out uiautomator dump /dev/tty > /tmp/sis-autopsia/LABEL.xml
python3 /home/jonathan/.codex-app/plugins/cache/openai-curated/test-android-apps/6807e4de/skills/android-emulator-qa/scripts/ui_tree_summarize.py \
  /tmp/sis-autopsia/LABEL.xml \
  /tmp/sis-autopsia/LABEL-summary.txt
```

### Pontos da linha do tempo

| Ponto | Acao | Evidencia que precisa existir |
| --- | --- | --- |
| T0 | Login do solicitante | Sessao, usuario, perfil e entidade |
| T1 | Criar ticket de teste | Ticket ID, status remoto, tela de detalhe |
| T2 | Abrir detalhe e manter tela na pilha | UI tree com status e acoes visiveis |
| T3 | Login/acao do tecnico em outra rota ou sessao | Usuario tecnico, perfil e permissao |
| T4 | Tecnico registra solucao | Solucao criada, status remoto depois da solucao |
| T5 | Solicitante aprova solucao | Solucao aprovada, ticket fechado no GLPI |
| T6 | Voltar para detalhe antigo | Comparar UI antiga com estado remoto fechado |
| T7 | Tentar `Em Atendimento` | Resposta UI, resposta API, estado remoto depois |
| T8 | Tentar `Solucionado` | Resposta UI, resposta API, estado remoto depois |
| T9 | Fechar e reabrir app | Estado real apresentado apos bootstrap limpo |

## Probes de API

As chamadas abaixo devem ser feitas com sessao valida e sem expor credenciais em logs.

### Ticket

```http
GET /Ticket/{ticketId}?expand_dropdowns=true
```

Registrar:

- `id`
- `status`
- `date_mod`
- `users_id_recipient`
- tecnico atribuido, se vier no payload

### Relacoes de usuario

```http
GET /Ticket/{ticketId}/Ticket_User?range=0-200
```

Registrar:

- solicitante (`type = 1`)
- tecnico (`type = 2`)

### Solucoes

```http
GET /Ticket/{ticketId}/ITILSolution?expand_dropdowns=true&sort=date_creation&order=DESC
```

Registrar:

- `id`
- `status`
- `users_id`
- `date_creation`
- `date_mod`, se existir

### Followups

```http
GET /Ticket/{ticketId}/TicketFollowup?expand_dropdowns=true&range=0-200&sort=date_creation&order=DESC
```

Registrar:

- se uma recusa ou mensagem foi criada indevidamente;
- autor;
- data.

## Perguntas que a autopsia precisa responder

1. Quando o ticket foi fechado, qual tela ficou sabendo disso primeiro?
2. A tela de detalhe antiga refez fetch ao voltar ou reutilizou snapshot?
3. Os botoes estavam visiveis ou apenas desabilitados?
4. A acao `Em Atendimento` chamou API ou morreu localmente?
5. A acao `Solucionado` chamou API de status, abriu modo solucao ou alterou solucao existente?
6. A API aceitou mutacao em ticket fechado?
7. Se aceitou, qual endpoint aceitou?
8. Depois de reabrir o app, qual estado remoto prevaleceu?
9. O problema esta na exibicao, na execucao da acao ou em ambas?

## Criterios de conclusao

### Hipotese validada

Uma hipotese so e considerada validada se houver:

- estado remoto antes;
- acao executada;
- resposta da API ou ausencia comprovada de chamada;
- estado remoto depois;
- UI antes/depois.

### Causa raiz provavel

A causa raiz deve ser formulada como:

> Quando `X` acontece, a camada `Y` usa `Z` como fonte de verdade, enquanto a camada `W` usa `K`; por isso a acao `A` permanece disponivel ou executavel apesar do estado remoto `S`.

Adicionar:

- confianca: alta, media ou baixa;
- evidencias que sustentam a conclusao;
- hipoteses descartadas e por que foram descartadas.

### Correcao minima

A correcao minima deve ser escolhida nesta ordem:

1. Corrigir a guarda de execucao antes da mutacao.
2. Corrigir refresh/invalidation da tela obsoleta.
3. Corrigir exibicao do botao.
4. Somente depois considerar centralizacao ou refactor.

### Criterio de stop

Encerrar a investigacao quando:

- a causa raiz estiver pelo menos 80% provavel;
- a correcao minima tiver sido validada no ticket de teste;
- nao houver outra hipotese restante com risco maior;
- o aprendizado para processo tiver sido registrado.

Nao prolongar a autopsia para buscar certeza absoluta se a correcao minima ja elimina o risco operacional observado.

## Aprendizado metodologico esperado

Este caso deve gerar pelo menos uma regra reutilizavel:

- uma invariante;
- uma pergunta de teste;
- um teste automatizado;
- uma evidencia manual.

Exemplo de invariante candidata:

> Um ticket fechado pelo GLPI nao pode executar acao de status, solucao ou mensagem a partir de nenhuma tela, mesmo que essa tela tenha sido aberta antes do fechamento.

## Aprendizado para processo

Ao encerrar este caso, preencher obrigatoriamente:

- Invariante quebrada:
- Pergunta de validacao que faltou:
- Teste automatizado criado ou atualizado:
- Evidencia manual capturada:
- Checklist ou matriz que deve receber a regra:
