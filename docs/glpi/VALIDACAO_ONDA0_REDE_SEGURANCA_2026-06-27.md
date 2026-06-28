# Validacao Onda0 rede seguranca - estado atual

Data local: 2026-06-27 22h (-03)
Branch: `fix/onda0-rede-seguranca`
Base: `ffc246c`
Escopo: build, probes read-only contra GLPI SIS vivo, smoke visual web local e
checagem das correcoes necessarias para remover acoplamento por IDs de grupo.

## Restricoes aplicadas

- Credencial usada para probes GLPI: somente `SIS_TEST_USER` /
  `SIS_TEST_PASSWORD` do `.env`.
- Nenhum ticket real de usuario foi alterado.
- Nenhum `DELETE /Ticket`, usuario, grupo ou entidade foi executado.
- Nenhum ticket de teste foi criado nesta rodada.
- `https://app.glpi.sis.rs.gov.br` nao resolveu DNS a partir desta WSL; a
  confrontacao live possivel nesta rodada foi via API GLPI direta
  `SIS_TEST_BASE_URL`.

## Evidencia da conta de teste

Probe read-only via `initSession`, `getFullSession`, `getMyProfiles` e
`killSession`:

- usuario GLPI: `glpiID=2373`, `glpiname=teste`;
- perfil ativo: `id=9`, `name=Solicitante`, `interface=helpdesk`;
- perfis disponiveis: somente `9/Solicitante`;
- grupos da sessao: `[12]`;
- leitura direta `Group/21`, `Group/22`, `Group/49`: HTTP `403` para a conta de
  teste.

Conclusao: a conta de teste atual nao prova cenario tecnico/co-requerente. Com
essa credencial, ausencia de botoes tecnicos na UI e esperada e nao valida P-6.

## Evidencia dos grupos SIS

Como a conta de teste recebe HTTP `403` em `Group/{id}`, a confirmacao dos
grupos foi feita pelo Worker apenas em leitura de diretorio (`GET /Group/{id}`),
rota que usa sessao de servico para `User/Group` sem alterar a sessao do usuario.

| Grupo | Resultado live | Papel GLPI |
| ---: | --- | --- |
| 21 | `CC-CONSERVACÃO`, `is_assign=1`, `is_requester=1` | equipe tecnica de conservacao |
| 22 | `CC-MANUTENCAO`, `is_assign=1`, `is_requester=1` | equipe tecnica de manutencao |
| 49 | `GG-CONSERVACAO`, `is_assign=0`, `is_requester=1` | grupo GG observador/requerente, sem atribuicao tecnica |

Conclusao: os IDs 21/22/49 continuam ativos na instancia SIS, mas isso e fonte
de verdade da instancia, nao regra de runtime do app.

## Evidencia de Meus chamados / Ticket_User

Busca read-only direta em `search/Ticket` com criterio `field=4` para o usuario
`2373` retornou HTTP `206` e `totalcount=88` tickets como requerente. Amostra
mais recente:

| Ticket | Nome | Status | `Ticket_User type=1` |
| ---: | --- | ---: | --- |
| 10013 | `[TESTE-AUTOMATIZADO SIS] [E2E-CONTROLADO] RECUSAR 1782413027939` | 6 | usuario `2373`, requester unico |
| 10012 | `[TESTE-AUTOMATIZADO SIS] [E2E-CONTROLADO] APROVAR 1782413027939` | 6 | usuario `2373`, requester unico |
| 10011 | `[TESTE-AUTOMATIZADO SIS] [E2E-CONTROLADO] MAIN 1782413027939` | 6 | usuario `2373`, requester unico; `actorsCount=2` |

Conclusao: a API real confirma a forma `Ticket_User type=1` para a conta de
teste e explica a visibilidade em "Meus chamados". A amostra nao contem tecnico
co-requerente nem multiplos requesters, portanto nao valida P-6.

## Correcoes aplicadas no codigo

### Remocao de IDs fixos 21/22/49 no runtime

Foi criada a semantica central de grupos:

- `lib/models/glpi_group_semantics.dart`

Pontos alterados para usar nome/semantica do grupo, nao ID numerico:

