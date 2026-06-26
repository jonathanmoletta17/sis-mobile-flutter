# Checklists SIS - conhecimento consolidado

## Objetivo

Consolidar o conhecimento existente no repo sobre os checklists da SIS:

- onde estao documentados ou materializados;
- quais contratos, rules e configs os descrevem;
- quais acoes GLPI/FormCreator derivam deles;
- por que o app Flutter SIS atual nao trata checklist como formulario comum.

Este documento e read-only por natureza. Ele nao autoriza validacao mutavel no
GLPI real nem altera o escopo do app.

## Fontes verificadas

- `assets/glpi_rules_sis.json`
  - contrato v2 versionado, gerado de dumps read-only da API GLPI SIS;
  - contem status, transicoes por perfil, visibilidade, SearchOptions,
    `form_catalog`, arvore de categorias e notificacoes.
- `tool/external-access/workers-vpc/src/metadata_catalog.js`
  - catalogo runtime servido pelo Worker SIS;
  - fonte mais rica para o app, com records governados, atores por alvo,
    sub-servicos, flags de checklist e contrato de read-back.
- `lib/catalog/governed_service_catalog.dart`
  - modelo Dart do catalogo governado.
- `lib/catalog/service_catalog_repository.dart`
  - projecao do catalogo runtime para servicos renderizaveis por perfil.
- `lib/catalog/governed_submission_contract.dart`
  - resolve contratos de submissao e bloqueia checklist como fluxo
    especializado.
- `lib/services/glpi_ticket_support.dart`
  - monta payload nativo `POST /Ticket` e limita atores que o app pode enviar.
- Testes relacionados:
  - `test/service_catalog_repository_test.dart`
  - `test/governed_submission_contract_test.dart`
  - `test/lab_profile_services_test.dart`
  - `test/glpi_ticket_support_test.dart`
- Docs relacionados:
  - `README.md`
  - `docs/MVP_SCOPE_FINAL.md`
  - `docs/PADRONIZACAO_APPS_SIS_DTIC.md`
  - `docs/domain/ticket/SOURCES_OF_TRUTH.md`
  - `docs/ROTEIRO_TESTE_E2E_SOLICITANTE.md`
  - `MVP_VALIDATION_CHECKLIST.txt`

Ocorrencias homonimas encontradas, mas nao usadas como regra de checklist SIS:

- `TEST_PLAN_COMPLETE.md` usa "REGRESSAO CHECKLIST" como lista de regressao de
  QA; os casos ali sao encoding UTF-8 e validacao de solucao, nao formularios
  FormCreator de checklist;
- `HERMES_TEST_EXECUTION_PROTOCOL.md` usa checklist como lista operacional para
  execucao de protocolo;
- arquivos DTIC com `FormCreator` pertencem a linha DTIC, que o `README.md`
  mantem separada da linha SIS.

## Inventario atual

### Contrato bruto versionado

`assets/glpi_rules_sis.json` declara, sob a chave `_meta` (nao na raiz; usar
`jq '._meta'`, e nao `jq '.counts'`):

- `_meta.generated_at`: `2026-06-17T23:28:44.503441+00:00`
- `_meta.schema_version`: `2.0`
- `_meta.counts`:
  - profiles: 11
  - forms: 41
  - target_tickets: 241
  - categories: 109

As chaves de topo do contrato sao `_meta`, `category_tree`, `form_catalog`,
`notifications`, `search_options`, `status` e `visibility`.

Nesse contrato bruto gerado, a busca por checklist no `form_catalog` encontra:

- 12 formularios com nome ou alvo contendo `CHECKLIST`;
- 67 target tickets relacionados a checklist.

Resumo dos formularios brutos:

| Form | Nome | Targets checklist | Regras principais |
| --- | --- | ---: | --- |
| 41 | sem nome | 2 | `category_rule=1`, `show_rule=1`, `CURRENT_ENTITY` |
| 42 | sem nome | 2 | `category_rule=1`, `show_rule=1`, `CURRENT_ENTITY` |
| 43 | sem nome | 11 | `category_rule=1`, `show_rule=2`, `SPECIFIC:58` |
| 44 | CHECKLIST TOTAL | 11 | `category_rule=1`, `show_rule=2`, `SPECIFIC:58` |
| 45 | sem nome | 11 | `category_rule=1`, `show_rule=2`, `SPECIFIC:58` |
| 46 | sem nome | 2 | `category_rule=1`, `show_rule=2`, `SPECIFIC:58` |
| 47 | sem nome | 11 | `category_rule=1`, `show_rule=2`, `SPECIFIC:58` |
| 48 | CHECKLIST REFRIGERACAO | 3 | `category_rule=2`, categoria 152, `show_rule=2`, `SPECIFIC:58` |
| 49 | CHECKLIST CALHAS E PLUVIAIS | 1 | `category_rule=2`, categoria 149, `show_rule=1`, `SPECIFIC:58` |
| 50 | CHECKLIST HIDRAULICO | 5 | `category_rule=2`, categoria 151, `show_rule=2`, `SPECIFIC:58` |
| 51 | CHECKLIST PEDRAS PORTUGUESAS | 1 | `category_rule=2`, categoria 150, `show_rule=1`, `SPECIFIC:58` |
| 52 | CHECKLIST ILUMINACAO | 7 | `category_rule=2`, categoria 148, `show_rule=2`, `SPECIFIC:58` |

Observacao importante: essa contagem vem do contrato gerado em
`assets/glpi_rules_sis.json`. Em varios targets, o campo `target_name` ja esta
enriquecido com templates como `Checklist ... ##answer_x##`. No snapshot API
bruto, parte dos mesmos targets tem nome operacional sem a palavra checklist.

