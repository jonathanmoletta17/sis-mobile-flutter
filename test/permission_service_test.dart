import 'package:flutter_test/flutter_test.dart';
import 'package:sis_mobile_flutter/models/glpi_identity.dart';
import 'package:sis_mobile_flutter/models/operational_role.dart';
import 'package:sis_mobile_flutter/models/ticket_domain.dart';
import 'package:sis_mobile_flutter/policy/permission_service.dart';

void main() {
  group('PermissionService', () {
    test('standard requester sees own ticket but cannot use technical actions', () {
      final decision = PermissionService.evaluate(
        role: OperationalRole.standardRequester,
        ticketDomain: TicketDomain.maintenance,
        loggedUserId: 10,
        requesterUserId: 10,
        status: 2,
      );

      expect(decision.canView, isTrue);
      expect(decision.canSendFollowup, isTrue);
      expect(decision.canViewTechnicalQueue, isFalse);
      expect(decision.canProposeSolution, isFalse);
      expect(decision.reasons, contains('Usuário é requerente do ticket'));
    });

    test('GG conservation requester sees shared GG demand without technical execution rights', () {
      final decision = PermissionService.evaluate(
        role: OperationalRole.ggConservationRequester,
        ticketDomain: TicketDomain.ggConservationObserver,
        loggedUserId: 20,
        requesterUserId: 99,
        observerGroups: const [GlpiGroupRef(id: 49, name: 'GG-CONSERVACAO', isAssign: false)],
        status: 2,
      );

      expect(decision.canView, isTrue);
      expect(decision.canViewGgSharedQueue, isTrue);
      expect(decision.canViewTechnicalQueue, isFalse);
      expect(decision.canChangeStatus, isFalse);
      expect(decision.canProposeSolution, isFalse);
    });

    test('conservation technician can act only on conservation tickets', () {
      final allowed = PermissionService.evaluate(
        role: OperationalRole.conservationTechnician,
        ticketDomain: TicketDomain.conservation,
        loggedUserId: 30,
        requesterUserId: 99,
        status: 2,
      );
      final blocked = PermissionService.evaluate(
        role: OperationalRole.conservationTechnician,
        ticketDomain: TicketDomain.maintenance,
        loggedUserId: 30,
        requesterUserId: 99,
        status: 2,
      );

      expect(allowed.canViewTechnicalQueue, isTrue);
      expect(allowed.canChangeStatus, isTrue);
      expect(allowed.canProposeSolution, isTrue);
      expect(blocked.canViewTechnicalQueue, isFalse);
      expect(blocked.canChangeStatus, isFalse);
      expect(blocked.warnings, contains('Papel técnico não cobre o domínio do ticket'));
    });

    test('requester precedence blocks technical actions on own ticket', () {
      final decision = PermissionService.evaluate(
        role: OperationalRole.maintenanceTechnician,
        ticketDomain: TicketDomain.maintenance,
        loggedUserId: 40,
        requesterUserId: 40,
        status: 2,
      );

      expect(decision.canView, isTrue);
      expect(decision.canChangeStatus, isFalse);
      expect(decision.canProposeSolution, isFalse);
      expect(decision.warnings, contains('Requerente do ticket não recebe ações técnicas no próprio ticket'));
    });

    test('closed tickets keep history visible and block mutations', () {
      final decision = PermissionService.evaluate(
        role: OperationalRole.maintenanceTechnician,
        ticketDomain: TicketDomain.maintenance,
        loggedUserId: 50,
        requesterUserId: 99,
        status: 6,
      );

      expect(decision.canView, isTrue);
      expect(decision.canOpenConversation, isTrue);
      expect(decision.canSendFollowup, isFalse);
      expect(decision.canAttachFile, isFalse);
      expect(decision.canChangeStatus, isFalse);
      expect(decision.canProposeSolution, isFalse);
    });
  });
}
