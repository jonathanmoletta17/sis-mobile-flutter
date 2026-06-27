# Dossiês de Consolidação P1–P5 — fase pós-auditoria FormCreator

Data: 2026-06-27
Branch: `fix/onda0-rede-seguranca`
Base: commits `393ef25` (catálogo live + dossiê 1.3) e `4539e83` (docs/auditoria).

> **Para quem executa (Claude/Codex/Antigravity):** cada dossiê é auto-contido,
> aterrado em arquivo:linha real verificado em 2026-06-27. Implemente exatamente o
> escopo; NÃO improvise além dele. Rode o gate verde de cada dossiê antes de commit
> atômico. NÃO faça mutação contra GLPI real, NÃO use Worker pass-through destrutivo,
> NÃO implemente operadores `show_condition` 3/4/5/6/9 sem novo escopo.

## Por que esta ordem

A auditoria (`AUDITORIA_FORMCREATOR_RUNTIME_2026-06-27.md`) mostrou que o risco maior
não está nos dossiês originais 1.1/1.2, e sim em dois pontos client-side achados fora
deles. Ordem por impacto/risco, não por número de dossiê:

| Dossiê | Tema | Risco | Precisa GLPI? | Status |
| --- | --- | --- | --- | --- |
| P1 | Offline governado preserva contrato | Alto | Não | A fazer |
| P2 | Resolver governado fail-closed | Médio/Alto | Não | A fazer |
| P3 | Guarda de regressão do 1.3 (`show_rule` de section) | Baixo | Não | 1.3 já aplicado; falta guarda |
| P4 | Operadores 7/8 como hardening (engine) | Baixo/defensivo | Não p/ hardening; Sim p/ bug ativo | A fazer (opcional) |
| P5 | Contrato `show_tree_depth` produtor/consumidor | Médio | Não | A fazer |

Gate BD direto (sem credenciais DB nem cliente mysql/mariadb no WSL) segue pendente
e é independente de P1–P5, que são todos verificáveis localmente.

---

## DOSSIÊ P1 — Offline governado preserva o contrato ⭐ PRIORITÁRIO

### Problema (com evidência)

O fluxo online de submissão usa ids governados; o fluxo offline os perde.

- Envio online: `lib/services/glpi_ticket_support.dart:117-123` lê
  `formData['governedCategoryId']` e `formData['governedLocationId']` para montar o
  payload GLPI (`itilcategories_id` / localização).
- Modelo offline: `lib/models/glpi_ticket.dart:3-50` — `GlpiTicket` **não possui**
  campos `governedCategoryId`, `governedLocationId`, `governedEntityId` nem readback.
  Só guarda `entitiesId` (`entities_id`), `entityName` e `localizacao` (string livre).
- Serialização: `toMap()` (linha 52-77) e `fromMap()` (linha 79-132) **não** carregam
  ids governados de categoria/localização.
- Sincronização: `lib/state/app_state.dart:938` monta `mapData = ticket.toMap()` e
  `:977` chama `_apiService.createTicket(mapData, ...)`.

### Consequência

Um ticket criado offline a partir de fluxo governado, ao sincronizar, não reproduz o
payload online: a categoria pode cair em fallback estático por nome de serviço e a
localização vira string/é perdida. Divergência online vs. offline silenciosa.

### Arquivos a tocar

- `lib/models/glpi_ticket.dart` — adicionar campos governados + serialização.
- `lib/state/app_state.dart` — garantir que a criação offline preencha os campos e que
  `synchronizeTickets()` os repasse no `mapData`.
- `lib/services/glpi_ticket_support.dart` — só se necessário, para também aceitar os
  ids vindos do `GlpiTicket` persistido (já lê de `formData`; manter a chave igual).
- Teste novo: `test/models/glpi_ticket_governed_offline_test.dart` (ou estender
  `test/glpi_ticket_support_test.dart`).

### Mudança especificada

1. Em `GlpiTicket`: adicionar `final int? governedCategoryId;`,
   `final int? governedLocationId;`, `final int? governedEntityId;` e, se houver readback
   contratual a preservar, `final Map<String, dynamic>? governedReadback;`. Tornar todos
   opcionais no construtor (sem quebrar call sites existentes).
2. `toMap()`: emitir as MESMAS chaves que o `glpi_ticket_support` consome
   (`governedCategoryId`, `governedLocationId`, `governedEntityId`), para que o
   `mapData` de sync seja indistinguível do `formData` online.
3. `fromMap()`: parsear as chaves com `_parseOptionalInt` (já existe, linha 134).
4. No ponto de criação offline em `app_state.dart`, preencher os campos a partir do
   mesmo `formData` governado usado no online.