### Snapshot API local de origem

O catalogo runtime declara como fonte um snapshot API `2026-06-10`. A copia
local verificada esta em:

`/home/jonathan/.brain/glpi-governance/2026-06-10-api/`

Arquivos relevantes nessa fonte:

- `sis-snapshot-api-2026-06-10.json`
- `questions_full.json`
- `conditions_full.json`
- `target_actors.json`

Contagens do snapshot:

- `formcreator_forms`: 41
- `formcreator_questions`: 6992
- `formcreator_targettickets`: 241
- `formcreator_sections`: 249
- `formcreator_target_actors`: 865
- `rule_ticket_criteria`: 262
- `rule_ticket_actions`: 297
- `categories`: 109
- `locations`: 422
- `entities`: 85
- `profiles`: 11

Para os IDs 41-52 relacionados a checklist, o snapshot contem:

- 12 IDs de formulario com secoes/perguntas/targets;
- apenas 6 linhas correspondentes em `formcreator_forms`: 44, 48, 49, 50, 51 e
  52;
- 94 secoes;
- 6361 perguntas;
- 3897 perguntas obrigatorias;
- 67 target tickets;
- 6023 condicoes em perguntas, 93 em secoes e 108 em targets.

Tabela consolidada dos 12 IDs:

| Form | Linha em `formcreator_forms` | Ativo | Secoes | Perguntas | Obrigatorias | Targets | Fieldtypes predominantes |
| --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| 41 | nao | n/a | 3 | 531 | 448 | 2 | glpiselect 198, multiselect 84, radios 83 |
| 42 | nao | n/a | 5 | 531 | 448 | 2 | glpiselect 198, multiselect 84, radios 83 |
| 43 | nao | n/a | 10 | 815 | 681 | 11 | glpiselect 273, multiselect 137, radios 136 |
| 44 | sim | 0 | 20 | 1237 | 0 | 11 | glpiselect 319, radios 236, textarea 234 |
| 45 | nao | n/a | 12 | 366 | 274 | 11 | radios 92, file 91, textarea 91 |
| 46 | nao | n/a | 10 | 814 | 680 | 2 | glpiselect 275, radios 136, multiselect 135 |
| 47 | nao | n/a | 10 | 815 | 681 | 11 | glpiselect 273, multiselect 137, radios 136 |
| 48 | sim | 1 | 4 | 111 | 0 | 3 | file 27, textarea 27, radios 27 |
| 49 | sim | 1 | 2 | 67 | 1 | 1 | glpiselect 29, multiselect 10, radios 9 |
| 50 | sim | 1 | 6 | 235 | 0 | 5 | multiselect 59, radios 58, file 58 |
| 51 | sim | 1 | 2 | 20 | 0 | 1 | radios 6, file 6, textarea 6 |
| 52 | sim | 1 | 10 | 819 | 684 | 7 | glpiselect 276, radios 136, multiselect 136 |

Distribuicao dos 67 targets brutos:

- `category_rule=1`: 50 targets
- `category_rule=2`: 17 targets
- `location_rule=1`: 4 targets
- `location_rule=2`: 63 targets
- `type_rule=1`: 67 targets
- `urgency_rule=1`: 67 targets
- `show_rule=1`: 6 targets
- `show_rule=2`: 61 targets
- `destination_entity_value=0`: 4 targets
- `destination_entity_value=58`: 63 targets

Atores brutos dos 67 targets:

- `observer:validator:0`: 67
- `assigned:group:22`: 59
- `requester:author:0`: 54
- `requester:group:49`: 41
- `observer:group:49`: 3
- `assigned:group:21`: 1

Categorias de checklist na arvore SIS:

| Categoria | Caminho |
| ---: | --- |
| 147 | `Manutencao > Checklist` |
| 148 | `Manutencao > Checklist > Iluminacao` |
| 149 | `Manutencao > Checklist > Calhas e Pluviais` |
| 150 | `Manutencao > Checklist > Pedras Portuguesas` |
| 151 | `Manutencao > Checklist > Hidraulico` |
| 152 | `Manutencao > Checklist > Refrigeracao` |

Nos 17 targets runtime, o campo historico `category_question` guarda esses IDs
de categoria 148-152 quando `category_rule=2`. A propria secao
`known_enum_semantics` do catalogo runtime marca `category_rule=2` como
atipico/legado e exige validacao antes de uso vivo.

Leitura desse snapshot:

- forms 41, 42, 43, 45, 46 e 47 tem secoes/perguntas/targets, mas nao tem linha
  propria em `formcreator_forms` no snapshot verificado;
- forms 48-52 sao os checklists ativos com linha completa em
  `formcreator_forms`;
- o runtime publicou exatamente os 17 targets com `category_rule=2`, que
  correspondem aos forms 48-52;
- os outros 50 targets brutos parecem historico/intermediario, variacoes de
  checklist total ou configuracoes que nao foram expostas como records
  runtime.

### Catalogo runtime do Worker

`tool/external-access/workers-vpc/src/metadata_catalog.js` declara:

- `generated_at`: `2026-06-12T11:25:56.689073+00:00`
- source snapshot API: `2026-06-10`
- source counts:
  - FormCreator forms: 41
  - FormCreator questions: 6992
  - FormCreator target tickets: 241
  - RuleTicket criteria: 262
  - RuleTicket actions: 297
  - categories: 109
  - locations: 422
  - entities: 85
- records publicados ao app: 133
- records de checklist publicados ao app: 17
- records com `requires_specialized_flow=true`: 17
- portanto, no runtime atual, todos os fluxos especializados publicados sao
  checklists.

Os 17 records runtime sao:

