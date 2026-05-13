# Adaptacao da Quality Foundation para Flutter

## Origem

Em 2026-04-29 foi estudado o pacote externo localizado em:

- `/home/jonathan/projects/work/files`
- `/home/jonathan/projects/work/files/sis-quality-foundation/sis-quality-foundation`

O pacote veio de uma pesquisa/conversa anterior sobre conclusao de aplicacoes, governanca de validacao e bugs de estado em tickets.

## Diagnostico do pacote

O pacote contem uma boa base metodologica:

- Definition of Ready;
- Definition of Done;
- autopsia de bugs;
- matriz de estados de ticket;
- matriz de transicoes;
- invariantes;
- fontes de verdade;
- skills conceituais para agentes;
- exemplo de `TicketPolicy`.

Porem ele foi produzido com premissas que nao batem integralmente com este repo:

- menciona React Native/Expo, mas este projeto e Flutter/Dart;
- menciona FastAPI como backend intermediario, mas o app atual usa GLPI SIS REST API diretamente;
- menciona Hub DTIC como escopo combinado, mas este repo e o app SIS Mobile Flutter;
- menciona Cerebro Central, mas este workspace nao tem Cerebro Central canonico disponivel;
- traz `ticketPolicy.ts`, mas a base atual usa `GlpiStatusMapper`, `AppStateTicketSupport`, `AppState` e `GlpiClient`.

Conclusao: o pacote deve ser adaptado, nao copiado literalmente.

## O que foi adotado

Foram criados documentos Flutter-native:

- `docs/domain/ticket/STATES.md`
- `docs/domain/ticket/TRANSITIONS.md`
- `docs/domain/ticket/INVARIANTS.md`
- `docs/domain/ticket/SOURCES_OF_TRUTH.md`
- `docs/quality/DOR.md`
- `docs/quality/DOD.md`
- `docs/quality/BUG_AUTOPSY_TEMPLATE.md`

Tambem foram atualizados:

- `AGENTS.md`
- `docs/README.md`
- `docs/AUTOPSIA_COMPLETA.md`
- `docs/AUTOPSIA_TICKET_FECHADO_STALE_STATE.md`

## O que nao foi adotado diretamente

### `TicketPolicy.ts`

Nao foi copiado.

Motivo:

- e TypeScript;
- pressupoe React/TS;
- criaria uma nova camada antes de provar duplicacao real no Dart atual;
- o app ja possui regras parciais em `GlpiStatusMapper` e `AppStateTicketSupport`.

Decisao:

- primeiro documentar invariantes e fontes de verdade;
- depois extrair regras reais do codigo atual;
- somente criar uma policy Dart se houver evidencia de que a correcao local nao basta.

### Skills locais

Nao foram instaladas em `.skills`.

Motivo:

- este repo ja tem governanca propria;
- instalar skills sem uso comprovado adicionaria configuracao persistente desnecessaria;
- as instrucoes de skills ainda falam em React/FastAPI.

Decisao:

- aproveitar os fluxos como docs operacionais;
- adaptar skills apenas se o uso recorrente provar valor.

### FastAPI/backend intermediario

Nao foi adotado como premissa.

Motivo:

- o backend real deste app e o GLPI SIS REST API;
- qualquer backend intermediario precisa ser decisao arquitetural explicita, fora deste slice.

### Cerebro Central

Nao foi adotado.

Motivo:

- `AGENTS.md` ja define que nao ha Cerebro Central canonico disponivel neste workspace;
- nenhum indice externo substitui leitura do repo atual.

## Como usar daqui para frente

Para bug simples:

1. `docs/AUTOPSIA_RAPIDA.md`
2. se houver divergencia UI/API/GLPI, promover para `docs/AUTOPSIA_COMPLETA.md`

Para bug de ticket fechado/tela stale:

1. `docs/AUTOPSIA_TICKET_FECHADO_STALE_STATE.md`
2. `docs/quality/BUG_AUTOPSY_TEMPLATE.md`
3. `docs/domain/ticket/*.md`

Para feature ou correcao nao trivial:

1. preencher `docs/quality/DOR.md`;
2. implementar a menor mudanca suficiente;
3. validar com `docs/quality/DOD.md`;
4. atualizar `docs/domain/ticket/*.md` se mudar estado, transicao, invariante ou fonte de verdade.

## Proximo slice recomendado

Rodar uma extracao de invariantes no codigo atual, focando:

- `lib/models/glpi_status.dart`;
- `lib/state/app_state_ticket_support.dart`;
- `lib/state/app_state.dart`;
- `lib/state/app_state_solution_support.dart`;
- `lib/screens/ticket_detail_screen.dart`;
- `lib/screens/ticket_message_screen.dart`;
- `test/ticket_role_policy_test.dart`;
- `test/glpi_status_mapper_test.dart`.

Saida esperada:

- regras ja cobertas;
- regras duplicadas;
- lacunas reais de guarda;
- decisao fundamentada sobre criar ou nao uma policy Dart.
