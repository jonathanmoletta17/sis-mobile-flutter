# Handoff para Claude Code — auditoria FormCreator/SIS

Data: 2026-06-27
Branch alvo: `fix/onda0-rede-seguranca`
Regra de segurança: não implementar antes de confirmar as evidências abaixo.
Estado após execução Codex 2026-06-27: o catálogo especializado foi
regenerado da API live e o dossiê 1.3 foi aplicado. Este handoff preserva a
auditoria preparatória, mas os trechos abaixo já refletem o estado pós-execução
quando citam `showRule`/`show_rule`.

> Complemento live: ler também
> `docs/audits/VALIDACAO_GLPI_LIVE_2026-06-27.md`. A validação Web/Admin + API
> encontrou o catálogo especializado local stale: target vivo `369`
> (`HIDRÁULICO 951`) e contagens live 25/1271/18/1191 para
> sections/questions/targets/conditions. O catálogo especializado foi
> regenerado depois dessa validação; antes de implementar dossiês, confirme
> que esses números continuam presentes.

## Limitação explícita da auditoria Codex

A auditoria Codex anterior não fez login no GLPI Web, não navegou no menu Administração, não executou discovery API live com `initSession` e não consultou diretamente o banco GLPI. Ela consolidou código local, fixtures, snapshots locais, evidências locais já exportadas e fontes primárias upstream.

Claude Code deve tratar isso como análise preparatória forte, não como validação viva final.

## Prompt recomendado

```text
Repo: /home/jonathan/projects/work/mobile/sis-mobile-flutter
Branch: fix/onda0-rede-seguranca

Leia, nesta ordem:
1. AGENTS.md
2. docs/audits/AUDITORIA_FORMCREATOR_RUNTIME_2026-06-27.md
3. docs/glpi/DOSSIES_CORRECAO_DELEGAVEL.md
4. docs/CHECKLISTS_SIS_CONHECIMENTO.md

Tarefa inicial: NÃO implemente nada ainda.

Confirme ou refute, com comandos e evidências locais, estes pontos:

1. O dossiê 1.3 não era implementável como one-line fix no estado auditado; após a execução Codex, `SisChecklistSection` possui `showRule`, o builder exporta `show_rule` de sections e o engine usa `section.showRule`.
2. O dossiê 1.2 usa semântica correta para operadores 7/8, mas o impacto declarado não bate com os checklists ativos 48-52, cujo fixture ativo usa apenas operadores 1/2.
3. O show_tree_depth do catálogo governado normal já parece ser aplicado pelo produtor Worker via options_sample; o risco atual é falta de contrato/teste, não necessariamente bug visual no Flutter.
4. O fluxo offline governado perde governedCategoryId/governedLocationId/readback ao passar por GlpiTicket.toMap/fromMap.
5. O resolver governado tem comportamento fail-open quando a opção selecionada não casa com nenhum candidato.

Se qualquer evidência divergir, PARE e reporte.
Se tudo confirmar, proponha novos dossiês corrigidos, nesta ordem:
A. Preservação offline governada.
B. Fail-closed no resolver governado.
C. Validar que o dossiê 1.3 já aplicado não regrediu: builder/model/parser/engine/testes preservam `show_rule` de sections.
D. Dossiê 1.2 reescrito como hardening de operadores 7/8, sem afirmar impacto ativo não comprovado.
E. Contrato show_tree_depth produtor/consumidor.

Não implemente operadores 3/4/5/6/9 sem novo escopo explícito.
Não execute mutação contra GLPI real.
Não use Worker pass-through para métodos destrutivos.

Antes de implementar, se houver VPN/credenciais autorizadas disponíveis, rode validação direta read-only em três frentes:
1. GLPI Web/Admin: conferir manualmente forms, sections, questions, targets, show_rule, show_condition e regras de localização.
2. API live: repetir discovery read-only das entidades FormCreator/GLPI relevantes.
3. BD live: consultar tabelas FormCreator/GLPI relevantes em modo somente leitura.

Se Web/API/BD divergirem dos snapshots locais, PARE e reporte.
```

