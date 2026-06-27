#!/usr/bin/env node
// Gera o catalogo read-only de checklists SIS (forms 48-52).
//
// Modos:
//   - snapshot local: node tool/checklists/build_sis_checklists_catalog.mjs
//   - GLPI live read-only: node tool/checklists/build_sis_checklists_catalog.mjs --live
//
// Saidas:
//   - assets/sis_checklists_catalog.json                 (asset usado pelo app)
//   - test/fixtures/sis_checklists_catalog.json          (fixture deterministico p/ Flutter)
//   - tool/external-access/workers-vpc/src/checklist_catalog.js (export p/ Worker)
//
// Guardrails do modo live:
//   - le credenciais do .env ou ambiente;
//   - usa apenas GET/initSession/killSession;
//   - nao imprime token, senha ou App-Token;
//   - nao cria/altera/fecha tickets nem salva configuracao no GLPI.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';

const defaultSnapshotDir = '/home/jonathan/.brain/glpi-governance/2026-06-10-api';
const args = new Map();
for (let i = 2; i < process.argv.length; i += 1) {
  const key = process.argv[i];
  const value = process.argv[i + 1];
  if (key === '--help') {
    console.log(
      [
        'Usage: node tool/checklists/build_sis_checklists_catalog.mjs [--snapshot-dir DIR] [--live] [--env-file FILE]',
        '',
        'Default mode reads the local governance snapshot.',
        'Live mode reads GLPI SIS API using .env credentials, read-only.',
      ].join('\n'),
    );
    process.exit(0);
  }
  if (key === '--live') {
    args.set(key, 'true');
    continue;
  }
  if (key.startsWith('--')) {
    args.set(key, value);
    i += 1;
  }
}

const root = process.cwd();
const snapshotDir = args.get('--snapshot-dir') || defaultSnapshotDir;
const envFile = args.get('--env-file') || '.env';
const useLive = args.has('--live');
const activeFormIds = new Set([48, 49, 50, 51, 52]);
const checklistCategoryIds = new Set([147, 148, 149, 150, 151, 152]);

const num = (value, fallback = 0) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};

const text = (value, fallback = '') => {
  if (value === null || value === undefined) return fallback;
  const trimmed = String(value).trim();
  return trimmed.length === 0 ? fallback : trimmed;
};

const boolFromGlpi = (value) => num(value) === 1 || value === true;

const formIdOf = (row) =>
  num(row.plugin_formcreator_forms_id ?? row.form_id ?? row.forms_id);

const sectionFormIdOf = (row) =>
  num(row.plugin_formcreator_forms_id ?? row.form_id ?? row.forms_id);

const questionSectionIdOf = (row) =>
  num(row.plugin_formcreator_sections_id ?? row.section_id);

const targetFormIdOf = (row) =>
  num(row.plugin_formcreator_forms_id ?? row.form_id ?? row.forms_id);

const targetCategoryIdOf = (row) => num(row.category_question ?? row.category_id);

const stableHash = (value) =>
  crypto
    .createHash('sha256')
    .update(JSON.stringify(value))
    .digest('hex');

