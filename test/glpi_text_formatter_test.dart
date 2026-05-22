import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/utils/glpi_text_formatter.dart';

void main() {
  group('GlpiTextFormatter', () {
    test('decodes entities and strips HTML without leaking tags', () {
      final cleaned = GlpiTextFormatter.toPlainText(
        '&lt;div&gt;Solicita&amp;ccedil;&amp;atilde;o&nbsp;com &lt;strong&gt;urgência&lt;/strong&gt;&lt;br&gt;Linha 2&lt;/div&gt;',
      );

      expect(cleaned, contains('Solicitação com urgência'));
      expect(cleaned, contains('Linha 2'));
      expect(cleaned, isNot(contains('<div')));
      expect(cleaned, isNot(contains('&lt;')));
      expect(cleaned, isNot(contains('&nbsp;')));
    });

    test('removes script/style content from GLPI rich text', () {
      final cleaned = GlpiTextFormatter.toPlainText(
        '<p>Texto seguro</p><script>alert(1)</script><style>.x{}</style>',
      );

      expect(cleaned, 'Texto seguro');
      expect(cleaned, isNot(contains('alert')));
      expect(cleaned, isNot(contains('.x')));
    });
  });
}
