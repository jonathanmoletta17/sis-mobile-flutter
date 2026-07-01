# Auditoria FormCreator/SIS — runtime, dossiês e evidências

Data: 2026-06-27
Branch auditada: `fix/onda0-rede-seguranca`
Commit auditado: `1c52d78`
Modo: read-only sobre runtime/código; este arquivo é documentação de auditoria.

> Complemento live: após esta auditoria preparatória, foi executada validação
> direta Web/Admin + API em `docs/audits/VALIDACAO_GLPI_LIVE_2026-06-27.md`.
> Essa validação encontrou divergência real: o GLPI vivo tem 25 sections,
> 1271 questions, 18 targets e 1191 conditions nos checklists 48-52, enquanto
> asset/fixture/Worker locais tinham 24/1252/17/1175. O target vivo `369`
> (`HIDRÁULICO 951`) não existia no catálogo local antes da regeneração.
>
> Complemento de execução: depois disso, o catálogo especializado de checklists
> foi regenerado a partir da API live. `assets/sis_checklists_catalog.json`,
> `test/fixtures/sis_checklists_catalog.json` e
> `tool/external-access/workers-vpc/src/checklist_catalog.js` passaram a carregar
> 25/1271/18/1191 e o target `369`. O `metadata_catalog.js` governado normal
> continua snapshot/draft separado.

## Fronteira de validação desta rodada

Esta auditoria não substitui o gate direto no GLPI SIS.

O que foi validado nesta rodada:

- código local do app Flutter;
- Worker e fixtures locais;
- snapshots e artefatos locais já existentes;
- evidências locais em `docs/discovery/glpi-live/evidence/`;
- fontes primárias upstream do plugin FormCreator;
- relatórios paralelos read-only de subagentes.

O que não foi executado nesta rodada:

- login no GLPI Web;
- navegação no menu Administração do GLPI;
- inspeção visual/manual da configuração FormCreator no painel administrativo;
- chamadas API live com `initSession` contra o GLPI SIS;
- consulta direta ao banco MariaDB/MySQL do GLPI;
- validação mutável contra tickets reais.

Portanto, as conclusões abaixo são fortes para o estado do repo, dos snapshots locais e da semântica upstream, mas não são uma certificação de que o GLPI vivo de hoje está idêntico aos snapshots. Qualquer implementação deve rodar o gate GLPI direto antes de commit.

## Resumo executivo

Os dossiês em `docs/glpi/DOSSIES_CORRECAO_DELEGAVEL.md` capturam problemas reais, mas misturam três camadas que precisam ficar separadas:

1. FormCreator upstream: semântica real de `show_rule`, `show_condition`, seções, perguntas e targets.
2. Catálogo governado normal do Worker: projeção parcial, não um renderizador completo de FormCreator.
3. Catálogo especializado de checklists: fluxo separado, com engine própria em Flutter e fixture embarcada.

Veredito prático da auditoria inicial:

- Não era seguro implementar os dossiês 1.2 e 1.3 "exatamente como estavam"
  antes da validação live e da regeneração do catálogo.
- A auditoria inicial encontrou uma afirmação local falsa no dossiê 1.3:
  naquele momento, `SisChecklistSection` não expunha `showRule`.
- O dossiê 1.2 usa semântica upstream correta para operadores 7/8, mas o impacto descrito não bate com os checklists ativos 48-52: nesses checklists ativos, as condições são apenas operadores 1/2.
- A justificativa anterior para não tratar `show_tree_depth` é incompleta: o Worker já entrega catálogo dinâmico governado com opções podadas; o ponto correto é travar o contrato produtor/consumidor, não aplicar uma correção cega no Flutter.
- Foi encontrado um risco concreto fora dos dossiês: o fluxo offline genérico perde `governedCategoryId` e `governedLocationId`, então a sincronização posterior pode não reproduzir o payload governado online.

Estado após execução Codex 2026-06-27:

- o catálogo especializado de checklists foi regenerado da API live;
- `SisChecklistSection` passou a expor `showRule`;
- `isSectionVisible()` passou a usar `section.showRule`;
- o dossiê 1.3 foi aplicado com testes diretos para sections `show_rule=1`
  e `show_rule=2`;
