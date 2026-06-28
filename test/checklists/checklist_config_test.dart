import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/config/glpi_config.dart';

void main() {
  test('submission flag defaults to false when unset', () {
    dotenv.testLoad(mergeWith: const <String, String>{});
    expect(GlpiConfig.sisChecklistSubmissionEnabled, isFalse);
  });

  test('submission flag reads truthy values', () {
    dotenv.testLoad(
      mergeWith: const <String, String>{
        'SIS_ENABLE_CHECKLISTS_SUBMISSION': '1',
      },
    );
    expect(GlpiConfig.sisChecklistSubmissionEnabled, isTrue);
  });

  test('submission flag treats non-truthy strings as false', () {
    dotenv.testLoad(
      mergeWith: const <String, String>{
        'SIS_ENABLE_CHECKLISTS_SUBMISSION': 'maybe',
      },
    );
    expect(GlpiConfig.sisChecklistSubmissionEnabled, isFalse);
  });

  test('checklist ticket name prefix defaults to empty', () {
    dotenv.testLoad(mergeWith: const <String, String>{});

    expect(GlpiConfig.sisChecklistTicketNamePrefix, isEmpty);
  });

  test('checklist ticket name prefix reads env value', () {
    dotenv.testLoad(
      mergeWith: const <String, String>{
        'SIS_CHECKLIST_TICKET_NAME_PREFIX': '[TESTE-AUTOMATIZADO SIS]',
      },
    );

    expect(GlpiConfig.sisChecklistTicketNamePrefix, '[TESTE-AUTOMATIZADO SIS]');
  });
}
