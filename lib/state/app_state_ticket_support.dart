import '../data/service_data.dart';
import '../models/glpi_ticket.dart';

class AppStateTicketSupport {
  static String normalizeIdentity(dynamic value) {
    if (value == null) return '';
    return value.toString().trim().toLowerCase();
  }

  static bool ticketBelongsToLoggedUser(
    Map<String, dynamic> ticket, {
    String? loggedUsername,
    int? loggedUserId,
  }) {
    final normalizedUsername = normalizeIdentity(loggedUsername);
    final normalizedUserId = normalizeIdentity(loggedUserId);

    if (normalizedUsername.isEmpty && normalizedUserId.isEmpty) {
      return true;
    }

    bool matchesIdentity(dynamic candidate) {
      final normalizedCandidate = normalizeIdentity(candidate);
      if (normalizedCandidate.isEmpty) return false;

      return (normalizedUsername.isNotEmpty &&
              normalizedCandidate == normalizedUsername) ||
          (normalizedUserId.isNotEmpty &&
              normalizedCandidate == normalizedUserId);
    }

    final dynamic recipient =
        ticket['users_id_recipient'] ?? ticket['Users_id_recipient'];

    if (matchesIdentity(recipient)) {
      return true;
    }

    if (recipient is Map) {
      return matchesIdentity(recipient['id']) ||
          matchesIdentity(recipient['name']) ||
          matchesIdentity(recipient['completename']) ||
          matchesIdentity(recipient['value']);
    }

    return false;
  }

  static String normalizeServiceCategory(dynamic rawCategory) {
    return normalizeServiceCategoryLabel(rawCategory);
  }

  static List<Map<String, dynamic>> decorateOnlineTickets(
    List<Map<String, dynamic>> tickets,
  ) {
    return tickets.map((ticket) {
      ticket['serviceName'] = normalizeServiceCategory(
        ticket['itilcategories_id'],
      );
      return ticket;
    }).toList();
  }

  static List<Map<String, dynamic>> buildOfflineTickets(
    List<GlpiTicket> pendingTickets,
  ) {
    return pendingTickets.map((ticket) {
      return ticket.toMap()
        ..['id'] = 'OFFLINE-${ticket.assunto.hashCode.abs()}'
        ..['status'] = 'Pendente (Offline)'
        ..['serviceName'] = ticket.serviceName;
    }).toList();
  }
}
