import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/catalog/governed_service_catalog.dart';
import 'package:sis_mobile_flutter/catalog/governed_submission_contract.dart';

void main() {
  GovernedServiceRecord record({
    required String id,
    required String profile,
    required String audience,
    int destinationValue = 28,
  }) {
    return GovernedServiceRecord(
      catalogRecordId: id,
      serviceId: 'pintura',
      serviceLabel: 'Pintura',
      profileVisibility: [GovernedProfile(name: profile)],
      formId: 1,
      targetTicketId: 1,
      audience: audience,
      destinationEntityMode: audience == 'para_terceiro'
          ? 'third_party_question'
          : 'requester_context_para_mim',
      destinationEntityValue: destinationValue,
      expectedBaseTaskTemplates: const [],
      readbackContract: const [],
    );
  }

  final records = [
    record(
      id: 'solicitante:para-mim',
      profile: 'Solicitante',
      audience: 'para_mim',
    ),
    record(
      id: 'solicitante:para-terceiro',
      profile: 'Solicitante',
      audience: 'para_terceiro',
      destinationValue: 371,
    ),
    record(
      id: 'gg:para-mim',
      profile: 'Solicitante-GG-Conservação',
      audience: 'para_mim',
      destinationValue: 58,
    ),
    record(
      id: 'super-admin:para-mim',
      profile: 'Super-Admin',
      audience: 'para_mim',
      destinationValue: 58,
    ),
  ];

  group('third-party visibility from governed catalog', () {
    test('Solicitante habilita Para outra Pessoa quando ha para_terceiro', () {
      expect(
        GovernedSubmissionResolver.hasThirdPartyOption(
          records: records,
          profileName: 'Solicitante',
        ),
        isTrue,
      );
    });

    test('GG desabilita Para outra Pessoa quando nao ha para_terceiro', () {
      expect(
        GovernedSubmissionResolver.hasThirdPartyOption(
          records: records,
          profileName: 'Solicitante-GG-Conservação',
        ),
        isFalse,
      );
    });

    test(
      'Super-Admin desabilita Para outra Pessoa quando nao ha para_terceiro',
      () {
        expect(
          GovernedSubmissionResolver.hasThirdPartyOption(
            records: records,
            profileName: 'Super-Admin',
          ),
          isFalse,
        );
      },
    );
  });
}
