import '../models/glpi_status.dart';
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
      return {'success': false, 'error': 'Sessão expirada'};
    }

    try {
      final currentTicket = await apiService.getTicketById(
        ticketId,
        sessionToken,
      );
      if (!GlpiStatusMapper.canValidateSolution(currentTicket['status'])) {
        return {
          'success': false,
          'error': 'Só é possível validar solução quando o chamado está solucionado. Recarregue a tela.',
        };
      }

      final success = await apiService.updateSolutionStatus(
        solutionId: solutionId,
        newStatus: 3,
        sessionToken: sessionToken,
      );

      if (success) {
        final closeResult = await apiService.updateTicketStatus(
          ticketId,
          'Fechado',
          sessionToken,
        );
        if (closeResult['success'] == true) {
          return {'success': true};
        }
        return {
          'success': false,
          'error': closeResult['message'] ??
              closeResult['error'] ??
              'Solução aprovada, mas o chamado não foi fechado.',
        };
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
      return {'success': false, 'error': 'Sessão expirada'};
    }

    try {
      final currentTicket = await apiService.getTicketById(
        ticketId,
        sessionToken,
      );
      if (!GlpiStatusMapper.canValidateSolution(currentTicket['status'])) {
        return {
          'success': false,
          'error': 'Só é possível validar solução quando o chamado está solucionado. Recarregue a tela.',
        };
      }

      final success = await apiService.updateSolutionStatus(
        solutionId: solutionId,
        newStatus: 4,
        sessionToken: sessionToken,
      );

      if (success) {
        final reopenResult = await apiService.updateTicketStatus(
          ticketId,
          'Novo',
          sessionToken,
        );
        if (reopenResult['success'] != true) {
          return {
            'success': false,
            'error': reopenResult['message'] ??
                reopenResult['error'] ??
                'Solução recusada, mas o chamado não foi reaberto.',
          };
        }

        final messageResult = await sendTicketMessageWithAttachments(
          ticketId: ticketId,
          messageContent:
              '❌ Solução recusada.\n\nJustificativa do usuário:\n$justification',
          filePaths: attachmentPaths,
        );
        if (messageResult['success'] != true) {
          return {
            'success': false,
            'error': messageResult['error'] ??
                'Chamado reaberto, mas a justificativa não foi registrada.',
          };
        }

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
