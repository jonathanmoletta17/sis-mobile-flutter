# SIS Checklists End-to-End Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the SIS checklist flow end to end without exposing mutating GLPI behavior before profile, Worker and sandbox gates are explicit.

**Architecture:** Treat SIS checklists as a specialized FormCreator flow, not as a normal `POST /Ticket` form. The app receives a read-only checklist catalog from the SIS Worker, renders/validates checklist answers locally, and only submits through `PluginFormcreatorFormAnswer` behind app and Worker flags after sandbox approval.

**Tech Stack:** Flutter/Dart, Provider/AppState, existing SIS Worker on Cloudflare Workers VPC, GLPI FormCreator REST resources, existing Widgetbook/Flutter tests, Node tests for Worker allowlist.

---

## Source Evidence

Use these files as the current authority before implementation:

- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/CHECKLISTS_SIS_CONHECIMENTO.md`
- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/quality/DOR.md`
- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/quality/DOD.md`
- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/docs/domain/ticket/SOURCES_OF_TRUTH.md`
- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/dtic/models/dtic_formcreator_models.dart`
- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/lib/dtic/screens/dtic_dynamic_form_screen.dart`
- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/tool/external-access/workers-vpc/src/index.js`
- `/home/jonathan/projects/work/mobile/sis-mobile-flutter/tool/external-access/workers-vpc-dtic/src/index.js`
- `/home/jonathan/.brain/glpi-governance/2026-06-10-api/sis-snapshot-api-2026-06-10.json`
- `/home/jonathan/.brain/glpi-governance/2026-06-10-api/questions_full.json`
- `/home/jonathan/.brain/glpi-governance/2026-06-10-api/conditions_full.json`
- `/home/jonathan/.brain/glpi-governance/2026-06-10-api/target_actors.json`

## Hard Boundaries

- Do not use Windows or `/mnt/c` as source root.
- Do not mutate real user tickets.
- Do not enable Worker FormCreator submission by default.
- Do not let checklist flow use generic `POST /Ticket` as a replacement for FormCreator.
- Do not show checklist cards to `Solicitante` by default.
- Do not treat `Super-Admin` as the final product profile. It is current evidence only.
- Do not add UI directly to `lib/` without test and Widgetbook planning if it changes visible surfaces.
- Do not add GLPI app-token secrets to Flutter config. The SIS Worker owns `GLPI_APP_TOKEN`; Flutter only forwards the user session.

## Current State Summary

- 67 raw target tickets exist for checklist-related forms 41-52.
- 17 are locally classified as active/runtime-relevant:
  - form 48: targets 316, 325, 326
  - form 49: target 337
  - form 50: targets 341, 342, 343, 344, 350
  - form 51: target 359
  - form 52: targets 362, 363, 364, 365, 366, 367, 368
- The other 50 are legacy/test/inactive by local evidence.
- Runtime catalog currently publishes 17 `requires_specialized_flow=true` records and the app hides them.
- Current app behavior is intentionally safe: `GovernedSubmissionResolver` blocks checklist submission.

## File Structure

### New Files

- `tool/checklists/build_sis_checklists_catalog.mjs`
  - Reads the local GLPI governance snapshot.
  - Selects only forms 48-52 and targets 316/325/326/337/341/342/343/344/350/359/362-368.
  - Emits Worker and Flutter fixtures.

- `tool/external-access/workers-vpc/src/checklist_catalog.js`
  - Generated static export consumed by the SIS Worker.
  - Contains forms, sections, questions, conditions, targets, category mapping and source hash.

- `test/fixtures/sis_checklists_catalog.json`
  - Deterministic fixture generated from the same source for Flutter tests.

- `lib/checklists/checklist_catalog.dart`
  - Dart model and parser for checklist catalog.
  - Owns fieldtype support, required fields, sections, conditions and target mapping.

- `lib/checklists/checklist_condition_engine.dart`
  - Visibility evaluator for question, section and target conditions.

- `lib/checklists/checklist_submission.dart`
  - Prepared answer model, validation, derivation of category/entity/target and FormCreator payload shape.

- `lib/checklists/checklist_metadata_client.dart`
  - Fetches `/metadata/mobile/sis/checklists`, caches JSON in `SharedPreferences`, falls back safely.

- `lib/checklists/checklist_option_client.dart`
  - Read-only lookup provider for `glpiselect` questions.
  - Supports Ticket lookup for `Checklist Programada` and known generic object lookup for `PluginGenericobjectConservacao`.

- `lib/checklists/screens/sis_checklist_catalog_screen.dart`
  - Specialized checklist entry surface.

- `lib/checklists/screens/sis_checklist_form_screen.dart`
  - Dynamic renderer/reviewer for a selected checklist target.

- `lib/checklists/widgets/checklist_question_field.dart`
  - Renders `select`, `radios`, `multiselect`, `textarea`, `file`, `glpiselect`.

- `lib/checklists/widgets/checklist_review_panel.dart`
  - Shows derived category/entity/target, unsupported fields, missing fields and submission guard state.

- `test/checklists/checklist_catalog_test.dart`
- `test/checklists/checklist_condition_engine_test.dart`
- `test/checklists/checklist_submission_test.dart`
- `test/checklists/checklist_metadata_client_test.dart`
- `test/checklists/sis_checklist_form_screen_test.dart`
- `tool/external-access/workers-vpc/test/checklist_metadata.test.mjs`
- `tool/external-access/workers-vpc/test/formcreator_submission_guard.test.mjs`

### Modified Files

- `tool/external-access/workers-vpc/src/index.js`
  - Add read-only checklist metadata endpoint.
  - Add guarded FormCreator submission allowlist, default off.
  - Add tightly scoped read-only lookup paths for checklist option providers.

- `tool/external-access/workers-vpc/wrangler.jsonc`
  - Add `ALLOW_FORMCREATOR_SUBMISSION=false`.

- `.env.example`
  - Add `SIS_CHECKLISTS_METADATA_URL`.
  - Add `SIS_ENABLE_CHECKLISTS_PREVIEW=false`.
  - Add `SIS_ENABLE_CHECKLISTS_SUBMISSION=false`.

- `lib/config/glpi_config.dart` or equivalent SIS config source
  - Add checklist URLs and feature flags.

- `lib/state/app_state.dart`
  - Load checklist metadata after login/profile load when preview flag is true.
  - Expose read-only checklist repository state.

- `lib/screens/service_catalog_screen.dart`
  - Add a gated entry point to specialized checklists only when profile and flag permit.

- `lib/services/glpi_client.dart`
  - Add `submitFormCreatorAnswer()` only behind app flag and Worker allowlist.

- `widgetbook/lib/previews/service_catalog_surface_preview.dart`
  - Add preview state for checklist entry hidden/visible.

- `docs/CHECKLISTS_SIS_CONHECIMENTO.md`
  - Link this plan as the end-to-end execution route.

---

## Phase 0: Readiness Gate

### Task 0.1: Create DoR for Checklist Initiative

**Files:**
- Create: `docs/quality/dor-sis-checklists-formcreator.md`

- [ ] **Step 1: Add DoR document**

Content:

```markdown
# DoR - SIS Checklists FormCreator