| Form | Alvo | Sub-servico | Regras | Atores |
| --- | --- | --- | --- | --- |
| 49 CHECKLIST CALHAS E PLUVIAIS | 337 | CHECKLIST CALHAS E PLUVIAIS | cat 2, loc 2, type 1, urgency 1, show 1, entity 58 | observer validator; assigned group 22; requester group 49 |
| 50 CHECKLIST HIDRAULICO | 341 | HIDRAULICO ALA RESIDENCIAL | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22 |
| 50 CHECKLIST HIDRAULICO | 342 | HIDRAULICO ALA GOVERNAMENTAL | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22 |
| 50 CHECKLIST HIDRAULICO | 343 | HIDRAULICO GALPAO | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | observer validator; assigned group 22 |
| 50 CHECKLIST HIDRAULICO | 344 | HIDRAULICO GARAGEM | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | observer validator; assigned group 22 |
| 50 CHECKLIST HIDRAULICO | 350 | HIDRAULICO Casa Civil 1005 | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22 |
| 52 CHECKLIST ILUMINACAO | 362 | ILUMINACAO ALA RESIDENCIAL 3o Pavimento | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22; requester group 49 |
| 52 CHECKLIST ILUMINACAO | 363 | ILUMINACAO ALA GOVERNAMENTAL - 1o Pavimento | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22; requester group 49 |
| 52 CHECKLIST ILUMINACAO | 364 | ILUMINACAO ALA RESIDENCIAL - 2o Pavimento | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 21; requester group 49 |
| 52 CHECKLIST ILUMINACAO | 365 | ILUMINACAO ALA RESIDENCIAL 1o Pavimento | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22; requester group 49 |
| 52 CHECKLIST ILUMINACAO | 366 | ILUMINACAO ALA GOVERNAMENTAL - 2o Pavimento | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; requester group 49; assigned group 22 |
| 52 CHECKLIST ILUMINACAO | 367 | ILUMINACAO ALA GOVERNAMENTAL - 3o Pavimento | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22; requester group 49 |
| 52 CHECKLIST ILUMINACAO | 368 | ILUMINACAO ALA GOVERNAMENTAL - 4o Pavimento | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22; requester group 49 |
| 51 CHECKLIST PEDRAS PORTUGUESAS | 359 | PEDRAS PORTUGUESAS | cat 2, loc 2, type 1, urgency 1, show 1, entity 58 | observer validator; assigned group 22; requester group 49 |
| 48 CHECKLIST REFRIGERACAO | 316 | REFRIGERACAO AR CENTRAL | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | requester author; observer validator; assigned group 22; observer group 49 |
| 48 CHECKLIST REFRIGERACAO | 325 | REFRIGERACAO 1005 | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | observer validator; assigned group 22; observer group 49 |
| 48 CHECKLIST REFRIGERACAO | 326 | REFRIGERACAO 951 | cat 2, loc 2, type 1, urgency 1, show 2, entity 58 | observer validator; assigned group 22; observer group 49 |

Distribuicao dos atores nos 17 records:

- `observer:validator:0`: 17
- `assigned:group:22`: 16
- `requester:author:0`: 11
- `requester:group:49`: 9
- `observer:group:49`: 3
- `assigned:group:21`: 1

Visibilidade publicada:

- todos os 17 records aparecem para `Super-Admin`;
- nenhum record de checklist runtime aparece para `Solicitante` comum na
  projecao atual.

Warnings runtime:

- o catalogo tem 49 warnings de governanca no total;
- 34 warnings recaem sobre records de checklist;
- os 17 records de checklist tem warning de `category_rule=2` atipico;
- os 17 records de checklist tem warning de `location_rule=2` atipico;
- a leitura segura e que esses records nao devem ser liberados sem validacao
  viva e fluxo especializado.

## Regras e configs relevantes

### Categorias SIS

Os checklists ativos publicados no runtime estao amarrados a categorias da
subarvore `Manutencao > Checklist`:

- form 52, iluminacao: categoria 148;
- form 49, calhas e pluviais: categoria 149;
- form 51, pedras portuguesas: categoria 150;
- form 50, hidraulico: categoria 151;
- form 48, refrigeracao: categoria 152.

Nao foi encontrado criterio `RuleTicket` com match por ID exato 147-152. As
regras GLPI que capturam checklists aparecem por texto amplo:
`itilcategories_id contains Manutencao`.

### FormCreator

Os checklists sao modelados como forms/targettickets FormCreator, nao como
simples categorias SIS.

Campos recorrentes nos targets:

- `category_rule`
- `category_question`
- `location_rule`
- `type_rule`
- `urgency_rule`
- `show_rule`
- `destination_entity`
- `destination_entity_mode`
- `destination_entity_value`

No catalogo runtime, os checklists usam:

- `category_rule=2`
- `location_rule=2`
- `type_rule=1`
- `urgency_rule=1`
- `show_rule=1` ou `show_rule=2`
- `destination_entity.mode=maintenance_context_para_mim`
- `destination_entity_value=58`

Nos targets ativos, `category_rule=2` deve ser lido junto da arvore de
categorias: o valor armazenado em `category_question` coincide com IDs de
categoria checklist, nao com perguntas do form. Exemplo: form 48 usa
`category_question=152`, que no `category_tree` e
`Manutencao > Checklist > Refrigeracao`.

No contrato bruto ha tambem checklists historicos/intermediarios com:

- `category_rule=1`
- `category_question=0`
- `destination_entity_mode=CURRENT_ENTITY` ou `SPECIFIC`

### RuleTicket e acoes derivadas

A secao `governance_rules` do catalogo runtime resume regras GLPI relevantes:

- rule 156: criterio `itilcategories_id contains Manutencao`, acao
  `assign CC-MANUTENCAO`, grupo 22;
