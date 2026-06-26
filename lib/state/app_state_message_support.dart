import '../models/glpi_status.dart';
import '../models/ticket_message.dart';
import '../services/glpi_client.dart';
import '../services/glpi_ticket_support.dart';

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
      return 'Defina a categoria do chamado antes de registrar a solução.';
    }

    return cleaned.isEmpty ? 'Falha ao enviar interação.' : cleaned;
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
    List<GlpiTicketAttachment> attachments = const [],
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
      return {'success': false, 'error': 'Sessão expirada'};
    }

    try {
      final currentTicket = await apiService.getTicketById(
        ticketId,
        sessionToken,
      );
      if (!GlpiStatusMapper.isOpenForInteraction(currentTicket['status'])) {
        return {
          'success': false,
          'error': 'Chamado já está solucionado ou fechado. Recarregue a tela.',
        };
      }

      final trimmedMessage = messageContent.trim();
      log?.call(
        'Enviando ${isSolution ? "SOLUCAO" : "MENSAGEM"} para ticket $ticketId...',
      );

      final hasAttachments = filePaths.isNotEmpty || attachments.isNotEmpty;
      final isAttachmentOnly = trimmedMessage.isEmpty && hasAttachments;
      final mustCreateInteraction = trimmedMessage.isNotEmpty || hasAttachments;
      String? interactionId;
      String? interactionType;
      var messageSent = false;

      var successCount = 0;
      var failCount = 0;
      final errors = <String>[];

      if (isAttachmentOnly) {
        log?.call(
          'Modo anexo-only: fazer upload dos anexos ANTES de criar follow-up',
        );
        for (final path in filePaths) {
          final uploadResult = await uploadAndLinkImage(ticketId, path);
          if (uploadResult['success'] == true) {
            successCount++;
          } else {
            failCount++;
            final errorMsg = uploadResult['error'] ?? 'Erro desconhecido';
            errors.add('${path.split('/').last}: $errorMsg');
          }
        }

        for (final attachment in attachments) {
          final uploadResult = await _uploadAndLinkAttachment(
            apiService: apiService,
            sessionToken: sessionToken,
            ticketId: ticketId,
            attachment: attachment,
            isSessionInvalidError: isSessionInvalidError,
            handleSessionInvalid: handleSessionInvalid,
            log: log,
          );
          if (uploadResult['success'] == true) {
            successCount++;
          } else {
            failCount++;
            final errorMsg = uploadResult['error'] ?? 'Erro desconhecido';
            errors.add('${attachment.filename}: $errorMsg');
          }
        }

        final allAttachmentsFailed = successCount == 0 && failCount > 0;
        if (allAttachmentsFailed) {
          log?.call('Todos os anexos falharam. Não criar follow-up vazio.');
          final attachmentErrors = errors.join('; ');
          return {
            'success': false,
            'messageSent': false,
            'interactionCreated': false,
            'attachmentsSuccess': successCount,
            'attachmentsFail': failCount,
            'errors': errors,
            'error': attachmentErrors.isEmpty
                ? 'Nenhum anexo foi enviado.'
                : 'Nenhum anexo foi enviado: $attachmentErrors',
          };
        }

        if (successCount > 0) {
          log?.call(
            '$successCount anexo(s) enviado(s). Criar follow-up placeholder.',
          );
          final result = isSolution
              ? await apiService.addTicketSolution(
                  ticketId,
                  '[Anexo enviado pelo aplicativo]',
                  sessionToken,
                )
              : await apiService.addTicketMessage(
                  ticketId,
                  '[Anexo enviado pelo aplicativo]',
                  sessionToken,
                );

          if (result['success'] != true) {
            final err = _normalizeInteractionError(
              result['error']?.toString() ?? 'Falha ao criar follow-up.',
              isSolution: isSolution,
            );
            if (isSessionInvalidError(err)) {
              await handleSessionInvalid(err);
            }
            return {
              'success': false,
              'error': err,
              'attachmentsSuccess': successCount,
              'attachmentsFail': failCount,
            };
          }

          interactionId = result['entity_id']?.toString();
          interactionType = isSolution ? 'ITILSolution' : 'ITILFollowup';
          messageSent = false;
        }
      } else if (mustCreateInteraction) {
        final result = isSolution
            ? await apiService.addTicketSolution(
                ticketId,
                trimmedMessage,
                sessionToken,
              )
            : await apiService.addTicketMessage(
                ticketId,
                trimmedMessage,
                sessionToken,
              );

        if (result['success'] != true) {
          final err = _normalizeInteractionError(
            result['error']?.toString() ?? 'Falha ao enviar interação.',
            isSolution: isSolution,
          );
          if (isSessionInvalidError(err)) {
            await handleSessionInvalid(err);
          }
          return {'success': false, 'error': err};
        }

        interactionId = result['entity_id']?.toString();
        interactionType = isSolution ? 'ITILSolution' : 'ITILFollowup';
        messageSent = true;

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

        for (final attachment in attachments) {
          final uploadResult = await _uploadAndLinkAttachment(
            apiService: apiService,
            sessionToken: sessionToken,
            ticketId: ticketId,
            attachment: attachment,
            targetItemType: interactionType,
            targetItemId: interactionId,
            isSessionInvalidError: isSessionInvalidError,
            handleSessionInvalid: handleSessionInvalid,
            log: log,
          );
          if (uploadResult['success'] == true) {
            successCount++;
          } else {
            failCount++;
            final errorMsg = uploadResult['error'] ?? 'Erro desconhecido';
            errors.add('${attachment.filename}: $errorMsg');
          }
        }
      }

      final attachmentErrors = errors.join('; ');
      final interactionCreated =
          interactionId != null && interactionId.trim().isNotEmpty;

      final isSuccess = messageSent || successCount > 0;
      return {
        'success': isSuccess,
        'messageSent': messageSent,
        'interactionCreated': interactionCreated,
        'interactionId': interactionId,
        'interactionType': interactionType,
        'attachmentsSuccess': successCount,
        'attachmentsFail': failCount,
        'partialFailure': isSuccess && failCount > 0,
        if (isSuccess && failCount > 0)
          'warning': attachmentErrors.isEmpty
              ? 'Mensagem enviada, mas houve falha em anexo.'
              : 'Mensagem enviada, mas houve falha em anexo: $attachmentErrors',
        if (!isSuccess) 'error': 'Nada foi enviado.',
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

  static Future<Map<String, dynamic>> _uploadAndLinkAttachment({
    required GlpiClient apiService,
    required String sessionToken,
    required String ticketId,
    required GlpiTicketAttachment attachment,
    String? targetItemType,
    String? targetItemId,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    final hasSpecificTarget =
        targetItemType != null &&
        targetItemType.trim().isNotEmpty &&
        targetItemId != null &&
        targetItemId.trim().isNotEmpty;

    try {
      if (hasSpecificTarget) {
        await apiService.uploadAndAttachToItem(
          sessionToken: sessionToken,
          itemType: targetItemType,
          itemId: targetItemId,
          bytes: attachment.bytes,
          filename: attachment.filename,
          mimeType: attachment.mimeType,
        );
      } else {
        await apiService.uploadAndAttachToTicket(
          sessionToken: sessionToken,
          ticketId: ticketId,
          bytes: attachment.bytes,
          filename: attachment.filename,
          mimeType: attachment.mimeType,
        );
      }
      return {'success': true};
    } catch (uploadError) {
      Object effectiveError = uploadError;

      if (hasSpecificTarget) {
        log?.call(
          'Falha ao vincular anexo em $targetItemType/$targetItemId. '
          'Aplicando fallback para Ticket/$ticketId: $uploadError',
        );
        try {
          await apiService.uploadAndAttachToTicket(
            sessionToken: sessionToken,
            ticketId: ticketId,
            bytes: attachment.bytes,
            filename: attachment.filename,
            mimeType: attachment.mimeType,
          );
          return {'success': true, 'fallback': true};
        } catch (fallbackError) {
          effectiveError = fallbackError;
        }
      }

      if (isSessionInvalidError(effectiveError)) {
        await handleSessionInvalid(effectiveError);
      }
      return {'success': false, 'error': effectiveError.toString()};
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
