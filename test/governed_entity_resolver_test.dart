import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_entity_resolver.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';

void main() {
  GovernedServiceRecord record({required String mode, int? value, int? code}) {
    return GovernedServiceRecord(
      catalogRecordId: 'test:$mode',
      serviceId: 'teste',
      serviceLabel: 'Teste',
      profileVisibility: const [GovernedProfile(name: 'Solicitante')],
      formId: 1,
      targetTicketId: 1,
      audience: mode == 'third_party_question' ? 'para_terceiro' : 'para_mim',
      expectedBaseTaskTemplates: const [],
      readbackContract: const [],
      destinationEntityMode: mode,
      destinationEntityCode: code,
      destinationEntityValue: value,
    );
  }

  test(
    'requester_context_para_mim usa entidade selecionada/ativa do requester',
    () {
      final resolved = GovernedEntityResolver.resolve(
        record: record(mode: 'requester_context_para_mim', value: 0, code: 2),
        context: const GovernedEntityContext(
          selectedTicketEntityId: 24,
          activeEntityId: 58,
        ),
      );

      expect(resolved.ok, isTrue);
      expect(resolved.entityId, 24);
    },
  );

  test(
    'maintenance_context_para_mim prioriza destination_entity_value positivo',
    () {
      final resolved = GovernedEntityResolver.resolve(
        record: record(
          mode: 'maintenance_context_para_mim',
          value: 58,
          code: 7,
        ),
        context: const GovernedEntityContext(
          selectedTicketEntityId: 24,
          activeEntityId: 99,
        ),
      );

      expect(resolved.ok, isTrue);
      expect(resolved.entityId, 58);
    },
  );

  test(
    'third_party_question bloqueia quando beneficiario GLPI nao foi resolvido',
    () {
      final resolved = GovernedEntityResolver.resolve(
        record: record(mode: 'third_party_question', value: 371, code: 8),
        context: const GovernedEntityContext(
          selectedTicketEntityId: 24,
          activeEntityId: 58,
        ),
      );

      expect(resolved.ok, isFalse);
      expect(resolved.entityId, isNull);
      expect(
        resolved.blocker,
        contains('destination_entity_value=371 é id da pergunta'),
      );
    },
  );

  test(
    'third_party_question usa entidade do beneficiario quando ela existir',
    () {
      final resolved = GovernedEntityResolver.resolve(
        record: record(mode: 'third_party_question', value: 371, code: 8),
        context: const GovernedEntityContext(
          selectedTicketEntityId: 24,
          activeEntityId: 58,
          beneficiaryEntityId: 77,
        ),
      );

      expect(resolved.ok, isTrue);
      expect(resolved.entityId, 77);
    },
  );

  test(
    'fixed_or_direct usa valor direto quando positivo e bloqueia sem contexto',
    () {
      final direct = GovernedEntityResolver.resolve(
        record: record(mode: 'fixed_or_direct', value: 88, code: 1),
        context: const GovernedEntityContext(),
      );
      final blocked = GovernedEntityResolver.resolve(
        record: record(mode: 'fixed_or_direct', value: 0, code: 1),
        context: const GovernedEntityContext(),
      );

      expect(direct.ok, isTrue);
      expect(direct.entityId, 88);
      expect(blocked.ok, isFalse);
      expect(blocked.blocker, contains('fixed_or_direct'));
    },
  );

  test('modo desconhecido bloqueia explicitamente', () {
    final resolved = GovernedEntityResolver.resolve(
      record: record(mode: 'modo_novo_glpi', value: 88, code: 99),
      context: const GovernedEntityContext(selectedTicketEntityId: 24),
    );

    expect(resolved.ok, isFalse);
    expect(
      resolved.blocker,
      contains('modo de entidade governada desconhecido'),
    );
  });
}