- rule 155: criterio `itilcategories_id contains Conservacao`, acao
  `assign CC-CONSERVACAO`, grupo 21;
- rule 149: criterio `status novo + itilcategories_id contains Manutencao`,
  acao `append task_template` com templates 1 `EQUIPE EXECUTORA`, 3
  `MATERIAIS UTILIZADOS` e 2 `SERVICO REALIZADO`;
- rules 158-177: criterios por padroes de `locations_id`, acao
  `append task_template` com templates de localizacao 6-21.

Leitura para checklists:

- todos os filhos de `Manutencao > Checklist` sao candidatos a cair no criterio
  amplo `contains Manutencao`; portanto, a regra 156 e candidata a atribuir
  grupo 22 e a regra 149 e candidata a anexar templates base de tarefa quando o
  ticket nasce como novo;
- regras de localizacao podem adicionar task templates extras se o local do
  checklist bater nos padroes mapeados;
- `rule_ticket_criteria/actions` brutos tambem mostram rule 157
  `entities_id=58 -> _groups_id_observer=49`; isso nao aparece no resumo
  `governance_rules`, mas e uma acao GLPI potencial para tickets na entidade
  operacional 58;
- essas acoes sao diferentes dos atores FormCreator do target ticket: uma coisa
  e o ator configurado no FormCreator, outra e a regra GLPI executada depois na
  criacao/atualizacao do ticket.

### Atores derivados dos checklists

Os atores FormCreator de checklist nao se reduzem a requerente simples:

- todos usam `observer:validator:0`;
- quase todos atribuem `assigned:group:22`;
- um target de iluminacao atribui `assigned:group:21`;
- varios adicionam `requester:group:49` ou `observer:group:49`;
- parte usa `requester:author:0`.

Isso e relevante porque o payload nativo do SIS via `POST /Ticket` evita campos
de grupo/atribuicao para nao quebrar o perfil Solicitante. Ver
`GlpiTicketSupport.buildGovernedActorFields`.

### Entidade

O runtime traduz o destino dos checklists para:

- modo governado: `maintenance_context_para_mim`;
- valor: `58`.

`GovernedEntityResolver` resolve esse modo priorizando `destination_entity_value`
e depois entidades selecionadas/ativas. Portanto, para estes records, a entidade
resolvida esperada e 58, salvo alteracao futura do contrato.

### Read-back esperado

Os records de checklist carregam o contrato de read-back:

- `GET/SEARCH Ticket: id, entity, category, group, status, requesttype`
- `GET Ticket include_tasks/admin-equivalent: task templates when permitted`
- `Document_Item by Document.id/admin-equivalent when attachment uploaded`

No runtime atual, os records de checklist nao trazem `base_task_templates` nem
`expected_assignment_group` materializado como `expected_result.assignment_group`.
O grupo aparece como ator FormCreator (`assigned:group:*`), nao como
`expectedAssignmentGroup` do read-back.

### Resposta ao checklist MVP

`MVP_VALIDATION_CHECKLIST.txt` pede duas respostas sobre FormCreator SIS:

1. Se ha perguntas obrigatorias alem de categoria/localizacao.
2. Se ha atores `validator` ou `question_group`.

Para checklists SIS, a evidencia atual responde:

- sim, ha muitas perguntas alem de categoria/localizacao: nos 12 IDs brutos
  41-52 ha 6361 perguntas, 3897 obrigatorias e fieldtypes como `radios`,
  `multiselect`, `glpiselect`, `file` e `textarea`;
- considerando apenas os forms ativos publicados no runtime, 48-52 somam 1252
  perguntas e 685 obrigatorias;
- sim, ha `validator`: todos os 67 targets brutos de checklist carregam
  `observer:validator:0`, e todos os 17 records runtime tambem;
- `question_group` nao apareceu nos atores de checklist verificados; os atores
  brutos encontrados foram `author`, `validator` e `group`.

Isso confirma a decisao de v2/fluxo especializado documentada no MVP: checklist
nao cabe no renderer generico de categoria/localizacao.

### Status, busca e acoes de ticket

`assets/glpi_rules_sis.json` tambem governa:

- labels e terminalidade dos status GLPI 1-6;
- transicoes por perfil;
- escopo de visibilidade por perfil;
- campos de busca para "meus chamados".

Para "meus chamados", o contrato usa OR sobre:

- field 4: requerente;
- field 22: autor/recipient;
- field 66: observador.

Isso e importante para checklists porque alguns records adicionam usuario/grupo
como requester/observer/validator.

## Comportamento atual do app

### Catalogo

`ServiceCatalogRepository.servicesForProfile()` filtra qualquer record com
`requiresSpecializedFlow=true`. Se um servico tem somente records de checklist,
ele nao vira card renderizavel.

Esse comportamento esta coberto por teste em
`test/service_catalog_repository_test.dart`: checklists puros ficam ocultos e
servicos mistos preservam apenas records genericos.

### Submissao

`GovernedSubmissionResolver.resolve()` bloqueia explicitamente records com
`requiresSpecializedFlow=true` com a mensagem (citacao literal do codigo, com
acentos, em `lib/catalog/governed_submission_contract.dart`):

`formulário de checklist requer fluxo especializado; indisponível no app`

Esse comportamento esta coberto por
`test/governed_submission_contract_test.dart`.

### Payload nativo SIS

`GlpiTicketSupport.buildCreateTicketPayload()` envia:

- `name`;
- `content`;
- `status=1`;
- `requesttypes_id=1`;
- `entities_id`;
- `itilcategories_id`;
- `locations_id`, quando resolvido;
- `urgency`;
- `type`;
- `contact`;
- `_users_id_requester` e, no fluxo para terceiro, `_users_id_observer`.