- o dossiê 1.2 permaneceu não implementado porque a validação live dos forms
  ativos 48-52 não encontrou operadores 7/8 nesse escopo.

## Fontes primárias verificadas

### Upstream FormCreator 2.13.11

- Constantes de condição: `pluginsGLPI/formcreator`, `inc/condition.class.php`, release `2.13.11`, linhas 47-62: <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/condition.class.php#L47-L62>
- Labels de condição: `inc/condition.class.php`, linhas 96-120: <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/condition.class.php#L96-L120>
- Avaliação real de visibilidade: `inc/fields.class.php`, linhas 139-358: <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/fields.class.php#L139-L358>
- Schema de perguntas/condições/seções/targets: `install/mysql/plugin_formcreator_2.13.10_empty.sql`, linhas 126-249: <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/install/mysql/plugin_formcreator_2.13.10_empty.sql#L126-L249>
- `PluginFormcreatorQuestion` usa `PluginFormcreatorConditionnableTrait`: <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/question.class.php#L41-L52>
- `PluginFormcreatorSection` usa `PluginFormcreatorConditionnableTrait`: <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/section.class.php#L40-L50>
- Targets FormCreator têm labels próprios de geração: <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/abstracttarget.class.php#L110-L120>

Semântica upstream confirmada:

| Campo | Valores confirmados |
| --- | --- |
| `show_condition=1` | igual |
| `show_condition=2` | diferente |
| `show_condition=3` | menor que |
| `show_condition=4` | maior que |
| `show_condition=5` | menor ou igual |
| `show_condition=6` | maior ou igual |
| `show_condition=7` | questão-fonte visível |
| `show_condition=8` | questão-fonte invisível |
| `show_condition=9` | regex |
| `show_rule=1` | sempre visível/gerado |
| `show_rule=2` | oculto/desabilitado salvo condição |
| `show_rule=3` | exibido/gerado salvo condição |

Detalhes importantes do upstream:

- O upstream implementa 3/4/5/6/9. Portanto, "não implementar 3/4/5/6/9" só é defensável como recorte SIS local, não como verdade FormCreator.
- Para 7/8, a comparação não é sobre valor de resposta; é sobre visibilidade da pergunta-fonte.
- O upstream tem cache/sentinela para evitar ciclo e lança exceção em loop infinito.
- Se a condição aponta para uma pergunta ausente, o upstream tende a desistir da avaliação e manter visível, não tratar automaticamente como "invisível".
- Sem condições:
  - `show_rule=2` resulta oculto/desabilitado.
  - `show_rule=3` resulta visível/gerado.

### Fontes locais auditadas

- Dossiês atuais: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/glpi/DOSSIES_CORRECAO_DELEGAVEL.md`
- Documento de conhecimento de checklists: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/CHECKLISTS_SIS_CONHECIMENTO.md`
- Engine de checklists: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/checklists/checklist_condition_engine.dart`
- Modelo do catálogo de checklists: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/checklists/checklist_catalog.dart`
- Builder do catálogo de checklists: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/tool/checklists/build_sis_checklists_catalog.mjs`
- Fixture de checklists: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/test/fixtures/sis_checklists_catalog.json`
- Worker metadata normal: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/tool/external-access/workers-vpc/src/metadata_catalog.js`
- Worker checklist metadata: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/tool/external-access/workers-vpc/src/checklist_catalog.js`
- Resolver governado: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/catalog/governed_submission_contract.dart`
- Projeção de catálogo para UI: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/catalog/service_catalog_repository.dart`
- Payload GLPI: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/services/glpi_ticket_support.dart`
- Modelo offline de ticket: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/models/glpi_ticket.dart`
- Sincronização offline: `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/state/app_state.dart`

## Mapa das três camadas

### 1. FormCreator upstream

FormCreator é o sistema de referência para:

- `show_rule` em perguntas, seções e targets.
- `show_condition` 1-9.
- Interpretação de 7/8 como visibilidade de outra pergunta.
- Inversão de lógica por `show_rule=3`.
- Tratamento de ciclos e dependências entre campos.

Mas o app SIS Mobile não executa hoje o motor completo do FormCreator para todos os formulários.

### 2. Catálogo governado normal do Worker

O Worker publica `/metadata/mobile/sis/catalog` a partir de `metadata_catalog.js`.

Dados auditados:

