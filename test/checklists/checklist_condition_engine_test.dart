import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';
import 'package:sis_mobile_flutter/checklists/checklist_condition_engine.dart';

/// Catalogo sintetico minimo para exercitar a engine de condicoes com controle
/// total dos valores. Form 1, secao 10, perguntas variadas.
SisChecklistCatalog _catalog({
  required List<Map<String, dynamic>> questions,
  List<Map<String, dynamic>> conditions = const [],
  List<Map<String, dynamic>> targets = const [],
  int sectionShowRule = 1,
}) {
  return SisChecklistCatalog.fromMap({
    'schema_version': 'test',
    'source_snapshot_sha256': 'test',
    'forms': [
      {
        'id': 1,
        'name': 'F',
        'is_active': true,
        'is_visible': true,
        'helpdesk_home': true,
        'profile_ids': [4],
      },
    ],
    'sections': [
      {
        'id': 10,
        'form_id': 1,
        'name': 'S',
        'order': 1,
        'show_rule': sectionShowRule,
      },
    ],
    'questions': questions,
    'conditions': conditions,
    'targets': targets,
    'categories': const [],
  });
}

Map<String, dynamic> _q(
  int id, {
  int showRule = 1,
  String fieldtype = 'text',
}) => {
  'id': id,
  'form_id': 1,
  'section_id': 10,
  'name': 'Q$id',
  'fieldtype': fieldtype,
  'required': false,
  'show_rule': showRule,
  'row': id,
  'col': 0,
  'width': 4,
};

Map<String, dynamic> _cond(
  int itemId,
  int sourceQuestionId, {
  int showCondition = 1,
  String showValue = 'SIM',
  int showLogic = 1,
  int order = 1,
  String itemType = SisChecklistCondition.questionItemType,
}) => {
  'id': 9000 + itemId + order,
  'itemtype': itemType,
  'items_id': itemId,
  'source_question_id': sourceQuestionId,
  'show_condition': showCondition,
  'show_value': showValue,
  'show_logic': showLogic,
  'order': order,
};

void main() {
  test('show rule 1 is always visible', () {
    final catalog = _catalog(questions: [_q(1, showRule: 1)]);
    final engine = SisChecklistConditionEngine(catalog);
    final question = catalog.questions.first;
    expect(engine.isQuestionVisible(question, {}), isTrue);
    expect(engine.isQuestionVisible(question, {99: 'qualquer'}), isTrue);
  });

  test('show rule 2 is visible only when the condition matches', () {
    final catalog = _catalog(
      questions: [_q(1, showRule: 2)],
      conditions: [_cond(1, 99, showValue: 'SIM')],
    );
    final engine = SisChecklistConditionEngine(catalog);
    final question = catalog.questions.first;
    expect(engine.isQuestionVisible(question, {99: 'SIM'}), isTrue);
    expect(engine.isQuestionVisible(question, {99: 'NAO'}), isFalse);
    expect(engine.isQuestionVisible(question, {}), isFalse);
  });

  test('show rule 3 is hidden when the condition matches', () {
    final catalog = _catalog(
      questions: [_q(1, showRule: 3)],
      conditions: [_cond(1, 99, showValue: 'SIM')],
    );
    final engine = SisChecklistConditionEngine(catalog);
    final question = catalog.questions.first;
    expect(engine.isQuestionVisible(question, {99: 'SIM'}), isFalse);
    expect(engine.isQuestionVisible(question, {99: 'NAO'}), isTrue);
  });

  test(
    'multiselect answer matches when any selected value equals expected',
    () {
      final catalog = _catalog(
        questions: [_q(1, showRule: 2)],
        conditions: [_cond(1, 99, showValue: 'B')],
      );
      final engine = SisChecklistConditionEngine(catalog);
      final question = catalog.questions.first;
      expect(
        engine.isQuestionVisible(question, {
          99: ['A', 'B', 'C'],
        }),
        isTrue,
      );
      expect(
        engine.isQuestionVisible(question, {
          99: ['A', 'C'],
        }),
        isFalse,
      );
    },
  );

  test('show_logic 1 is AND and 2 is OR', () {
    final andCatalog = _catalog(
      questions: [_q(1, showRule: 2)],
      conditions: [
        _cond(1, 98, showValue: 'X', showLogic: 1, order: 1),
        _cond(1, 99, showValue: 'Y', showLogic: 1, order: 2),
      ],
    );
    final andEngine = SisChecklistConditionEngine(andCatalog);
    final andQuestion = andCatalog.questions.first;
    expect(
      andEngine.isQuestionVisible(andQuestion, {98: 'X', 99: 'Y'}),
      isTrue,
    );
    expect(
      andEngine.isQuestionVisible(andQuestion, {98: 'X', 99: 'Z'}),
      isFalse,
    );

    final orCatalog = _catalog(
      questions: [_q(1, showRule: 2)],
      conditions: [
        _cond(1, 98, showValue: 'X', showLogic: 1, order: 1),
        _cond(1, 99, showValue: 'Y', showLogic: 2, order: 2),
      ],
    );
    final orEngine = SisChecklistConditionEngine(orCatalog);
    final orQuestion = orCatalog.questions.first;
    expect(orEngine.isQuestionVisible(orQuestion, {98: 'X', 99: 'Z'}), isTrue);
    expect(orEngine.isQuestionVisible(orQuestion, {98: 'W', 99: 'Z'}), isFalse);
  });

  test('show_condition 2 means not-equals', () {
    final catalog = _catalog(
      questions: [_q(1, showRule: 2)],
      conditions: [_cond(1, 99, showCondition: 2, showValue: 'OK')],
    );
    final engine = SisChecklistConditionEngine(catalog);
    final question = catalog.questions.first;
    expect(engine.isQuestionVisible(question, {99: 'FALHA'}), isTrue);
    expect(engine.isQuestionVisible(question, {99: 'OK'}), isFalse);
  });

  test(
    'section show rule 1 remains visible even when its condition does not match',
    () {
      final catalog = _catalog(
        sectionShowRule: 1,
        questions: [_q(1)],
        conditions: [
          _cond(
            10,
            99,
            showValue: 'SIM',
            itemType: SisChecklistCondition.sectionItemType,
          ),
        ],
      );
      final engine = SisChecklistConditionEngine(catalog);
      final section = catalog.sections.first;
      final question = catalog.questions.first;

      expect(engine.isSectionVisible(section, {99: 'NAO'}), isTrue);
      expect(engine.isQuestionVisible(question, {99: 'NAO'}), isTrue);
    },
  );

  test('section show rule 2 follows matching conditions', () {
    final catalog = _catalog(
      sectionShowRule: 2,
      questions: [_q(1)],
      conditions: [
        _cond(
          10,
          99,
          showValue: 'SIM',
          itemType: SisChecklistCondition.sectionItemType,
        ),
      ],
    );
    final engine = SisChecklistConditionEngine(catalog);
    final section = catalog.sections.first;

    expect(engine.isSectionVisible(section, {99: 'SIM'}), isTrue);
    expect(engine.isSectionVisible(section, {99: 'NAO'}), isFalse);
  });

  test('section show rule 1 remains visible without conditions', () {
    final catalog = _catalog(
      sectionShowRule: 1,
      questions: [_q(1)],
    );
    final engine = SisChecklistConditionEngine(catalog);
    final section = catalog.sections.first;

    expect(engine.isSectionVisible(section, {}), isTrue);
  });
}
