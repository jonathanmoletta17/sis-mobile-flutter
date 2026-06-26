import '../models/glpi_identity.dart';
import '../models/operational_role.dart';
import '../models/ticket_domain.dart';
import '../models/ticket_queue_type.dart';
import 'ticket_queue_filter.dart';

class TicketQueueClassifier {
  static List<TicketQueueType> queuesForTicket(
    Map<String, dynamic> ticket, {
    required OperationalRole role,
    required int? loggedUserId,
    List<GlpiGroupRef> sessionGroups = const [],
  }) {
    final assignedGroups = _assignedGroups(ticket);
    final observerGroups = _observerGroups(ticket, sessionGroups);
    final domain = TicketDomainResolver.resolve(
      categoryCompletename: _categoryText(ticket),
      assignedGroups: assignedGroups,
      observerGroups: observerGroups,
    );
    final requesterUserId = _numericId(
      ticket['requester_user_id'] ??
          ticket['users_id_recipient_id'] ??
          ticket['Users_id_recipient_id'] ??
          ticket['users_id_recipient'],
    );
    final assigneeUserId = _numericId(
      ticket['assignee_user_id'] ??
          ticket['users_id_assign_id'] ??
          ticket['Users_id_assign_id'],
    );

    return TicketQueueFilter.resolveQueues(
      role: role,
      ticketDomain: domain,
      loggedUserId: loggedUserId,
      requesterUserId: requesterUserId,
      status: ticket['status'],
      assignedGroups: assignedGroups,
      observerGroups: observerGroups,
      assignedToLoggedUser:
          loggedUserId != null && assigneeUserId == loggedUserId,
    );
  }

  static TicketQueueType? primaryQueueForTicket(
    Map<String, dynamic> ticket, {
    required OperationalRole role,
    required int? loggedUserId,
    List<GlpiGroupRef> sessionGroups = const [],
  }) {
    final queues = queuesForTicket(
      ticket,
      role: role,
      loggedUserId: loggedUserId,
      sessionGroups: sessionGroups,
    );
    for (final preferred in _priority) {
      if (queues.contains(preferred)) return preferred;
    }
    return queues.isEmpty ? null : queues.first;
  }

  static const _priority = [
    TicketQueueType.assignedToMe,
    TicketQueueType.pendingValidation,
    TicketQueueType.maintenanceQueue,
    TicketQueueType.conservationQueue,
    TicketQueueType.ggConservationShared,
    TicketQueueType.requestedByMe,
    TicketQueueType.supervision,
    TicketQueueType.allAdmin,
  ];

  static String? _categoryText(Map<String, dynamic> ticket) {
    final value =
        ticket['itilcategories_id'] ??
        ticket['Itilcategories_id'] ??
        ticket['serviceName'] ??
        ticket['categoria'];
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static List<GlpiGroupRef> _assignedGroups(Map<String, dynamic> ticket) {
    return _groupRefs(
      id: ticket['assigned_group_id'] ?? ticket['groups_id_assign'],
      name: ticket['assigned_group_name'] ?? ticket['groups_id_assign_name'],
      isAssign: true,
    );
  }

  static List<GlpiGroupRef> _observerGroups(
    Map<String, dynamic> ticket,
    List<GlpiGroupRef> sessionGroups,
  ) {
    final refs = _groupRefs(
      id: ticket['observer_group_id'] ?? ticket['groups_id_observer'],
      name: ticket['observer_group_name'] ?? ticket['groups_id_observer_name'],
      isAssign: false,
    );
    if (refs.isNotEmpty) return refs;

    return sessionGroups
        .where(
          (group) => group.id == TicketDomainResolver.ggConservationGroupId,
        )
        .map(
          (group) =>
              GlpiGroupRef(id: group.id, name: group.name, isAssign: false),
        )
        .toList();
  }

  static List<GlpiGroupRef> _groupRefs({
    required dynamic id,
    required dynamic name,
    required bool isAssign,
  }) {
    final parsedId = _numericId(id);
    if (parsedId == null) return const [];
    return [
      GlpiGroupRef(
        id: parsedId,
        name: name?.toString().trim() ?? '',
        isAssign: isAssign,
      ),
    ];
  }

  static int? _numericId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final text = value.toString().trim();
    if (!RegExp(r'^\d+$').hasMatch(text)) return null;
    return int.tryParse(text);
  }
}