| Métrica | Valor |
| --- | ---: |
| `schema_version` | `2.0-readonly-draft` |
| `generated_at` | `2026-06-12T11:25:56.689073+00:00` |
| forms de origem | 41 |
| questions de origem | 6992 |
| targettickets de origem | 241 |
| records publicados | 133 |
| records normais | 116 |
| records especializados/checklists | 17 |
| warnings totais | 49 |
| warnings em records normais | 15 |

Esse catálogo não é renderização total de FormCreator. Ele projeta contratos como:

- categoria governada;
- localização governada;
- entidade de destino;
- atores;
- anexos;
- perfil/serviço;
- readback e metadados de validação.

Evidência crítica: `source_counts.formcreator_conditions` no Worker aparece como `0`, enquanto os snapshots locais têm milhares de condições FormCreator. Portanto, a camada normal não deve ser tratada como engine completa de `show_condition`.

### 3. Catálogo especializado de checklists

O fluxo de checklists é separado.

Dados auditados no fixture ativo:

| Métrica | Valor |
| --- | ---: |
| forms ativos | 5 |
| form ids ativos | 48, 49, 50, 51, 52 |
| sections | 24 |
| questions | 1252 |
| conditions | 1175 |
| targets | 17 |
| categories | 6 |

Distribuição no fixture ativo:

| Item | `show_rule=1` | `show_rule=2` | Ausente |
| --- | ---: | ---: | ---: |
| sections | 0 | 0 | 24 |
| questions | 240 | 1012 | 0 |
| targets | 2 | 15 | 0 |

Distribuição de `show_condition` no fixture ativo:

| Item | `show_condition=1` | `show_condition=2` | Outros |
| --- | ---: | ---: | ---: |
| sections | 24 | 0 | 0 |
| questions | 724 | 405 | 0 |
| targets | 22 | 0 | 0 |
| total | 770 | 405 | 0 |

Conclusão: para os checklists ativos 48-52, operadores 7/8 não aparecem no fixture ativo. A existência de 7/8 no universo FormCreator real não prova, sozinha, bug atual nesses checklists ativos.

## Análise dos dossiês atuais

### Dossiê 1.2 — operadores `show_condition` 7/8

Partes corretas:

- A semântica upstream dos operadores 7/8 está correta: eles avaliam visibilidade da pergunta-fonte, não valor.
- A correção, se feita no fluxo de checklists, pertence ao engine e não ao método `SisChecklistCondition.matches(value)`.
- A proteção anti-ciclo é necessária se houver avaliação recursiva de visibilidade.

Problemas encontrados:

| Afirmação do dossiê | Veredito | Evidência |
| --- | --- | --- |
| "148 condições reais nunca casam nesses formulários" | Incompleto/enganoso para os checklists ativos | No fixture ativo 48-52, operadores são apenas 1/2. Os 7/8 aparecem em `conditions_full.json`, sobretudo em outros forms/targets. |
| `source == null => op8 true` | Não fiel ao upstream | FormCreator tende a dar `true`/manter visível quando não consegue avaliar a fonte. |
| "Não implementar 3,4,5,6,9" | Só vale como recorte SIS local | Upstream implementa 3/4/5/6/9. A decisão local precisa ser justificada por contagem do escopo ativo. |
| Impacto direto em target visibility | Não demonstrado no runtime atual | `isTargetVisible()` existe no engine, mas a tela de catálogo lista `targetsForForm` diretamente e o formulário usa target conditions apenas para prefill de categoria/localização com `showCondition == 1`. |

Estado local:

- `SisChecklistCondition.matches()` trata apenas 1/2.
- `SisChecklistConditionEngine` chama `condition.matches(...)`.
- Há função `isTargetVisible()`, mas ela não foi comprovada como decisiva no fluxo de submissão atual.

Recomendação corrigida:

1. Não implementar 1.2 como correção de bug ativo dos checklists 48-52 sem nova evidência.
2. Se virar hardening defensivo, o dossiê deve ser reescrito declarando escopo:
   - engine de checklists especializado;
   - operadores 7/8 por visibilidade;
   - sem alterar `matches(value)`;
   - proteção anti-ciclo;
   - comportamento para fonte ausente definido conscientemente, com justificativa se divergir do upstream.
