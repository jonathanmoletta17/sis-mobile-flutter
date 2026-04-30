import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/state/app_state_ticket_support.dart';

void main() {
  group('ticket role policy', () {
    test('requester identity takes precedence over technician profile', () {
      final ticket = {
        'requester_user_id': 2039,
        'users_id_recipient': 'jonathan-moletta',
        'status': GlpiStatus.emAtendimento.code,
      };

      expect(
        AppStateTicketSupport.isLoggedUserRequester(
          ticket,
          loggedUsername: 'jonathan-moletta',
          loggedUserId: 2039,
        ),
        isTrue,
      );
      expect(
        AppStateTicketSupport.canShowTechnicianActions(
          ticket,
          activeProfile: 'Tecnico',
          loggedUsername: 'jonathan-moletta',
          loggedUserId: 2039,
        ),
        isFalse,
      );
    });

    test(
      'closed and solved tickets never expose technician status actions',
      () {
        for (final status in [
          GlpiStatus.solucionado.code,
          GlpiStatus.fechado.code,
        ]) {
          expect(
            AppStateTicketSupport.canShowTechnicianActions(
              {'requester_user_id': 100, 'status': status},
              activeProfile: 'Tecnico',
              loggedUsername: 'tecnico',
              loggedUserId: 2039,
            ),
            isFalse,
          );
        }
      },
    );

    test('fallback requester label still matches logged user id', () {
      final ticket = {
        'users_id_recipient': 'Usuario 2039',
        'status': GlpiStatus.emAtendimento.code,
      };

      expect(
        AppStateTicketSupport.isLoggedUserRequester(
          ticket,
          loggedUsername: 'jonathan-moletta',
          loggedUserId: 2039,
        ),
        isTrue,
      );
      expect(
        AppStateTicketSupport.canShowTechnicianActions(
          ticket,
          activeProfile: 'Tecnico',
          loggedUsername: 'jonathan-moletta',
          loggedUserId: 2039,
        ),
        isFalse,
      );
    });
  });
}
