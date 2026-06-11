import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/utils/attachment_display.dart';

void main() {
  group('AttachmentDisplay', () {
    test('treats image by mime type', () {
      expect(
        AttachmentDisplay.isImageDocument(
          filename: 'evidencia.bin',
          mime: 'image/jpeg',
        ),
        isTrue,
      );
    });

    test('treats image by filename when GLPI does not return image mime', () {
      expect(
        AttachmentDisplay.isImageDocument(
          filename: 'foto_manutencao.jpg',
          mime: 'application/octet-stream',
        ),
        isTrue,
      );
      expect(
        AttachmentDisplay.isImageDocument(
          filename: 'print-servico.PNG',
          mime: '',
        ),
        isTrue,
      );
    });

    test('does not treat regular documents as images', () {
      expect(
        AttachmentDisplay.isImageDocument(
          filename: 'relatorio.pdf',
          mime: 'application/pdf',
        ),
        isFalse,
      );
    });
  });
}