3. Antes de implementar, decidir se target visibility deve realmente entrar no fluxo. Hoje isso não está provado.

### Dossiê 1.3 — seção respeita `show_rule`

Partes corretas na auditoria inicial:

- Upstream FormCreator tem `show_rule` em seções.
- O engine local de checklists hardcodava `showRule: 2` em `isSectionVisible`.
- A ideia conceitual de usar `section.showRule` é correta para aproximar do FormCreator.

Problemas encontrados:

| Afirmação do dossiê | Veredito | Evidência |
| --- | --- | --- |
| "`SisChecklistSection` já expõe `showRule`" | Era falsa no código auditado; corrigida depois | O modelo local não tinha campo `showRule` antes da execução Codex. |
| "Correção trivial: trocar hardcode por `section.showRule`" | Era falsa como one-line fix | A correção exigiu alterar builder, modelo, parser, fixture/testes e fonte do dado. |
| Seções reais têm `show_rule` no snapshot principal | Incompleto | O snapshot principal de 2026-06-10 não traz `show_rule` em sections; o discovery posterior `sections_all_forms.json` traz. |

Estado local auditado antes da execução:

- `SisChecklistSection` possuía `id`, `formId`, `name`, `rank`, `uuid`, `conditions`.
- `tool/checklists/build_sis_checklists_catalog.mjs` não exportava `show_rule` para sections.
- `isSectionVisible()` passava `showRule: 2` hardcoded.

Estado local após execução Codex 2026-06-27:

- `SisChecklistSection` possui `showRule`;
- `tool/checklists/build_sis_checklists_catalog.mjs` exporta `show_rule`
  para sections;
- `isSectionVisible()` usa `section.showRule`;
- `test/checklists/checklist_condition_engine_test.dart` cobre section
  `show_rule=1` com condição falsa, section `show_rule=2` com condição falsa/
  verdadeira e section `show_rule=1` sem condição.

Evidência complementar do discovery local antigo:

- Em `/home/jonathan/.brain/glpi-governance/discovery-2026-06-22/sections_all_forms.json`, as 24 sections ativas têm `show_rule`:
  - `show_rule=1`: 7
  - `show_rule=2`: 17
- Todas as 17 sections condicionadas no fixture ativo correspondem a `show_rule=2`.
- Não foi encontrado caso ativo de section `show_rule=1` com condição quebrando hoje.

Evidência live de 2026-06-27:

- forms ativos 48-52 têm 25 sections;
- distribuição de sections por `show_rule`: `1=7`, `2=18`;
- todas as conditions de section continuam em sections `show_rule=2`;
- nenhuma section ativa `show_rule=1` tem condition.

Recomendação corrigida, executada para 1.3:

1. Não implementar 1.3 como "one-line fix".
2. Tratar como dossiê de harmonização de modelo:
   - fonte do dado: discovery/API que contenha `show_rule` de sections;
   - builder exporta `show_rule`;
   - `SisChecklistSection` parseia `showRule` com default seguro;
   - engine usa `section.showRule`;
   - testes cobrem `show_rule=1`, `show_rule=2` e ausência de condições.
3. Declarar impacto atual como baixo/defensivo, não bug comprovado nos checklists ativos.

### 1.1 — `show_tree_depth`

A justificativa anterior dizia, em essência, que não havia ponto de aplicação porque os formulários normais eram "estáticos". Essa explicação está incompleta.

Estado real encontrado:

- O catálogo governado normal do Worker já entrega `options_sample` para categoria/localização.
- Para casos como Ar-Condicionado, o Worker já aplica a restrição de localização:
  - root 70;
  - `show_tree_depth=2`;
  - 35 opções;
  - sem divergência entre form 1 e form 21 para o contrato de localização.
- O Flutter consome a lista pronta; ele não aplica `show_tree_depth` localmente.
- Portanto, se o produtor continuar entregando opções já podadas, não há bug visual atual provado.
- Mas o Flutter descarta metadados como `tree_depth`, `show_tree_depth`, `options_count`, `category_root` e parte de `raw_values`, então o contrato não está bem protegido contra regressão no produtor.

Risco real:

- O acoplamento está implícito: o produtor deve podar; o consumidor só consome.
- Se o Worker parar de podar ou trocar o significado de `options_sample`, o Flutter não detecta.