const loadEnv = (filePath) => {
  const env = {...process.env};
  const absolute = path.isAbsolute(filePath) ? filePath : path.join(root, filePath);
  if (!fs.existsSync(absolute)) return env;
  for (const rawLine of fs.readFileSync(absolute, 'utf8').split(/\r?\n/)) {
    const line = rawLine.trim();
    if (line.length === 0 || line.startsWith('#') || !line.includes('=')) continue;
    const index = line.indexOf('=');
    const key = line.slice(0, index).trim();
    const value = line
      .slice(index + 1)
      .trim()
      .replace(/^['"]|['"]$/g, '');
    env[key] = value;
  }
  return env;
};

const fetchJson = async (url, headers) => {
  const response = await fetch(url, {headers});
  const bodyText = await response.text();
  let body = null;
  if (bodyText.length > 0) {
    try {
      body = JSON.parse(bodyText);
    } catch (_) {
      body = bodyText;
    }
  }
  if (!response.ok) {
    throw new Error(`GET ${url} failed: HTTP ${response.status}`);
  }
  return {body, headers: response.headers, status: response.status};
};

const fetchAllGlpi = async (baseUrl, itemtype, headers) => {
  const rows = [];
  const pageSize = 1000;
  let start = 0;
  let total = null;

  while (true) {
    const url = new URL(`${baseUrl}/${itemtype}`);
    url.searchParams.set('range', `${start}-${start + pageSize - 1}`);
    const {body, headers: responseHeaders} = await fetchJson(url.toString(), headers);
    if (!Array.isArray(body)) {
      throw new Error(`${itemtype} did not return a JSON list`);
    }
    rows.push(...body);

    const contentRange = responseHeaders.get('content-range') || '';
    const match = contentRange.match(/(\d+)-(\d+)\/(\d+|\*)/);
    if (match && match[3] !== '*') {
      total = Number(match[3]);
    }
    if (total !== null && rows.length >= total) break;
    if (body.length < pageSize) break;
    start += pageSize;
    if (start > 100000) {
      throw new Error(`pagination safety stop for ${itemtype}`);
    }
  }

  return rows;
};

const loadLiveSource = async () => {
  const env = loadEnv(envFile);
  const baseUrl = text(env.SIS_TEST_BASE_URL || env.SIS_GLPI_BASE_URL || env.GLPI_BASE_URL).replace(
    /\/+$/,
    '',
  );
  const appToken = text(env.GLPI_APP_TOKEN);
  const user = text(env.SIS_TEST_ADMIN_USER || env.SIS_TEST_USER);
  const password = text(env.SIS_TEST_ADMIN_PASSWORD || env.SIS_TEST_PASSWORD);
  if (!baseUrl || !user || !password) {
    throw new Error('missing SIS_TEST_BASE_URL/GLPI_BASE_URL or test credentials in .env');
  }

  const baseHeaders = {
    Accept: 'application/json',
    ...(appToken ? {'App-Token': appToken} : {}),
  };
  const auth = Buffer.from(`${user}:${password}`).toString('base64');
  const init = await fetchJson(`${baseUrl}/initSession`, {
    ...baseHeaders,
    Authorization: `Basic ${auth}`,
  });
  if (!init.body || typeof init.body !== 'object' || !init.body.session_token) {
    throw new Error('initSession did not return session_token');
  }

  const sessionHeaders = {
    ...baseHeaders,
    'Session-Token': init.body.session_token,
  };

  try {
    const [
      forms,
      sections,
      questions,
      conditions,
      targets,
      formsProfiles,
      formsGroups,
      categories,
    ] = await Promise.all([
      fetchAllGlpi(baseUrl, 'PluginFormcreatorForm', sessionHeaders),
      fetchAllGlpi(baseUrl, 'PluginFormcreatorSection', sessionHeaders),
      fetchAllGlpi(baseUrl, 'PluginFormcreatorQuestion', sessionHeaders),
      fetchAllGlpi(baseUrl, 'PluginFormcreatorCondition', sessionHeaders),
      fetchAllGlpi(baseUrl, 'PluginFormcreatorTargetTicket', sessionHeaders),
      fetchAllGlpi(baseUrl, 'PluginFormcreatorForm_Profile', sessionHeaders),
      fetchAllGlpi(baseUrl, 'PluginFormcreatorForm_Group', sessionHeaders),
      fetchAllGlpi(baseUrl, 'ITILCategory', sessionHeaders),
    ]);

    return {
      mode: 'live-api',
      rows: {
        forms,
        sections,
        questions,
        conditions,
        targets,
        formsProfiles,
        formsGroups,
        categories,
      },
    };
  } finally {
    try {
      await fetchJson(`${baseUrl}/killSession`, sessionHeaders);
    } catch (_) {
      // A falha no encerramento da sessao nao deve vazar segredos nem mascarar
      // uma geracao ja concluida. O GLPI expira a sessao server-side.
    }
  }
};

const loadSnapshotSource = () => {
  const snapshotPath = path.join(snapshotDir, 'sis-snapshot-api-2026-06-10.json');
  const questionsPath = path.join(snapshotDir, 'questions_full.json');
  const conditionsPath = path.join(snapshotDir, 'conditions_full.json');
  const formsGroupsPath = path.join(snapshotDir, 'formcreator_forms_groups.json');

  const snapshotRaw = fs.readFileSync(snapshotPath, 'utf8');
  const snapshot = JSON.parse(snapshotRaw).sections;
  const questionsFull = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));
  const conditionsFull = JSON.parse(fs.readFileSync(conditionsPath, 'utf8'));
  const formsGroups = fs.existsSync(formsGroupsPath)
    ? JSON.parse(fs.readFileSync(formsGroupsPath, 'utf8'))
    : [];

  return {
    mode: 'snapshot',
    snapshotRaw,
    rows: {
      forms: snapshot.formcreator_forms.rows,
      sections: snapshot.formcreator_sections.rows,
      questions: questionsFull,
      conditions: conditionsFull,
      targets: snapshot.formcreator_targettickets.rows,
      formsProfiles: snapshot.formcreator_forms_profiles.rows,
      formsGroups,
      categories: snapshot.categories.rows,
    },
  };
};

