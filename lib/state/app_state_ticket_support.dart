import '../data/service_data.dart';
import '../models/glpi_status.dart';
import '../models/glpi_ticket.dart';
import '../utils/glpi_name_formatter.dart';

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
    if (isLoggedUserRequester(
      ticket,
      loggedUsername: loggedUsername,
      loggedUserId: loggedUserId,
    )) {
      return true;
    }

    final normalizedUsername = normalizeIdentity(loggedUsername);
    final normalizedUserId = normalizeIdentity(loggedUserId);

    if (normalizedUsername.isEmpty && normalizedUserId.isEmpty) {
      return true;
    }

    bool matchesIdentity(dynamic candidate) {
      final normalizedCandidate = normalizeIdentity(candidate);
      if (normalizedCandidate.isEmpty) return false;

      if (normalizedUserId.isNotEmpty) {
        final numericCandidate = GlpiNameFormatter.extractNumericId(candidate);
        if (numericCandidate != null &&
            normalizeIdentity(numericCandidate) == normalizedUserId) {
          return true;
        }
      }

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

  static bool isLoggedUserRequester(
    Map<String, dynamic> ticket, {
    String? loggedUsername,
    int? loggedUserId,
  }) {
    final normalizedUsername = normalizeIdentity(loggedUsername);
    final normalizedUserId = normalizeIdentity(loggedUserId);

    if (normalizedUsername.isEmpty && normalizedUserId.isEmpty) {
      return false;
    }

    bool matchesIdentity(dynamic candidate) {
      final normalizedCandidate = normalizeIdentity(candidate);
      if (normalizedCandidate.isEmpty) return false;

      if (normalizedUserId.isNotEmpty) {
        final numericCandidate = GlpiNameFormatter.extractNumericId(candidate);
        if (numericCandidate != null &&
            normalizeIdentity(numericCandidate) == normalizedUserId) {
          return true;
        }
      }

      return (normalizedUsername.isNotEmpty &&
              normalizedCandidate == normalizedUsername) ||
          (normalizedUserId.isNotEmpty &&
              normalizedCandidate == normalizedUserId);
    }

    final requesterCandidates = [
      ticket['requester_user_id'],
      ticket['users_id_recipient_id'],
      ticket['Users_id_recipient_id'],
      ticket['users_id_recipient'],
      ticket['Users_id_recipient'],
    ];

    for (final candidate in requesterCandidates) {
      if (matchesIdentity(candidate)) return true;
      if (candidate is Map) {
        if (matchesIdentity(candidate['id']) ||
            matchesIdentity(candidate['name']) ||
            matchesIdentity(candidate['completename']) ||
            matchesIdentity(candidate['value']) ||
            matchesIdentity(candidate['login'])) {
          return true;
        }
      }
    }

    return false;
  }

  static bool isRequesterProfile(String? activeProfile) {
    final profile = normalizeIdentity(activeProfile);
    return profile.contains('self-service') ||
        profile.contains('post-only') ||
        profile.contains('requerente') ||
        profile.contains('solicitante');
  }

  static bool canShowTechnicianActions(
    Map<String, dynamic> ticket, {
    required String? activeProfile,
    required String? loggedUsername,
    required int? loggedUserId,
  }) {
    if (GlpiStatusMapper.isOffline(ticket['status'])) return false;
    if (!GlpiStatusMapper.isOpenForInteraction(ticket['status'])) return false;
    if (isRequesterProfile(activeProfile)) return false;

    return !isLoggedUserRequester(
      ticket,
      loggedUsername: loggedUsername,
      loggedUserId: loggedUserId,
    );
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
