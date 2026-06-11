// LAB (read-only): valida servicesForProfile() do REPOSITÓRIO real sobre o
// catálogo governado produzido via API. Mostra quais serviços CADA perfil veria
// na tela de Serviços — em especial o Solicitante-GG-Conservação.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/service_catalog_repository.dart';

void main() {
  final fixture = File('test/lab_fixtures/sis-governed-catalog.runtime.json');
  if (!fixture.existsSync()) {
    // ignore: avoid_print
    print('SKIP: fixture ausente.');
    return;
  }
  final repo = ServiceCatalogRepository.fromRuntimeCatalogJson(
    fixture.readAsStringSync(),
  );

  List<String> namesFor(String profile) =>
      repo.servicesForProfile(profile).map((s) => s.name).toList()..sort();

  test('catálogo carregou como v2 (governado)', () {
    expect(
      repo.source,
      ServiceCatalogSource.runtimeCatalog,
      reason: 'se não for runtimeCatalog, servicesForProfile cai no fallback',
    );
  });

  for (final profile in const [
    'Solicitante',
    'Manutenção e Conservação',
    'Solicitante-GG-Conservação',
    'Super-Admin',
  ]) {
    test('servicesForProfile: $profile', () {
      final names = namesFor(profile);
      // ignore: avoid_print
      print('  [$profile] (${names.length}) -> $names');
      expect(names, isNotEmpty);
    });
  }

  test('GG-Conservação: 4 CARDS fiéis ao GLPI (decisão 2026-06-10)', () {
    final names = namesFor('Solicitante-GG-Conservação');
    expect(
      names.toSet(),
      <String>{'CONSERVAÇÃO', 'MANUTENÇÃO', 'Multiplas Demandas', 'Projeto'},
      reason: 'GG deve ver exatamente os 4 cards agregados, como no GLPI',
    );
    expect(
      names.contains('Ar-Condicionado'),
      isFalse,
      reason: 'GG não vê forms por-item; sub-serviços ficam DENTRO do card',
    );
  });

  test(
    'Super-Admin: CHECKLISTs exigem fluxo especializado e não viram cards',
    () {
      final names = namesFor('Super-Admin');
      final checklistNames = names
          .where((name) => name.trim().toUpperCase().startsWith('CHECKLIST'))
          .toList(growable: false);

      expect(
        checklistNames,
        isEmpty,
        reason:
            'formulários CHECKLIST têm perguntas especializadas e não podem usar o renderer genérico',
      );
    },
  );
}