Ele nao envia:

- `_groups_id_assign`;
- `_groups_id_requester`;
- `_groups_id_observer`;
- `_users_id_assign`.

O motivo documentado e provado em validacao E2E: o perfil Solicitante pode criar
chamado, mas nao pode atribuir grupo/tecnico; esses campos causam
`ERROR_GLPI_ADD`.

### Consequencia pratica

Checklist precisa de fluxo especializado porque mistura pelo menos tres
exigencias que o formulario SIS generico nao cobre:

1. perguntas FormCreator especializadas alem de categoria/localizacao;
2. atores FormCreator como `validator` e grupos;
3. semantica de destino/entidade e read-back diferente do `POST /Ticket`
   minimo usado hoje pelo Solicitante.

## Lacunas confirmadas

- O app SIS atual nao implementa renderer/submissao especializado de checklist.
- `MVP_SCOPE_FINAL.md` classifica `validator` e `question_group` como proxima
  iteracao.
- `MVP_SCOPE_FINAL.md` tambem declara que outras perguntas FormCreator alem de
  categoria/localizacao ficaram fora do MVP.
- `docs/PADRONIZACAO_APPS_SIS_DTIC.md` diz para nao introduzir FormCreator na
  SIS sem decisao arquitetural especifica.
- O Worker SIS permite endpoints FormCreator em allowlist, mas isso nao equivale
  a fluxo de submissao de checklist implementado no Flutter.

## Hipotese operacional para proximos passos

Confianca alta: checklists SIS devem ser tratados como uma iniciativa propria,
nao como extensao pequena do formulario atual.

## Respostas operacionais as perguntas abertas

Estas respostas usam evidencia local: `assets/glpi_rules_sis.json`, snapshot API
`2026-06-10`, `metadata_catalog.js`, codigo Dart e testes. Nao houve validacao
mutavel contra GLPI real.

### 1. Quais target tickets ainda parecem ativos e relevantes?

Confianca alta para o estado local: os 17 targets publicados no runtime sao os
ativos/relevantes para uma futura superficie especializada.

| Grupo | Targets | Evidencia |
| --- | --- | --- |
| Refrigeração | 316, 325, 326 | form 48 ativo, visivel, `helpdesk_home=1`, publicado no runtime |
| Calhas e Pluviais | 337 | form 49 ativo, visivel, `helpdesk_home=1`, publicado no runtime |
| Hidraulico | 341, 342, 343, 344, 350 | form 50 ativo, visivel, `helpdesk_home=1`, publicado no runtime |
| Pedras Portuguesas | 359 | form 51 ativo, visivel, `helpdesk_home=1`, publicado no runtime |
| Iluminacao | 362, 363, 364, 365, 366, 367, 368 | form 52 ativo, visivel, `helpdesk_home=1`, publicado no runtime |

Os outros 50 targets devem ser tratados como historico/teste/legado ate prova
contraria:

- 11 targets do form 44 pertencem a `CHECKLIST TOTAL`, mas o form esta
  `is_active=0`;
- 39 targets pertencem a forms 41, 42, 43, 45, 46 e 47, que tem secoes,
  perguntas e targets no snapshot, mas nao tem linha correspondente em
  `formcreator_forms`;
- targets 257 e 259 carregam explicitamente nome de teste:
  `CHECKLIST teste somente mostrar equipamentos com erro`;
- nenhum desses 50 aparece como record runtime.

### 2. Por que o runtime publica 17 records a partir dos 67?

Confianca alta por inferencia de dados; o script gerador exato nao esta
versionado no repo.

O runtime publica exatamente os targets dos forms 48-52 porque eles tem o
conjunto que parece representar a configuracao viva:

- form row existente em `formcreator_forms`;
- `is_active=1`, `is_visible=1`, `helpdesk_home=1`;
- target com `category_rule=2` apontando para categorias 148-152 da arvore
  `Manutencao > Checklist`;
- `destination_entity_value=58`;
- atores FormCreator e warnings de fluxo especializado;
- perfil FormCreator `Super-Admin` no snapshot.

Os outros 50 targets ficam fora porque caem em uma destas categorias:

- form inexistente no conjunto atual de `formcreator_forms`;
- form desativado;
- `category_rule=1`/`category_question=0` historico;
- nomes de teste ou templates antigos;
- ausencia no catalogo runtime governado.

### 3. Qual perfil real deve usar checklist no app?

Estado atual confirmado: apenas `Super-Admin` aparece na visibilidade
FormCreator dos forms 41-52 e nos 17 records runtime.

Nota de evidencia (verificada em `formcreator_forms_profiles` do snapshot
`2026-06-10`): existe no GLPI o perfil `Manutencao e Conservacao`
(`profiles_id=11`), que aparece como visibilidade FormCreator de outros forms SIS
(ex.: forms 18, 19, 20), mas NAO dos forms de checklist 48-52. Ou seja, hoje
nenhum perfil operacional ve os checklists; somente `Super-Admin` (`profiles_id=4`).
Liberar checklist para `Manutencao e Conservacao` no app seria uma decisao de
produto a confirmar no GLPI, nao um fato ja configurado. Por isso o gate de perfil
do app deve ser derivado de `formcreator_forms_profiles` (a fonte de verdade do
GLPI), e nao de nomes de perfil fixados em codigo.

Produto recomendado: nao liberar para `Solicitante` comum e nao depender de
`Super-Admin` como perfil operacional de app. O perfil correto precisa ser um
perfil/grupo de trabalho de manutencao/conservacao, a confirmar no GLPI, porque
as regras e atores apontam para esse dominio:

- categorias `Manutencao > Checklist`;
- entidade operacional 58;
- rule 156 atribui `CC-MANUTENCAO`, grupo 22;
- rule 155 atribui `CC-CONSERVACAO`, grupo 21 em cenarios de conservacao;
- ha usos de grupo 49 como requester/observer;
- os formularios sao de execucao/inspecao, nao de abertura simples por
  solicitante final.

Antes de app habilitar isso, o GLPI precisa declarar explicitamente o perfil
alvo dos checklists, por exemplo `Manutencao e Conservacao` ou um perfil
dedicado de operadores de checklist. Sem essa confirmacao, manter bloqueado.

### 4. Quais perguntas precisam ser renderizadas e quais sao derivaveis?

Precisam ser renderizadas no fluxo especializado:

- `Checklist`: select `CORRETIVA`/`PREVENTIVA`;
- `Checklist Programada`: referencia opcional a Ticket;
- `Local`: radios ou multiselect, conforme o form;
- secoes condicionais por area/local;
- radios de estado/avaliacao;
- multiselect de defeitos, componentes ou acoes;
- `glpiselect` para itens/equipamentos `PluginGenericobjectConservacao`;
- anexo `file`;
- descricao `textarea`;
- regras de exibicao condicionais por pergunta/secao/target.

Escala dos forms ativos:

| Form | Perguntas | Obrigatorias | Principais fieldtypes |
| --- | ---: | ---: | --- |
| 48 Refrigeracao | 111 | 0 | file, textarea, radios, glpiselect, multiselect |
| 49 Calhas e Pluviais | 67 | 1 | glpiselect, multiselect, radios, file, textarea |
| 50 Hidraulico | 235 | 0 | multiselect, radios, file, textarea |
| 51 Pedras Portuguesas | 20 | 0 | radios, file, textarea |
| 52 Iluminacao | 819 | 684 | glpiselect, radios, multiselect, textarea, file |

Podem ser derivados automaticamente pelo contrato:

- form/target selecionado pelo card/subservico;
- categoria final 148-152;
- entidade 58;
- destino `maintenance_context_para_mim`;
- tipo e urgencia default/fixos;
- atores FormCreator configurados;
- grupos e task templates derivados por `RuleTicket`;
- read-back esperado.

Nao devem ser derivados sem entrada/contrato explicito:

- avaliacao de cada ponto de checklist;
- defeito/componente escolhido;
- item `PluginGenericobjectConservacao`;
- anexo e descricao;
- vinculo de checklist programada a Ticket;
- condicoes dinamicas de exibicao.

### 5. Submeter via FormCreator real ou `POST /Ticket` equivalente?

Recomendacao: para checklist completo, usar FormCreator real ou manter
indisponivel. Nao usar apenas `POST /Ticket` nativo como substituto imediato.

Motivo:

- os checklists sao forms FormCreator com centenas de perguntas, condicoes,
  anexos, glpiselects e target tickets;
- FormCreator configura validadores, grupos e nomes de target com templates
  `##answer_x##`;
- `POST /Ticket` nativo do SIS atual e deliberadamente minimo e evita campos de
  grupo/atribuicao porque o perfil `Solicitante` nao pode envia-los;
- um contrato equivalente em `POST /Ticket` teria que reimplementar a semantica
  do FormCreator, inclusive target selection, respostas, arquivos, atores,
  regras, templates e read-back. Isso e mais arriscado do que integrar o fluxo
  real.

Linha segura:

1. primeiro implementar renderer/read-only local dos forms 48-52;
2. depois habilitar submissao FormCreator em Worker com allowlist estrita e
   ambiente homologacao/sandbox ou ticket sintetico;
3. validar read-back de ticket, categoria, entidade, grupo, observadores,
   anexos e task templates;
4. so entao liberar para o perfil operacional confirmado.

Enquanto isso, o comportamento atual do app esta correto: checklist fica
bloqueado como `requires_specialized_flow`.

Roteiro executavel detalhado: `docs/superpowers/plans/2026-06-21-sis-checklists-end-to-end.md`.

## Perguntas remanescentes antes de implementar

Antes de implementar, ainda precisa confirmar fora do snapshot local:

1. Qual perfil GLPI real deve substituir `Super-Admin` como operador de
   checklist no app?
2. Se o endpoint FormCreator do Worker SIS sera habilitado para um allowlist
   minimo ou se sera criado um Worker/rota separada para checklist.
3. Como validar sem criar tickets reais indevidos: sandbox/homologacao, conta de
   teste, criterio de parada e cleanup controlado.

## Verificação ao vivo — 2026-06-22

Coleta 100% read-only via API REST GLPI (curl WSL, sessão Super-Admin).
Relatório completo: `/home/jonathan/.brain/glpi-governance/checklists-discovery-2026-06-22.md`

### Resultado dos checkpoints (vs snapshot 2026-06-10)

| # | Pergunta | Resultado |
|---|----------|-----------|
| 1 | Forms 48-52 ativos e sem alterações? | ✅ Idênticos — 1252 perguntas, 24 seções, sem mudanças |
| 2 | Apenas Super-Admin (id=4) enxerga os forms? | ✅ Confirmado — profile 11 ainda não atribuído no GLPI |
| 3 | Conservacao: quantos registros? Pesquisável por nome? | ✅ 342 registros, campo [1]=name tipo itemlink |
| 4 | 17 targets com entity=58 e categories 148-152? | ✅ Todos confirmados (anomalia target 364, ver abaixo) |
| 5 | Rules 149/155/156/157 ativas? | ✅ Todas ativas — comportamento provado em ticket 8852 |
| 6 | FormAnswers históricos provam o fluxo? | ✅ 38 answers, último 2026-06-16 — ticket 8852 verificado |
| 7 | Form 52 navegável? | ✅ Navegável — 1 seção inicial + 8 condicionais por ala/pavimento |

