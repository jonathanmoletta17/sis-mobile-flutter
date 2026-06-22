#!/usr/bin/env node
// Gera o catalogo read-only de checklists SIS (forms 48-52) a partir do snapshot
// API local de governanca GLPI. 100% local: nao toca o GLPI real.
//
// Saidas:
//   - test/fixtures/sis_checklists_catalog.json   (fixture deterministico p/ Flutter)
//   - tool/external-access/workers-vpc/src/checklist_catalog.js (export p/ Worker)
//
// Fidelidade ao GLPI SIS:
//   - somente forms ativos 48-52 e seus 17 target tickets;
//   - category_id derivado de target.category_question (148-152);
//   - entidade destino 58 (destination_entity_value);
//   - gate de acesso derivado de formcreator_forms_profiles (profile_ids) +
//     formcreator_forms_groups.json suplementar (group_ids por form),
//     sem nomes hardcoded; resolve para profile_ids=[4], group_ids=[22];
//   - condicoes (question/section/target) preservadas para a engine de visibilidade.
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
const formsGroupsPath = path.join(snapshotDir, 'formcreator_forms_groups.json');

const snapshotRaw = fs.readFileSync(snapshotPath, 'utf8');
const snapshot = JSON.parse(snapshotRaw).sections;
const questionsFull = JSON.parse(fs.readFileSync(questionsPath, 'utf8'));
const conditionsFull = JSON.parse(fs.readFileSync(conditionsPath, 'utf8'));
// Dados de grupo por form: coletados ao vivo via PluginFormcreatorForm_Group
// (nao presente no snapshot 2026-06-10, arquivo suplementar gerado uma vez).
const formsGroupsRaw = fs.existsSync(formsGroupsPath)
  ? JSON.parse(fs.readFileSync(formsGroupsPath, 'utf8'))
  : [];

const num = (value, fallback = 0) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
};
const text = (value, fallback = '') => {
  if (value === null || value === undefined) return fallback;
  const trimmed = String(value).trim();
  return trimmed.length === 0 ? fallback : trimmed;
};

const activeFormIds = new Set([48, 49, 50, 51, 52]);
const activeTargetIds = new Set([
  316, 325, 326, 337, 341, 342, 343, 344, 350, 359, 362, 363, 364, 365, 366, 367, 368,
]);
const checklistCategoryIds = new Set([147, 148, 149, 150, 151, 152]);

const forms = snapshot.formcreator_forms.rows
  .filter((form) => activeFormIds.has(num(form.id)))
  .map((form) => ({
    id: num(form.id),
    name: text(form.name),
    is_active: num(form.is_active) === 1,
    is_visible: num(form.is_visible) === 1,
    helpdesk_home: num(form.helpdesk_home) === 1,
    // Gate de acesso derivado do GLPI (formcreator_forms_profiles + Form_Group).
    profile_ids: [],
    group_ids: [],
  }));
const formById = new Map(forms.map((form) => [form.id, form]));

// profile_ids por form: fonte de verdade do GLPI (formcreator_forms_profiles).
for (const row of snapshot.formcreator_forms_profiles.rows) {
  const formId = num(row.form_id);
  const form = formById.get(formId);
  if (!form) continue;
  const profileId = num(row.profiles_id);
  if (profileId > 0 && !form.profile_ids.includes(profileId)) {
    form.profile_ids.push(profileId);
  }
}
for (const form of forms) form.profile_ids.sort((a, b) => a - b);

// group_ids por form: fonte de verdade do GLPI (PluginFormcreatorForm_Group).
for (const row of formsGroupsRaw) {
  const formId = num(row.form_id);
  const form = formById.get(formId);
  if (!form) continue;
  const groupId = num(row.groups_id);
  if (groupId > 0 && !form.group_ids.includes(groupId)) {
    form.group_ids.push(groupId);
  }
}
for (const form of forms) form.group_ids.sort((a, b) => a - b);

const sections = snapshot.formcreator_sections.rows
  .filter((section) => activeFormIds.has(num(section.plugin_formcreator_forms_id)))
  .map((section) => ({
    id: num(section.id),
    form_id: num(section.plugin_formcreator_forms_id),
    name: text(section.name),
    order: num(section.order),
  }));

const sectionToForm = new Map(sections.map((section) => [section.id, section.form_id]));
const sectionIds = new Set(sections.map((section) => section.id));
const questionIds = new Set();
const questions = questionsFull
  .filter((question) => sectionToForm.has(num(question.plugin_formcreator_sections_id)))
  .map((question) => {
    const id = num(question.id);
    questionIds.add(id);
    return {
      id,
      form_id: sectionToForm.get(num(question.plugin_formcreator_sections_id)),
      section_id: num(question.plugin_formcreator_sections_id),
      name: text(question.name),
      fieldtype: text(question.fieldtype, 'text').toLowerCase(),
      itemtype: text(question.itemtype),
      required: num(question.required) === 1,
      values: question.values ?? '',
      default_values: question.default_values ?? '',
      show_rule: num(question.show_rule, 1),
      row: num(question.row),
      col: num(question.col),
      width: num(question.width),
    };
  });

const targets = snapshot.formcreator_targettickets.rows
  .filter((target) => activeTargetIds.has(num(target.id)))
  .map((target) => ({
    id: num(target.id),
    form_id: num(target.form_id),
    name: text(target.name),
    destination_entity_value: num(target.destination_entity_value),
    category_rule: num(target.category_rule),
    // category_rule=2 => category_question guarda o ID da categoria (148-152).
    category_id: num(target.category_question),
    location_rule: num(target.location_rule),
    urgency_rule: num(target.urgency_rule),
    type_rule: num(target.type_rule),
    show_rule: num(target.show_rule, 1),
  }));
const targetIds = new Set(targets.map((target) => target.id));

const conditions = conditionsFull
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

const categories = snapshot.categories.rows
  .filter((category) => checklistCategoryIds.has(num(category.id)))
  .map((category) => ({
    id: num(category.id),
    name: text(category.name),
    completename: text(category.completename),
    parent_id: num(category.itilcategories_id),
    level: num(category.level),
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
  `// GERADO por tool/checklists/build_sis_checklists_catalog.mjs. Nao editar a mao.\nexport const SIS_CHECKLIST_CATALOG = ${JSON.stringify(catalog, null, 2)};\n`,
);

console.log(
  `forms=${forms.length} targets=${targets.length} questions=${questions.length} ` +
    `conditions=${conditions.length} categories=${categories.length}`,
);