### Gate de aceite (verde)

1. `flutter analyze` → No issues found.
2. `flutter test` → verde, incluindo o teste novo.
3. Teste mínimo:
   - montar `GlpiTicket` com `governedCategoryId/governedLocationId/governedEntityId`;
   - `GlpiTicket.fromMap(ticket.toMap())` preserva os três ids;
   - simular `synchronizeTickets()` (ou montar `mapData = ticket.toMap()`) e provar que
     o payload final usa os ids governados, não o fallback por nome de serviço.

### Critérios de parada

- Se `glpi_ticket_support.dart` já consumir os ids de outra chave que não
  `governedCategoryId/governedLocationId`, parar e alinhar nomes antes de codar.
- Se houver readback contratual obrigatório que não seja round-trip-safe, parar e
  reportar antes de inventar serialização.

---

## DOSSIÊ P2 — Resolver governado fail-closed

### Problema (com evidência)

`lib/catalog/governed_submission_contract.dart:205-221`, `_filterByOption`:

```dart
final withMatchingOption = candidates.where((record) {
  final question = selector(record);
  if (question == null || question.options.isEmpty) return true;
  return question.options.any((option) => option.id == selectedId);
}).toList(growable: false);

return withMatchingOption.isEmpty ? candidates : withMatchingOption; // fail-open
```

Quando `selectedId` é válido (`> 0`, linha 210) mas **nenhum** candidato tem opção
correspondente, o resolver devolve os candidatos ORIGINAIS em vez de bloquear. Isso
pode produzir um contrato governado errado em vez de falhar explicitamente — sensível
para categoria/localização.

Observação: o resolver já bloqueia quando a lista fica vazia por outros motivos
(`:150-154`) e em ambiguidade (`_singleOrBlock`, `:192-203`). O furo é só o fallback
silencioso do `_filterByOption`.

### Arquivos a tocar

- `lib/catalog/governed_submission_contract.dart` — `_filterByOption` e/ou o call site
  (`:139-148`) para distinguir "sem filtro aplicável" de "filtro aplicado e zerou".
- Testes do resolver (criar/estender; ex.: `test/catalog/governed_submission_contract_test.dart`).

### Mudança especificada

Distinguir três casos de forma explícita:

1. `selectedId` nulo/≤0 → não filtra (comportamento atual mantido).
2. Há candidatos com a questão-fonte (categoria/localização) e a opção selecionada
   **não casa em nenhum** → retornar lista vazia (sinal de bloqueio), que o call site
   converte em `GovernedSubmissionResolution.blocked('categoria/localização selecionada
   não corresponde a nenhum contrato governado')`.
3. Questões ausentes/sem options em todos os candidatos → manter passagem (não há base
   para filtrar; não inventar bloqueio onde o catálogo não tem o dado).

Não alterar a semântica de desambiguação (`_singleOrBlock`) nem o bloqueio de
agregado (`:131-136`).

### Gate de aceite (verde)

1. `flutter analyze` limpo; `flutter test` verde.
2. Teste negativo: dois candidatos com `categoryQuestion.options` conhecidas; seleção de
   `selectedCategoryId` inexistente → resolução `blocked`, NUNCA `resolved` com fallback.
3. Teste de não-regressão: seleção válida com match → continua `resolved`; seleção nula
   → continua `resolved`/desambigua como hoje; candidatos sem question/options → passa.

### Critérios de parada

- Se transformar fail-open em fail-closed quebrar testes verdes existentes que dependem
  do fallback, parar e reportar (significa que algum fluxo real depende do
  comportamento atual e precisa de decisão de produto).

---

## DOSSIÊ P3 — Guarda de regressão do `show_rule` de section (1.3 aplicado)

### Estado

1.3 já aplicado em `393ef25`: `SisChecklistSection.showRule`
(`lib/checklists/checklist_catalog.dart:233/241`), `isSectionVisible` usa
`section.showRule` (`lib/checklists/checklist_condition_engine.dart:25`), builder
exporta `show_rule` de sections, testes cobrem `show_rule=1` e `=2`.

### Objetivo

Travar a fonte do dado para que uma futura regeneração do catálogo não volte a perder
`show_rule` de sections silenciosamente.

### Arquivos a tocar

- `test/checklists/checklist_catalog_test.dart` (ou teste de fixture) — assert de contrato.

### Mudança especificada

Teste de contrato sobre `test/fixtures/sis_checklists_catalog.json`:

- toda section parseada tem `showRule` em `{1, 2, 3}`;
- a distribuição bate com a evidência live: `show_rule=1` → 7, `show_rule=2` → 18
  (`VALIDACAO_GLPI_LIVE_2026-06-27.md`);
