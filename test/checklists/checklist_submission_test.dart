import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';
import 'package:sis_mobile_flutter/checklists/checklist_condition_engine.dart';
import 'package:sis_mobile_flutter/checklists/checklist_submission.dart';

SisChecklistCatalog _catalog() {
  return SisChecklistCatalog.fromMap({
    'schema_version': 'test',
    'source_snapshot_sha256': 'test',
    'forms': [
      {'id': 50, 'name': 'CHECKLIST HIDRAULICO', 'is_active': true, 'is_visible': true, 'helpdesk_home': true, 'profile_ids': [4]},
    ],
    'sections': [
      {'id': 500, 'form_id': 50, 'name': 'S', 'order': 1},
    ],
    'questions': [
      // obrigatoria sempre visivel
      {'id': 1, 'form_id': 50, 'section_id': 500, 'name': 'Local', 'fieldtype': 'select', 'required': true, 'show_rule': 1, 'row': 0, 'col': 0, 'width': 4, 'values': '["A","B"]'},
      // obrigatoria condicional (so aparece se Q1 == B)
      {'id': 2, 'form_id': 50, 'section_id': 500, 'name': 'Detalhe', 'fieldtype': 'textarea', 'required': true, 'show_rule': 2, 'row': 1, 'col': 0, 'width': 4},
      // anexo opcional
      {'id': 3, 'form_id': 50, 'section_id': 500, 'name': 'Foto', 'fieldtype': 'file', 'required': false, 'show_rule': 1, 'row': 2, 'col': 0, 'width': 4},
    ],
    'conditions': [
      {'id': 9001, 'itemtype': 'PluginFormcreatorQuestion', 'items_id': 2, 'source_question_id': 1, 'show_condition': 1, 'show_value': 'B', 'show_logic': 1, 'order': 1},
    ],
    'targets': [
      {'id': 341, 'form_id': 50, 'name': 'HIDRAULICO ALA RESIDENCIAL', 'destination_entity_value': 58, 'category_rule': 2, 'category_id': 151, 'location_rule': 2, 'urgency_rule': 1, 'type_rule': 1, 'show_rule': 2},
    ],
    'categories': [
      {'id': 151, 'name': 'Hidraulico', 'completename': 'Manutencao > Checklist > Hidraulico', 'parent_id': 147, 'level': 3},
    ],
  });
}

SisChecklistSubmissionPreparer _preparer() {
  final catalog = _catalog();
  return SisChecklistSubmissionPreparer(
    catalog: catalog,
    conditionEngine: SisChecklistConditionEngine(catalog),
  );
}

void main() {
  test('missing required visible question blocks review', () {
    final result = _preparer().prepare(formId: 50, targetId: 341, answers: {});
    expect(result.missingRequiredQuestionIds, contains(1));
    expect(result.canReview, isFalse);
  });

  test('hidden required question does not block review', () {
    // Q1=A => Q2 (required, condicional) fica oculta e nao deve bloquear.
    final result = _preparer().prepare(formId: 50, targetId: 341, answers: {1: 'A'});
    expect(result.missingRequiredQuestionIds, isEmpty);
    expect(result.visibleQuestionIds, isNot(contains(2)));
    expect(result.canReview, isTrue);
  });

  test('conditional required question blocks when it becomes visible', () {
    // Q1=B revela Q2 (required) que esta vazia.
    final result = _preparer().prepare(formId: 50, targetId: 341, answers: {1: 'B'});
    expect(result.visibleQuestionIds, contains(2));
    expect(result.missingRequiredQuestionIds, contains(2));
    expect(result.canReview, isFalse);
  });

  test('derives category 151 and entity 58 from the selected target', () {
    final result = _preparer().prepare(formId: 50, targetId: 341, answers: {1: 'A'});
    expect(result.categoryId, 151);
    expect(result.entityId, 58);
  });

  test('file answers are tracked separately and excluded from payload', () {
    final result = _preparer().prepare(formId: 50, targetId: 341, answers: {
      1: 'A',
      3: {'name': 'foto.jpg', 'bytes': 'AAAA'},
    });
    expect(result.fileQuestionIds, contains(3));
    final payload = result.toFormCreatorInput();
    expect(payload['plugin_formcreator_forms_id'], 50);
    expect(payload['add'], '1');
    expect(payload['formcreator_field_1'], 'A');
    expect(payload.containsKey('formcreator_field_3'), isFalse);
  });

  test('rejects target that does not belong to the form', () {
    expect(
      () => _preparer().prepare(formId: 49, targetId: 341, answers: {}),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => _preparer().prepare(formId: 50, targetId: 999, answers: {}),
      throwsA(isA<ArgumentError>()),
    );
  });
}
