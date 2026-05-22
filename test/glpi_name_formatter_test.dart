import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/utils/glpi_name_formatter.dart';

void main() {
  group('GlpiNameFormatter', () {
    test('formats firstname and realname before falling back to login', () {
      final name = GlpiNameFormatter.formatNameFromMap({
        'id': 2039,
        'name': 'jonathan-moletta',
        'firstname': 'Jonathan',
        'realname': 'Moletta',
      });

      expect(name, 'Jonathan Moletta');
    });

    test('does not expose numeric GLPI id in display fallbacks', () {
      expect(
        GlpiNameFormatter.getFriendlyName('2039'),
        'Usuário não identificado',
      );
      expect(
        GlpiNameFormatter.formatNameFromMap({'id': 2039}),
        'Usuário não identificado',
      );
      expect(
        GlpiNameFormatter.fallbackUserLabel(2040, prefix: 'Tecnico'),
        'Técnico não identificado',
      );
    });

    test('extracts ids from numeric and fallback display labels', () {
      expect(GlpiNameFormatter.extractNumericId(2039), '2039');
      expect(GlpiNameFormatter.extractNumericId('2039'), '2039');
      expect(GlpiNameFormatter.extractNumericId('Usuario 2039'), '2039');
      expect(GlpiNameFormatter.extractNumericId('Tecnico 2040'), '2040');
    });
  });
}
