import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/checklists/checklist_submission.dart';
import 'package:sis_mobile_flutter/services/glpi_client.dart';

SisChecklistPreparedSubmission _submission({Set<int> files = const {}}) {
  return SisChecklistPreparedSubmission(
    formId: 50,
    targetId: 341,
    categoryId: 151,
    entityId: 58,
    answers: const {1: 'A'},
    fileQuestionIds: files,
    missingRequiredQuestionIds: const [],
    visibleQuestionIds: const [1],
  );
}

void main() {
  test('blocks before HTTP when the app submission flag is off', () async {
    dotenv.testLoad(
      mergeWith: const <String, String>{
        'SIS_ENABLE_CHECKLISTS_SUBMISSION': 'false',
      },
    );
    final result = await GlpiClient().submitFormCreatorAnswer(
      submission: _submission(),
      sessionToken: 'sess',
    );
    expect(result['success'], isFalse);
    expect(result['blocked'], isTrue);
  });

  test('blocks when session token is missing even with flag on', () async {
    dotenv.testLoad(
      mergeWith: const <String, String>{
        'SIS_ENABLE_CHECKLISTS_SUBMISSION': 'true',
      },
    );
    final result = await GlpiClient().submitFormCreatorAnswer(
      submission: _submission(),
      sessionToken: '',
    );
    expect(result['success'], isFalse);
    expect(result['blocked'], isTrue);
  });

  test(
    'blocks attachment submissions until the file contract is validated',
    () async {
      dotenv.testLoad(
        mergeWith: const <String, String>{
          'SIS_ENABLE_CHECKLISTS_SUBMISSION': 'true',
        },
      );
      final result = await GlpiClient().submitFormCreatorAnswer(
        submission: _submission(files: {3}),
        sessionToken: 'sess',
      );
      expect(result['success'], isFalse);
      expect(result['blocked'], isTrue);
      expect(result['message'], contains('anexos'));
    },
  );

  test('prepared payload carries FormCreator shape', () {
    final payload = _submission().toFormCreatorInput();
    expect(payload['plugin_formcreator_forms_id'], 50);
    expect(payload['add'], '1');
    expect(payload['formcreator_field_1'], 'A');
  });
}
