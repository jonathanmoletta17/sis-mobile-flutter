import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/glpi_config.dart';

class GlpiAuthFailure implements Exception {
  final String userMessage;
  final String detail;

  const GlpiAuthFailure({required this.userMessage, required this.detail});

  @override
  String toString() => detail;
}

class GlpiClientSupport {
  static void debugLog(String message) {
    if (GlpiConfig.debugLogging) {
      debugPrint(message);
    }
  }

  static void logResponse(String label, http.Response response) {
    debugLog('[$label] Status: ${response.statusCode}');
    debugLog('[$label] Body: ${response.body}');
  }

  static bool isAuthError(int statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  static Exception authException(http.Response response) {
    final apiMessage = extractApiErrorMessage(response.body);
    final body = apiMessage ?? response.body;

    if (body.contains('ERROR_RIGHT_MISSING') ||
        body.contains('permissão') ||
        body.contains('permissao')) {
      return Exception(
        'GLPI_PERMISSION_DENIED: ${response.statusCode} - $body',
      );
    }

    return Exception(
      'SESSION_INVALID_OR_EXPIRED: ${response.statusCode} - $body',
    );
  }

  static GlpiAuthFailure mapAuthenticationFailure(
    Object error, {
    int? statusCode,
    String? body,
  }) {
    final detail = error.toString();
    final normalizedBody = body?.trim() ?? '';

    if (error is TimeoutException || detail.contains('TimeoutException')) {
      return const GlpiAuthFailure(
        userMessage:
            'Tempo esgotado ao conectar no GLPI. Verifique a rede interna ou a VPN.',
        detail: 'AUTH_TIMEOUT',
      );
    }

    if (detail.contains('Failed host lookup')) {
      return const GlpiAuthFailure(
        userMessage:
            'O celular não conseguiu localizar o servidor interno da SIS. Estar no Wi-Fi não basta; a rede precisa resolver cau.ppiratini.intra.rs.gov.br.',
        detail: 'AUTH_DNS_FAILURE',
      );
    }

    if (detail.contains('Cleartext HTTP traffic') ||
        detail.contains('CLEARTEXT communication')) {
      return const GlpiAuthFailure(
        userMessage:
            'O Android bloqueou a conexão HTTP com o GLPI. Esta rede ou aparelho exige uma revisão de segurança de tráfego.',
        detail: 'AUTH_CLEARTEXT_BLOCKED',
      );
    }

    if (error is SocketException ||
        detail.contains('SocketException') ||
        detail.contains('Connection refused') ||
        detail.contains('No route to host') ||
        detail.contains('Network is unreachable')) {
      return const GlpiAuthFailure(
        userMessage:
            'O celular não conseguiu alcançar o GLPI pela rede atual. Verifique Wi-Fi corporativo, VPN e acesso ao domínio interno.',
        detail: 'AUTH_NETWORK_FAILURE',
      );
    }

    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      final apiMessage = extractApiErrorMessage(normalizedBody);
      if (apiMessage != null && apiMessage.isNotEmpty) {
        return GlpiAuthFailure(
          userMessage: 'Falha na autenticacao: $apiMessage',
          detail: 'AUTH_INVALID_CREDENTIALS: $statusCode - $apiMessage',
        );
      }

      return const GlpiAuthFailure(
        userMessage: 'Usuario ou senha invalidos.',
        detail: 'AUTH_INVALID_CREDENTIALS',
      );
    }

    return GlpiAuthFailure(
      userMessage:
          'Falha ao autenticar. Verifique os dados informados e tente novamente.',
      detail: detail,
    );
  }

  static bool isSessionInvalidException(Object error) {
    final detail = error.toString();
    return detail.contains('SESSION_INVALID_OR_EXPIRED') &&
        !detail.contains('ERROR_RIGHT_MISSING') &&
        !detail.contains('GLPI_PERMISSION_DENIED');
  }

  static bool isPermissionDeniedException(Object error) {
    final detail = error.toString();
    return detail.contains('GLPI_PERMISSION_DENIED') ||
        detail.contains('ERROR_RIGHT_MISSING') ||
        detail.contains('permissão') ||
        detail.contains('permissao');
  }

