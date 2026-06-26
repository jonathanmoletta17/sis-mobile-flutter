import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/utils/attachment_opening_policy.dart';

void main() {
  group('AttachmentOpeningPolicy', () {
    test('sanitizes remote filenames before local or browser handoff', () {
      expect(
        AttachmentOpeningPolicy.safeFilename(r'folder\relatorio/final.pdf'),
        'folder_relatorio_final.pdf',
      );
      expect(AttachmentOpeningPolicy.safeFilename('   '), 'anexo');
    });

    test('resolves browser-previewable mime types from filename fallback', () {
      expect(
        AttachmentOpeningPolicy.resolveMimeType(
          filename: 'EVENTO.PDF',
          mimeType: 'application/octet-stream',
        ),
        'application/pdf',
      );
      expect(
        AttachmentOpeningPolicy.shouldOpenInlineInBrowser(
          filename: 'EVENTO.PDF',
          mimeType: 'application/octet-stream',
        ),
        isTrue,
      );
    });

    test(
      'keeps office documents as downloads because browsers cannot preview them reliably',
      () {
        expect(
          AttachmentOpeningPolicy.shouldOpenInlineInBrowser(
            filename: 'planilha.xlsx',
            mimeType: '',
          ),
          isFalse,
        );
      },
    );
  });

  test(
    'SIS remote attachment openers do not call native file plugins directly',
    () {
      final files = [
        File('lib/screens/ticket_detail_screen.dart'),
        File('lib/screens/ticket_message_screen.dart'),
      ];

      for (final file in files) {
        final source = file.readAsStringSync();
        expect(
          source,
          isNot(contains('getTemporaryDirectory(')),
          reason: '${file.path} must use the platform attachment opener.',
        );
        expect(
          source,
          isNot(contains('OpenFilex.open')),
          reason: '${file.path} must use the platform attachment opener.',
        );
      }
    },
  );
}
