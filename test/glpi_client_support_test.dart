import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/services/glpi_client_support.dart';

void main() {
  group('GlpiClientSupport.mapSearchTicketRow', () {
    test(
      'keeps requester and assigned technician display values from search rows',
      () {
        final mapped = GlpiClientSupport.mapSearchTicketRow({
          '2': 9157,
          '1': 'Chamado de teste',
          '4': 'jonathan-moletta',
          '5': 'anderson-cardoso',
          '7': 'Manutenção > Elétrica > Conserto',
          '12': 2,
          '15': '2026-05-26 10:00:00',
        });

        expect(mapped['users_id_recipient'], 'jonathan-moletta');
        expect(mapped['Users_id_recipient'], 'jonathan-moletta');
        expect(mapped['users_id_assign'], 'anderson-cardoso');
        expect(mapped['Users_id_assign'], 'anderson-cardoso');
      },
    );
  });

  group('GlpiClientSupport.extractDocumentIdFromBody', () {
    test('returns null for empty successful direct upload body', () {
      expect(GlpiClientSupport.extractDocumentIdFromBody(''), isNull);
    });

    test('extracts document id from GLPI document response variants', () {
      expect(GlpiClientSupport.extractDocumentIdFromBody('{"id": 123}'), '123');
      expect(
        GlpiClientSupport.extractDocumentIdFromBody('{"documents_id": 456}'),
        '456',
      );
      expect(
        GlpiClientSupport.extractDocumentIdFromBody('{"id": " 789 "}'),
        '789',
      );
    });

    test('returns null for invalid or empty document id payloads', () {
      expect(GlpiClientSupport.extractDocumentIdFromBody('not-json'), isNull);
      expect(
        GlpiClientSupport.extractDocumentIdFromBody('{"id": null}'),
        isNull,
      );
      expect(GlpiClientSupport.extractDocumentIdFromBody('{"id": ""}'), isNull);
      expect(
        GlpiClientSupport.extractDocumentIdFromBody('{"id": "   "}'),
        isNull,
      );
    });
  });

  group('GlpiClientSupport.isVerifiableDocumentUploadSuccess', () {
    test(
      'rejects 200 without document id until caller verifies Document_Item',
      () {
        expect(
          GlpiClientSupport.isVerifiableDocumentUploadSuccess(
            statusCode: 200,
            body: '',
          ),
          isFalse,
        );
      },
    );

    test('accepts success only when response contains a document id', () {
      expect(
        GlpiClientSupport.isVerifiableDocumentUploadSuccess(
          statusCode: 201,
          body: '{"id": 789}',
        ),
        isTrue,
      );
      expect(
        GlpiClientSupport.isVerifiableDocumentUploadSuccess(
          statusCode: 200,
          body: '{"documents_id": 987}',
        ),
        isTrue,
      );
    });

    test('rejects success status without usable id', () {
      expect(
        GlpiClientSupport.isVerifiableDocumentUploadSuccess(
          statusCode: 201,
          body: '',
        ),
        isFalse,
      );
      expect(
        GlpiClientSupport.isVerifiableDocumentUploadSuccess(
          statusCode: 200,
          body: '{"id": ""}',
        ),
        isFalse,
      );
    });

    test('rejects non-success status even with id in body', () {
      expect(
        GlpiClientSupport.isVerifiableDocumentUploadSuccess(
          statusCode: 400,
          body: '{"id": 789}',
        ),
        isFalse,
      );
    });
  });

  group('GlpiClientSupport.extractDocumentIdsFromDocumentItemBody', () {
    test('extracts linked document ids from GLPI Document_Item responses', () {
      expect(
        GlpiClientSupport.extractDocumentIdsFromDocumentItemBody(
          '[{"id": 10, "documents_id": 123}, {"documents_id": "456"}]',
        ),
        {'123', '456'},
      );
    });

    test('returns empty set for invalid or empty Document_Item responses', () {
      expect(
        GlpiClientSupport.extractDocumentIdsFromDocumentItemBody(''),
        isEmpty,
      );
      expect(
        GlpiClientSupport.extractDocumentIdsFromDocumentItemBody('not-json'),
        isEmpty,
      );
    });
  });

  group('GlpiClientSupport.hasNewDocumentLink', () {
    test('detects new linked document after direct upload without body id', () {
      expect(
        GlpiClientSupport.hasNewDocumentLink(
          before: {'10', '11'},
          after: {'10', '11', '12'},
        ),
        isTrue,
      );
    });

    test('does not accept unchanged links as verified upload success', () {
      expect(
        GlpiClientSupport.hasNewDocumentLink(
          before: {'10', '11'},
          after: {'10', '11'},
        ),
        isFalse,
      );
    });
  });
}