### Fatos novos descobertos

**Rule 153 (não documentada anteriormente):**
- Critério: `profiles_id = 12` (Solicitante-GG-Conservação)
- Ação: `_groups_id_observer = 49` (GG-CONSERVACAO)
- Complementa a Rule 157 (que usa entidade=58 como critério)

**Anomalia target 364 (ILUMINACAO ALA RESIDENCIAL - 2o Pavimento):**
- assigned `group:21` (CC-CONSERVACAO) em vez de `group:22` (CC-MANUTENCAO)
- Único dos 17 targets com essa configuração
- Pode ser intencional — verificar com equipe antes de habilitar submissão

**PluginGenericobjectConservacao confirmado:**
- 342 itens físicos do palácio (luminárias ARC201, ARC203, interruptores, tomadas)
- Campos de busca: [1]=name, [3]=localização, [91]=prédio, [92]=sala
- Os 276 glpiselect do form 52 mapeiam para estes itens

**Ticket 8852 prova o fluxo completo:**
- Form 49, entidade=58, categoria=149, group assigned=22, observer=49
- Task templates criados: [1=EQUIPE EXECUTORA, 3=MATERIAIS UTILIZADOS, 2=SERVIÇO REALIZADO]
- Confirma rules 149 + 155 + 156 + 157 todas disparando corretamente

### Impacto no app Flutter

O catálogo embarcado `assets/sis_checklists_catalog.json` está **atualizado** —
não há alterações desde o snapshot de 2026-06-10. Nenhuma regeneração necessária.

Antes de habilitar submissão (Fase 9), ações pendentes no GLPI (não no app):
1. Decidir se profile 11 (Manutenção e Conservação) deve ser adicionado aos forms 48-52
2. Confirmar se target 364 com group 21 é intencional

O app permanece correto com `SIS_ENABLE_CHECKLISTS_SUBMISSION=false`.

## Validação ponta-a-ponta — 2026-06-22 (Phase 9)

Sessão de validação E2E com harness real (curl + sessão GLPI ao vivo + Flutter web app).

### Achados de gate OR (group_ids)

`PluginFormcreatorForm_Group` adicionado ao allowlist do Worker. Verificação ao vivo:
- Worker `GET /PluginFormcreatorForm_Group`: HTTP 200 com 5 registros (forms 48-52, group=22 todos) ✅
- `getFullSession` retorna `glpigroups` como `List<int>` — Admin: `[12,21,22,...]`, Solicitante: `[12]` ✅
- Gate OR com sessão real profile 11 + grupo 22: `por_perfil=False, por_grupo=True` → forms visíveis ✅
- Gate OR com sessão real profile 9 + grupo 12: `por_perfil=False, por_grupo=False` → forms ocultos ✅
- App Flutter ao vivo (conta de teste com grupo 22): tela mostra "Checklists de manutenção: 5 formulários · 17 itens" ✅

### Phase 9 — descoberta crítica: FormCreator REST API não aceita POST

Tentativa de submissão via `POST /PluginFormcreatorFormAnswer` (REST API GLPI) retorna HTTP 400 com
`["ERROR_GLPI_ADD",""]` em TODOS os cenários testados:
- Admin (profile 4, autorizado por `formcreator_forms_profiles`) → HTTP 400
- Conta de teste (profile 9 + grupo 22) → HTTP 400
- Qualquer payload (minimal, com respostas, com/sem campo `add`) → HTTP 400
- Qualquer entidade ativa (1 ou 58) → HTTP 400

O Worker com `ALLOW_FORMCREATOR_SUBMISSION=true` foi deployado e o app Flutter corretamente
enviou a requisição — o erro veio do GLPI, não do Worker nem do app. O app retornou
"Falha: GLPI respondeu HTTP 400" conforme esperado pelo error handler.

**Conclusão:** FormCreator nesta versão do GLPI não suporta criação de FormAnswer via REST API.
Os 5269 FormAnswers existentes no GLPI foram criados via helpdesk web PHP
(`/sis/plugins/formcreator/front/formanswer.form.php`), não via REST.

### O que isso significa para o app

A rota `POST /PluginFormcreatorFormAnswer` via REST não é viável com este GLPI/FormCreator.
Opções para Phase 9 real:
1. **Submissão via helpdesk web** (requer session cookie PHP + CSRF) — fora do escopo mobile
2. **FormCreator com upgrade de versão** — se nova versão do plugin resolver o suporte REST
3. **Alternativa: POST /Ticket direto** com categoria e entidade corretas — perde validações FormCreator
4. **Manter modo read-only** como estado canônico do app — revisão checklist sem submissão

Flags restaurados imediatamente após teste: `ALLOW_FORMCREATOR_SUBMISSION=false` e `.env` sem `SIS_ENABLE_CHECKLISTS_SUBMISSION`.

### Estado canônico pós-Phase 9

- Worker: deployado com `ALLOW_FORMCREATOR_SUBMISSION=false` (Version ID: b35db215)
- App: submissão desabilitada (flag ausente do .env = false)
- Conta de teste: grupo 22 removido (`glpigroups: [12]` restaurado, Group_User ID 1299 deletado)
- 269 testes Flutter passando, 22 testes Worker passando, `flutter analyze` clean

---

## Resolução Phase 9 — 2026-06-22: Pivot para POST /Ticket

### Decisão

`POST /PluginFormcreatorFormAnswer` retorna HTTP 400 em todos os cenários nesta versão do GLPI/FormCreator (causa raiz: `prepareInputForAdd()` retorna false sem mensagem de erro). FormCreator REST não é viável sem upgrade do plugin.