Recomendação corrigida:

1. Não implementar poda cega no Flutter sem decidir o dono do contrato.
2. Escrever teste de contrato do catálogo normal:
   - para perguntas de localização com `options_count`, exigir `options_count == options_sample.length`;
   - para records normais de localização, exigir `option_source=locations`;
   - travar casos conhecidos como Ar-Condicionado root 70/depth 2/35 opções.
3. Preservar metadados críticos no parse, ou documentar explicitamente que o Flutter não é dono da poda.
4. Para checklists especializados, tratar `show_tree_depth` separadamente, porque `SisChecklistQuestion` preserva `rawValues`, mas não parseia/aplica isso de forma tipada.

## Achados fora dos dossiês

### A. Offline governado perde ids de categoria/localização

Confiança: alta.
Impacto: alto.

Fluxo online:

- `FormTemplate` monta `formData` com dados governados.
- `GlpiTicketSupport` usa `governedCategoryId`, `governedLocationId`, `governedEntityId` para montar payload.

Fluxo offline:

- `GlpiTicket` não tem campos próprios para `governedCategoryId`, `governedLocationId`, readback ou contrato governado.
- `GlpiTicket.toMap()` não serializa esses ids.
- `GlpiTicket.fromMap()` não recupera esses ids.
- `AppState.synchronizeTickets()` envia `ticket.toMap()` para `createTicket(...)`.

Consequência provável:

- Um ticket criado offline a partir de fluxo governado pode sincronizar depois sem os mesmos ids usados no fluxo online.
- Categoria pode cair em fallback estático por nome de serviço.
- Localização pode virar string ou ser perdida.

Este é o candidato mais forte a novo dossiê corretivo antes de mexer em operadores 7/8.

### B. `_filterByOption` é fail-open

Confiança: alta.
Impacto: médio/alto.

O resolver governado filtra candidatos por opção escolhida. Se nenhum candidato casa com o `selectedId`, ele devolve os candidatos originais em vez de bloquear.

Risco:

- Catálogo incompleto/anômalo pode produzir contrato errado em vez de falhar com mensagem explícita.
- Isso é especialmente sensível para categoria/localização governadas.

Recomendação:

- Criar teste negativo: seleção sem match deve bloquear ou retornar estado de erro explícito.
- Só depois escolher a correção mínima.

### C. Records normais com warning não bloqueiam UI

Confiança: alta.
Impacto: médio.

Foram encontrados 15 warnings em records normais no Worker, mas o Flutter não usa esses warnings para decidir renderização/submissão.

Risco:

- O app pode publicar serviços normais cujo contrato está incompleto ou atípico.

Recomendação:

- Listar os 15 warnings normais.
- Classificar cada um: aceitável, corrigir produtor, marcar `requires_specialized_flow`, ou bloquear no client.

### D. Elevadores com `location_question` anômala

Confiança: alta.
Impacto: alto para esse serviço.

Records normais de Elevadores apontam `location_rule=2` para uma questão que não é dropdown de localização, mas telefone/integer.

Risco:

- A UI pode exigir localização com lista vazia ou contrato incoerente.

Recomendação:

- Teste em `ServiceCatalogRepository`: `locationQuestion.fieldtype=integer` não deve habilitar campo de localização como se fosse localização governada.
- Conferir no produtor se a regra deveria apontar para outra pergunta.

### E. Checklist Worker/client não está ligado como runtime principal

Confiança: alta.

Existe `SIS_CHECKLISTS_METADATA_URL` em `.env.example` e endpoint Worker `/metadata/mobile/sis/checklists`, mas o `AppState` atual carrega o asset embarcado `assets/sis_checklists_catalog.json`.

Recomendação:

- Decidir explicitamente: asset embarcado é fonte canônica da versão atual, ou Worker será runtime.
- Remover/adiar flag morta ou ligar com gate claro.

## Plano recomendado

### P0 — Reconciliar documentação

Objetivo: impedir nova implementação baseada em dossiê errado.

- Marcar `DOSSIES_CORRECAO_DELEGAVEL.md` como "não executar sem revisão" ou reescrever 1.2/1.3.
- Manter `docs/CHECKLISTS_SIS_CONHECIMENTO.md` como fonte mais confiável para mapa de checklists, mas separar evidência de implementação.

