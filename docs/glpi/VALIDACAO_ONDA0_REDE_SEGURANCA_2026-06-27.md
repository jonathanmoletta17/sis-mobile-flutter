# Validacao Onda0 rede seguranca - estado atual

Data local: 2026-06-27 23h45 (-03)
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
- `changeActiveProfile` foi usado apenas em sessoes da propria conta de teste,
  para validar UI com perfis GLPI reais. Isso altera somente o contexto da
  sessao GLPI e as sessoes foram encerradas com `killSession`.
- `https://app.glpi.sis.rs.gov.br` nao resolveu DNS a partir desta WSL; a
  confrontacao live possivel nesta rodada foi via API GLPI direta
  `SIS_TEST_BASE_URL`.

## Evidencia da conta de teste

Probe read-only via `initSession`, `getFullSession`, `getMyProfiles` e
`killSession`:

- usuario GLPI: `glpiID=2373`, `glpiname=teste`;
- perfil ativo padrao: `id=9`, `name=Solicitante`, `interface=helpdesk`;
- perfis disponiveis: `11/Manutenção e Conservação`, `9/Solicitante`,
  `12/Solicitante-GG-Conservação`;
- grupos da sessao: `[12, 21, 22, 49]`;
- leitura direta `Group/21`, `Group/22`, `Group/49`: HTTP `403` para a conta de
  teste.

Conclusao: a conta de teste atual permite validar UI com perfis tecnico e GG por
`changeActiveProfile` na propria sessao. O P-6 ainda depende de existir um ticket
onde o usuario `2373` seja co-requerente junto de outro usuario.

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
`2373` retornou `87` tickets como requerente na varredura mais recente. Amostra
mais recente:

| Ticket | Nome | Status | `Ticket_User type=1` |
| ---: | --- | ---: | --- |
| 10013 | `[TESTE-AUTOMATIZADO SIS] [E2E-CONTROLADO] RECUSAR 1782413027939` | 6 | usuario `2373`, requester unico |
| 10012 | `[TESTE-AUTOMATIZADO SIS] [E2E-CONTROLADO] APROVAR 1782413027939` | 6 | usuario `2373`, requester unico |
| 10011 | `[TESTE-AUTOMATIZADO SIS] [E2E-CONTROLADO] MAIN 1782413027939` | 6 | usuario `2373`, requester unico; `actorsCount=2` |

Varredura completa salva em
`output/playwright/onda0-rede-seguranca/p6-multiple-requester-scan.json`:

- tickets varridos: `87`;
- `multipleRequesterMatches`: `[]`.

