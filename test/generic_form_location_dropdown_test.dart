import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/catalog/service_catalog_repository.dart';
import 'package:sis_mobile_flutter/data/service_data.dart';
import 'package:sis_mobile_flutter/screens/generic_form_screen.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';
import 'package:sis_mobile_flutter/widgets/custom_dropdown_field.dart';
import 'package:sis_mobile_flutter/widgets/searchable_select_field.dart';

void main() {
  const runtimeCatalogJson = '''
{
  "consumer": "sis-mobile-flutter",
  "instance": "sis",
  "snapshot_hash": "runtime-hash",
  "etag": "runtime-etag",
  "services": [
    {
      "service_id": "carregadores",
      "label": "Carregadores",
      "category_id": 55,
      "category_label": "Conservação > Carregadores",
      "expected_assignment_group_label": "CC-CONSERVACÃO",
      "ui_schema_source": "formcreator_runtime_metadata",
      "canonical_form_status": "ambiguous",
      "ui_schema": {
        "location_question": {
          "id": 20,
          "root_id": 36,
          "options": [
            {"id": 45, "label": "Ala Residencial", "full_label": "Carregadores e Mensageiros > Ala Residencial"},
            {"id": 52, "label": "CAFF", "full_label": "Carregadores e Mensageiros > CAFF"},
            {"id": 37, "label": "Casa Civil 1005", "full_label": "Carregadores e Mensageiros > Casa Civil 1005"}
          ]
        },
        "type_question": {
          "options": [
            {"id": 56, "label": "Movimentação de Insumos"},
            {"id": 57, "label": "Recolhimento"}
          ]
        }
      }
    }
  ]
}
''';

  testWidgets(
    'GenericFormScreen location dropdown uses runtime labels, not Root fallback',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        runtimeCatalogJson,
        staticFallback: serviceCategories,
      );
      final service = repository.findByName('Carregadores')!;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(GlpiClient()),
          child: MaterialApp(home: GenericFormScreen(service: service)),
        ),
      );
      await tester.pumpAndSettle();

      final locationPicker = tester.widget<SearchableSelectField>(
        find.byWidgetPredicate(
          (widget) =>
              widget is SearchableSelectField && widget.label == 'Localização',
        ),
      );

      expect(locationPicker.items, hasLength(3));
      expect(
        locationPicker.items,
        contains('Carregadores e Mensageiros > Ala Residencial'),
      );
      expect(
        locationPicker.items,
        contains('Carregadores e Mensageiros > CAFF'),
      );
      expect(
        locationPicker.items.any((item) => item.contains('Root')),
        isFalse,
      );
      expect(
        locationPicker.items.any((item) => item.startsWith('Local (')),
        isFalse,
      );
    },
  );

  testWidgets(
    'GenericFormScreen renders Localização as searchable picker without changing other dropdowns',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
        runtimeCatalogJson,
        staticFallback: serviceCategories,
      );
      final service = repository.findByName('Carregadores')!;

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => AppState(GlpiClient()),
          child: MaterialApp(home: GenericFormScreen(service: service)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Buscar localização'), findsOneWidget);
      expect(find.text('Selecione uma localização'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomDropdownField && widget.label == 'Localização',
        ),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CustomDropdownField &&
              widget.label == 'Tipo de serviço',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('GenericFormScreen location picker filters and selects by text', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = ServiceCatalogRepository.fromRuntimeCatalogJson(
      runtimeCatalogJson,
      staticFallback: serviceCategories,
    );
    final service = repository.findByName('Carregadores')!;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(GlpiClient()),
        child: MaterialApp(home: GenericFormScreen(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Buscar localização'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Buscar localização',
      ),
      'CAFF',
    );
    await tester.pumpAndSettle();

    expect(find.text('Carregadores e Mensageiros > CAFF'), findsOneWidget);
    expect(
      find.text('Carregadores e Mensageiros > Ala Residencial'),
      findsNothing,
    );

    await tester.tap(find.text('Carregadores e Mensageiros > CAFF'));
    await tester.pumpAndSettle();

    expect(find.text('Carregadores e Mensageiros > CAFF'), findsOneWidget);
  });
}
