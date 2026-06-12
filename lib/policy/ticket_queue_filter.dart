import '../models/glpi_identity.dart';
import '../models/operational_role.dart';
import '../models/ticket_domain.dart';
import '../models/ticket_queue_type.dart';
import 'permission_service.dart';

class TicketQueueFilter {
  static List<TicketQueueType> resolveQueues({
    required OperationalRole role,
    required TicketDomain ticketDomain,
    required int? loggedUserId,
    required int? requesterUserId,
    required dynamic status,
    List<GlpiGroupRef> assignedGroups = const [],
    List<GlpiGroupRef> observerGroups = const [],
    bool assignedToLoggedUser = false,
  }) {
    final decision = PermissionService.evaluate(
      role: role,
      ticketDomain: ticketDomain,
      loggedUserId: loggedUserId,
      requesterUserId: requesterUserId,
      status: status,
      assignedGroups: assignedGroups,
      observerGroups: observerGroups,
    );

    final queues = <TicketQueueType>[];
    final isRequester =
        loggedUserId != null &&
        requesterUserId != null &&
        loggedUserId == requesterUserId;

    if (isRequester) queues.add(TicketQueueType.requestedByMe);
    if (assignedToLoggedUser) queues.add(TicketQueueType.assignedToMe);
    if (decision.canViewGgSharedQueue) {
      queues.add(TicketQueueType.ggConservationShared);
    }

    if (decision.canViewTechnicalQueue) {
      switch (ticketDomain) {
        case TicketDomain.maintenance:
          queues.add(TicketQueueType.maintenanceQueue);
          break;
        case TicketDomain.conservation:
          queues.add(TicketQueueType.conservationQueue);
          break;
        case TicketDomain.ggConservationObserver:
        case TicketDomain.dtic:
        case TicketDomain.unknown:
          break;
      }
    }

    if (role == OperationalRole.supervisor) {
      queues.add(TicketQueueType.supervision);
    }
    if (role == OperationalRole.admin) {
      queues.add(TicketQueueType.allAdmin);
    }
    if (decision.canValidateSolution) {
      queues.add(TicketQueueType.pendingValidation);
    }

    return List.unmodifiable(queues.toSet());
  }
}
