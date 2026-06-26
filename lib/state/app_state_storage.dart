import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/glpi_ticket.dart';

class AppSessionSnapshot {
  const AppSessionSnapshot({
    this.sessionToken,
    this.loggedUsername,
    this.activeProfile,
    this.activeEntityId,
    this.activeEntityName,
    this.defaultEntityId,
    this.selectedTicketEntityId,
    this.selectedTicketEntityName,
  });

  final String? sessionToken;
  final String? loggedUsername;
  final String? activeProfile;
  final int? activeEntityId;
  final String? activeEntityName;
  final int? defaultEntityId;
  final int? selectedTicketEntityId;
  final String? selectedTicketEntityName;
}

class AppStateStorage {
  static const String _pendingTicketsKey = 'pendingTickets';

  // Bytes acima deste limite por ticket não são persistidos em SharedPreferences.
  // No mobile, o sync relê o arquivo pelo path; na web, o anexo grande não pode
  // ser salvo offline e o usuário deve reenviar quando houver conexão.
  static const int maxOfflineAttachmentBytes = 10 * 1024 * 1024; // 10 MB
  static const String _sessionTokenKey = 'sessionToken';
  static const String _loggedUsernameKey = 'loggedUsername';
  static const String _activeProfileKey = 'activeProfile';
  static const String _activeEntityIdKey = 'activeEntityId';
  static const String _activeEntityNameKey = 'activeEntityName';
  static const String _defaultEntityIdKey = 'defaultEntityId';
  static const String _selectedTicketEntityIdKey = 'selectedTicketEntityId';
  static const String _selectedTicketEntityNameKey = 'selectedTicketEntityName';
  static const String _ticketReadPrefix = 'ticket_read_';

  static Future<List<GlpiTicket>> loadPendingTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsJson = prefs.getStringList(_pendingTicketsKey) ?? const [];
    return ticketsJson
        .map((jsonString) => GlpiTicket.fromMap(json.decode(jsonString)))
        .toList();
  }

  static Future<void> savePendingTickets(List<GlpiTicket> tickets) async {
    final prefs = await SharedPreferences.getInstance();
    final ticketsJson = tickets.map((ticket) {
      final map = ticket.toMap();
      final bytesList = map['attachmentBytesList'];
      if (bytesList is List && bytesList.isNotEmpty) {
        final totalBytes = bytesList.fold<int>(
          0,
          (sum, b) => sum + (b is List ? b.length : 0),
        );
        if (totalBytes > maxOfflineAttachmentBytes) {
          map['attachmentBytesList'] = <List<int>>[];
        }
      }
      return json.encode(map);
    }).toList();
    await prefs.setStringList(_pendingTicketsKey, ticketsJson);
  }

  static Future<AppSessionSnapshot> loadSessionSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSessionSnapshot(
      sessionToken: prefs.getString(_sessionTokenKey),
      loggedUsername: prefs.getString(_loggedUsernameKey),
      activeProfile: prefs.getString(_activeProfileKey),
      activeEntityId: prefs.getInt(_activeEntityIdKey),
      activeEntityName: prefs.getString(_activeEntityNameKey),
      defaultEntityId: prefs.getInt(_defaultEntityIdKey),
      selectedTicketEntityId: prefs.getInt(_selectedTicketEntityIdKey),
      selectedTicketEntityName: prefs.getString(_selectedTicketEntityNameKey),
    );
  }

  static Future<void> saveSessionSnapshot({
    required String sessionToken,
    required String loggedUsername,
    String? activeProfile,
    int? activeEntityId,
    String? activeEntityName,
    int? defaultEntityId,
    int? selectedTicketEntityId,
    String? selectedTicketEntityName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, sessionToken);
    await prefs.setString(_loggedUsernameKey, loggedUsername);

    if (activeProfile != null && activeProfile.trim().isNotEmpty) {
      await prefs.setString(_activeProfileKey, activeProfile);
    } else {
      await prefs.remove(_activeProfileKey);
    }

    if (activeEntityId != null && activeEntityId > 0) {
      await prefs.setInt(_activeEntityIdKey, activeEntityId);
    } else {
      await prefs.remove(_activeEntityIdKey);
    }

    if (activeEntityName != null && activeEntityName.trim().isNotEmpty) {
      await prefs.setString(_activeEntityNameKey, activeEntityName);
    } else {
      await prefs.remove(_activeEntityNameKey);
    }

    if (defaultEntityId != null && defaultEntityId > 0) {
      await prefs.setInt(_defaultEntityIdKey, defaultEntityId);
    } else {
      await prefs.remove(_defaultEntityIdKey);
    }

    if (selectedTicketEntityId != null && selectedTicketEntityId > 0) {
      await prefs.setInt(_selectedTicketEntityIdKey, selectedTicketEntityId);
    } else {
      await prefs.remove(_selectedTicketEntityIdKey);
    }

    if (selectedTicketEntityName != null &&
        selectedTicketEntityName.trim().isNotEmpty) {
      await prefs.setString(
        _selectedTicketEntityNameKey,
        selectedTicketEntityName,
      );
    } else {
      await prefs.remove(_selectedTicketEntityNameKey);
    }
  }

  static Future<void> clearSessionSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_loggedUsernameKey);
    await prefs.remove(_activeProfileKey);
    await prefs.remove(_activeEntityIdKey);
    await prefs.remove(_activeEntityNameKey);
    await prefs.remove(_defaultEntityIdKey);
    await prefs.remove(_selectedTicketEntityIdKey);
    await prefs.remove(_selectedTicketEntityNameKey);
  }

  static Future<Map<String, String>> loadReadDates() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, String>{};

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_ticketReadPrefix)) continue;
      final ticketId = key.replaceFirst(_ticketReadPrefix, '');
      final storedDate = prefs.getString(key);
      if (storedDate != null && storedDate.isNotEmpty) {
        result[ticketId] = storedDate;
      }
    }

    return result;
  }

  static Future<void> saveReadDate(String ticketId, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_ticketReadPrefix$ticketId', timestamp);
  }
}
