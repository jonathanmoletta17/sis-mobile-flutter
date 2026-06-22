import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';
import 'package:sis_mobile_flutter/checklists/screens/sis_checklist_catalog_screen.dart';
import 'package:sis_mobile_flutter/checklists/screens/sis_checklist_form_screen.dart';

SisChecklistCatalog _catalog() {
  return SisChecklistCatalog.fromMap({
    'schema_version': 'test',
    'source_snapshot_sha256': 'test',
    'forms': [
      {
        'id': 50,
        'name': 'CHECKLIST HIDRAULICO',
        'is_active': true,
        'is_visible': true,
        'helpdesk_home': true,
        'profile_ids': [4],
        'group_ids': [22],
      },
    ],
    'sections': [
      {'id': 500, 'form_id': 50, 'name': 'Dados', 'order': 1},
    ],
    'questions': [
      {
        'id': 1,
        'form_id': 50,
        'section_id': 500,
        'name': 'Local',
        'fieldtype': 'multiselect',
        'required': true,
        'show_rule': 1,
        'row': 0,
        'col': 0,
        'width': 4,
        'values': '["A","B"]',
      },
      {
        'id': 2,
        'form_id': 50,
        'section_id': 500,
        'name': 'Detalhe',
        'fieldtype': 'textarea',
        'required': true,
        'show_rule': 2,
        'row': 1,
        'col': 0,
        'width': 4,
      },
    ],
    'conditions': [
      {
        'id': 9001,
        'itemtype': 'PluginFormcreatorQuestion',
        'items_id': 2,
        'source_question_id': 1,
        'show_condition': 1,
        'show_value': 'B',
        'show_logic': 1,
        'order': 1,
      },
      {
        'id': 9002,
        'itemtype': 'PluginFormcreatorTargetTicket',
        'items_id': 341,
        'source_question_id': 1,
        'show_condition': 1,
        'show_value': 'A',
        'show_logic': 1,
        'order': 1,
      },
    ],
    'targets': [
      {
        'id': 341,
        'form_id': 50,
        'name': 'HIDRAULICO ALA RESIDENCIAL',
        'destination_entity_value': 58,
        'category_rule': 2,
        'category_id': 151,
        'location_rule': 2,
        'urgency_rule': 1,
        'type_rule': 1,
        'show_rule': 2,
      },
      // Target sem condicoes: nenhum pre-fill, form inicia bloqueado se campo obrigatorio vazio.
      {
        'id': 342,
        'form_id': 50,
        'name': 'HIDRAULICO GERAL',
        'destination_entity_value': 58,
        'category_rule': 2,
        'category_id': 151,
        'location_rule': 2,
        'urgency_rule': 1,
        'type_rule': 1,
        'show_rule': 2,
      },
    ],
    'categories': [
      {
        'id': 151,
        'name': 'Hidraulico',
        'completename': 'Manutencao > Checklist > Hidraulico',
        'parent_id': 147,
        'level': 3,
      },
    ],
  });
}

void main() {
  group('catalog screen gate (perfil OR grupo)', () {
    testWidgets('Super-Admin (profile 4) ve via profile_ids', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistCatalogScreen(
            catalog: _catalog(), activeProfileId: 4, userGroupIds: const []),
      ));
      expect(find.byKey(const Key('checklist_target_341')), findsOneWidget);
      expect(find.byKey(const Key('checklist_empty_state')), findsNothing);
    });

    testWidgets('Operador Manutencao (profile 11 + grupo 22) ve via group_ids', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistCatalogScreen(
            catalog: _catalog(), activeProfileId: 11, userGroupIds: const [22]),
      ));
      expect(find.byKey(const Key('checklist_target_341')), findsOneWidget);
      expect(find.byKey(const Key('checklist_empty_state')), findsNothing);
    });

    testWidgets('perfil 11 sem grupo 22 ve estado vazio', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistCatalogScreen(
            catalog: _catalog(), activeProfileId: 11, userGroupIds: const []),
      ));
      expect(find.byKey(const Key('checklist_target_341')), findsNothing);
      expect(find.byKey(const Key('checklist_empty_state')), findsOneWidget);
    });

    testWidgets('null profile mas com grupo 22 ve os forms', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistCatalogScreen(
            catalog: _catalog(), activeProfileId: null, userGroupIds: const [22]),
      ));
      expect(find.byKey(const Key('checklist_target_341')), findsOneWidget);
    });

    testWidgets('null profile sem grupos ve estado vazio', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistCatalogScreen(catalog: _catalog(), activeProfileId: null),
      ));
      expect(find.byKey(const Key('checklist_empty_state')), findsOneWidget);
    });
  });

  group('form screen', () {
    testWidgets('allows review when target pre-fills required field and conditional is hidden', (tester) async {
      // target 341 pre-preenche Local=A; detalhe (required) so mostra com Local=B
      // portanto nao ha required visivel vazio -> review habilitado
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 341),
      ));
      await tester.pump();
      final reviewButton = tester.widget<FilledButton>(
        find.byKey(const Key('checklist_review_button')),
      );
      expect(reviewButton.onPressed, isNotNull, reason: 'review enabled quando required visivel preenchida');
      expect(find.text('Detalhe'), findsNothing, reason: 'campo condicional oculto inicialmente');
    });

    testWidgets('blocks review when required visible field is empty', (tester) async {
      // target 342 nao tem condicoes -> nenhum pre-fill -> Local fica vazio -> form bloqueado
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 342),
      ));
      await tester.pump();
      final reviewButton = tester.widget<FilledButton>(
        find.byKey(const Key('checklist_review_button')),
      );
      expect(reviewButton.onPressed, isNull, reason: 'review disabled com required visivel vazia');
    });

    testWidgets('pre-fill: target conditions pre-select Local=A via multiselect', (tester) async {
      // target 341 tem condicao: Local=A (source_question_id=1, show_value='A')
      // Ao abrir o form, o checkbox 'A' deve estar marcado automaticamente.
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 341),
      ));
      await tester.pump();
      final checkA = tester.widget<CheckboxListTile>(
        find.byKey(const Key('checklist_check_A')),
      );
      expect(checkA.value, isTrue, reason: 'Local=A deve vir pre-marcado pelo target 341');
      final checkB = tester.widget<CheckboxListTile>(
        find.byKey(const Key('checklist_check_B')),
      );
      expect(checkB.value, isFalse, reason: 'Local=B nao deve estar marcado');
    });

    testWidgets('selecting Local=B reveals the conditional required section', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 341),
      ));
      // Desmarcar A e marcar B
      await tester.tap(find.byKey(const Key('checklist_check_A')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('checklist_check_B')));
      await tester.pumpAndSettle();
      expect(find.text('Detalhe'), findsOneWidget);
    });

    testWidgets('submission disabled shows review button, not send', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 341),
      ));
      expect(find.byKey(const Key('checklist_review_button')), findsOneWidget);
      expect(find.byKey(const Key('checklist_submit_button')), findsNothing);
      expect(find.byKey(const Key('checklist_status_banner')), findsOneWidget);
    });
  });
}