## 1. Tipo

- [x] Feature
- [ ] Correcao de bug
- [x] Evolucao de fluxo existente
- [x] Ajuste operacional/runtime

## 2. Fato ou objetivo

Implementar fluxo especializado de checklist SIS para forms 48-52 sem expor mutacao GLPI real antes de perfil, Worker e sandbox estarem confirmados.

## 3. Entidades envolvidas

- Primaria: GLPI Ticket criado via FormCreator
- Secundarias: PluginFormcreatorForm, PluginFormcreatorQuestion, PluginFormcreatorCondition, PluginFormcreatorTargetTicket, Document, Document_Item, RuleTicket, Group_Ticket

## 4. Estados tocados

- Le: catalogo FormCreator, perguntas, condicoes, perfis, categorias, grupos e read-back de ticket
- Altera: apenas depois do gate de submissao, cria FormAnswer/Ticket em ambiente autorizado
- Estados invalidos que precisam ser bloqueados: usuario sem perfil operacional, Worker sem allowlist, app flag off, campos obrigatorios ausentes, target ambiguo, ticket real nao sintetico

## 5. Papeis envolvidos

- Quem dispara: perfil operacional de checklist a confirmar
- Quem e afetado: equipes de manutencao/conservacao e usuarios observadores configurados pelo GLPI
- Existe caso tecnico-solicitante? Sim, deve ser separado de Solicitante comum
- Existe sessao expirada ou usuario sem permissao? Sim, deve bloquear antes de submissao

## 6. Fonte de verdade

- Origem remota: GLPI SIS FormCreator e RuleTicket
- Origem local: catalogo Worker gerado do snapshot 2026-06-10
- Quando reidrata: login, troca de perfil, refresh manual do catalogo e retorno ao app
- Quem vence em divergencia: GLPI/Worker; cache local e apenas fallback read-only

## 7. Invariantes aplicaveis

- Nao mutar ticket real de usuario sem aprovacao humana explicita.
- Nao usar POST /Ticket nativo para simular FormCreator de checklist.
- Nao permitir checklist para Solicitante comum por inferencia.
- Nao enviar grupo/tecnico direto por perfil sem permissao.

## 8. Cenarios de borda obrigatorios

1. Perfil sem permissao tenta abrir checklist.
2. Campo obrigatorio condicional aparece depois de resposta e bloqueia revisao.
3. Worker sem ALLOW_FORMCREATOR_SUBMISSION recebe tentativa de envio.
4. FormCreator cria ticket mas read-back nao confirma grupo/task template.
5. Usuario perde sessao antes do envio.

## 9. Fora de escopo

- Redesenhar o catalogo SIS inteiro.
- Separar fisicamente SIS e DTIC.
- Liberar submissao contra tickets reais de usuarios.

## 10. Validacao planejada

- Teste unitario: parser, condicoes, validacao, payload, flags
- Teste Widgetbook/visual: entrada de catalogo e formulario checklist
- Teste Android/emulador: smoke read-only antes de mutacao
- Teste API/GLPI: somente sandbox/ticket sintetico, com aprovacao
- Evidencia manual: README de execucao com hashes, screenshots e ticket sintetico

## 11. Criterio de pronto preliminar

Checklist fica visivel somente para perfil autorizado, renderiza e valida forms 48-52 em modo read-only, e submissao so cria ticket FormCreator em ambiente autorizado com read-back consistente.
```

- [ ] **Step 2: Validate markdown whitespace**

Run:

```bash
git diff --check -- docs/quality/dor-sis-checklists-formcreator.md
```

Expected: no output and exit code 0.

---

## Phase 1: Generate Read-Only Checklist Catalog

### Task 1.1: Add Catalog Generator

**Files:**
- Create: `tool/checklists/build_sis_checklists_catalog.mjs`
- Create: `test/fixtures/sis_checklists_catalog.json`
- Create: `tool/external-access/workers-vpc/src/checklist_catalog.js`

- [ ] **Step 1: Write generator test by command expectation**

Run before implementation:

```bash
node tool/checklists/build_sis_checklists_catalog.mjs --help
```

Expected: fails because file does not exist.

- [ ] **Step 2: Implement generator**

Create `tool/checklists/build_sis_checklists_catalog.mjs` with this behavior:

```javascript
#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const defaultSnapshotDir = '/home/jonathan/.brain/glpi-governance/2026-06-10-api';
const args = new Map();
for (let i = 2; i < process.argv.length; i += 1) {
  const key = process.argv[i];
  const value = process.argv[i + 1];
  if (key === '--help') {
    console.log('Usage: node tool/checklists/build_sis_checklists_catalog.mjs [--snapshot-dir DIR]');
    process.exit(0);
  }
  if (key.startsWith('--')) {
    args.set(key, value);
    i += 1;
  }
}

const snapshotDir = args.get('--snapshot-dir') || defaultSnapshotDir;
const root = process.cwd();
const snapshotPath = path.join(snapshotDir, 'sis-snapshot-api-2026-06-10.json');
const questionsPath = path.join(snapshotDir, 'questions_full.json');
const conditionsPath = path.join(snapshotDir, 'conditions_full.json');

const snapshotRaw = fs.readFileSync(snapshotPath, 'utf8');
const snapshot = JSON.parse(snapshotRaw).sections;
const questionsFull = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));
const conditionsFull = JSON.parse(fs.readFileSync(conditionsPath, 'utf8'));

const activeFormIds = new Set([48, 49, 50, 51, 52]);
const activeTargetIds = new Set([316, 325, 326, 337, 341, 342, 343, 344, 350, 359, 362, 363, 364, 365, 366, 367, 368]);
const checklistCategoryIds = new Set([147, 148, 149, 150, 151, 152]);

const forms = snapshot.formcreator_forms.rows
  .filter((form) => activeFormIds.has(Number(form.id)))
  .map((form) => ({
    id: Number(form.id),
    name: String(form.name || '').trim(),
    is_active: Number(form.is_active) === 1,
    is_visible: Number(form.is_visible) === 1,
    helpdesk_home: Number(form.helpdesk_home) === 1,
  }));