- `lib/models/operational_role.dart`
- `lib/models/ticket_domain.dart`
- `lib/policy/permission_service.dart`
- `lib/policy/ticket_queue_classifier.dart`
- `lib/services/glpi_client.dart`

Tambem foi removido o fallback local que traduzia `21`, `22` e `49` para nomes
conhecidos em `_hydrateTicketGroups`.

Protecoes adicionadas em teste:

- `OperationalRoleResolver` nao classifica tecnico por ID numerico vazio;
- `TicketDomainResolver` nao infere dominio por ID SIS sem nome de grupo;
- `TicketQueueClassifier` nao classifica fila operacional apenas por ID numerico
  SIS.

Varredura final:

```text
rg -n "conservationGroupId|maintenanceGroupId|ggConservationGroupId|==\s*21|==\s*22|==\s*49|case ['\"]21['\"]|case ['\"]22['\"]|case ['\"]49['\"]" lib -g '*.dart'
```

Resultado: sem ocorrencias.

### SearchOptions de "Meus chamados" sem fallback embutido

A revisao separou o numero `22` de SearchOption GLPI do grupo SIS `22`. Para
evitar um segundo hardcode silencioso, a busca de "Meus chamados" deixou de
assumir `[4,22,66]` no cliente:

- `GlpiRulesClient.myTicketsActorFields` agora retorna somente os campos vindos
  de `assets/glpi_rules_sis.json` (`search_options.my_tickets_criteria`);
- `GlpiClientSupport.buildRequesterTicketSearchUri` exige `actorFieldIds`
  fornecidos pelo contrato governado;
- `AppState.fetchTickets` carrega o contrato antes de montar a busca pessoal;
- testes cobrem a falha explicita quando os campos nao sao fornecidos.

Conclusao: `22` ainda aparece como SearchOption documentado/contratado para
autor/recipient, mas nao como grupo de manutencao nem como fallback fixo no
runtime.

### CORS do Worker para metadata ETag

Durante o smoke web autenticado, o Worker publicado retornou preflight sem
`If-None-Match` em `Access-Control-Allow-Headers` para
`/metadata/mobile/sis/catalog`. A UI autenticou e caiu para catalogo em cache,
mas o refresh do runtime catalog falhou por CORS. Correcoes locais:

- `tool/external-access/workers-vpc/src/index.js`
- `tool/external-access/workers-vpc/test/allowlist.test.mjs`

## Resultado por cenario

| Cenario | Status | Evidencia | Observacao |
| --- | --- | --- | --- |
| Pull/build web | PASS | `git pull origin fix/onda0-rede-seguranca`; `/opt/flutter/bin/flutter build web` -> `Built build/web` | Build web recompilado apos as alteracoes. |
| Smoke UI web local | PASS com divergencia de Worker publicado | screenshots `/tmp/sis-mobile-validation/artifacts/11-current-build-login.png` e `/tmp/sis-mobile-validation/artifacts/12-current-build-after-login.png` | Login com conta de teste renderizou home `Serviços`/`Meus chamados`; console confirmou CORS em `If-None-Match`, entao a UI usou catalogo em cache. |
| P-6 tecnico co-requerente | BLOCKED | conta teste so possui perfil `9/Solicitante` e grupo `[12]`; API confirma tickets da conta como `Ticket_User type=1`, mas amostra tem requester unico | Necessita conta de teste com perfil/grupo tecnico e ticket onde ela seja co-requerente, ou ajuste reversivel da propria conta de teste aprovado explicitamente. |
| OperationalRole/fila por grupos 21/22/49 | PASS no codigo e fonte GLPI; BLOCKED na UI live | `rg` sem IDs fixos em `lib/`; testes de role/domain/queue passam; Worker `GET /Group/{id}` confirma 21/22/49 no GLPI real | UI live tecnica nao validavel com a conta atual. |
| GG observador sem acoes tecnicas | PASS no codigo e fonte GLPI; BLOCKED na UI live | `ticket_role_policy_test` cobre GG observador por nome; `Group/49` confirma `is_assign=0` | UI live GG nao validavel com a conta atual. |
| Checklist catalogo target 369 | PASS read-only | GLPI bruto `PluginFormcreatorTargetTicket/369`: form `50`, nome `HIDRÁULICO 951`, `category_question=151`, `destination_entity_value=58`, `show_rule=2`; asset local mostra target como 6o item do form 50 | Submissao UI nao executada porque a conta teste nao ve checklists. |
| Checklist submissao e ticket GLPI criado | BLOCKED | conta teste sem perfil/grupo de checklist; nenhum ticket criado | Requer perfil/grupo tecnico na conta de teste e aprovacao de mutacao sintetica. |
| `show_rule` de sections | PASS read-only + testes | asset local: `show_rule=1 count=7`, `show_rule=2 count=18`; testes `checklist_condition_engine_test` cobrem regra 1 sempre visivel e regra 2 condicional | UI live de checklist com conta teste nao disponivel. |

