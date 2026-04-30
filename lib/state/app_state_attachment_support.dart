import 'dart:io';
import 'dart:typed_data';

import '../models/glpi_status.dart';
import '../services/glpi_client.dart';

class AppStateAttachmentSupport {
  static Future<Map<String, dynamic>> uploadAndLinkImage({
    required GlpiClient apiService,
    required bool isAuthenticated,
    required String? sessionToken,
    required String ticketId,
    required String imagePath,
    String? targetItemType,
    String? targetItemId,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    if (!isAuthenticated || sessionToken == null) {
      log?.call('Nao autenticado para enviar imagem');
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

      final file = File(imagePath);
      if (!await file.exists()) {
        log?.call('Arquivo nao encontrado: $imagePath');
        return {'success': false, 'error': 'Arquivo não encontrado'};
      }

      final hasSpecificTarget =
          targetItemType != null &&
          targetItemType.trim().isNotEmpty &&
          targetItemId != null &&
          targetItemId.trim().isNotEmpty;

      if (hasSpecificTarget) {
        log?.call(
          '[UPLOAD] Fazendo upload para entidade da interacao: $targetItemType/$targetItemId',
        );
      } else {
        log?.call(
          '[UPLOAD] Fazendo upload no ticket raiz ($ticketId) por falta de entidade da interacao.',
        );
      }

      final bytes = await file.readAsBytes();
      final filename = file.path.split(Platform.pathSeparator).last;

      try {
        if (hasSpecificTarget) {
          await apiService.uploadAndAttachToItem(
            sessionToken: sessionToken,
            itemType: targetItemType,
            itemId: targetItemId,
            bytes: bytes,
            filename: filename,
          );
        } else {
          await apiService.uploadAndAttachToTicket(
            sessionToken: sessionToken,
            ticketId: ticketId,
            bytes: bytes,
            filename: filename,
          );
        }

        log?.call('Arquivo enviado e vinculado com sucesso');
        return {'success': true};
      } catch (uploadError) {
        Object effectiveError = uploadError;

        if (hasSpecificTarget) {
          log?.call(
            'Falha ao vincular em $targetItemType/$targetItemId. Aplicando fallback para Ticket/$ticketId: $uploadError',
          );
          try {
            await apiService.uploadAndAttachToTicket(
              sessionToken: sessionToken,
              ticketId: ticketId,
              bytes: bytes,
              filename: filename,
            );
            return {'success': true, 'fallback': true};
          } catch (fallbackError) {
            effectiveError = fallbackError;
          }
        }

        if (isSessionInvalidError(effectiveError)) {
          await handleSessionInvalid(effectiveError);
        }

        log?.call('Erro ao fazer upload/link de imagem: $effectiveError');
        return {'success': false, 'error': _mapUploadError(effectiveError)};
      }
    } catch (error) {
      if (isSessionInvalidError(error)) {
        await handleSessionInvalid(error);
      }

      log?.call('Erro geral no upload/link de imagem: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  static Future<Uint8List?> downloadImage({
    required GlpiClient apiService,
    required bool isAuthenticated,
    required String? sessionToken,
    required String url,
    required bool Function(Object error) isSessionInvalidError,
    required Future<void> Function(Object error) handleSessionInvalid,
    void Function(String message)? log,
  }) async {
    if (!isAuthenticated || sessionToken == null) {
      log?.call('Nao autenticado para baixar imagem');
      return null;
    }

    try {
      log?.call('Baixando imagem: $url');
      final imageBytes = await apiService.downloadSecureImage(url, sessionToken);

      if (imageBytes != null) {
        log?.call('Imagem baixada com sucesso (${imageBytes.length} bytes)');
      } else {
        log?.call('Imagem retornou nula');
      }

      return imageBytes;
    } catch (error) {
      if (isSessionInvalidError(error)) {
        await handleSessionInvalid(error);
      }

      log?.call('Erro ao baixar imagem: $error');
      return null;
    }
  }

  static String _mapUploadError(Object error) {
    var errorMessage = error.toString();

    if (errorMessage.contains('403') || errorMessage.contains('Forbidden')) {
      return 'Permissão negada. Seu perfil pode não ter acesso a esta operação.';
    }

    if (errorMessage.contains('401') || errorMessage.contains('Unauthorized')) {
      return 'Não autorizado. Sessão pode ter expirado.';
    }

    if (errorMessage.contains('400')) {
      return 'Arquivo rejeitado (tamanho ou extensão inválida).';
    }

    return errorMessage;
  }
}
