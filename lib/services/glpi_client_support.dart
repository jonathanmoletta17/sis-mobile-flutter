import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/glpi_config.dart';

class GlpiAuthFailure implements Exception {
  final String userMessage;
  final String detail;

  const GlpiAuthFailure({
    required this.userMessage,
    required this.detail,
  });

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
    return Exception(
      'SESSION_INVALID_OR_EXPIRED: ${response.statusCode} - ${response.body}',
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
            'O celular nao conseguiu localizar o servidor interno da SIS. Estar no Wi-Fi nao basta; a rede precisa resolver cau.ppiratini.intra.rs.gov.br.',
        detail: 'AUTH_DNS_FAILURE',
      );
    }

    if (detail.contains('Cleartext HTTP traffic') ||
        detail.contains('CLEARTEXT communication')) {
      return const GlpiAuthFailure(
        userMessage:
            'O Android bloqueou a conexao HTTP com o GLPI. Esta rede ou aparelho exige uma revisao de seguranca de trafego.',
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
            'O celular nao conseguiu alcancar o GLPI pela rede atual. Verifique Wi-Fi corporativo, VPN e acesso ao dominio interno.',
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
      userMessage: 'Falha ao autenticar. $detail',
      detail: detail,
    );
  }

  static bool isSessionInvalidException(Object error) {
    return error.toString().contains('SESSION_INVALID_OR_EXPIRED');
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

  static Map<String, dynamic> mapSearchTicketRow(Map<String, dynamic> row) {
    final requester = row['4'] ?? row['users_id_recipient'];
    return {
      'id': row['2'] ?? row['id'],
      'name': row['1'] ?? row['name'],
      'status': row['12'] ?? row['status'],
      'date_mod': row['15'] ?? row['date_mod'],
      'itilcategories_id': row['7'] ?? row['itilcategories_id'],
      'users_id_recipient': requester,
      'Users_id_recipient': requester,
      if (row['80'] != null) 'entities_id': row['80'],
    };
  }
}