### P1 — Novo dossiê: preservação offline governada

Objetivo: corrigir risco de payload divergente entre online e offline.

Critério mínimo:

- Teste prova que `governedCategoryId`, `governedLocationId`, `governedEntityId` e readback sobrevivem `toMap/fromMap`.
- Teste prova que sincronização usa os mesmos ids do online.
- Não tocar em FormCreator engine.

### P2 — Novo dossiê: resolver governado fail-closed

Objetivo: impedir contrato errado quando uma opção selecionada não casa com nenhum candidato.

Critério mínimo:

- Teste negativo para categoria/localização sem match.
- Mensagem de erro clara em vez de fallback silencioso.

### P3 — Dossiê 1.3 reescrito e aplicado

Objetivo: harmonizar `show_rule` de sections no fluxo de checklist.

Critério mínimo atendido na execução Codex:

- Fonte com `show_rule` de sections validada.
- Builder exporta campo.
- Modelo parseia campo.
- Engine usa campo.
- Testes cobrem `show_rule=1`, `show_rule=2` e ausência de condições em sections.

### P4 — Dossiê 1.2 reescrito como hardening

Objetivo: suportar 7/8 no engine de checklist, se e somente se o escopo for explicitamente defensivo ou houver novo checklist ativo com 7/8.

Critério mínimo:

- Contagem atualizada do fixture ativo prova onde 7/8 aparecem.
- Sem alterar semântica de 1/2.
- Sem implementar 3/4/5/6/9 sem novo escopo.
- Proteção anti-ciclo.
- Comportamento de fonte ausente definido e testado.

### P5 — `show_tree_depth` como contrato produtor/consumidor

Objetivo: evitar regressão de localização sem inventar renderizador FormCreator completo.

Critério mínimo:

- Teste de contrato do Worker normal.
- Casos conhecidos travados.
- Decisão documentada: poda no produtor ou consumidor.

## Critérios de parada para qualquer agente

Parar e reportar, sem improvisar, se ocorrer qualquer um destes casos:

- Contagens de fixture/snapshot divergirem das registradas aqui.
- `SisChecklistSection` já tiver `showRule` em novo código, invalidando esta auditoria.
- Worker passar a publicar `formcreator_conditions` reais para o fluxo normal.
- `AppState` deixar de carregar asset e passar a consumir checklist Worker em runtime.
- `GlpiTicket` já tiver campos governados persistidos.
- Validação exigir GLPI real/VPN ou mutação de ticket real.

## Comandos read-only usados na auditoria

Exemplos representativos:

```bash
git status --short --branch
git rev-parse --short HEAD
git log --oneline -5
nl -ba docs/glpi/DOSSIES_CORRECAO_DELEGAVEL.md | sed -n '1,260p'
rg -n "showRule|show_rule|showCondition|show_condition|isSectionVisible|isTargetVisible" lib tool test docs
python3 - <<'PY'
# scripts read-only para contar fixture/snapshots e validar distribuição de operadores
PY
node - <<'NODE'
// scripts read-only para inspecionar metadata_catalog.js e checklist_catalog.js
NODE
```

Validações mutáveis contra GLPI real não foram executadas.

## Gate direto ainda pendente

Antes de declarar certeza operacional completa, executar pelo menos:

1. GLPI Web/Admin: conferir no menu Administração/Plugins/FormCreator os forms 48-52, suas sections, questions, targets, `show_rule`, `show_condition`, regras de localização e target tickets.
2. API live read-only: repetir discovery de `PluginFormcreatorForm`, `PluginFormcreatorSection`, `PluginFormcreatorQuestion`, `PluginFormcreatorCondition`, `PluginFormcreatorTargetTicket`, `ITILCategory`, `Location`, `RuleCriteria`, `RuleAction`, `Profile`, `ProfileRight`.
3. BD live read-only: consultar tabelas FormCreator e tabelas GLPI relacionadas para confirmar contagens e campos que a API pode omitir.
4. Reconciliar Web/API/BD contra:
   - fixture ativo;
   - `metadata_catalog.js`;
   - `checklist_catalog.js`;
   - snapshots em `/home/jonathan/.brain/glpi-governance/`;
   - este relatório.

Se qualquer número divergir, a documentação deve ser atualizada antes de qualquer implementação.