Conclusao: a API real confirma a forma `Ticket_User type=1` para a conta de
teste e explica a visibilidade em "Meus chamados". Nao existe, hoje, ticket da
conta `2373` com multiplos requerentes para provar P-6 na UI real.

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
| Pull/build web | PASS | `git fetch origin fix/onda0-rede-seguranca`; branch limpa e `ahead 4`; `/opt/flutter/bin/flutter build web` -> `Built build/web` | `git pull` nao foi repetido porque ha commits locais a frente; remoto nao esta a frente apos `fetch`. |
| `flutter run -d chrome` | PASS | `/opt/flutter/bin/flutter run -d chrome --web-hostname 127.0.0.1 --web-port 8099` | Porta 8080 ja estava ocupada por um `flutter_tool` antigo deste workspace; a instancia limpa foi aberta em 8099. |
| Smoke UI web local | PASS com divergencia de Worker publicado | screenshots `output/playwright/onda0-rede-seguranca/03-login-current-flutter-run-8099.png`, `05-after-login-current-flutter-run-8099.png` | Login com conta de teste renderizou home `Serviços`/`Meus chamados`; console confirmou CORS em `If-None-Match`, entao a UI usou catalogo em cache. |
| P-6 tecnico co-requerente | BLOCKED | perfil 11 real disponivel, mas scan de `87` tickets do usuario `2373` encontrou `multipleRequesterMatches=[]` | Necessita ticket sintetico seguro com outro requerente de teste ou outro dado GLPI existente. Nao foi criado/alterado ticket com usuario real. |
| OperationalRole tecnico perfil 11 | PASS parcial na UI live | `changeActiveProfile(11)` na sessao da conta de teste; screenshots `09-home-profile-11-manutencao-conservacao-8099.png`, `10-chamados-profile-11-manutencao-conservacao-8099.png` | UI mostrou `Fila Operacional` com `107` itens. A conta tem simultaneamente grupos 21 e 22, entao nao separa manutencao vs conservacao por grupo isolado. |
| Grupos 21/22/49 ativos no GLPI | PASS fonte GLPI | Worker `GET /Group/{id}`: 21=`CC-CONSERVACÃO`, 22=`CC-MANUTENCAO`, 49=`GG-CONSERVACAO`; direto com usuario teste segue 403 | Fonte live confirma os IDs, mas runtime do app nao classifica por ID numerico. |
| GG observador sem acoes tecnicas | PASS na UI live | `changeActiveProfile(12)`; screenshot `12-chamados-profile-12-gg-conservacao-8099.png`; `Group/49 is_assign=0` | UI mostrou apenas `Fechado` com `3` itens, sem `Fila Operacional`, coerente com GG observador sem acoes tecnicas. |
| Checklist catalogo target 369 | PASS UI + read-only | screenshot `07-checklists-catalog-8099.png`; GLPI bruto `PluginFormcreatorTargetTicket/369`: form `50`, nome `HIDRÁULICO 951`, `category_question=151`, `destination_entity_value=58`, `show_rule=2` | UI mostra `CHECKLIST HIDRÁULICO` e `HIDRÁULICO 951` como 6o item. |
| Checklist formulario HIDRÁULICO 951 | PASS UI read-only | screenshot `08-checklist-hidraulico-951-form-8099.png`; `PluginFormcreatorSection/400 -> CHECKLIST HIDRÁULICO 951, show_rule=2` | Form abriu com target `Duque de Caxias 951` pre-selecionado. |
| Checklist submissao e ticket GLPI criado | BLOCKED | `SisChecklistPreparedSubmission.toTicketInput()` gera nome `Checklist <target>` sem prefixo inicial `[TESTE-AUTOMATIZADO SIS]`; nenhum ticket criado | Submeter agora violaria a restricao de prefixo obrigatorio no ticket de teste. |
| `show_rule` de sections | PASS UI + read-only + testes | `Section/350 Dados Gerais show_rule=1` aparece no formulario; `Section/400 CHECKLIST HIDRÁULICO 951 show_rule=2` aparece quando target 369 e selecionado; asset local: `show_rule=1 count=7`, `show_rule=2 count=18` | Testes `checklist_condition_engine_test` cobrem regra 1 sempre visivel e regra 2 condicional. |

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
PluginFormcreatorSection/350 -> Dados Gerais, show_rule=1
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

1. Nao ha ticket atual da conta `2373` com multiplos requerentes. Isso bloqueia
   a validacao P-6 real sem criar/alterar ticket envolvendo outro usuario.
2. A conta de teste possui grupos 21 e 22 simultaneamente. Isso valida o fluxo
   tecnico hibrido na UI, mas nao isola manutencao versus conservacao sem mudar
   a configuracao da propria conta.
3. A submissao de checklist real esta bloqueada por seguranca: o nome gerado
   pelo fluxo atual nao comeca com `[TESTE-AUTOMATIZADO SIS]`.
4. `https://app.glpi.sis.rs.gov.br` nao resolve DNS nesta WSL. A validacao Web
   Admin existente em `docs/glpi/VALIDACAO_GLPI_LIVE_2026-06-27.md` permanece
   historica; esta rodada usou API direta e Worker read-only como fonte live.
5. Worker publicado ainda bloqueia `If-None-Match` no preflight do catalogo
   metadata. A correcao esta no worktree, mas precisa ser publicada no Worker.
6. A ausencia de botoes tecnicos com a conta no perfil `Solicitante` nao deve
   ser usada como evidencia de P-6.

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
