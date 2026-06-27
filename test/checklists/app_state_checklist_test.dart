import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';
import 'package:sis_mobile_flutter/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('catalog is null before loading', () {
    final appState = AppState(GlpiClient());
    expect(appState.checklistCatalog, isNull);
    expect(appState.checklistCatalogError, isNull);
  });

  test('loadChecklistCatalog loads 5 forms from embedded asset', () async {
    final appState = AppState(GlpiClient());
    await appState.loadChecklistCatalog();

    expect(appState.checklistCatalog, isNotNull);
    expect(appState.checklistCatalog!.forms, hasLength(5));
    expect(appState.checklistCatalogError, isNull);
  });

  test('catalog targets total 18 across all 5 forms', () async {
    final appState = AppState(GlpiClient());
    await appState.loadChecklistCatalog();

    final catalog = appState.checklistCatalog!;
    final totalTargets = catalog.forms.fold<int>(
      0,
      (sum, form) => sum + catalog.targetsForForm(form.id).length,
    );
    expect(totalTargets, 18);
    expect(catalog.targetById(369)?.name, 'HIDRÁULICO 951');
  });

  test('Super-Admin (profile 4) sees all 5 forms', () async {
    final appState = AppState(GlpiClient());
    await appState.loadChecklistCatalog();

    final visible = appState.checklistCatalog!.formsVisibleToProfile(4);
    expect(visible, hasLength(5));
  });

  test('Solicitante (profile 9) sees no checklist forms', () async {
    final appState = AppState(GlpiClient());
    await appState.loadChecklistCatalog();

    final visible = appState.checklistCatalog!.formsVisibleToProfile(9);
    expect(visible, isEmpty);
  });
}
