import '../models/ticket_message.dart';
import '../services/glpi_client.dart';

class AppStateMessageSupport {
  static String _normalizeInteractionError(
    String error, {
    bool isSolution = false,
  }) {
    final cleaned = error
        .replaceFirst('Exception: ', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final lowered = cleaned.toLowerCase();

    if (isSolution &&
        lowered.contains('categoria') &&
        lowered.contains('obrigat')) {
      return 'Defina a categoria do chamado antes de registrar a solucao.';
    }

    return cleaned.isEmpty ? 'Falha ao enviar interacao.' : cleaned;
  }

  static Future<List<TicketMessage>> fetchTicketMessages({
    required GlpiClient apiService,
    required bool isAuthenticated,
    required String? sessionToken,
    required String ticketId,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    if (!isAuthenticated || sessionToken == null) {
      log?.call('Nao autenticado para buscar mensagens');
      return [];
    }

    try {
      log?.call('Buscando mensagens do ticket $ticketId...');

      final messagesData = await apiService.getTicketMessages(
        ticketId,
        sessionToken,
      );
      final textMessages = _buildTextMessages(messagesData);
      log?.call('${textMessages.length} mensagens de texto carregadas');

      final followupIds = _extractFollowupIds(messagesData);
      final docMessages = await _loadDocumentMessages(
        apiService: apiService,
        ticketId: ticketId,
        sessionToken: sessionToken,
        followupIds: followupIds,
        isSessionInvalidError: isSessionInvalidError,
        handleSessionInvalid: handleSessionInvalid,
        log: log,
      );

      final solutionMessages = await _loadSolutionMessages(
        apiService: apiService,
        ticketId: ticketId,
        sessionToken: sessionToken,
        isSessionInvalidError: isSessionInvalidError,
        handleSessionInvalid: handleSessionInvalid,
        log: log,
      );

      final solutionDocumentMessages = await _loadSolutionDocumentMessages(
        apiService: apiService,
        sessionToken: sessionToken,
        solutionMessages: solutionMessages,
        isSessionInvalidError: isSessionInvalidError,
        handleSessionInvalid: handleSessionInvalid,
        log: log,
      );

      final allItems = _mergeConversationItems(
        textMessages: textMessages,
        docMessages: [...docMessages, ...solutionDocumentMessages],
        solutionMessages: solutionMessages,
      );

      log?.call('Total de ${allItems.length} itens prontos para o chat');
      return allItems;
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
      }
      log?.call('Erro ao buscar mensagens: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> sendTicketMessageWithAttachments({
    required GlpiClient apiService,
    required bool isAuthenticated,
    required String? sessionToken,
    required String ticketId,
    required String messageContent,
    List<String> filePaths = const [],
    bool isSolution = false,
    required Future<Map<String, dynamic>> Function(
      String ticketId,
      String imagePath, {
      String? targetItemType,
      String? targetItemId,
    })
    uploadAndLinkImage,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    if (!isAuthenticated || sessionToken == null) {
      return {'success': false, 'error': 'Sessao expirada'};
    }

    try {
      final trimmedMessage = messageContent.trim();
      log?.call(
        'Enviando ${isSolution ? "SOLUCAO" : "MENSAGEM"} para ticket $ticketId...',
      );

      final mustCreateInteraction =
          trimmedMessage.isNotEmpty || filePaths.isNotEmpty;
      String? interactionId;
      String? interactionType;
      var messageSent = false;

      if (mustCreateInteraction) {
        final effectiveContent = trimmedMessage.isNotEmpty
            ? trimmedMessage
            : '[Anexo enviado pelo aplicativo]';

        final result = isSolution
            ? await apiService.addTicketSolution(
                ticketId,
                effectiveContent,
                sessionToken,
              )
            : await apiService.addTicketMessage(
                ticketId,
                effectiveContent,
                sessionToken,
              );

        if (result['success'] != true) {
          final err = _normalizeInteractionError(
            result['error']?.toString() ?? 'Falha ao enviar interacao.',
            isSolution: isSolution,
          );
          if (isSessionInvalidError(err)) {
            await handleSessionInvalid(err);
          }
          return {'success': false, 'error': err};
        }

        interactionId = result['entity_id']?.toString();
        interactionType = isSolution ? 'ITILSolution' : 'ITILFollowup';
        messageSent = trimmedMessage.isNotEmpty;
      }

      var successCount = 0;
      var failCount = 0;
      final errors = <String>[];

      for (final path in filePaths) {
        final uploadResult = await uploadAndLinkImage(
          ticketId,
          path,
          targetItemType: interactionType,
          targetItemId: interactionId,
        );
        if (uploadResult['success'] == true) {
          successCount++;
        } else {
          failCount++;
          final errorMsg = uploadResult['error'] ?? 'Erro desconhecido';
          errors.add('${path.split('/').last}: $errorMsg');
        }
      }

      final isSuccess =
          messageSent || successCount > 0 || mustCreateInteraction;
      return {
        'success': isSuccess,
        'messageSent': messageSent,
        'interactionId': interactionId,
        'interactionType': interactionType,
        'attachmentsSuccess': successCount,
        'attachmentsFail': failCount,
        'errors': errors,
      };
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
      }
      log?.call('Erro geral no envio: $e');
      return {
        'success': false,
        'error': _normalizeInteractionError(
          e.toString(),
          isSolution: isSolution,
        ),
      };
    }
  }

  static List<TicketMessage> _buildTextMessages(
    List<Map<String, dynamic>> messagesData,
  ) {
    return messagesData.map(TicketMessage.fromMap).toList();
  }

  static List<String> _extractFollowupIds(
    List<Map<String, dynamic>> messagesData,
  ) {
    return messagesData.map((message) => message['id'].toString()).toList();
  }

  static Future<List<TicketMessage>> _loadDocumentMessages({
    required GlpiClient apiService,
    required String ticketId,
    required String sessionToken,
    required List<String> followupIds,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    final docMessages = <TicketMessage>[];

    try {
      final ticketDocs = await apiService.getTicketDocuments(
        ticketId,
        sessionToken,
      );
      docMessages.addAll(ticketDocs.map(TicketMessage.fromDocumentMap));

      if (followupIds.isNotEmpty) {
        final followupDocs = await apiService.getFollowupDocuments(
          followupIds,
          sessionToken,
        );
        docMessages.addAll(followupDocs.map(TicketMessage.fromDocumentMap));
      }
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
        rethrow;
      }
      log?.call('Erro ao buscar documentos: $e');
    }

    return docMessages;
  }

  static Future<List<TicketMessage>> _loadSolutionMessages({
    required GlpiClient apiService,
    required String ticketId,
    required String sessionToken,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    try {
      final solutionsData = await apiService.getTicketSolutions(
        ticketId,
        sessionToken,
      );
      final solutionMessages = solutionsData
          .map(TicketMessage.fromSolutionMap)
          .toList();
      log?.call('${solutionMessages.length} solucoes carregadas');
      return solutionMessages;
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
        rethrow;
      }
      log?.call('Erro ao buscar solucoes: $e');
      return [];
    }
  }

  static Future<List<TicketMessage>> _loadSolutionDocumentMessages({
    required GlpiClient apiService,
    required String sessionToken,
    required List<TicketMessage> solutionMessages,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    final solutionIds = solutionMessages
        .map((solution) => solution.id)
        .where((id) => id.isNotEmpty)
        .toList();

    if (solutionIds.isEmpty) {
      return [];
    }

    try {
      final solutionDocs = await apiService.getSolutionDocuments(
        solutionIds,
        sessionToken,
      );

      return solutionDocs.map((doc) {
        final matching = solutionMessages.where(
          (solution) => solution.id == doc['items_id'].toString(),
        );
        if (matching.isNotEmpty) {
          doc['date_creation'] = matching.first.createdAt.toIso8601String();
        }
        return TicketMessage.fromDocumentMap(doc);
      }).toList();
    } catch (e) {
      if (isSessionInvalidError(e)) {
        await handleSessionInvalid(e);
        rethrow;
      }
      log?.call('Erro ao buscar anexos de solucoes: $e');
      return [];
    }
  }

  static List<TicketMessage> _mergeConversationItems({
    required List<TicketMessage> textMessages,
    required List<TicketMessage> docMessages,
    required List<TicketMessage> solutionMessages,
  }) {
    final allItems = <TicketMessage>[
      ...textMessages,
      ...docMessages,
      ...solutionMessages,
    ];
    allItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return allItems;
  }
}