const sections = snapshot.formcreator_sections.rows
  .filter((section) => activeFormIds.has(Number(section.plugin_formcreator_forms_id)))
  .map((section) => ({
    id: Number(section.id),
    form_id: Number(section.plugin_formcreator_forms_id),
    name: String(section.name || '').trim(),
    order: Number(section.order || 0),
  }));

const sectionToForm = new Map(sections.map((section) => [section.id, section.form_id]));
const questionIds = new Set();
const questions = questionsFull
  .filter((question) => {
    const formId = sectionToForm.get(Number(question.plugin_formcreator_sections_id));
    if (!activeFormIds.has(Number(formId))) return false;
    questionIds.add(Number(question.id));
    return true;
  })
  .map((question) => ({
    id: Number(question.id),
    form_id: sectionToForm.get(Number(question.plugin_formcreator_sections_id)),
    section_id: Number(question.plugin_formcreator_sections_id),
    name: String(question.name || '').trim(),
    fieldtype: String(question.fieldtype || 'text').trim().toLowerCase(),
    itemtype: String(question.itemtype || '').trim(),
    required: Number(question.required || 0) === 1,
    values: question.values ?? '',
    default_values: question.default_values ?? '',
    show_rule: Number(question.show_rule || 1),
    row: Number(question.row || 0),
    col: Number(question.col || 0),
    width: Number(question.width || 0),
  }));

const sectionIds = new Set(sections.map((section) => section.id));
const targets = snapshot.formcreator_targettickets.rows
  .filter((target) => activeTargetIds.has(Number(target.id)))
  .map((target) => ({
    id: Number(target.id),
    form_id: Number(target.form_id),
    name: String(target.name || '').trim(),
    destination_entity_value: Number(target.destination_entity_value || 0),
    category_rule: Number(target.category_rule || 0),
    category_id: Number(target.category_question || 0),
    location_rule: Number(target.location_rule || 0),
    urgency_rule: Number(target.urgency_rule || 0),
    type_rule: Number(target.type_rule || 0),
    show_rule: Number(target.show_rule || 1),
  }));

const targetIds = new Set(targets.map((target) => target.id));
const conditions = conditionsFull
  .filter((condition) => {
    const itemType = String(condition.itemtype || '');
    const itemId = Number(condition.items_id);
    return (
      (itemType === 'PluginFormcreatorQuestion' && questionIds.has(itemId)) ||
      (itemType === 'PluginFormcreatorSection' && sectionIds.has(itemId)) ||
      (itemType === 'PluginFormcreatorTargetTicket' && targetIds.has(itemId))
    );
  })
  .map((condition) => ({
    id: Number(condition.id),
    itemtype: String(condition.itemtype || ''),
    items_id: Number(condition.items_id),
    source_question_id: Number(condition.plugin_formcreator_questions_id || 0),
    show_condition: Number(condition.show_condition || 1),
    show_value: String(condition.show_value || ''),
    show_logic: Number(condition.show_logic || 1),
    order: Number(condition.order || 0),
  }));

const categories = snapshot.categories.rows
  .filter((category) => checklistCategoryIds.has(Number(category.id)))
  .map((category) => ({
    id: Number(category.id),
    name: String(category.name || '').trim(),
    completename: String(category.completename || '').trim(),
    parent_id: Number(category.itilcategories_id || 0),
    level: Number(category.level || 0),
  }));

const catalog = {
  schema_version: '1.0-readonly',
  generated_at: new Date().toISOString(),
  source_snapshot_sha256: crypto.createHash('sha256').update(snapshotRaw).digest('hex'),
  active_form_ids: [...activeFormIds],
  active_target_ids: [...activeTargetIds],
  forms,
  sections,
  questions,
  conditions,
  targets,
  categories,
};

const fixturePath = path.join(root, 'test/fixtures/sis_checklists_catalog.json');
fs.mkdirSync(path.dirname(fixturePath), { recursive: true });
fs.writeFileSync(fixturePath, `${JSON.stringify(catalog, null, 2)}\n`);

const workerPath = path.join(root, 'tool/external-access/workers-vpc/src/checklist_catalog.js');
fs.mkdirSync(path.dirname(workerPath), { recursive: true });
fs.writeFileSync(
  workerPath,
  `export const SIS_CHECKLIST_CATALOG = ${JSON.stringify(catalog, null, 2)};\n`,
);

console.log(`forms=${forms.length} targets=${targets.length} questions=${questions.length} conditions=${conditions.length}`);
```

- [ ] **Step 3: Generate catalog**

Run:

```bash
node tool/checklists/build_sis_checklists_catalog.mjs
```

Expected output contains:

```text
forms=5 targets=17 questions=1252
```

- [ ] **Step 4: Validate generated JSON**

Run:

```bash
jq '.forms | length, .targets | length, .questions | length' test/fixtures/sis_checklists_catalog.json
```

Expected output:

```text
5
17
1252
```

- [ ] **Step 5: Commit**

```bash
git add tool/checklists/build_sis_checklists_catalog.mjs test/fixtures/sis_checklists_catalog.json tool/external-access/workers-vpc/src/checklist_catalog.js
git commit -m "chore: generate SIS checklist catalog"
```

---

## Phase 2: Worker Read-Only Metadata and Guards

### Task 2.1: Add Checklist Metadata Endpoint

**Files:**
- Modify: `tool/external-access/workers-vpc/src/index.js`
- Test: `tool/external-access/workers-vpc/test/checklist_metadata.test.mjs`

- [ ] **Step 1: Write failing Worker metadata test**

Create `tool/external-access/workers-vpc/test/checklist_metadata.test.mjs`:

```javascript
import test from 'node:test';
import assert from 'node:assert/strict';
import worker from '../src/index.js';

test('SIS checklist metadata endpoint is read-only and returns checklist catalog', async () => {
  const request = new Request('https://worker.test/metadata/mobile/sis/checklists');
  const response = await worker.fetch(request, {});
  assert.equal(response.status, 200);
  const body = await response.json();
  assert.equal(body.forms.length, 5);
  assert.equal(body.targets.length, 17);
  assert.equal(body.questions.length, 1252);
});

test('SIS checklist metadata rejects POST', async () => {
  const request = new Request('https://worker.test/metadata/mobile/sis/checklists', { method: 'POST' });
  const response = await worker.fetch(request, {});
  assert.equal(response.status, 405);
});
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
node --test tool/external-access/workers-vpc/test/checklist_metadata.test.mjs
```

Expected: first test fails with HTTP 500 or non-200 because endpoint is not implemented.

- [ ] **Step 3: Implement endpoint**

Modify `tool/external-access/workers-vpc/src/index.js`:

```javascript
import {MOBILE_METADATA_CATALOG} from './metadata_catalog.js';
import {SIS_CHECKLIST_CATALOG} from './checklist_catalog.js';

