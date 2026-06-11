import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/state/app_state_ticket_support.dart';

void main() {
  group('AppStateTicketSupport profile semantics', () {
    test(
      'reconhece Manutenção e Conservação como perfil técnico operacional',
      () {
        expect(
          AppStateTicketSupport.isTechnicianProfile('Manutenção e Conservação'),
          isTrue,
        );
      },
    );

    test('não classifica Solicitante-GG-Conservação como técnico', () {
      expect(
        AppStateTicketSupport.isRequesterProfile('Solicitante-GG-Conservação'),
        isTrue,
      );
      expect(
        AppStateTicketSupport.isTechnicianProfile('Solicitante-GG-Conservação'),
        isFalse,
      );
    });
  });
}
