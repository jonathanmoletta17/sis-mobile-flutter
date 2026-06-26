import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_catalog.dart';

void main() {
  late SisChecklistCatalog catalog;

  setUpAll(() {
    final raw = File(
      'test/fixtures/sis_checklists_catalog.json',
    ).readAsStringSync();
    catalog = SisChecklistCatalog.fromJson(raw);
  });

  test('parses generated SIS checklist catalog', () {
    expect(
      catalog.forms.map((form) => form.id),
      containsAll(<int>[48, 49, 50, 51, 52]),
    );
    expect(catalog.targets, hasLength(17));
    expect(catalog.questions, hasLength(1252));
    expect(catalog.formById(52)!.name, 'CHECKLIST ILUMINAÇÃO');
    expect(
      catalog.targetsForForm(50).map((target) => target.id),
      containsAll(<int>[341, 342, 343, 344, 350]),
    );
  });

  test('carries GLPI profile gate (formcreator_forms_profiles) per form', () {
    for (final form in catalog.forms) {
      expect(form.profileIds, <int>[
        4,
      ], reason: 'form ${form.id} deve ser so Super-Admin hoje');
      expect(form.isVisibleToProfile(4), isTrue);
      // perfil 11 sem grupo 22 nao ve os checklists (gate OR: precisa de perfil OU grupo)
      expect(
        form.isVisibleToProfile(11),
        isFalse,
        reason: 'perfil 11 sem grupo nao ve',
      );
      expect(form.isVisibleToProfile(null), isFalse);
    }
  });

  test('carries GLPI group gate (PluginFormcreatorForm_Group) per form', () {
    for (final form in catalog.forms) {
      expect(form.groupIds, <int>[
        22,
      ], reason: 'form ${form.id} deve ter grupo CC-MANUTENCAO (22)');
    }
  });

  test('formsVisibleToUser: OR semantico entre perfil e grupo', () {
    // Super-Admin (profile 4) ve por perfil, independente de grupos
    expect(catalog.formsVisibleToUser(4, const []), hasLength(5));
    // Operador de Manutencao e Conservacao (profile 11) ve por grupo 22
    expect(catalog.formsVisibleToUser(11, const [22]), hasLength(5));
    // Perfil sem acesso, grupo sem acesso => nenhum form
    expect(catalog.formsVisibleToUser(11, const []), isEmpty);
    // Sem perfil mas com grupo 22 => ve os forms (e.g. usuario sem perfil ativo)
    expect(catalog.formsVisibleToUser(null, const [22]), hasLength(5));
    // Sem perfil e sem grupos => nada
    expect(catalog.formsVisibleToUser(null, const []), isEmpty);
    // Grupo irrelevante (ex: grupo 99) nao da acesso
    expect(catalog.formsVisibleToUser(11, const [99]), isEmpty);
  });

  test('derives checklist categories 148-152 from active targets', () {
    final categoryIds = catalog.targets
        .map((target) => target.categoryId)
        .toSet();
    expect(categoryIds, <int>{148, 149, 150, 151, 152});
    for (final target in catalog.targets) {
      expect(target.destinationEntityValue, 58);
    }
  });

  test('parses select option values', () {
    final checklistType = catalog.questions.firstWhere(
      (question) =>
          question.fieldType == 'select' && question.options.isNotEmpty,
    );
    expect(
      checklistType.options.map((option) => option.value),
      containsAll(<String>['CORRETIVA', 'PREVENTIVA']),
    );
  });

  test('rejects empty or invalid catalog', () {
    expect(() => SisChecklistCatalog.fromJson('{}'), throwsFormatException);
    expect(
      () => SisChecklistCatalog.fromJson('{"forms":[]}'),
      throwsFormatException,
    );
    expect(() => SisChecklistCatalog.fromJson('[]'), throwsFormatException);
  });
}