const MOBILE_METADATA_PATH = '/metadata/mobile/sis/catalog';
const MOBILE_CHECKLIST_METADATA_PATH = '/metadata/mobile/sis/checklists';
```

Add inside `worker.fetch()` after the existing metadata route:

```javascript
    if (incoming.pathname === MOBILE_CHECKLIST_METADATA_PATH) {
      return checklistCatalogResponse(request);
    }
```

Add below `metadataCatalogResponse()`:

```javascript
function checklistCatalogResponse(request) {
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    return jsonError(405, 'Checklist metadata catalog is read-only.');
  }

  const etag = quotedEtag(SIS_CHECKLIST_CATALOG.source_snapshot_sha256);
  if (request.headers.get('If-None-Match') === etag) {
    return withCors(new Response(null, {
      status: 304,
      headers: metadataHeaders(etag),
    }));
  }

  const body = JSON.stringify(SIS_CHECKLIST_CATALOG);
  return withCors(new Response(request.method === 'HEAD' ? null : body, {
    status: 200,
    headers: {
      ...metadataHeaders(etag),
      'Content-Type': 'application/json; charset=utf-8',
    },
  }));
}
```

Export in `__test`:

```javascript
  checklistCatalogResponse,
```

- [ ] **Step 4: Run Worker test**

Run:

```bash
node --test tool/external-access/workers-vpc/test/checklist_metadata.test.mjs
```

Expected: both tests pass.

- [ ] **Step 5: Commit**

```bash
git add tool/external-access/workers-vpc/src/index.js tool/external-access/workers-vpc/test/checklist_metadata.test.mjs
git commit -m "feat: expose SIS checklist metadata"
```

### Task 2.2: Add FormCreator Submission Guard to SIS Worker

**Files:**
- Modify: `tool/external-access/workers-vpc/src/index.js`
- Modify: `tool/external-access/workers-vpc/wrangler.jsonc`
- Test: `tool/external-access/workers-vpc/test/formcreator_submission_guard.test.mjs`

- [ ] **Step 1: Write failing allowlist test**

Create `tool/external-access/workers-vpc/test/formcreator_submission_guard.test.mjs`:

```javascript
import test from 'node:test';
import assert from 'node:assert/strict';
import {__test} from '../src/index.js';