- nenhuma section com `showRule == 1` carrega condition (invariante live atual);
  se passar a carregar, o teste falha e força revisão consciente.

### Gate de aceite

`flutter test` verde com o novo assert; se a fixture for regenerada e quebrar o invariante,
o teste deve falhar (é o ponto).

### Critério de parada

- Se a fonte (builder `--live`) deixar de trazer `show_rule` de sections, parar: não
  introduzir default que mascare a ausência.

---

## DOSSIÊ P4 — Operadores `show_condition` 7/8 como hardening de engine (opcional)

### Estado / escopo

Hardening defensivo, **não** bug ativo: a validação live confirmou que os checklists
ativos 48-52 usam apenas `show_condition` 1/2; 7/8 existem só no universo GLPI global
(`VALIDACAO_GLPI_LIVE_2026-06-27.md`). Implementar somente se houver decisão explícita
de blindar o engine antes de um novo checklist live com 7/8.

### Arquivos a tocar

- `lib/checklists/checklist_condition_engine.dart` — ramo 7/8 no ponto que hoje chama
  `condition.matches(...)` (ver dossiê 1.2 original, `DOSSIES_CORRECAO_DELEGAVEL.md`).
- NÃO alterar `SisChecklistCondition.matches(value)` (7/8 são visibilidade da
  questão-fonte, não comparação de valor).
- Testes novos de engine + manter o teste de caracterização de `matches()`.

### Mudança especificada

- `show_condition == 7` → dependente visível sse a questão-fonte está visível;
  `== 8` → visível sse a fonte está invisível.
- Proteção anti-ciclo OBRIGATÓRIA: propagar `Set<int> visiting`; ao reentrar num `id`
  já em `visiting`, cortar retornando `true` e logar.
- Fonte ausente: definir conscientemente (upstream tende a manter visível). Documentar
  a escolha SIS no código.
- NÃO implementar 3/4/5/6/9.

### Gate de aceite

- `flutter analyze`/`flutter test` verdes.
- Testes: fonte visível+op7 → visível; fonte visível+op8 → oculto; fonte oculta+op7 →
  oculto; fonte oculta+op8 → visível; ciclo A↔B não trava; `matches()` inalterado p/ 1/2.

### Critério de parada

- Se o objetivo declarado virar "bug ativo", primeiro provar 7/8 no fixture ativo ou no
  runtime afetado. Sem essa prova, manter como hardening explícito.

---

## DOSSIÊ P5 — Contrato `show_tree_depth` produtor/consumidor

### Problema (com evidência)

O Worker normal entrega `options_sample` já podada (ex.: Ar-Condicionado, root 70,
`show_tree_depth=2`, 35 opções — `AUDITORIA_FORMCREATOR_RUNTIME_2026-06-27.md`). O
Flutter consome a lista pronta e descarta metadados (`tree_depth`, `show_tree_depth`,
`options_count`, `category_root`). Não há bug visual provado, mas o contrato é
implícito: se o produtor parar de podar, o consumidor não detecta.

### Arquivos a tocar

- Teste de contrato do catálogo normal (Worker/metadata) — onde os records normais são
  validados; ex.: `tool/external-access/workers-vpc/test/` e/ou teste Flutter de parse.
- Opcional: parser de metadados, só se a decisão for o Flutter passar a preservar
  `tree_depth`.

### Mudança especificada

1. Decidir e documentar o dono da poda (recomendado: produtor Worker poda; consumidor só
   consome lista pronta).
2. Teste de contrato:
   - records normais de localização com `options_count` → `options_count ==
     options_sample.length`;
   - records de localização → `option_source = locations`;
   - travar caso conhecido Ar-Condicionado (root 70 / depth 2 / 35 opções) enquanto for o
     contrato vigente.
3. Para checklists especializados, tratar `show_tree_depth` separadamente
   (`SisChecklistQuestion` preserva `rawValues` mas não aplica isso tipado).

### Gate de aceite

- Testes de contrato verdes; regressão de poda no produtor deve quebrar o teste.

### Critério de parada

- Se o produtor não garantir poda e a decisão for mover a poda para o Flutter, isso vira
  refatoração maior (renderização dinâmica de FormCreator) — fora do escopo deste dossiê.

---

## Comandos de validação (qualquer dossiê de código)

```bash
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
node --test tool/external-access/workers-vpc/test/*.test.mjs   # se tocar Worker/metadata
```

Regras de segurança (todas as execuções): read-only por padrão contra GLPI real;
nenhuma mutação de ticket real fora do fluxo de conta de teste; nenhum método
destrutivo via Worker pass-through.