## Evidencia GLPI checklist

API GLPI direta, read-only:

```text
PluginFormcreatorForm/50 -> CHECKLIST HIDRÁULICO
PluginFormcreatorTargetTicket/369 -> HIDRÁULICO 951
PluginFormcreatorTargetTicket/369 raw:
  plugin_formcreator_forms_id=50
  category_question=151
  destination_entity=7
  destination_entity_value=58
  show_rule=2
PluginFormcreatorSection/400 -> CHECKLIST HIDRÁULICO 951, show_rule=2
```

Catalogo embarcado atual:

```text
form=50 name=CHECKLIST HIDRÁULICO
target_index=1 id=341 name=HIDRÁULICO ALA RESIDÊNCIAL category_id=151 destination_entity_value=58 show_rule=2
target_index=2 id=342 name=HIDRÁULICO ALA GOVERNAMENTAL category_id=151 destination_entity_value=58 show_rule=2
target_index=3 id=343 name=HIDRÁULICO GALPÃO category_id=151 destination_entity_value=58 show_rule=2
target_index=4 id=344 name=HIDRÁULICO GARAGEM category_id=151 destination_entity_value=58 show_rule=2
target_index=5 id=350 name=HIDRÁULICO Casa Civil 1005 category_id=151 destination_entity_value=58 show_rule=2
target_index=6 id=369 name=HIDRÁULICO 951 category_id=151 destination_entity_value=58 show_rule=2
```

## Tickets de teste

Nenhum ticket foi criado nesta rodada.

IDs para limpeza manual posterior: nenhum.

## Divergencias e bloqueios

1. Conta de teste atual e apenas `Solicitante`. Isso bloqueia validacao real de
   P-6 tecnico/co-requerente, filas tecnicas 21/22, GG observador e submissao de
   checklist por tecnico.
2. `https://app.glpi.sis.rs.gov.br` nao resolve DNS nesta WSL. A validacao Web
   Admin existente em `docs/glpi/VALIDACAO_GLPI_LIVE_2026-06-27.md` permanece
   historica; esta rodada usou API direta e Worker read-only como fonte live.
3. Worker publicado ainda bloqueia `If-None-Match` no preflight do catalogo
   metadata. A correcao esta no worktree, mas precisa ser publicada no Worker.
4. A ausencia de botoes tecnicos com a conta `Solicitante` nao deve ser usada
   como evidencia de P-6.

## Commits necessarios

1. `fix(policy): remover hardcode de grupos SIS do runtime`
   - inclui `glpi_group_semantics.dart`;
   - troca role/domain/permission/queue para semantica por nome de grupo;
   - adiciona testes contra classificacao por ID numerico isolado.
2. `fix(worker): permitir If-None-Match no preflight de metadata`
   - corrige CORS para refresh/cache do catalogo no web.
3. `fix(search): usar SearchOptions governados em meus chamados`
   - remove fallback embutido `[4,22,66]` do cliente;
   - mantem os campos vindo do contrato GLPI versionado.
4. Opcionalmente, consolidar este relatorio e o ajuste do documento de
   acoplamento no mesmo commit de documentacao.

## Gates executados

```text
git diff --check
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
/opt/flutter/bin/flutter build web
node --test tool/external-access/workers-vpc/test/*.mjs
```

Resultados:

- `flutter analyze`: sem issues;
- `flutter test`: `341` testes passaram, `15` skipped por flags de validacao
  live/mutavel desabilitadas;
- `flutter build web`: `Built build/web`;
- Worker tests: `23` testes passaram;
- `git diff --check`: sem erros.