test('SIS FormCreator submission is blocked by default', () => {
  assert.equal(__test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', {}), false);
});

test('SIS FormCreator submission requires explicit Worker flag', () => {
  assert.equal(
    __test.isAllowedRequest('POST', '/PluginFormcreatorFormAnswer', {
      ALLOW_FORMCREATOR_SUBMISSION: 'true',
    }),
    true,
  );
});
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
node --test tool/external-access/workers-vpc/test/formcreator_submission_guard.test.mjs
```

Expected: fails because `isAllowedRequest()` does not accept `env` yet.

- [ ] **Step 3: Modify allowlist signature**

Change call site:

```javascript
    if (!isAllowedRequest(request.method, apiPath, env)) {
```

Change function:

```javascript
function isAllowedRequest(method, apiPath, env = {}) {
  if (method === 'GET') {
    return GET_ALLOWLIST.has(apiPath) || READ_ONLY_ITEM_PATTERN.test(apiPath);
  }
  if (method === 'POST') {
    if (POST_ALLOWLIST.has(apiPath) || SIS_ACTION_POST_PATTERNS.some((pattern) => pattern.test(apiPath))) {
      return true;
    }
    return (
      env.ALLOW_FORMCREATOR_SUBMISSION === 'true' &&
      apiPath === '/PluginFormcreatorFormAnswer'
    );
  }
  if (method === 'PUT') {
    return SIS_ACTION_PUT_PATTERN.test(apiPath);
  }
  return false;
}
```

- [ ] **Step 4: Add default false flag**

In `tool/external-access/workers-vpc/wrangler.jsonc`, add:

```jsonc
"ALLOW_FORMCREATOR_SUBMISSION": "false"
```

- [ ] **Step 5: Run Worker tests**

Run:

```bash
node --test tool/external-access/workers-vpc/test/formcreator_submission_guard.test.mjs
```

Expected: pass.

- [ ] **Step 6: Commit**

```bash
git add tool/external-access/workers-vpc/src/index.js tool/external-access/workers-vpc/wrangler.jsonc tool/external-access/workers-vpc/test/formcreator_submission_guard.test.mjs
git commit -m "feat: guard SIS FormCreator submission"
```

---

## Phase 3: Flutter Models and Local Validation

### Task 3.1: Add Checklist Catalog Model

**Files:**
- Create: `lib/checklists/checklist_catalog.dart`
- Test: `test/checklists/checklist_catalog_test.dart`

- [ ] **Step 1: Write parser tests**

Create `test/checklists/checklist_catalog_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';

void main() {
  test('parses generated SIS checklist catalog', () {
    final raw = File('test/fixtures/sis_checklists_catalog.json').readAsStringSync();
    final catalog = SisChecklistCatalog.fromJson(raw);

    expect(catalog.forms.map((form) => form.id), containsAll([48, 49, 50, 51, 52]));
    expect(catalog.targets, hasLength(17));
    expect(catalog.questions, hasLength(1252));
    expect(catalog.formById(52)!.name, 'CHECKLIST ILUMINAÇÃO');
    expect(catalog.targetsForForm(50).map((target) => target.id), containsAll([341, 342, 343, 344, 350]));
  });

  test('rejects empty or invalid catalog', () {
    expect(() => SisChecklistCatalog.fromJson('{}'), throwsFormatException);
  });
}
```

- [ ] **Step 2: Run test to verify failure**

Run:

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_catalog_test.dart
```

Expected: fails because model file does not exist.

- [ ] **Step 3: Implement model**

Create `lib/checklists/checklist_catalog.dart` with immutable model classes for:

- `SisChecklistCatalog`
- `SisChecklistForm`
- `SisChecklistSection`
- `SisChecklistQuestion`
- `SisChecklistCondition`
- `SisChecklistTarget`
- `SisChecklistCategory`

Required public methods:

```dart
factory SisChecklistCatalog.fromJson(String rawJson)
SisChecklistForm? formById(int id)
List<SisChecklistTarget> targetsForForm(int formId)
List<SisChecklistSection> sectionsForForm(int formId)
List<SisChecklistQuestion> questionsForSection(int sectionId)
SisChecklistCategory? categoryById(int id)
```

Parsing rules:

- Throw `FormatException('checklist catalog forms must be non-empty')` if `forms` is missing or empty.
- Convert `required`, `is_active`, `is_visible`, `helpdesk_home` to bool.
- Keep raw `values` and `default_values` as strings or primitive values.
- Sort sections by `order`, then `id`.
- Sort questions by `row`, then `col`, then `id`.

- [ ] **Step 4: Run parser tests**

Run:

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_catalog_test.dart
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add lib/checklists/checklist_catalog.dart test/checklists/checklist_catalog_test.dart
git commit -m "feat: parse SIS checklist catalog"
```

### Task 3.2: Add Condition Engine

**Files:**
- Create: `lib/checklists/checklist_condition_engine.dart`
- Test: `test/checklists/checklist_condition_engine_test.dart`

- [ ] **Step 1: Write condition tests**

Create tests covering:

- show rule 1 always visible.
- show rule 2 visible when condition matches.
- show rule 3 hidden when condition matches.
- multiselect answer matches when any selected value equals expected.
- multiple conditions use `show_logic=1` as AND and `show_logic=2` as OR.

- [ ] **Step 2: Implement engine**

Create:

```dart
class SisChecklistConditionEngine {
  const SisChecklistConditionEngine(this.catalog);

  final SisChecklistCatalog catalog;

  bool isSectionVisible(SisChecklistSection section, Map<int, dynamic> answers);
  bool isQuestionVisible(SisChecklistQuestion question, Map<int, dynamic> answers);
  bool isTargetVisible(SisChecklistTarget target, Map<int, dynamic> answers);
}
```

Use the same semantics already proven in `DticFormCatalog`: item types
`PluginFormcreatorQuestion`, `PluginFormcreatorSection` and
`PluginFormcreatorTargetTicket`; condition 1 equals; condition 2 not equals.

- [ ] **Step 3: Run tests**

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_condition_engine_test.dart
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add lib/checklists/checklist_condition_engine.dart test/checklists/checklist_condition_engine_test.dart
git commit -m "feat: evaluate SIS checklist conditions"
```

### Task 3.3: Add Submission Preparation Without Network

**Files:**
- Create: `lib/checklists/checklist_submission.dart`
- Test: `test/checklists/checklist_submission_test.dart`

- [ ] **Step 1: Write preparation tests**

Tests must prove:

- missing required visible question blocks review.
- hidden required question does not block.
- selected target derives category 148-152.
- entity derives as 58.
- generated payload uses `plugin_formcreator_forms_id`, `add=1`, and `formcreator_field_<id>` keys.
- file answers are represented separately and not stringified into text payload.

- [ ] **Step 2: Implement preparation model**

Create:

```dart
class SisChecklistPreparedSubmission {
  const SisChecklistPreparedSubmission({
    required this.formId,
    required this.targetId,
    required this.categoryId,
    required this.entityId,
    required this.answers,
    required this.fileQuestionIds,
    required this.missingRequiredQuestionIds,
    required this.visibleQuestionIds,
  });

  final int formId;
  final int targetId;
  final int categoryId;
  final int entityId;
  final Map<int, dynamic> answers;
  final Set<int> fileQuestionIds;
  final List<int> missingRequiredQuestionIds;
  final List<int> visibleQuestionIds;

  bool get canReview => missingRequiredQuestionIds.isEmpty;

  Map<String, dynamic> toFormCreatorInput() => {
    'plugin_formcreator_forms_id': formId,
    'add': '1',
    for (final entry in answers.entries)
      if (!fileQuestionIds.contains(entry.key))
        'formcreator_field_${entry.key}': entry.value,
  };
}
```

Add a preparer:

```dart
class SisChecklistSubmissionPreparer {
  const SisChecklistSubmissionPreparer({
    required this.catalog,
    required this.conditionEngine,
  });

  final SisChecklistCatalog catalog;
  final SisChecklistConditionEngine conditionEngine;

  SisChecklistPreparedSubmission prepare({
    required int formId,
    required int targetId,
    required Map<int, dynamic> answers,
  });
}
```

Preparation rules:

- Target must exist and belong to form.
- Target category id must be positive.
- Target entity must be 58 for current known checklists.
- Only visible questions count for required validation.
- Empty string, empty list and null are missing.
- File fields are excluded from JSON input and carried separately.

- [ ] **Step 3: Run submission tests**

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_submission_test.dart
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add lib/checklists/checklist_submission.dart test/checklists/checklist_submission_test.dart
git commit -m "feat: prepare SIS checklist submissions"
```

---

## Phase 4: App Feature Flags and Metadata Client

### Task 4.1: Add SIS Checklist Config

**Files:**
- Modify: `.env.example`
- Modify: `lib/config/glpi_config.dart` or current SIS config file
- Test: existing config tests or new `test/checklists/checklist_config_test.dart`

- [ ] **Step 1: Add env keys**

Add to `.env.example`:

```env
SIS_CHECKLISTS_METADATA_URL=
SIS_ENABLE_CHECKLISTS_PREVIEW=false
SIS_ENABLE_CHECKLISTS_SUBMISSION=false
```

- [ ] **Step 2: Add config getters**

Expose:

```dart
static String get sisChecklistsMetadataUrl =>
    dotenv.env['SIS_CHECKLISTS_METADATA_URL']?.trim() ?? '';

static bool get sisChecklistPreviewEnabled =>
    (dotenv.env['SIS_ENABLE_CHECKLISTS_PREVIEW'] ?? 'false').toLowerCase() == 'true';

static bool get sisChecklistSubmissionEnabled =>
    (dotenv.env['SIS_ENABLE_CHECKLISTS_SUBMISSION'] ?? 'false').toLowerCase() == 'true';
```

- [ ] **Step 3: Test false defaults**

Run:

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_config_test.dart
```

Expected: pass and flags default to false.

- [ ] **Step 4: Commit**

```bash
git add .env.example lib/config/glpi_config.dart test/checklists/checklist_config_test.dart
git commit -m "feat: add SIS checklist feature flags"
```

### Task 4.2: Add Checklist Metadata Client

**Files:**
- Create: `lib/checklists/checklist_metadata_client.dart`
- Test: `test/checklists/checklist_metadata_client_test.dart`

- [ ] **Step 1: Write tests**

Cover:

- empty URL returns null and does not throw.
- HTTP 200 parses catalog and caches.
- HTTP 304 uses cache.
- network error uses cache if available.
- invalid cache returns null.

- [ ] **Step 2: Implement client**

Follow `GlpiMetadataClient` pattern:

```dart
class SisChecklistMetadataClient {
  static const cacheKeyCatalogJson = 'sis_mobile_checklist_catalog_json';
  static const cacheKeyCatalogEtag = 'sis_mobile_checklist_catalog_etag';
  static const cacheKeyCatalogFetchedAt = 'sis_mobile_checklist_catalog_fetched_at';

  Future<SisChecklistCatalog?> loadChecklistCatalog({required String? catalogUrl});
}
```

Use:

- `Accept: application/json`
- `If-None-Match` when cached etag exists
- timeout 8 seconds
- no throw to UI for network/catalog failure

- [ ] **Step 3: Run tests**

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_metadata_client_test.dart
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add lib/checklists/checklist_metadata_client.dart test/checklists/checklist_metadata_client_test.dart
git commit -m "feat: load SIS checklist metadata"
```

---

## Phase 5: Read-Only UI and Renderer

### Task 5.1: Add AppState Checklist Loading

**Files:**
- Modify: `lib/state/app_state.dart`
- Test: `test/checklists/app_state_checklist_test.dart`

- [ ] **Step 1: Add state fields**

Add:

```dart
SisChecklistCatalog? _checklistCatalog;
String? _checklistCatalogError;

SisChecklistCatalog? get checklistCatalog => _checklistCatalog;
String? get checklistCatalogError => _checklistCatalogError;
```

- [ ] **Step 2: Add loading method**

```dart
Future<void> loadChecklistCatalogIfEnabled() async {
  if (!GlpiConfig.sisChecklistPreviewEnabled) return;
  final client = SisChecklistMetadataClient();
  _checklistCatalog = await client.loadChecklistCatalog(
    catalogUrl: GlpiConfig.sisChecklistsMetadataUrl,
  );
  _checklistCatalogError = _checklistCatalog == null
      ? 'Catalogo de checklists indisponivel.'
      : null;
  notifyListeners();
}
```

Call after successful login/profile hydration, not before session exists.

- [ ] **Step 3: Test disabled flag does not load**

Run:

```bash
/opt/flutter/bin/flutter test test/checklists/app_state_checklist_test.dart
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add lib/state/app_state.dart test/checklists/app_state_checklist_test.dart
git commit -m "feat: load SIS checklist state"
```

### Task 5.2: Add Checklist Entry Surface

**Files:**
- Create: `lib/checklists/screens/sis_checklist_catalog_screen.dart`
- Modify: `lib/screens/service_catalog_screen.dart`
- Test: `test/checklists/sis_checklist_catalog_screen_test.dart`

- [ ] **Step 1: Write UI tests**

Tests:

- preview flag false hides checklist entry.
- preview flag true and profile `Super-Admin` shows entry.
- profile `Solicitante` hides entry.
- catalog unavailable shows empty state.

- [ ] **Step 2: Implement profile gate (derivado do GLPI, sem nomes hardcoded)**

> **Fidelidade ao GLPI:** o gate NAO usa nomes de perfil fixados em codigo. Ele
> compara o `profiles_id` ativo da sessao com a lista de perfis que o GLPI atribui
> a cada form, derivada de `formcreator_forms_profiles` e embarcada no catalogo
> gerado (`form.profile_ids`). Hoje essa lista e `[4]` (Super-Admin) para todos os
> forms 48-52; `Manutencao e Conservacao` (`profiles_id=11`) NAO esta atribuido aos
> checklists no GLPI, entao fica bloqueado por regra do GLPI, nao por escolha do
> app. Se o GLPI passar a atribuir os forms a outro perfil, o app reflete sem
> mudanca de codigo.

```dart
bool canPreviewChecklistForm(SisChecklistForm form, int? activeProfileId) {
  if (activeProfileId == null) return false;
  return form.profileIds.contains(activeProfileId);
}
```

O `Solicitante` e demais perfis ficam bloqueados porque o GLPI nao lhes atribui os
forms; nenhuma excecao em codigo.

- [ ] **Step 3: Implement catalog screen**

Group targets by form:

- Refrigeracao
- Calhas e Pluviais
- Hidraulico
- Pedras Portuguesas
- Iluminacao

Each row opens `SisChecklistFormScreen(formId, targetId)`.

- [ ] **Step 4: Run UI tests**

```bash
/opt/flutter/bin/flutter test test/checklists/sis_checklist_catalog_screen_test.dart
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add lib/checklists/screens/sis_checklist_catalog_screen.dart lib/screens/service_catalog_screen.dart test/checklists/sis_checklist_catalog_screen_test.dart
git commit -m "feat: add SIS checklist entry surface"
```

### Task 5.3: Add Dynamic Checklist Form Renderer

**Files:**
- Create: `lib/checklists/screens/sis_checklist_form_screen.dart`
- Create: `lib/checklists/widgets/checklist_question_field.dart`
- Create: `lib/checklists/widgets/checklist_review_panel.dart`
- Test: `test/checklists/sis_checklist_form_screen_test.dart`

- [ ] **Step 1: Write renderer tests**

Tests:

- shows only visible sections for initial answers.
- selecting `Local` reveals conditional section.
- missing required visible field disables review.
- `SIS_ENABLE_CHECKLISTS_SUBMISSION=false` shows read-only guard.
- supported fieldtypes render: `select`, `radios`, `multiselect`, `textarea`, `file`.
- `glpiselect` shows lookup field and loading/error states.

- [ ] **Step 2: Implement fields**

`ChecklistQuestionField` must render:

- `select`: dropdown/select control from JSON list values.
- `radios`: radio list.
- `multiselect`: checkbox list.
- `textarea`: multiline text field.
- `file`: file picker with names, bytes and mime type captured.
- `glpiselect`: searchable lookup using `SisChecklistOptionClient`.

Validation:

- visible required question with null/empty value returns `Campo obrigatorio.`
- hidden question is ignored.

- [ ] **Step 3: Implement review panel**

Show:

- form name
- target name
- category id and label
- entity 58
- visible question count
- missing required count
- submission status: blocked, preview only, ready for sandbox submit

- [ ] **Step 4: Run renderer tests**

```bash
/opt/flutter/bin/flutter test test/checklists/sis_checklist_form_screen_test.dart
```

Expected: pass.

- [ ] **Step 5: Commit**

```bash
git add lib/checklists/screens/sis_checklist_form_screen.dart lib/checklists/widgets/checklist_question_field.dart lib/checklists/widgets/checklist_review_panel.dart test/checklists/sis_checklist_form_screen_test.dart
git commit -m "feat: render SIS checklist forms"
```

---

## Phase 6: Read-Only Option Lookups

### Task 6.1: Add Worker Read-Only Lookup Allowlist

**Files:**
- Modify: `tool/external-access/workers-vpc/src/index.js`
- Test: `tool/external-access/workers-vpc/test/checklist_lookup_allowlist.test.mjs`

> **Estado atual do Worker (verificado):** `READ_ONLY_ITEM_PATTERN` em
> `index.js` JA permite `GET /search/Ticket` e os GETs `PluginFormcreator(Form|
> Category|Section|Question|TargetTicket|Form_Profile)`. A unica adicao necessaria
> aqui e `PluginGenericobjectConservacao`. Nao reescrever o que ja existe.

- [ ] **Step 1: Write allowlist tests**

Allow (ja permitido hoje, manter coberto por teste):

- `GET /search/Ticket`

Allow (adicao desta task):

- `GET /PluginGenericobjectConservacao`
- `GET /search/PluginGenericobjectConservacao`

Block:

- `POST /PluginGenericobjectConservacao`
- `PUT /PluginGenericobjectConservacao/1`
- `DELETE /PluginGenericobjectConservacao/1`

- [ ] **Step 2: Modify read-only regex**

Extend `READ_ONLY_ITEM_PATTERN` with:

```javascript
|PluginGenericobjectConservacao(?:\/\d+)?
|search\/PluginGenericobjectConservacao
```

Keep this GET-only.

- [ ] **Step 3: Run Worker tests**

```bash
node --test tool/external-access/workers-vpc/test/checklist_lookup_allowlist.test.mjs
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add tool/external-access/workers-vpc/src/index.js tool/external-access/workers-vpc/test/checklist_lookup_allowlist.test.mjs
git commit -m "feat: allow read-only checklist lookups"
```

### Task 6.2: Add Flutter Option Client

**Files:**
- Create: `lib/checklists/checklist_option_client.dart`
- Test: `test/checklists/checklist_option_client_test.dart`

- [ ] **Step 1: Write tests**

Cover:

- `Ticket` lookup uses `/search/Ticket` with query text.
- `PluginGenericobjectConservacao` lookup uses `/search/PluginGenericobjectConservacao`.
- unknown itemtype returns empty list and warning state.
- HTTP error returns empty list, not exception to UI.

- [ ] **Step 2: Implement client**

Model:

```dart
class SisChecklistLookupOption {
  const SisChecklistLookupOption({required this.id, required this.label});
  final int id;
  final String label;
}
```

Client:

```dart
class SisChecklistOptionClient {
  Future<List<SisChecklistLookupOption>> search({
    required String itemType,
    required String query,
    required String sessionToken,
  });
}
```

Rules:

- Only support `Ticket` and `PluginGenericobjectConservacao`.
- Always GET.
- Do not log query results with user data in production logs.

- [ ] **Step 3: Run tests**

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_option_client_test.dart
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add lib/checklists/checklist_option_client.dart test/checklists/checklist_option_client_test.dart
git commit -m "feat: add SIS checklist lookup client"
```

---

## Phase 7: FormCreator Submission Gated by Two Flags

> **Forma do payload e uma HIPOTESE ate a Phase 9.** O contrato
> `/PluginFormcreatorFormAnswer` + `plugin_formcreator_forms_id` + `add=1` +
> `formcreator_field_<id>` espelha a convencao ja usada no DTIC
> (`DticPreparedSubmission.toFormCreatorInput`), mas so e CONFIRMADO contra o GLPI
> real na submissao sintetica em sandbox (Phase 9). Ate la, tratar como hipotese:
> codigo escrito, testado por unidade, porem desligado por duas flags.

### Task 7.1: Add App-Side Submission Guard

**Files:**
- Modify: `lib/services/glpi_client.dart`
- Test: `test/checklists/checklist_formcreator_submission_test.dart`

- [ ] **Step 1: Write guard tests**

Tests:

- app flag false returns blocked result before HTTP.
- app flag true sends POST to `/PluginFormcreatorFormAnswer`.
- payload contains `plugin_formcreator_forms_id`, `add`, and `formcreator_field_*`.
- file payload path is blocked until file contract is validated.

- [ ] **Step 2: Implement method**

Add:

```dart
Future<Map<String, dynamic>> submitFormCreatorAnswer({
  required SisChecklistPreparedSubmission submission,
}) async {
  if (!GlpiConfig.sisChecklistSubmissionEnabled) {
    return {
      'success': false,
      'blocked': true,
      'message': 'Submissao de checklist desabilitada no app.',
    };
  }
  final sessionToken = _sessionToken;
  if (sessionToken == null || sessionToken.isEmpty) {
    return {
      'success': false,
      'blocked': true,
      'message': 'Sessao GLPI ausente para submissao de checklist.',
    };
  }
  if (submission.fileQuestionIds.isNotEmpty) {
    return {
      'success': false,
      'blocked': true,
      'message': 'Submissao com anexos de checklist exige validacao sandbox antes de habilitar.',
    };
  }
  final uri = Uri.parse('${GlpiConfig.baseUrl}/PluginFormcreatorFormAnswer');
  final response = await http.post(
    uri,
    headers: _headers,
    body: jsonEncode({'input': submission.toFormCreatorInput()}),
  );
  return _decodeGlpiMutationResponse(response);
}
```

Use existing response parsing conventions in `GlpiClient`. In Worker mode, do not send an app token from Flutter; `tool/external-access/workers-vpc/src/index.js` injects the Worker secret before forwarding upstream.

- [ ] **Step 3: Run tests**

```bash
/opt/flutter/bin/flutter test test/checklists/checklist_formcreator_submission_test.dart
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add lib/services/glpi_client.dart test/checklists/checklist_formcreator_submission_test.dart
git commit -m "feat: guard SIS checklist FormCreator submission"
```

### Task 7.2: Wire Submit Button With Read-Back

**Files:**
- Modify: `lib/checklists/screens/sis_checklist_form_screen.dart`
- Test: `test/checklists/sis_checklist_form_screen_test.dart`

- [ ] **Step 1: Add UI tests**

Tests:

- submission flag false shows `Revisar dados`, not `Enviar`.
- submission flag true but Worker returns 403 shows useful message.
- success triggers read-back route before showing success.
- read-back mismatch shows warning and does not pretend full validation.

- [ ] **Step 2: Implement submit flow**

Flow:

1. Validate visible required fields.
2. Prepare `SisChecklistPreparedSubmission`.
3. If `SIS_ENABLE_CHECKLISTS_SUBMISSION=false`, show review only.
4. If true, call `GlpiClient.submitFormCreatorAnswer`.
5. Extract created ticket id from response.
6. Call existing `validateGovernedTicketReadback` with expected entity/category/group/task templates.
7. Refresh ticket list.
8. Show success with ticket id and read-back summary.

- [ ] **Step 3: Run tests**

```bash
/opt/flutter/bin/flutter test test/checklists/sis_checklist_form_screen_test.dart
```

Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add lib/checklists/screens/sis_checklist_form_screen.dart test/checklists/sis_checklist_form_screen_test.dart
git commit -m "feat: wire SIS checklist review and submit"
```

---

## Phase 8: Visual Lab and Android Read-Only Validation

### Task 8.1: Add Widgetbook Preview

**Files:**
- Modify: `widgetbook/lib/widgetbook_app.dart`
- Create: `widgetbook/lib/previews/sis_checklist_surface_preview.dart`
- Test: `widgetbook/test/sis_checklist_surface_preview_test.dart`

- [ ] **Step 1: Add preview states**

States:

- entry hidden for Solicitante
- entry visible for Super-Admin
- form 49 with one required Local missing
- form 52 with many required fields and conditional section visible
- submission disabled banner

- [ ] **Step 2: Run Widgetbook tests**

```bash
cd widgetbook
/opt/flutter/bin/flutter test
```

Expected: pass.

- [ ] **Step 3: Commit**

```bash
git add widgetbook/lib/widgetbook_app.dart widgetbook/lib/previews/sis_checklist_surface_preview.dart widgetbook/test/sis_checklist_surface_preview_test.dart
git commit -m "test: add SIS checklist Widgetbook preview"
```

### Task 8.2: Run Structural Gates

- [ ] **Step 1: Flutter analyze**

```bash
/opt/flutter/bin/flutter analyze
```

Expected: no analyzer errors.

- [ ] **Step 2: Flutter tests**

```bash
/opt/flutter/bin/flutter test
```

Expected: all tests pass.

- [ ] **Step 3: Worker tests**

```bash
node --test tool/external-access/workers-vpc/test/*.mjs
```

Expected: all Worker tests pass.

- [ ] **Step 4: Commit any fixes**

```bash
git status --short
git add lib/checklists lib/config/glpi_config.dart lib/screens/service_catalog_screen.dart lib/services/glpi_client.dart lib/state/app_state.dart test/checklists tool/checklists tool/external-access/workers-vpc widgetbook .env.example
git commit -m "test: validate SIS checklist read-only flow"
```

### Task 8.3: Android Read-Only Smoke

- [ ] **Step 1: Build debug or use existing APK**

Use existing project Android flow. If validating WSL AVD:

```bash
ANDROID_HOME=/home/jonathan/Android/Sdk ANDROID_AVD_HOME=/home/jonathan/.android/avd ./tool/android/readonly_smoke_android.sh --sis-apk <apk> --skip-dtic --allow-kvm-chmod --keep-emulator
```

Expected:

- app opens
- no GLPI mutation happens
- screenshot/logcat evidence path is recorded

- [ ] **Step 2: Record evidence**

Add evidence path and APK hash to the final validation note, not to source if it contains runtime artifacts.

---

## Phase 9: Controlled Sandbox Submission

### Task 9.1: Prepare Sandbox Runbook

**Files:**
- Create: `docs/checklists/SIS_CHECKLIST_SANDBOX_RUNBOOK.md`

- [ ] **Step 1: Create runbook**

The runbook must require:

- human approval for mutating test
- environment URL
- app flag `SIS_ENABLE_CHECKLISTS_SUBMISSION=true`
- Worker flag `ALLOW_FORMCREATOR_SUBMISSION=true`
- test account/profile
- synthetic checklist target
- stop criteria
- read-back fields
- cleanup owner

- [ ] **Step 2: Validate no secrets**

```bash
rg -n -i 'password|passwd|senha|token|secret|authorization|bearer|apikey|api_key' docs/checklists/SIS_CHECKLIST_SANDBOX_RUNBOOK.md
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add docs/checklists/SIS_CHECKLIST_SANDBOX_RUNBOOK.md
git commit -m "docs: add SIS checklist sandbox runbook"
```

### Task 9.2: Execute One Synthetic Submission

Do this only after human approval and sandbox target confirmation.

- [ ] **Step 1: Deploy Worker with submission allowed**

```bash
npx wrangler deploy
```

Expected: deployment succeeds with `ALLOW_FORMCREATOR_SUBMISSION=true` in the validated environment.

- [ ] **Step 2: Run app with submission enabled**

```bash
/opt/flutter/bin/flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8083
```

Expected: app starts; checklist submit button visible only for authorized profile.

- [ ] **Step 3: Submit one synthetic checklist without file first**

Expected read-back:

- ticket id created
- entity 58
- category one of 148-152
- assignment group matches expected rule outcome
- observer/requester/group behavior visible where permitted
- task templates present or documented as not readable by profile

- [ ] **Step 4: Disable submission flags immediately after test**

Set:

```text
SIS_ENABLE_CHECKLISTS_SUBMISSION=false
ALLOW_FORMCREATOR_SUBMISSION=false
```

- [ ] **Step 5: Record result**

Record ticket id, environment, timestamp, read-back result and cleanup owner without exposing credentials.

---

## Phase 10: Definition of Done Audit

Before claiming complete:

- [ ] DoR exists and has no unresolved blocker hidden as implementation detail.
- [ ] Read-only catalog generator selects only forms 48-52 and 17 targets.
- [ ] Worker metadata endpoint is read-only and tested.
- [ ] Worker FormCreator submit route is blocked by default and tested.
- [ ] Flutter parser/conditions/submission prep tests pass.
- [ ] UI hides checklists for Solicitante.
- [ ] UI does not submit when app flag is false.
- [ ] Widgetbook preview exists for hidden, visible and blocked states.
- [ ] `/opt/flutter/bin/flutter analyze` passes.
- [ ] `/opt/flutter/bin/flutter test` passes.
- [ ] Worker tests pass.
- [ ] Android read-only smoke evidence exists if any visible mobile UI changed.
- [ ] Sandbox mutating test only ran with human approval, synthetic target and cleanup owner.
- [ ] `docs/CHECKLISTS_SIS_CONHECIMENTO.md` links this plan and records final evidence.

## Execution Recommendation

Execute in this order:

1. Phase 0 through Phase 6: safe read-only implementation.
2. Stop and review UI, Worker allowlist and profile decision.
3. Phase 7: code the submission path, still disabled by default.
4. Phase 8: validate locally and Android read-only.
5. Phase 9: run exactly one sandbox mutation after explicit approval.

Do not skip from Phase 1 directly to Phase 9.
