import '../services/glpi_client.dart';

class AppStateSolutionSupport {
  static Future<Map<String, dynamic>> approveSolution({
    required GlpiClient apiService,
    required bool isAuthenticated,
    required String? sessionToken,
    required String ticketId,
    required String solutionId,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
  }) async {
    if (!isAuthenticated || sessionToken == null) {
      return {'success': false, 'error': 'Sessao expirada'};
    }

    try {
      final success = await apiService.updateSolutionStatus(
        solutionId: solutionId,
        newStatus: 3,
        sessionToken: sessionToken,
      );

      if (success) {
        await apiService.updateTicketStatus(ticketId, 'Fechado', sessionToken);
        return {'success': true};
      }

      return {'success': false, 'error': 'Falha na API ao aprovar.'};
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> rejectSolution({
    required GlpiClient apiService,
    required bool isAuthenticated,
    required String? sessionToken,
    required String ticketId,
    required String solutionId,
    required String justification,
    List<String> attachmentPaths = const [],
    required Future<Map<String, dynamic>> Function({
      required String ticketId,
      required String messageContent,
      List<String> filePaths,
      bool isSolution,
    })
    sendTicketMessageWithAttachments,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
  }) async {
    if (!isAuthenticated || sessionToken == null) {
      return {'success': false, 'error': 'Sessao expirada'};
    }

    try {
      final success = await apiService.updateSolutionStatus(
        solutionId: solutionId,
        newStatus: 4,
        sessionToken: sessionToken,
      );

      if (success) {
        await sendTicketMessageWithAttachments(
          ticketId: ticketId,
          messageContent:
              '❌ Solução recusada.\n\nJustificativa do usuário:\n$justification',
          filePaths: attachmentPaths,
        );

        await apiService.updateTicketStatus(ticketId, 'Novo', sessionToken);
        return {'success': true};
      }

      return {'success': false, 'error': 'Falha na API ao recusar.'};
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}
