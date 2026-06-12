import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_user_ref.dart';

void main() {
  group('GlpiUserRef', () {
    test('builds full display name from GLPI SIS search numeric fields', () {
      final user = GlpiUserRef.fromSearchRow({
        '2': 2039,
        '1': 'jonathan-moletta',
        '9': 'Jonathan',
        '34': 'Nascimento Moletta',
      });

      expect(user, isNotNull);
      expect(user!.displayName, 'Jonathan Nascimento Moletta');
      expect(user.login, 'jonathan-moletta');
      expect(user.firstName, 'Jonathan');
      expect(user.realName, 'Nascimento Moletta');
      expect(user.label, 'Jonathan Nascimento Moletta (jonathan-moletta)');
    });

    test('does not show only surname when first name is available', () {
      final user = GlpiUserRef.fromSearchRow({
        'id': 2040,
        'login': 'jonatan-bronstrup',
        'firstname': 'Jonatan',
        'realname': 'Bronstrup',
      });

      expect(user, isNotNull);
      expect(user!.displayName, 'Jonatan Bronstrup');
      expect(user.displayName, isNot('Bronstrup'));
    });
  });
}
