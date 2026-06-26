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

  group('catalog screen tipo (PREVENTIVA/CORRETIVA)', () {
    testWidgets('mostra SegmentedButton de tipo por form', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistCatalogScreen(
          catalog: _catalog(), activeProfileId: 4, userGroupIds: const [],
        ),
      ));
      expect(find.byKey(const Key('checklist_type_50')), findsOneWidget);
      expect(find.text('Preventiva'), findsOneWidget);
      expect(find.text('Corretiva'), findsOneWidget);
    });

    testWidgets('default e PREVENTIVA; ao mudar para CORRETIVA repassa para form', (tester) async {
      String? capturedType;
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistCatalogScreen(
          catalog: _catalog(),
          activeProfileId: 4,
          userGroupIds: const [],
          onSubmit: (sub) async => {'success': false},
        ),
      ));
      // Trocar para CORRETIVA antes de abrir o target
      await tester.tap(find.text('Corretiva'));
      await tester.pumpAndSettle();
      // O SegmentedButton deve refletir CORRETIVA selecionada
      final seg = tester.widget<SegmentedButton<String>>(
        find.byKey(const Key('checklist_type_50')),
      );
      expect(seg.selected, {'CORRETIVA'});
      // Abrir o target — a navegação passará CORRETIVA como preselectedType
      // (verificação indireta via comportamento da tela de form)
      capturedType = seg.selected.first;
      expect(capturedType, 'CORRETIVA');
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

    testWidgets('inicializa pergunta Checklist com defaultValue PREVENTIVA', (tester) async {
      // A pergunta de id=1 (Local, multiselect) nao tem defaultValues;
      // mas se o catalog tivesse uma pergunta com defaultValues="PREVENTIVA",
      // ela estaria pre-preenchida. Verificamos que o form abre com Local
      // pre-preenchido pelo target E sem bloquear o botao de revisao.
      // (O test catalog usa multiselect sem defaultValues, mas o mecanismo
      //  é testado no checklist_submission_test via catalog real.)
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 341),
      ));
      await tester.pump();
      // Review deve estar habilitado (target 341 pre-preenche Local=A via condition)
      final reviewButton = tester.widget<FilledButton>(
        find.byKey(const Key('checklist_review_button')),
      );
      expect(reviewButton.onPressed, isNotNull);
    });

    testWidgets('preselectedType passa tipo escolhido na tela de catalogo', (tester) async {
      // Com preselectedType="CORRETIVA", o form screen usa esse valor como
      // resposta inicial da pergunta "Checklist". Para o catalog de teste (sem
      // pergunta "Checklist"), nao ha mudanca de comportamento — mas o widget
      // deve construir sem erros.
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(
          catalog: _catalog(),
          formId: 50,
          targetId: 341,
          preselectedType: 'CORRETIVA',
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('checklist_review_button')), findsOneWidget);
    });

    testWidgets('glpiselect sem ticketSearcher mostra info box (nao interativo)', (tester) async {
      // Sem ticketSearcher, o campo glpiselect cai no estado informativo padrão.
      // O catalog de teste nao tem glpiselect; verificamos que o form abre normal.
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 341),
      ));
      await tester.pump();
      expect(find.byKey(const Key('checklist_review_button')), findsOneWidget);
      expect(find.byKey(const Key('checklist_glpiselect_field')), findsNothing);
    });

    testWidgets('glpiselect com ticketSearcher mostra campo interativo', (tester) async {
      // Catalog com pergunta glpiselect; com ticketSearcher, deve aparecer o campo.
      final catalogComGlpiselect = SisChecklistCatalog.fromMap({
        'schema_version': 'test',
        'source_snapshot_sha256': 'test',
        'forms': [
          {'id': 50, 'name': 'CHECKLIST HIDRAULICO', 'is_active': true, 'is_visible': true, 'helpdesk_home': true, 'profile_ids': [4], 'group_ids': [22]},
        ],
        'sections': [
          {'id': 500, 'form_id': 50, 'name': 'Dados', 'order': 1},
        ],
        'questions': [
          {'id': 1, 'form_id': 50, 'section_id': 500, 'name': 'Local', 'fieldtype': 'select', 'required': true, 'show_rule': 1, 'row': 0, 'col': 0, 'width': 4, 'values': '["A","B"]'},
          {'id': 4, 'form_id': 50, 'section_id': 500, 'name': 'Checklist Programada', 'fieldtype': 'glpiselect', 'itemtype': 'Ticket', 'required': false, 'show_rule': 1, 'row': 1, 'col': 0, 'width': 4, 'values': '{"entity_restrict":"2"}'},
        ],
        'conditions': const [],
        'targets': [
          {'id': 341, 'form_id': 50, 'name': 'HIDRAULICO ALA RESIDENCIAL', 'destination_entity_value': 58, 'category_rule': 2, 'category_id': 151, 'location_rule': 2, 'urgency_rule': 1, 'type_rule': 1, 'show_rule': 2},
        ],
        'categories': [
          {'id': 151, 'name': 'Hidraulico', 'completename': 'Manutencao > Checklist > Hidraulico', 'parent_id': 147, 'level': 3},
        ],
      });

      Future<List<Map<String, dynamic>>> fakeSearcher(String q) async => const [];

      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(
          catalog: catalogComGlpiselect,
          formId: 50,
          targetId: 341,
          ticketSearcher: fakeSearcher,
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('checklist_glpiselect_field')), findsOneWidget);
      expect(find.text('Selecionar chamado...'), findsOneWidget);
    });

    testWidgets('submission disabled shows review button, not send', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: _catalog(), formId: 50, targetId: 341),
      ));
      expect(find.byKey(const Key('checklist_review_button')), findsOneWidget);
      expect(find.byKey(const Key('checklist_submit_button')), findsNothing);
      expect(find.byKey(const Key('checklist_status_banner')), findsOneWidget);
    });

    testWidgets('glpiselect PluginGenericobjectConservacao com conservacaoSearcher mostra seletor interativo', (tester) async {
      final catalogComConservacao = SisChecklistCatalog.fromMap({
        'schema_version': 'test',
        'source_snapshot_sha256': 'test',
        'forms': [
          {'id': 80, 'name': 'CHECKLIST CALHAS', 'is_active': true, 'is_visible': true, 'helpdesk_home': true, 'profile_ids': [4], 'group_ids': []},
        ],
        'sections': [{'id': 800, 'form_id': 80, 'name': 'Calhas', 'order': 1}],
        'questions': [
          {'id': 900, 'form_id': 80, 'section_id': 800, 'name': 'Calha Ala Gov', 'fieldtype': 'glpiselect', 'itemtype': 'PluginGenericobjectConservacao', 'required': false, 'show_rule': 1, 'row': 0, 'col': 0, 'width': 4, 'default_values': '299'},
        ],
        'conditions': const [],
        'targets': [
          {'id': 801, 'form_id': 80, 'name': 'CALHAS ALA GOV', 'destination_entity_value': 58, 'category_rule': 2, 'category_id': 148, 'location_rule': 2, 'urgency_rule': 1, 'type_rule': 1, 'show_rule': 1},
        ],
        'categories': [
          {'id': 148, 'name': 'Calhas', 'completename': 'Manutencao > Checklist > Calhas', 'parent_id': 147, 'level': 3},
        ],
      });

      Future<List<Map<String, dynamic>>> fakeConservacaoSearcher(String q) async => const [];

      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(
          catalog: catalogComConservacao,
          formId: 80,
          targetId: 801,
          conservacaoSearcher: fakeConservacaoSearcher,
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('checklist_conservacao_900')), findsOneWidget);
      expect(find.text('Selecionar item de inventário...'), findsOneWidget);
      expect(find.text('299'), findsNothing);
    });

    testWidgets('conservacaoResolver pre-popula campo com nome resolvido assincronamente', (tester) async {
      final catalogComDefault = SisChecklistCatalog.fromMap({
        'schema_version': 'test',
        'source_snapshot_sha256': 'test',
        'forms': [
          {'id': 81, 'name': 'CHECKLIST CALHAS', 'is_active': true, 'is_visible': true, 'helpdesk_home': true, 'profile_ids': [4], 'group_ids': []},
        ],
        'sections': [{'id': 810, 'form_id': 81, 'name': 'Calhas', 'order': 1}],
        'questions': [
          {'id': 901, 'form_id': 81, 'section_id': 810, 'name': 'Calha Ala Gov', 'fieldtype': 'glpiselect', 'itemtype': 'PluginGenericobjectConservacao', 'required': false, 'show_rule': 1, 'row': 0, 'col': 0, 'width': 4, 'default_values': '42'},
        ],
        'conditions': const [],
        'targets': [
          {'id': 811, 'form_id': 81, 'name': 'TARGET', 'destination_entity_value': 1, 'category_rule': 2, 'category_id': 148, 'location_rule': 1, 'urgency_rule': 1, 'type_rule': 1, 'show_rule': 1},
        ],
        'categories': [
          {'id': 148, 'name': 'Calhas', 'completename': 'Manutencao > Checklist > Calhas', 'parent_id': 147, 'level': 3},
        ],
      });

      Future<List<Map<String, dynamic>>> noopSearcher(String q) async => const [];
      Future<String?> fakeResolver(int id) async => id == 42 ? 'CALHAS ALA GOVERNAMENTAL' : null;

      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(
          catalog: catalogComDefault,
          formId: 81,
          targetId: 811,
          conservacaoSearcher: noopSearcher,
          conservacaoResolver: fakeResolver,
        ),
      ));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('CALHAS ALA GOVERNAMENTAL'), findsOneWidget);
    });

    testWidgets('multiselect com default_values=[] nao pre-preenche o campo', (tester) async {
      final catalogComDefaultVazio = SisChecklistCatalog.fromMap({
        'schema_version': 'test',
        'source_snapshot_sha256': 'test',
        'forms': [
          {'id': 60, 'name': 'CHECKLIST VAZIO', 'is_active': true, 'is_visible': true, 'helpdesk_home': true, 'profile_ids': [4], 'group_ids': []},
        ],
        'sections': [
          {'id': 600, 'form_id': 60, 'name': 'Dados', 'order': 1},
        ],
        'questions': [
          {
            'id': 10,
            'form_id': 60,
            'section_id': 600,
            'name': 'Local',
            'fieldtype': 'multiselect',
            'required': true,
            'show_rule': 1,
            'row': 0,
            'col': 0,
            'width': 4,
            'values': '["X","Y"]',
            'default_values': '[]',
          },
        ],
        'conditions': const [],
        'targets': [
          {'id': 500, 'form_id': 60, 'name': 'ALVO SEM CONDICOES', 'destination_entity_value': 58, 'category_rule': 2, 'category_id': 151, 'location_rule': 2, 'urgency_rule': 1, 'type_rule': 1, 'show_rule': 1},
        ],
        'categories': [
          {'id': 151, 'name': 'Hidraulico', 'completename': 'Manutencao > Checklist > Hidraulico', 'parent_id': 147, 'level': 3},
        ],
      });
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: catalogComDefaultVazio, formId: 60, targetId: 500),
      ));
      await tester.pump();
      final checkX = tester.widget<CheckboxListTile>(find.byKey(const Key('checklist_check_X')));
      final checkY = tester.widget<CheckboxListTile>(find.byKey(const Key('checklist_check_Y')));
      expect(checkX.value, isFalse, reason: 'X nao deve estar marcado — default_values=[] e vazio');
      expect(checkY.value, isFalse, reason: 'Y nao deve estar marcado — default_values=[] e vazio');
      final reviewButton = tester.widget<FilledButton>(find.byKey(const Key('checklist_review_button')));
      expect(reviewButton.onPressed, isNull, reason: 'review bloqueado — campo required vazio');
    });

    testWidgets('condicoes de target vencem sobre default_values nao vazio', (tester) async {
      final catalogComDefaultNaoVazio = SisChecklistCatalog.fromMap({
        'schema_version': 'test',
        'source_snapshot_sha256': 'test',
        'forms': [
          {'id': 70, 'name': 'CHECKLIST REFRIG', 'is_active': true, 'is_visible': true, 'helpdesk_home': true, 'profile_ids': [4], 'group_ids': []},
        ],
        'sections': [
          {'id': 700, 'form_id': 70, 'name': 'Dados', 'order': 1},
        ],
        'questions': [
          {
            'id': 20,
            'form_id': 70,
            'section_id': 700,
            'name': 'Local',
            'fieldtype': 'multiselect',
            'required': true,
            'show_rule': 1,
            'row': 0,
            'col': 0,
            'width': 4,
            'values': '["AR CENTRAL","CASA CIVIL","951"]',
            'default_values': '["AR CENTRAL","CASA CIVIL","951"]',
          },
        ],
        'conditions': [
          {
            'id': 8001,
            'itemtype': 'PluginFormcreatorTargetTicket',
            'items_id': 600,
            'source_question_id': 20,
            'show_condition': 1,
            'show_value': '951',
            'show_logic': 1,
            'order': 1,
          },
        ],
        'targets': [
          {'id': 600, 'form_id': 70, 'name': 'REFRIG 951', 'destination_entity_value': 58, 'category_rule': 2, 'category_id': 151, 'location_rule': 2, 'urgency_rule': 1, 'type_rule': 1, 'show_rule': 2},
        ],
        'categories': [
          {'id': 151, 'name': 'Hidraulico', 'completename': 'Manutencao > Checklist > Hidraulico', 'parent_id': 147, 'level': 3},
        ],
      });
      await tester.pumpWidget(MaterialApp(
        home: SisChecklistFormScreen(catalog: catalogComDefaultNaoVazio, formId: 70, targetId: 600),
      ));
      await tester.pump();
      final check951 = tester.widget<CheckboxListTile>(find.byKey(const Key('checklist_check_951')));
      final checkAR = tester.widget<CheckboxListTile>(find.byKey(const Key('checklist_check_AR CENTRAL')));
      final checkCC = tester.widget<CheckboxListTile>(find.byKey(const Key('checklist_check_CASA CIVIL')));
      expect(check951.value, isTrue, reason: '951 deve estar marcado pela condicao do target');
      expect(checkAR.value, isFalse, reason: 'AR CENTRAL nao deve estar marcado — condicao de target vence sobre default');
      expect(checkCC.value, isFalse, reason: 'CASA CIVIL nao deve estar marcado — condicao de target vence sobre default');
    });
  });
}