const source = useLive ? await loadLiveSource() : loadSnapshotSource();
const rows = source.rows;

const forms = rows.forms
  .filter((form) => activeFormIds.has(num(form.id)))
  .map((form) => ({
    id: num(form.id),
    name: text(form.name),
    is_active: boolFromGlpi(form.is_active),
    is_visible: boolFromGlpi(form.is_visible),
    helpdesk_home: boolFromGlpi(form.helpdesk_home),
    // Gate de acesso derivado do GLPI (formcreator_forms_profiles + Form_Group).
    profile_ids: [],
    group_ids: [],
  }));
const formById = new Map(forms.map((form) => [form.id, form]));

for (const row of rows.formsProfiles) {
  const formId = formIdOf(row);
  const form = formById.get(formId);
  if (!form) continue;
  const profileId = num(row.profiles_id);
  if (profileId > 0 && !form.profile_ids.includes(profileId)) {
    form.profile_ids.push(profileId);
  }
}
for (const form of forms) form.profile_ids.sort((a, b) => a - b);

for (const row of rows.formsGroups) {
  const formId = formIdOf(row);
  const form = formById.get(formId);
  if (!form) continue;
  const groupId = num(row.groups_id);
  if (groupId > 0 && !form.group_ids.includes(groupId)) {
    form.group_ids.push(groupId);
  }
}
for (const form of forms) form.group_ids.sort((a, b) => a - b);

const sections = rows.sections
  .filter((section) => activeFormIds.has(sectionFormIdOf(section)))
  .map((section) => ({
    id: num(section.id),
    form_id: sectionFormIdOf(section),
    name: text(section.name),
    order: num(section.order),
    show_rule: num(section.show_rule, 1),
  }));

const sectionToForm = new Map(sections.map((section) => [section.id, section.form_id]));
const sectionIds = new Set(sections.map((section) => section.id));
const questionIds = new Set();
const questions = rows.questions
  .filter((question) => sectionToForm.has(questionSectionIdOf(question)))
  .map((question) => {
    const id = num(question.id);
    questionIds.add(id);
    return {
      id,
      form_id: sectionToForm.get(questionSectionIdOf(question)),
      section_id: questionSectionIdOf(question),
      name: text(question.name),
      fieldtype: text(question.fieldtype, 'text').toLowerCase(),
      itemtype: text(question.itemtype),
      required: boolFromGlpi(question.required),
      values: question.values ?? '',
      default_values: question.default_values ?? '',
      show_rule: num(question.show_rule, 1),
      row: num(question.row),
      col: num(question.col),
      width: num(question.width),
    };
  });