  static String? extractEntityIdFromBody(String body) {
    if (body.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final id =
            decoded['id'] ??
            decoded['items_id'] ??
            decoded['itilsolutions_id'] ??
            decoded['ticketfollowups_id'];
        return id?.toString();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String? extractDocumentIdFromBody(String body) {
    if (body.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final id = decoded['id'] ?? decoded['documents_id'];
        final normalized = id?.toString().trim();
        if (normalized == null || normalized.isEmpty) return null;
        return normalized;
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static bool isVerifiableDocumentUploadSuccess({
    required int statusCode,
    required String body,
  }) {
    if (statusCode != 200 && statusCode != 201) return false;
    return extractDocumentIdFromBody(body) != null;
  }

  static Set<String> extractDocumentIdsFromDocumentItemBody(String body) {
    if (body.trim().isEmpty) return <String>{};

    try {
      final decoded = jsonDecode(body);
      final Iterable<dynamic> rows = decoded is List
          ? decoded
          : decoded is Map<String, dynamic>
          ? [decoded]
          : const [];

      return rows
          .whereType<Map>()
          .map((row) => row['documents_id'] ?? row['id'])
          .where((id) => id != null)
          .map((id) => id.toString().trim())
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static bool hasNewDocumentLink({
    required Set<String> before,
    required Set<String> after,
  }) {
    return after.difference(before).isNotEmpty;
  }

  static bool verifiesDocumentUploadLink({
    required Set<String> before,
    required Set<String> after,
    String? documentId,
  }) {
    final newLinks = after.difference(before);
    if (newLinks.isEmpty) return false;

    final normalizedDocumentId = documentId?.trim();
    if (normalizedDocumentId == null || normalizedDocumentId.isEmpty) {
      return true;
    }

    return newLinks.contains(normalizedDocumentId) ||
        after.contains(normalizedDocumentId);
  }

  static String? extractApiErrorMessage(String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);

      if (decoded is List) {
        final values = decoded
            .whereType<Object>()
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .toList();

        if (values.isEmpty) return null;
        if (values.length == 1) return values.first;
        return values.last;
      }

      if (decoded is Map<String, dynamic>) {
        final candidates = [
          decoded['message'],
          decoded['error'],
          decoded['errors'],
          decoded['display_message'],
        ];

        for (final candidate in candidates) {
          if (candidate == null) continue;
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate.trim();
          }
          if (candidate is List) {
            final values = candidate
                .map((value) => value.toString().trim())
                .where((value) => value.isNotEmpty)
                .toList();
            if (values.isNotEmpty) {
              return values.join(' ');
            }
          }
        }
      }
    } catch (_) {
      return trimmed;
    }

    return trimmed;
  }

  static Uri buildRequesterTicketSearchUri(
    String baseUrl, {
    int? requesterUserId,
    String? requesterUsername,
    int rangeEnd = 500,
  }) {
    final value = requesterUserId != null && requesterUserId > 0
        ? requesterUserId.toString()
        : requesterUsername?.trim();
    if (value == null || value.isEmpty) {
      throw ArgumentError('requesterUserId or requesterUsername is required');
    }

    return Uri.parse('$baseUrl/search/Ticket').replace(
      queryParameters: {
        'criteria[0][field]': '4',
        'criteria[0][searchtype]':
            requesterUserId != null && requesterUserId > 0
            ? 'equals'
            : 'contains',
        'criteria[0][value]': value,
        'forcedisplay[0]': '2',
        'forcedisplay[1]': '1',
        'forcedisplay[2]': '12',
        'forcedisplay[3]': '15',
        'forcedisplay[4]': '4',
        'forcedisplay[5]': '7',
        'forcedisplay[6]': '5',
        'sort': '15',
        'order': 'DESC',
        'range': '0-$rangeEnd',
      },
    );
  }

  static Map<String, dynamic> mapSearchTicketRow(Map<String, dynamic> row) {
    final requester = row['4'] ?? row['users_id_recipient'];
    final assignee = row['5'] ?? row['users_id_assign'];
    return {
      'id': row['2'] ?? row['id'],
      'name': row['1'] ?? row['name'],
      'status': row['12'] ?? row['status'],
      'date_mod': row['15'] ?? row['date_mod'],
      'itilcategories_id': row['7'] ?? row['itilcategories_id'],
      'users_id_recipient': requester,
      'Users_id_recipient': requester,
      if (assignee != null) 'users_id_assign': assignee,
      if (assignee != null) 'Users_id_assign': assignee,
      if (row['80'] != null) 'entities_id': row['80'],
    };
  }
}
