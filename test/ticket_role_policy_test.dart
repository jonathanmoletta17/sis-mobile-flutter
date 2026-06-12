import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/models/operational_role.dart';
import 'package:sis_mobile_flutter/models/ticket_domain.dart';
import 'package:sis_mobile_flutter/models/ticket_queue_type.dart';
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
    test('only explicit technician-capable profiles expose status actions', () {
      final ticket = {
        'requester_user_id': 100,
        'status': GlpiStatus.emAtendimento.code,
      };

      for (final profile in [
        null,
        '',
        'Self-Service',
        'Requerente',
        'Solicitante',
        'Gabriel',
      ]) {
        expect(
          AppStateTicketSupport.canShowTechnicianActions(
            ticket,
            activeProfile: profile,
            loggedUsername: 'gabriel-conceicao',
            loggedUserId: 2039,
          ),
          isFalse,
          reason: 'profile=$profile must not mutate ticket status',
        );
      }

      for (final profile in ['Tecnico', 'Técnico', 'Super-Admin']) {
        expect(
          AppStateTicketSupport.canShowTechnicianActions(
            ticket,
            activeProfile: profile,
            loggedUsername: 'tecnico',
            loggedUserId: 2039,
          ),
          isTrue,
          reason: 'profile=$profile is allowed to mutate ticket status',
        );
      }
    });

    test(
      'central policy bridge resolves GG shared queue without technical actions',
      () {
        final ticket = {
          'requester_user_id': 100,
          'status': GlpiStatus.emAtendimento.code,
        };

        final decision = AppStateTicketSupport.evaluateTicketPermissions(
          ticket,
          role: OperationalRole.ggConservationRequester,
          ticketDomain: TicketDomain.ggConservationObserver,
          loggedUserId: 2039,
          observerGroups: const [GlpiGroupRef(id: 49, name: 'GG-CONSERVACAO')],
        );
        final queues = AppStateTicketSupport.resolveTicketQueues(
          ticket,
          role: OperationalRole.ggConservationRequester,
          ticketDomain: TicketDomain.ggConservationObserver,
          loggedUserId: 2039,
          observerGroups: const [GlpiGroupRef(id: 49, name: 'GG-CONSERVACAO')],
        );

        expect(decision.canView, isTrue);
        expect(decision.canChangeStatus, isFalse);
        expect(queues, contains(TicketQueueType.ggConservationShared));
        expect(queues, isNot(contains(TicketQueueType.conservationQueue)));
      },
    );
  });
}
