// LAB HARNESS (read-only): exercita o resolver REAL do app sobre o catalogo
// governado produzido via API, validando a matriz de comportamento esperado
// por perfil x servico x audiencia x contexto de entidade.
//
// NAO cria chamado, NAO acessa GLPI. Apenas logica pura de resolucao.
// Fixture: test/lab_fixtures/sis-governed-catalog.runtime.json (nao versionado).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_entity_resolver.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';
import 'package:sis_mobile_flutter/catalog/governed_submission_contract.dart';

String _norm(String v) => v
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[áàâãä]'), 'a')
    .replaceAll(RegExp(r'[éèêë]'), 'e')
    .replaceAll(RegExp(r'[íìîï]'), 'i')
    .replaceAll(RegExp(r'[óòôõö]'), 'o')
    .replaceAll(RegExp(r'[úùûü]'), 'u')
    .replaceAll('ç', 'c');

void main() {
  final fixture = File('test/lab_fixtures/sis-governed-catalog.runtime.json');
  if (!fixture.existsSync()) {
    // ignore: avoid_print
    print('SKIP: fixture do catalogo nao encontrada; rode o produtor por API.');
    return;
  }

  final catalog = GovernedServiceCatalog.fromJson(fixture.readAsStringSync());

  // registros de um servico (agrupado por service_label, como o app faz)
  List<GovernedServiceRecord> recordsFor(String serviceLabel) {
    final n = _norm(serviceLabel);
    return catalog.records
        .where((r) => _norm(r.serviceLabel) == n || _norm(r.serviceId) == n)
        .toList(growable: false);
  }

  GovernedSubmissionResolution resolve({
    required String service,
    required String profile,
    required GovernedTicketAudience audience,
    int? activeEntity,
    int? beneficiaryEntity,
    String? subService,
  }) {
    return GovernedSubmissionResolver.resolve(
      GovernedSubmissionInput(
        records: recordsFor(service),
        profileName: profile,
        audience: audience,
        selectedSubService: subService,
        entityContext: GovernedEntityContext(
          selectedTicketEntityId: activeEntity,
          activeEntityId: activeEntity,
          beneficiaryEntityId: beneficiaryEntity,
        ),
      ),
    );
  }

  void report(String title, GovernedSubmissionResolution r) {
    final out = r.ok
        ? 'entidade=${r.contract!.entityId} '
              'modo=${r.contract!.record.destinationEntityMode} '
              'form=${r.contract!.record.formId} target=${r.contract!.record.targetTicketId} '
              'grupo=${r.contract!.record.expectedAssignmentGroup?.label}'
        : 'BLOQUEADO: ${r.blocker}';
    // ignore: avoid_print
    print('  [$title] -> $out');
  }

  group(
    'CONTRASTE CENTRAL: mesma conta, muda o perfil (Pintura, para mim)',
    () {
      test(
        'Solicitante (entidade ativa 28) -> entidade do solicitante (28)',
        () {
          final r = resolve(
            service: 'Pintura',
            profile: 'Solicitante',
            audience: GovernedTicketAudience.paraMim,
            activeEntity: 28,
          );
          report('Pintura/Solicitante/paraMim/ativo=28', r);
          expect(r.ok, isTrue, reason: r.blocker);
          expect(r.contract!.entityId, 28);
          expect(r.contract!.record.destinationEntityCode, 2);
        },
      );

      test(
        'Manutencao (entidade ativa 1) -> entidade FIXA 24 (ignora sessao)',
        () {
          final r = resolve(
            service: 'Pintura',
            profile: 'Manutenção e Conservação',
            audience: GovernedTicketAudience.paraMim,
            activeEntity: 1,
          );
          report('Pintura/Manutencao/paraMim/ativo=1', r);
          expect(r.ok, isTrue, reason: r.blocker);
          expect(r.contract!.entityId, 24);
          expect(r.contract!.record.destinationEntityCode, 7);
        },
      );
    },
  );

  group('PARA TERCEIRO: entidade vem do beneficiario (modo 8)', () {
    test('Solicitante sem beneficiario -> BLOQUEIA (nao usa sessao)', () {
      final r = resolve(
        service: 'Pintura',
        profile: 'Solicitante',
        audience: GovernedTicketAudience.paraTerceiro,
        activeEntity: 28,
      );
      report('Pintura/Solicitante/paraTerceiro/sem-beneficiario', r);
      expect(r.ok, isFalse);
    });

    test('Solicitante com beneficiario(entidade 50) -> 50', () {
      final r = resolve(
        service: 'Pintura',
        profile: 'Solicitante',
        audience: GovernedTicketAudience.paraTerceiro,
        activeEntity: 28,
        beneficiaryEntity: 50,
      );
      report('Pintura/Solicitante/paraTerceiro/beneficiario=50', r);
      expect(r.ok, isTrue, reason: r.blocker);
      expect(r.contract!.entityId, 50);
      expect(r.contract!.record.destinationEntityCode, 8);
    });
  });

  group('Conservacao: Limpeza segue o mesmo padrao por perfil', () {
    test('Solicitante/paraMim/ativo=28 -> 28, grupo CC-CONSERVACAO', () {
      final r = resolve(
        service: 'Limpeza',
        profile: 'Solicitante',
        audience: GovernedTicketAudience.paraMim,
        activeEntity: 28,
      );
      report('Limpeza/Solicitante/paraMim/ativo=28', r);
      expect(r.ok, isTrue, reason: r.blocker);
      expect(r.contract!.entityId, 28);
    });

    test('Manutencao/paraMim/ativo=1 -> 24', () {
      final r = resolve(
        service: 'Limpeza',
        profile: 'Manutenção e Conservação',
        audience: GovernedTicketAudience.paraMim,
        activeEntity: 1,
      );
      report('Limpeza/Manutencao/paraMim/ativo=1', r);
      expect(r.ok, isTrue, reason: r.blocker);
      expect(r.contract!.entityId, 24);
    });
  });

  group('Ar-Condicionado (confirma o caso da tela / form 21 alvo 129)', () {
    test('Manutencao/paraMim -> entidade 24 via form 21', () {
      final r = resolve(
        service: 'Ar-Condicionado',
        profile: 'Manutenção e Conservação',
        audience: GovernedTicketAudience.paraMim,
        activeEntity: 1,
      );
      report('Ar-Condicionado/Manutencao/paraMim', r);
      expect(r.ok, isTrue, reason: r.blocker);
      expect(r.contract!.entityId, 24);
      expect(r.contract!.record.formId, 21);
      expect(r.contract!.record.targetTicketId, 129);
    });
  });

  group('PARTICULARIDADE GG: Solicitante-GG-Conservação usa forms agregados '
      '-> entidade FIXA 58', () {
    const ggProfile = 'Solicitante-GG-Conservação';

    test('INVARIANTE: todo record GG é modo 7 (fixa) e entidade 58', () {
      final ggRecords = catalog.records
          .where((r) => r.profileVisibility.any((p) => p.name == ggProfile))
          .toList(growable: false);
      // ignore: avoid_print
      print(
        '  [GG] records=${ggRecords.length} '
        'forms=${ggRecords.map((r) => r.formId).toSet().toList()..sort()}',
      );
      expect(ggRecords, isNotEmpty);
      for (final r in ggRecords) {
        expect(
          r.destinationEntityCode,
          7,
          reason: 'GG record ${r.catalogRecordId} deveria ser modo 7',
        );
        expect(
          r.destinationEntityValue,
          58,
          reason: 'GG record ${r.catalogRecordId} deveria resolver entidade 58',
        );
      }
    });

    // UX fiel ao GLPI (decisão 2026-06-10): GG vê 4 CARDS (CONSERVAÇÃO,
    // MANUTENÇÃO, Multiplas Demandas, Projeto). Dentro do card, o sub-serviço
    // é selecionado (selectedSubService) e resolve LIMPO -> 58.
    test('GG/MANUTENÇÃO + sub Pintura -> entidade 58 (form 39)', () {
      final r = resolve(
        service: 'MANUTENÇÃO',
        profile: ggProfile,
        audience: GovernedTicketAudience.paraMim,
        activeEntity: 1,
        subService: 'Pintura',
      );
      report('GG/MANUTENÇÃO/sub=Pintura', r);
      expect(r.ok, isTrue, reason: r.blocker);
      expect(r.contract!.entityId, 58);
      expect(r.contract!.record.formId, 39);
      expect(r.contract!.record.targetTicketId, 208);
    });

    test('GG/CONSERVAÇÃO + sub Limpeza -> entidade 58 (form 38)', () {
      final r = resolve(
        service: 'CONSERVAÇÃO',
        profile: ggProfile,
        audience: GovernedTicketAudience.paraMim,
        activeEntity: 1,
        subService: 'Limpeza',
      );
      report('GG/CONSERVAÇÃO/sub=Limpeza', r);
      expect(r.ok, isTrue, reason: r.blocker);
      expect(r.contract!.entityId, 58);
      expect(r.contract!.record.formId, 38);
      expect(r.contract!.record.targetTicketId, 200);
    });

    test('Card agregado SEM sub-serviço -> bloqueia pedindo seleção', () {
      final r = resolve(
        service: 'MANUTENÇÃO',
        profile: ggProfile,
        audience: GovernedTicketAudience.paraMim,
        activeEntity: 1,
      );
      report('GG/MANUTENÇÃO/sem-sub', r);
      expect(r.ok, isFalse);
      expect(r.blocker, contains('selecione o serviço'));
    });

    test('VARREDURA: todo sub-serviço dos 4 cards GG resolve -> 58', () {
      var checked = 0;
      final seen = <String>{};
      for (final rec in catalog.records) {
        if (!rec.profileVisibility.any((p) => p.name == ggProfile)) continue;
        final key = '${rec.serviceLabel}|${rec.subService}|${rec.audience}';
        if (!seen.add(key)) continue;
        if (rec.audience != 'para_mim') continue;
        final r = resolve(
          service: rec.serviceLabel,
          profile: ggProfile,
          audience: GovernedTicketAudience.paraMim,
          activeEntity: 1,
          subService: rec.subService,
        );
        expect(
          r.ok,
          isTrue,
          reason: '${rec.serviceLabel}/${rec.subService}: ${r.blocker}',
        );
        expect(
          r.contract!.entityId,
          58,
          reason: '${rec.serviceLabel}/${rec.subService} != 58',
        );
        checked++;
      }
      // ignore: avoid_print
      print('  [GG] sub-serviços validados -> 58: $checked');
      expect(checked, greaterThan(20));
    });

    test('VARREDURA actors: alvos GG carregam atores do catálogo', () {
      final ggRecords = catalog.records
          .where((r) => r.profileVisibility.any((p) => p.name == ggProfile))
          .toList(growable: false);
      final withActors = ggRecords.where((r) => r.actors.isNotEmpty).length;
      // ignore: avoid_print
      print('  [GG] records com actors: $withActors/${ggRecords.length}');
      expect(withActors, greaterThan(0));
    });
  });
}
