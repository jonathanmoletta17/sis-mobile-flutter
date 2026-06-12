import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/data/service_data.dart';

void main() {
  test('resolve ids from canonical service names', () {
    expect(resolveServiceCategoryId('Carregadores'), 55);
    expect(resolveServiceCategoryId('Projeto'), 144);
    expect(resolveServiceCategoryId('Vidracaria'), 94);
  });

  test('unknown category is not silently mapped to Ar-Condicionado', () {
    expect(tryResolveServiceCategoryId('Categoria inexistente'), isNull);
    expect(
      () => resolveServiceCategoryId('Categoria inexistente'),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('normalizes GLPI category labels to catalog names', () {
    expect(
      normalizeServiceCategoryLabel('Conservacao > Carregadores'),
      'Carregadores',
    );
    expect(
      normalizeServiceCategoryLabel({
        'completename': 'Infraestrutura > Tecnico de Redes',
      }),
      'Tecnico de Redes',
    );
    expect(normalizeServiceCategoryLabel('Ar condicionado'), 'Ar-Condicionado');
  });

  test('static location labels hide Root metadata while preserving ids', () {
    final carregadores = findServiceCategoryByName('Carregadores')!;

    expect(
      carregadores.displayLocations.any((label) => label.contains('Root')),
      isFalse,
    );
    expect(carregadores.effectiveLocationOptions, isNotEmpty);
    expect(carregadores.effectiveLocationOptions.first.id, greaterThan(0));
    expect(
      carregadores.effectiveLocationOptions.first.label.contains('Root'),
      isFalse,
    );
  });

  test('location display labels keep GLPI context and room code', () {
    const option = LocationOption(
      id: 283,
      label: 'P01S08-A',
      fullLabel: 'Locais > Casa Civil 1005 > 1° Andar > P01S08 > P01S08-A',
      rootId: 70,
      sourceQuestionId: 573,
    );

    expect(option.label, 'P01S08-A');
    expect(
      option.displayLabel,
      'Casa Civil 1005 > 1° Andar > P01S08 > P01S08-A',
    );
    expect(option.toPayload()['id'], 283);
    expect(
      option.toPayload()['full_label'],
      'Locais > Casa Civil 1005 > 1° Andar > P01S08 > P01S08-A',
    );
  });

  test('exposes extra field config only for matching services', () {
    final projeto = findServiceCategoryByName('Projeto');
    final vidracaria = findServiceCategoryByName('Vidracaria');
    final limpeza = findServiceCategoryByName('Limpeza');

    expect(projeto, isNotNull);
    expect(projeto!.hasExtraField, isTrue);
    expect(projeto.extraFieldLabel, 'Divisao / Departamento');

    expect(vidracaria, isNotNull);
    expect(vidracaria!.hasExtraField, isTrue);
    expect(vidracaria.extraFieldLabel, 'Tipo de Atendimento');

    expect(limpeza, isNotNull);
    expect(limpeza!.hasExtraField, isFalse);
  });
}