## Sequência de verificação local

### 1. Estado do repo

```bash
git status --short --branch
git rev-parse --short HEAD
git log --oneline -5
```

Esperado nesta auditoria:

- branch `fix/onda0-rede-seguranca`;
- commit base observado `1c52d78`;
- possíveis diretórios não rastreados prévios: `docs/contracts/`, `docs/discovery/`, `docs/testing/`.

Se houver mudanças de código não esperadas, parar e reportar antes de alterar.

### 2. Confirmar afirmações problemáticas do dossiê 1.3

Verificar o dossiê:

```bash
nl -ba docs/glpi/DOSSIES_CORRECAO_DELEGAVEL.md | sed -n '86,118p'
```

Verificar o modelo local:

```bash
rg -n "class SisChecklistSection|final int showRule|show_rule" lib/checklists tool/checklists test/fixtures/sis_checklists_catalog.json
```

Evidência esperada no estado pós-execução Codex:

- `SisChecklistSection` possui `showRule`.
- O builder exporta `show_rule` para sections quando a fonte live/snapshot contém o campo.
- `isSectionVisible` usa `section.showRule`.
- Há teste de regressão para section `show_rule=1` com condição falsa continuar visível.

Conclusão esperada:

- 1.3 foi corrigido como harmonização de modelo, não como one-line fix.
- Se qualquer uma dessas evidências desaparecer, parar e reabrir o dossiê.

### 3. Confirmar operadores dos checklists ativos

Executar script read-only equivalente:

```bash
python3 - <<'PY'
import json
from collections import Counter

path = 'test/fixtures/sis_checklists_catalog.json'
data = json.load(open(path))
print('forms', len(data.get('forms', [])))
print('sections', len(data.get('sections', [])))
print('questions', len(data.get('questions', [])))
print('conditions', len(data.get('conditions', [])))
print('targets', len(data.get('targets', [])))
print('active_form_ids', [f['id'] for f in data.get('forms', [])])

by_item = {}
for c in data.get('conditions', []):
    by_item.setdefault(c.get('itemtype'), Counter())[c.get('show_condition')] += 1
print(by_item)
PY
```

Evidência esperada:

- forms ativos: 48, 49, 50, 51, 52;
- conditions: 1175;
- operadores no fixture ativo: apenas 1 e 2;
- nenhum operador 7/8 nos checklists ativos.

Conclusão esperada:

- O dossiê 1.2 não pode afirmar que 7/8 quebram os checklists ativos 48-52.
- 7/8 podem existir no universo FormCreator mais amplo, mas isso é outro escopo.

### 4. Confirmar semântica upstream

Usar fontes primárias:

- <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/condition.class.php#L47-L62>
- <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/inc/fields.class.php#L139-L358>
- <https://github.com/pluginsGLPI/formcreator/blob/release/2.13.11/install/mysql/plugin_formcreator_2.13.10_empty.sql#L126-L249>

Evidência esperada:

- 7/8 são visibilidade/invisibilidade de pergunta-fonte.
- 3/4/5/6/9 existem upstream.
- sections/questions/targettickets têm `show_rule` no schema upstream.
- fonte ausente/ciclo não devem ser tratados de forma ingênua.

Conclusão esperada:

- O engine SIS pode escolher recorte local, mas deve dizer que é recorte, não semântica FormCreator completa.

### 5. Confirmar Worker normal versus renderizador FormCreator

Inspecionar:

```bash
node - <<'NODE'
const fs = require('fs');
const vm = require('vm');
const code = fs.readFileSync('tool/external-access/workers-vpc/src/metadata_catalog.js', 'utf8');
const sandbox = {};
vm.runInNewContext(code + '\nthis.MOBILE_METADATA_CATALOG = MOBILE_METADATA_CATALOG;', sandbox);
const catalog = sandbox.MOBILE_METADATA_CATALOG;
console.log(catalog.schema_version);
console.log(catalog.generated_at);
console.log(catalog.source_counts);
console.log('records', catalog.records.length);
console.log('specialized', catalog.records.filter(r => r.requires_specialized_flow).length);
NODE
```