**Decisão canônica: submissão de checklist via `POST /Ticket`** com as respostas visíveis formatadas em HTML no campo `content`, categoria e entidade derivadas do target escolhido pelo operador.

### Justificativa

- `POST /Ticket` funciona via REST API (provado em múltiplas sessões anteriores)
- Categoria correta (148-152) dispara RuleTickets de atribuição de grupo → CC-MANUTENCAO notificada/atribuída
- Entidade=58 garante o domínio correto no GLPI
- O app já valida as respostas localmente (condições, campos obrigatórios, pré-preenchimento) antes de submeter
- Não requer FormAnswer records: o ticket é o artefato de produção

### Mudanças de código implementadas

| Arquivo | O que mudou |
|---|---|
| `lib/checklists/checklist_submission.dart` | Adicionado `toTicketContent()` + `toTicketInput()` para gerar payload `POST /Ticket` com respostas agrupadas por seção |
| `lib/services/glpi_client.dart` | Adicionado `submitChecklistAsTicket()` — POST para `/Ticket` com respostas em HTML no `content` |
| `lib/state/app_state.dart` | `submitChecklist()` agora chama `submitChecklistAsTicket()` em vez de `submitFormCreatorAnswer()` |

### Validação E2E — 2026-06-22

**Ticket de teste criado: #9817**

Payload enviado via REST:
```json
{
  "input": {
    "name": "[TESTE-AUTOMATIZADO SIS] Checklist HIDRÁULICO ALA RESIDÊNCIAL",
    "content": "<p><b>Formulário:</b> CHECKLIST HIDRÁULICO<br>...",
    "entities_id": 58,
    "itilcategories_id": 151,
    "type": 1
  }
}
```

Read-back confirmado:
- `id: 9817` ✓
- `entities_id: 58` ✓ (Secretaria Executiva do Palácio Piratini)
- `itilcategories_id: 151` ✓ (Manutenção > Checklist > Hidraulico)
- `status: 5` (Solucionado após ITILSolution adicionada)
- **RuleTickets disparadas:** grupo CC-MANUTENCAO atribuído ao ticket ✓
- `users_id_recipient: 2373` = conta de teste ✓

**Cleanup:** followup de encerramento (ID 12907) + ITILSolution (ID 8262) adicionados. Ticket #9817 registrado para exclusão humana e auditoria.

### Estado canônico pós-resolução

- App: submissão via `POST /Ticket` implementada; habilitada quando `SIS_ENABLE_CHECKLISTS_SUBMISSION=true` no `.env`
- Worker: sem mudanças necessárias (já roteia `POST /Ticket`); `ALLOW_FORMCREATOR_SUBMISSION=false` permanece (não usado no novo fluxo)
- Testes: **269/269 passando**, `flutter analyze` limpo
- `submitFormCreatorAnswer()` mantido no código mas não mais chamado — preservado caso o FormCreator seja atualizado no futuro

## Comandos usados neste levantamento

```bash
rg --files | rg -i 'check|form|catalog|rules|metadata|validation|mvp|roteiro|governed|dtic|sis'
rg -n -i 'checklist|FormCreator|task templates|EQUIPE EXECUTORA|MATERIAIS UTILIZADOS|source_rule_id|location_map_task_rules|expected_tasks|expectedAssignmentGroup|GovernedChecklist|checklist requer|formulario de checklist|governed' docs lib test assets tool/external-access/workers-vpc/src
rg -l -i 'checklist|check list|formcreator|targetticket|target ticket|validator|question_group' -g '!build/**' -g '!**/.dart_tool/**' -g '!**/.git/**' .
jq 'keys' assets/glpi_rules_sis.json
jq '.form_catalog | to_entries[] | select(((.value.name // "") | test("CHECKLIST"; "i")) or ([.value.targets[]?.target_name // ""] | join(" ") | test("CHECKLIST"; "i"))) | {id:.key,name:.value.name,target_count:(.value.targets|length)}' assets/glpi_rules_sis.json
jq '.sections.formcreator_forms.rows[] | select(.id >= 41 and .id <= 52) | {id,name,is_active,is_visible,helpdesk_home}' /home/jonathan/.brain/glpi-governance/2026-06-10-api/sis-snapshot-api-2026-06-10.json
jq '.sections.formcreator_targettickets.rows[] | select(.form_id >= 41 and .form_id <= 52) | {id,form_id,name}' /home/jonathan/.brain/glpi-governance/2026-06-10-api/sis-snapshot-api-2026-06-10.json
jq '.category_tree[] | select(.id >= 147 and .id <= 152)' assets/glpi_rules_sis.json
jq '{criteria:[.sections.rule_ticket_criteria.rows[] | select(.rules_id as $r | [149,153,154,155,156,157,177] | index($r))], actions:[.sections.rule_ticket_actions.rows[] | select(.rules_id as $r | [149,153,154,155,156,157,177] | index($r))]}' /home/jonathan/.brain/glpi-governance/2026-06-10-api/sis-snapshot-api-2026-06-10.json
git log --oneline --all --grep='checklist\|FormCreator\|governed\|rules\|catalog' --regexp-ignore-case -n 30
```

Tambem foram usados filtros `jq` e scripts Node ad hoc read-only para:

- selecionar `form_catalog` com nome/alvo contendo `CHECKLIST`;
- parsear `tool/external-access/workers-vpc/src/metadata_catalog.js`;
- agregar secoes, perguntas, obrigatoriedade, fieldtypes, condicoes, regras e
  atores do snapshot API local;
- contar warnings runtime de `category_rule` e `location_rule` para checklist;
- contar records `CHECKLIST`, `requires_specialized_flow`, regras, atores e
  formularios no runtime.
