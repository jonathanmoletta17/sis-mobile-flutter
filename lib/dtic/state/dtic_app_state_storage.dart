import 'package:shared_preferences/shared_preferences.dart';

class DticSessionSnapshot {
  const DticSessionSnapshot({
    this.sessionToken,
    this.username,
    this.profile,
    this.activeEntityId,
    this.activeEntityName,
  });

  final String? sessionToken;
  final String? username;
  final String? profile;
  final int? activeEntityId;
  final String? activeEntityName;
}

class DticAppStateStorage {
  static const _prefix = 'dtic.';
  static const _sessionTokenKey = '${_prefix}sessionToken';
  static const _usernameKey = '${_prefix}username';
  static const _profileKey = '${_prefix}profile';
  static const _activeEntityIdKey = '${_prefix}activeEntityId';
  static const _activeEntityNameKey = '${_prefix}activeEntityName';
  static const _ticketReadPrefix = '${_prefix}ticketRead.';

  static Future<DticSessionSnapshot> loadSessionSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return DticSessionSnapshot(
      sessionToken: prefs.getString(_sessionTokenKey),
      username: prefs.getString(_usernameKey),
      profile: prefs.getString(_profileKey),
      activeEntityId: prefs.getInt(_activeEntityIdKey),
      activeEntityName: prefs.getString(_activeEntityNameKey),
    );
  }

  static Future<void> saveSessionSnapshot({
    required String sessionToken,
    required String username,
    String? profile,
    int? activeEntityId,
    String? activeEntityName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, sessionToken);
    await prefs.setString(_usernameKey, username);
    await _setOptionalString(prefs, _profileKey, profile);
    await _setOptionalString(prefs, _activeEntityNameKey, activeEntityName);

    if (activeEntityId != null && activeEntityId > 0) {
      await prefs.setInt(_activeEntityIdKey, activeEntityId);
    } else {
      await prefs.remove(_activeEntityIdKey);
    }
  }

  static Future<void> clearSessionSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_profileKey);
    await prefs.remove(_activeEntityIdKey);
    await prefs.remove(_activeEntityNameKey);
  }

  static Future<Map<String, String>> loadReadDates() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, String>{};

    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_ticketReadPrefix)) continue;
      final ticketId = key.replaceFirst(_ticketReadPrefix, '');
      final storedDate = prefs.getString(key);
      if (ticketId.isNotEmpty && storedDate != null && storedDate.isNotEmpty) {
        result[ticketId] = storedDate;
      }
    }

    return result;
  }

  static Future<void> saveReadDate(String ticketId, String timestamp) async {
    final normalizedId = ticketId.trim();
    if (normalizedId.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_ticketReadPrefix$normalizedId', timestamp);
  }

  static Future<void> _setOptionalString(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, normalized);
  }
}