const targets = rows.targets
  .filter((target) => activeFormIds.has(targetFormIdOf(target)))
  .map((target) => ({
    id: num(target.id),
    form_id: targetFormIdOf(target),
    name: text(target.name),
    destination_entity_value: num(target.destination_entity_value),
    category_rule: num(target.category_rule),
    // category_rule=2 => category_question guarda o ID da categoria (148-152).
    category_id: targetCategoryIdOf(target),
    location_rule: num(target.location_rule),
    location_question: num(target.location_question),
    urgency_rule: num(target.urgency_rule),
    type_rule: num(target.type_rule),
    show_rule: num(target.show_rule, 1),
  }))
  .filter((target) => target.category_id > 0);
const targetIds = new Set(targets.map((target) => target.id));

const conditions = rows.conditions
  .filter((condition) => {
    const itemType = text(condition.itemtype);
    const itemId = num(condition.items_id);
    return (
      (itemType === 'PluginFormcreatorQuestion' && questionIds.has(itemId)) ||
      (itemType === 'PluginFormcreatorSection' && sectionIds.has(itemId)) ||
      (itemType === 'PluginFormcreatorTargetTicket' && targetIds.has(itemId))
    );
  })
  .map((condition) => ({
    id: num(condition.id),
    itemtype: text(condition.itemtype),
    items_id: num(condition.items_id),
    source_question_id: num(condition.plugin_formcreator_questions_id),
    show_condition: num(condition.show_condition, 1),
    show_value: text(condition.show_value),
    show_logic: num(condition.show_logic, 1),
    order: num(condition.order),
  }));

const categoryIds = new Set([...checklistCategoryIds, ...targets.map((target) => target.category_id)]);
const categories = rows.categories
  .filter((category) => categoryIds.has(num(category.id)))
  .map((category) => ({
    id: num(category.id),
    name: text(category.name),
    completename: text(category.completename),
    parent_id: num(category.itilcategories_id ?? category.parent_id),
    level: num(category.level),
  }));

const sourceForHash =
  source.mode === 'snapshot'
    ? source.snapshotRaw
    : {
        mode: source.mode,
        rows: {
          forms: rows.forms,
          sections: rows.sections,
          questions: rows.questions,
          conditions: rows.conditions,
          targets: rows.targets,
          formsProfiles: rows.formsProfiles,
          formsGroups: rows.formsGroups,
          categories: rows.categories,
        },
      };

const catalog = {
  schema_version: '1.0-readonly',
  generated_at: new Date().toISOString(),
  source_mode: source.mode,
  source_snapshot_sha256:
    typeof sourceForHash === 'string'
      ? crypto.createHash('sha256').update(sourceForHash).digest('hex')
      : stableHash(sourceForHash),
  active_form_ids: [...activeFormIds],
  active_target_ids: [...targetIds].sort((a, b) => a - b),
  source_counts: {
    formcreator_forms: rows.forms.length,
    formcreator_sections: rows.sections.length,
    formcreator_questions: rows.questions.length,
    formcreator_conditions: rows.conditions.length,
    formcreator_targettickets: rows.targets.length,
    formcreator_forms_profiles: rows.formsProfiles.length,
    formcreator_forms_groups: rows.formsGroups.length,
    categories: rows.categories.length,
  },
  forms,
  sections,
  questions,
  conditions,
  targets,
  categories,
};

const writeJson = (filePath, value) => {
  fs.mkdirSync(path.dirname(filePath), {recursive: true});
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
};

const assetPath = path.join(root, 'assets/sis_checklists_catalog.json');
const fixturePath = path.join(root, 'test/fixtures/sis_checklists_catalog.json');
const workerPath = path.join(root, 'tool/external-access/workers-vpc/src/checklist_catalog.js');

writeJson(assetPath, catalog);
writeJson(fixturePath, catalog);
fs.mkdirSync(path.dirname(workerPath), {recursive: true});
fs.writeFileSync(
  workerPath,
  `// GERADO por tool/checklists/build_sis_checklists_catalog.mjs. Nao editar a mao.\nexport const SIS_CHECKLIST_CATALOG = ${JSON.stringify(catalog, null, 2)};\n`,
);

console.log(
  `mode=${source.mode} forms=${forms.length} sections=${sections.length} ` +
    `targets=${targets.length} questions=${questions.length} conditions=${conditions.length} ` +
    `categories=${categories.length}`,
);
