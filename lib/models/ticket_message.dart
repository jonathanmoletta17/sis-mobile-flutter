import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;

import '../utils/glpi_name_formatter.dart';

class TicketMessage {
  final String id;
  final String ticketId;
  final String content;
  final String sender;
  final DateTime createdAt;
  final bool isPrivate;
  final String? senderType;
  final List<String> imageUrls;
  final bool containsHtml;
  final String type;
  final String? mimeType;
  final String? documentUrl;
  final int? solutionStatus;
  final String? senderUserId;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.content,
    required this.sender,
    required this.createdAt,
    required this.isPrivate,
    this.senderType,
    this.imageUrls = const [],
    this.containsHtml = false,
    this.type = 'text',
    this.documentUrl,
    this.mimeType,
    this.solutionStatus,
    this.senderUserId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticketId': ticketId,
      'content': content,
      'sender': sender,
      'createdAt': createdAt.toIso8601String(),
      'isPrivate': isPrivate,
      'senderType': senderType,
      'imageUrls': imageUrls,
      'containsHtml': containsHtml,
      'type': type,
      'mimeType': mimeType,
      'documentUrl': documentUrl,
      'solutionStatus': solutionStatus,
      'senderUserId': senderUserId,
    };
  }

  static String? _extractUserId(dynamic userField) {
    if (userField == null) return null;

    if (userField is int) return userField.toString();

    if (userField is String) {
      final trimmed = userField.trim();
      return RegExp(r'^[0-9]+$').hasMatch(trimmed) ? trimmed : null;
    }

    if (userField is Map) {
      final id = userField['id'] ?? userField['users_id'];
      final idText = id?.toString().trim();
      return idText == null || idText.isEmpty ? null : idText;
    }

    return null;
  }

  static String _decodeHtml(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return '';

    try {
      String decoded = htmlText
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&amp;', '&')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&apos;', "'")
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&copy;', '©')
          .replaceAll('&reg;', '®');

      decoded = decoded.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
        try {
          final codePoint = int.parse(match.group(1)!);
          return String.fromCharCode(codePoint);
        } catch (_) {
          return match.group(0) ?? '';
        }
      });

      decoded = decoded.replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (
        match,
      ) {
        try {
          final codePoint = int.parse(match.group(1)!, radix: 16);
          return String.fromCharCode(codePoint);
        } catch (_) {
          return match.group(0) ?? '';
        }
      });

      if (decoded.contains('<') && decoded.contains('>')) {
        try {
          final document = html_parser.parse(decoded);
          document.querySelectorAll('script, style').forEach((e) => e.remove());
          final text = document.body?.text ?? decoded;
          return text.replaceAll(RegExp(r'\s+'), ' ').trim();
        } catch (e) {
          debugPrint('Erro ao fazer parse HTML: $e');
          return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
        }
      }

      return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
    } catch (e) {
      debugPrint('Erro ao decodificar HTML: $e');
      return htmlText;
    }
  }

  static List<String> _extractImageUrls(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return [];

    final imageUrls = <String>[];

    try {
      final document = html_parser.parse(htmlText);
      final images = document.querySelectorAll('img');

      for (final img in images) {
        final src = img.attributes['src'];
        if (src != null && src.isNotEmpty) {
          imageUrls.add(src);
        }
      }
    } catch (_) {
      final imgRegex = RegExp(r'<img[^>]*src="([^"]+)"');
      for (final match in imgRegex.allMatches(htmlText)) {
        final src = match.group(1);
        if (src != null) {
          imageUrls.add(src);
        }
      }
    }

    return imageUrls;
  }

  factory TicketMessage.fromMap(Map<String, dynamic> map) {
    final rawContent =
        map['content']?.toString() ?? map['text']?.toString() ?? '';

    final hadHtml =
        rawContent.contains('<') ||
        rawContent.contains('&#') ||
        rawContent.contains('&lt;') ||
        rawContent.contains('&gt;');

    final cleanedContent = _decodeHtml(rawContent);

    if (hadHtml && rawContent.isNotEmpty) {
      debugPrint('[DECODE_HTML] Raw: $rawContent');
      debugPrint('[DECODE_HTML] Cleaned: $cleanedContent');
    }

    final imageUrls = _extractImageUrls(rawContent);

    String senderName = 'Desconhecido';
    final userIdField = map['users_id'] ?? map['users_id_editor'];
    final senderUserId = _extractUserId(userIdField);

    if (userIdField is String) {
      senderName = GlpiNameFormatter.getFriendlyName(userIdField);
    } else if (userIdField is Map) {
      final userData = userIdField as Map<String, dynamic>;
      senderName = GlpiNameFormatter.getFriendlyName(
        null,
        firstname: userData['firstname'],
        realname: userData['realname'],
        username:
            userData['name']?.toString() ??
            userData['login']?.toString() ??
            userData['id']?.toString() ??
            userData['users_id']?.toString() ??
            'Desconhecido',
      );
    } else if (userIdField is int) {
      senderName = GlpiNameFormatter.fallbackUserLabel(userIdField);
    }

    return TicketMessage(
      id: map['id']?.toString() ?? '',
      ticketId: map['tickets_id']?.toString() ?? '',
      content: cleanedContent,
      sender: senderName,
      createdAt: _parseDateSafely(map),
      isPrivate: (map['is_private'] ?? 0) == 1,
      senderType: map['senderType'] ?? _inferSenderType(map),
      imageUrls: imageUrls,
      containsHtml: hadHtml,
      type: 'text',
      senderUserId: senderUserId,
    );
  }

  factory TicketMessage.fromSolutionMap(Map<String, dynamic> map) {
    final rawContent = map['content']?.toString() ?? '';
    final cleanedContent = _decodeHtml(rawContent);
    final imageUrls = _extractImageUrls(rawContent);

    String senderName = 'Tecnico';
    final userIdField = map['users_id'];
    final senderUserId = _extractUserId(userIdField);

    if (userIdField is String) {
      senderName = GlpiNameFormatter.getFriendlyName(userIdField);
    } else if (userIdField is Map) {
      final userData = userIdField as Map<String, dynamic>;
      final username =
          userData['name']?.toString() ?? userData['login']?.toString();
      senderName =
          username == null &&
              GlpiNameFormatter.extractNumericId(userData) != null
          ? GlpiNameFormatter.fallbackUserLabel(userData, prefix: 'Tecnico')
          : GlpiNameFormatter.getFriendlyName(
              null,
              firstname: userData['firstname'],
              realname: userData['realname'],
              username: username ?? 'Tecnico',
            );
    } else if (userIdField is int) {
      senderName = GlpiNameFormatter.fallbackUserLabel(
        userIdField,
        prefix: 'Tecnico',
      );
    }

    var parsedStatus = 2;
    if (map['status'] != null) {
      final statStr = map['status'].toString().toLowerCase();
      if (statStr.contains('aguardando') ||
          statStr.contains('waiting') ||
          statStr == '1' ||
          statStr == '2') {
        parsedStatus = 2;
      } else if (statStr.contains('aprovad') ||
          statStr.contains('approved') ||
          statStr.contains('accept') ||
          statStr == '3') {
        parsedStatus = 3;
      } else if (statStr.contains('recusad') ||
          statStr.contains('refused') ||
          statStr.contains('reject') ||
          statStr == '4') {
        parsedStatus = 4;
      } else {
        parsedStatus = int.tryParse(statStr) ?? 2;
      }
    }

    return TicketMessage(
      id: map['id']?.toString() ?? '',
      ticketId:
          map['items_id']?.toString() ?? map['tickets_id']?.toString() ?? '',
      content: cleanedContent.isEmpty
          ? 'Solução submetida sem texto.'
          : cleanedContent,
      sender: senderName,
      createdAt: _parseDateSafely(map),
      isPrivate: false,
      senderType: 'tech',
      imageUrls: imageUrls,
      containsHtml: rawContent.contains('<'),
      type: 'solution',
      solutionStatus: parsedStatus,
      senderUserId: senderUserId,
    );
  }

  factory TicketMessage.fromDocumentMap(Map<String, dynamic> docMap) {
    final date = docMap['date_creation'] != null
        ? DateTime.parse(docMap['date_creation'].toString())
        : DateTime.now();

    String uploaderName = 'Sistema';
    final uploaderIdField = docMap['uploader_id'] ?? docMap['users_id'];
    final senderUserId = _extractUserId(uploaderIdField);
    final uploaderField =
        docMap['uploader_name'] ??
        docMap['users_name'] ??
        docMap['users_id'] ??
        docMap['uploader_id'];

    if (uploaderField is String) {
      uploaderName = GlpiNameFormatter.getFriendlyName(uploaderField);
    } else if (uploaderField is Map) {
      final userData = uploaderField as Map<String, dynamic>;
      uploaderName = GlpiNameFormatter.getFriendlyName(
        null,
        firstname: userData['firstname'],
        realname: userData['realname'],
        username:
            userData['name']?.toString() ??
            userData['login']?.toString() ??
            userData['id']?.toString() ??
            userData['users_id']?.toString() ??
            'Sistema',
      );
    } else if (uploaderField is int) {
      uploaderName = GlpiNameFormatter.fallbackUserLabel(uploaderField);
    }

    return TicketMessage(
      id: 'doc-${docMap['id']}',
      ticketId: docMap['items_id']?.toString() ?? '',
      content: docMap['name'] ?? 'Arquivo',
      sender: uploaderName,
      createdAt: date,
      isPrivate: false,
      senderType: 'user',
      type: 'attachment',
      mimeType: docMap['mime']?.toString() ?? 'application/octet-stream',
      documentUrl:
          docMap['download_url']?.toString() ?? docMap['filepath']?.toString(),
      senderUserId: senderUserId,
    );
  }

  static DateTime _parseDateSafely(Map<String, dynamic> map) {
    try {
      if (map['date_creation'] != null) {
        return DateTime.parse(map['date_creation'].toString());
      }
      if (map['createdAt'] != null) {
        return DateTime.parse(map['createdAt'].toString());
      }
    } catch (e) {
      debugPrint('Erro ao fazer parse de data: $e');
    }
    return DateTime.now();
  }

  static String? _inferSenderType(Map<String, dynamic> map) {
    if ((map['is_private'] ?? 0) == 1) return 'tech';
    if (map['users_id'] != null) return 'user';
    return null;
  }

  factory TicketMessage.system({
    required String ticketId,
    required String content,
    required DateTime createdAt,
  }) {
    return TicketMessage(
      id: 'system-${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      content: content,
      sender: 'Sistema',
      createdAt: createdAt,
      isPrivate: false,
      senderType: 'system',
    );
  }

  String get initials {
    final parts = sender.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  int get senderColorHash => sender.hashCode;
}
