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
          'error':
              'Só é possível validar solução quando o chamado está solucionado. Recarregue a tela.',
        };
      }

      final result = await apiService.updateTicketSolutionDecision(
        ticketId: ticketId,
        approve: true,
        sessionToken: sessionToken,
      );

      if (result['success'] == true) {
        return {'success': true};
      }

      return {
        'success': false,
        'error': _friendlyApiError(result, approve: true),
      };
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
          'error':
              'Só é possível validar solução quando o chamado está solucionado. Recarregue a tela.',
        };
      }

      final result = await apiService.updateTicketSolutionDecision(
        ticketId: ticketId,
        approve: false,
        sessionToken: sessionToken,
      );

      if (result['success'] == true) {
        final messageContent =
            '❌ Solução recusada.\n\nJustificativa do usuário:\n$justification';
        final messageResult = attachmentPaths.isEmpty
            ? await apiService.addTicketMessage(
                ticketId,
                messageContent,
                sessionToken,
              )
            : await sendTicketMessageWithAttachments(
                ticketId: ticketId,
                messageContent: messageContent,
                filePaths: attachmentPaths,
              );
        if (messageResult['success'] != true) {
          return {
            'success': false,
            'error':
                messageResult['error'] ??
                'Solução recusada, mas a justificativa não foi registrada.',
          };
        }

        return {'success': true};
      }

      return {
        'success': false,
        'error': _friendlyApiError(result, approve: false),
      };
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  static String _friendlyApiError(
    Map<String, dynamic> result, {
    required bool approve,
  }) {
    final raw = result['error_message'] ?? result['message'] ?? '';
    if (raw.toString().contains('ERROR_RIGHT_MISSING') ||
        raw.toString().contains('ERROR_GLPI_UPDATE')) {
      return 'O perfil atual não tem permissão de ${approve ? 'aprovar' : 'recusar'} '
          'soluções via API. Contate o administrador do GLPI para habilitar '
          'a permissão de validação de solução para o perfil Solicitante.';
    }
    return raw.toString().isNotEmpty
        ? raw.toString()
        : (approve ? 'Falha na API ao aprovar.' : 'Falha na API ao recusar.');
  }
}
