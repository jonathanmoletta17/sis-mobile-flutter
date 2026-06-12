import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_status.dart';
import 'package:sis_mobile_flutter/state/app_state_ticket_support.dart';

void main() {
  group('ticket status action matrix', () {
    test('conversation history is available for every synced GLPI status', () {
      for (final status in GlpiStatusMapper.ordered) {
        expect(
          AppStateTicketSupport.canOpenConversation({
            'id': '1001',
            'status': status.code,
          }),
          isTrue,
          reason:
              'status ${status.label} must keep conversation/history accessible',
        );
      }
    });

    test('offline tickets do not open remote conversation', () {
      expect(
        AppStateTicketSupport.canOpenConversation({
          'id': 'OFFLINE-1001',
          'status': GlpiStatusMapper.offlineLabel,
        }),
        isFalse,
      );
    });

    test('common conversation mutations are allowed only in open statuses', () {
      for (final status in [
        GlpiStatus.novo,
        GlpiStatus.emAtendimento,
        GlpiStatus.planejado,
        GlpiStatus.pendente,
      ]) {
        expect(
          AppStateTicketSupport.canSendCommonInteraction(status.code),
          isTrue,
          reason: '${status.label} should allow followup/attachment composer',
        );
      }

      for (final status in [GlpiStatus.solucionado, GlpiStatus.fechado]) {
        expect(
          AppStateTicketSupport.canSendCommonInteraction(status.code),
          isFalse,
          reason: '${status.label} should be read-only for common interaction',
        );
      }
    });

    test('solution proposal is technician-only and only in open statuses', () {
      final openTicket = {
        'requester_user_id': 100,
        'status': GlpiStatus.emAtendimento.code,
      };
      final solvedTicket = {
        'requester_user_id': 100,
        'status': GlpiStatus.solucionado.code,
      };

      expect(
        AppStateTicketSupport.canProposeSolution(
          openTicket,
          activeProfile: 'Tecnico',
          loggedUsername: 'tecnico',
          loggedUserId: 200,
        ),
        isTrue,
      );
      expect(
        AppStateTicketSupport.canProposeSolution(
          openTicket,
          activeProfile: 'Tecnico',
          loggedUsername: 'solicitante',
          loggedUserId: 100,
        ),
        isFalse,
        reason:
            'technician-requester must be treated as requester for own ticket',
      );
      expect(
        AppStateTicketSupport.canProposeSolution(
          openTicket,
          activeProfile: 'Self-Service',
          loggedUsername: 'tecnico',
          loggedUserId: 200,
        ),
        isFalse,
      );
      expect(
        AppStateTicketSupport.canProposeSolution(
          solvedTicket,
          activeProfile: 'Tecnico',
          loggedUsername: 'tecnico',
          loggedUserId: 200,
        ),
        isFalse,
      );
    });

    test(
      'solution validation is hidden until SIS requester API approval is governed',
      () {
        final solvedTicket = {
          'requester_user_id': 100,
          'status': GlpiStatus.solucionado.code,
        };
        final activeTicket = {
          'requester_user_id': 100,
          'status': GlpiStatus.emAtendimento.code,
        };
        final closedTicket = {
          'requester_user_id': 100,
          'status': GlpiStatus.fechado.code,
        };

        expect(
          AppStateTicketSupport.canValidateSolutionForTicket(
            solvedTicket,
            loggedUsername: 'solicitante',
            loggedUserId: 100,
            solutionAuthorUserId: 200,
          ),
          isFalse,
          reason:
              'SIS requester profile currently cannot approve via API; avoid rendering a button that fails at runtime.',
        );
        expect(
          AppStateTicketSupport.canValidateSolutionForTicket(
            activeTicket,
            loggedUsername: 'solicitante',
            loggedUserId: 100,
            solutionAuthorUserId: 200,
          ),
          isFalse,
        );
        expect(
          AppStateTicketSupport.canValidateSolutionForTicket(
            closedTicket,
            loggedUsername: 'solicitante',
            loggedUserId: 100,
            solutionAuthorUserId: 200,
          ),
          isFalse,
        );
        expect(
          AppStateTicketSupport.canValidateSolutionForTicket(
            solvedTicket,
            loggedUsername: 'tecnico',
            loggedUserId: 200,
            solutionAuthorUserId: 200,
          ),
          isFalse,
          reason: 'solution author must not approve/reject their own solution',
        );
      },
    );
  });
}
