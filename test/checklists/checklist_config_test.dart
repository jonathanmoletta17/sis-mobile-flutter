import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/config/glpi_config.dart';

void main() {
  test('submission flag defaults to false when unset', () {
    dotenv.testLoad(mergeWith: const <String, String>{});
    expect(GlpiConfig.sisChecklistSubmissionEnabled, isFalse);
  });

  test('submission flag reads truthy values', () {
    dotenv.testLoad(mergeWith: const <String, String>{
      'SIS_ENABLE_CHECKLISTS_SUBMISSION': '1',
    });
    expect(GlpiConfig.sisChecklistSubmissionEnabled, isTrue);
  });

  test('submission flag treats non-truthy strings as false', () {
    dotenv.testLoad(mergeWith: const <String, String>{
      'SIS_ENABLE_CHECKLISTS_SUBMISSION': 'maybe',
    });
    expect(GlpiConfig.sisChecklistSubmissionEnabled, isFalse);
  });
}