Evidência esperada:

- `schema_version=2.0-readonly-draft`;
- `source_counts.formcreator_conditions=0`;
- 133 records, 17 especializados;
- fluxo normal é projeção governada, não engine completa de FormCreator.

Conclusão esperada:

- Não usar condições FormCreator globais para justificar mudança automática no fluxo normal.

### 6. Confirmar `show_tree_depth`

Verificar records de Ar-Condicionado e localização:

```bash
rg -n "show_tree_depth|options_count|selectable_tree_root|Ar-Condicionado|Manutenção e Conservação" tool/external-access/workers-vpc/src/metadata_catalog.js
```

Evidência esperada:

- casos normais com `show_tree_depth=2`, root 70 e 35 opções;
- Flutter consome opções prontas;
- Flutter não preserva/aplica `show_tree_depth` localmente.

Conclusão esperada:

- O próximo passo correto é contrato/teste produtor-consumidor.
- Não declarar bug visual sem caso reproduzido.

### 7. Confirmar offline governado

Inspecionar:

```bash
rg -n "governedCategoryId|governedLocationId|readback|toMap|fromMap|synchronizeTickets" lib test
```

Evidência esperada:

- `GlpiTicketSupport` usa ids governados no envio online.
- `GlpiTicket` não persiste esses ids.
- `AppState.synchronizeTickets()` usa `ticket.toMap()` para enviar pendências.

Conclusão esperada:

- Novo dossiê prioritário: preservar contrato governado no offline.

### 8. Confirmar fail-open do resolver

Inspecionar:

```bash
nl -ba lib/catalog/governed_submission_contract.dart | sed -n '190,230p'
rg -n "selectedId|filterByOption|sem match|no match|governed" test lib/catalog
```

Evidência esperada:

- se nenhum candidato casa com a opção selecionada, o resolver devolve candidatos originais;
- não há teste negativo suficiente cobrindo esse caso.

Conclusão esperada:

- Novo dossiê deve decidir se isso vira erro bloqueante.

## Gate GLPI direto

Esta seção é obrigatória antes de implementação se a máquina tiver VPN/credenciais autorizadas.

### GLPI Web/Admin

Conferir manualmente:

- forms 48-52;
- sections e seus `show_rule`;
- questions e seus `show_rule`;
- conditions e seus `show_condition`;
- targets e seus `show_rule`;
- regras de categoria/localização dos targets;
- casos com `show_tree_depth`, `show_tree_root` e `selectable_tree_root`.

Não salvar alterações no painel.

### API live read-only

Repetir discovery de:

- `PluginFormcreatorForm`;
- `PluginFormcreatorSection`;
- `PluginFormcreatorQuestion`;
- `PluginFormcreatorCondition`;
- `PluginFormcreatorTargetTicket`;
- `ITILCategory`;
- `Location`;
- `RuleCriteria`;
- `RuleAction`;
- `Profile`;
- `ProfileRight`.

Não criar, alterar, fechar, anexar ou limpar tickets.

### BD live read-only

Consultar, em transação/read-only ou usuário somente leitura:

- `glpi_plugin_formcreator_forms`;
- `glpi_plugin_formcreator_sections`;
- `glpi_plugin_formcreator_questions`;
- `glpi_plugin_formcreator_conditions`;
- `glpi_plugin_formcreator_targettickets`;
- tabelas de categoria/localização/perfil/rights relevantes.

Comparar Web/API/BD. Se qualquer fonte discordar, tratar divergência como bloqueio de implementação.

## Ordem de trabalho recomendada

### Primeiro: documentação e dossiês corrigidos

Não começar por implementação. A documentação atual mistura escopos. O primeiro entregável deve ser uma versão corrigida dos dossiês, com:

- escopo;
- evidência;
- arquivos a tocar;
- testes;
- critérios de stop.

### Segundo: corrigir risco online/offline

Prioridade técnica:

1. offline governado;
2. resolver fail-closed;
3. warnings normais do Worker;
4. `show_tree_depth` como contrato;
5. `show_rule` de sections;
6. operadores 7/8 como hardening.

Motivo:

- offline/fail-open afetam submissão governada real;
- 1.2 continua defensivo nos checklists ativos atuais; 1.3 já foi aplicado para
  remover divergência estrutural entre catálogo e engine.

## Dossiês corrigidos sugeridos

### Novo dossiê A — offline governado preserva contrato

Arquivos prováveis:

- `lib/models/glpi_ticket.dart`
- `lib/state/app_state.dart`
- `lib/services/glpi_ticket_support.dart`, se necessário
- testes em `test/glpi_ticket_support_test.dart` ou teste novo de offline

Teste mínimo:

- montar ticket offline com `governedCategoryId`, `governedLocationId`, `governedEntityId`, readback;
- passar por `GlpiTicket.fromMap().toMap()`;
- garantir ids preservados;
- simular sync e garantir que payload final usa os ids governados.

### Novo dossiê B — resolver governado fail-closed

Arquivos prováveis:

- `lib/catalog/governed_submission_contract.dart`
- testes do resolver governado

Teste mínimo:

- dois candidatos;
- seleção de categoria/localização inexistente;
- resultado deve ser erro explícito ou lista vazia bloqueante, nunca fallback silencioso para candidatos originais.

### Dossiê 1.3 aplicado — sections com `show_rule`

Arquivos tocados na execução Codex:

- `tool/checklists/build_sis_checklists_catalog.mjs`
- `lib/checklists/checklist_catalog.dart`
- `lib/checklists/checklist_condition_engine.dart`
- fixture/testes de checklist

Testes cobertos:

- section `show_rule=1` com condição falsa continua visível;
- section `show_rule=2` com condição falsa oculta;
- section `show_rule=2` com condição verdadeira visível;
- section `show_rule=1` sem condição continua visível.

Critério de stop:

- se a fonte usada pelo builder não tiver `show_rule` de sections, parar; não inventar default que mascare o problema.

### Dossiê 1.2 reescrito — 7/8 no engine de checklist

Arquivos prováveis:

- `lib/checklists/checklist_condition_engine.dart`
- testes novos de engine
- teste de caracterização de `SisChecklistCondition.matches`

Teste mínimo:

- fonte visível + op 7 => dependente visível;
- fonte visível + op 8 => dependente oculta;
- fonte oculta + op 7 => dependente oculta;
- fonte oculta + op 8 => dependente visível;
- ciclo A/B não trava;
- `matches(value)` continua sem assumir 7/8 como comparação de valor.

Critério de stop:

- se o objetivo for bug ativo, primeiro provar 7/8 no fixture ativo ou no runtime que será afetado.
- se for hardening, declarar isso explicitamente.

### Dossiê show_tree_depth — contrato produtor/consumidor

Arquivos prováveis:

- testes do catálogo governado/Worker;
- talvez parser de metadados, se for decidido preservar `tree_depth`.

Teste mínimo:

- records normais de localização com `options_count` devem ter `options_count == options_sample.length`;
- records com `option_source=locations` devem preservar root/depth suficientes para debug;
- Ar-Condicionado deve manter root 70/depth 2/35 opções enquanto esse for o contrato conhecido.

Critério de stop:

- se o produtor não garante poda, decidir explicitamente se a poda passa para Flutter; não duplicar regra sem dono.

## Comandos de validação após implementação futura

Para qualquer dossiê que altere código:

```bash
/opt/flutter/bin/flutter analyze
/opt/flutter/bin/flutter test
```

Para alterações em Worker/metadata:

```bash
rg -n "validation_ok|warnings|source_counts|options_count|show_tree_depth" tool/external-access/workers-vpc/src
```

Para alterações envolvendo GLPI real:

- usar fluxo read-only por padrão;
- não mutar tickets reais;
- não usar pass-through destrutivo;
- validar com VPN/local apenas quando o usuário autorizar.
