/// Classe utilitária para formatação de nomes de usuários do GLPI
///
/// Compatível com:
/// - Chamadas antigas: getFriendlyName(rawName)
/// - Chamadas novas: getFriendlyName(firstname:..., realname:..., username:...)
///
/// Respeita a configuração de formato de nomes do sistema GLPI (names_format)
class GlpiNameFormatter {

  /// Constantes para os formatos de nomes
  static const int firstNameBefore = 1;
  static const int realNameBefore = 0;

  /// ----------------------------------------------------------
  /// ENGINE PRINCIPAL (vinda da branch main)
  /// ----------------------------------------------------------
  static String formatName({
    required String? firstname,
    required String? realname,
    required String username,
    int nameFormat = firstNameBefore,
  }) {
    final cleanFirstname = _sanitize(firstname);
    final cleanRealname = _sanitize(realname);
    final cleanUsername = _sanitize(username);

    if (cleanFirstname.isEmpty && cleanRealname.isEmpty) {
      return cleanUsername.isNotEmpty ? cleanUsername : 'Usuário Desconhecido';
    }

    if (cleanFirstname.isEmpty) {
      return cleanRealname;
    }

    if (cleanRealname.isEmpty) {
      return cleanFirstname;
    }

    if (nameFormat == realNameBefore) {
      return '$cleanRealname $cleanFirstname';
    } else {
      return '$cleanFirstname $cleanRealname';
    }
  }

  /// ----------------------------------------------------------
  /// FORMATA A PARTIR DE MAP (GLPI API)
  /// ----------------------------------------------------------
  static String formatNameFromMap(
    Map<String, dynamic> userMap, {
    int nameFormat = firstNameBefore,
  }) {
    final firstname = userMap['firstname'] ?? userMap['first_name'];
    final realname = userMap['realname'] ?? userMap['real_name'];
    final username = userMap['name'] ?? userMap['login'] ?? 'Usuário';

    return formatName(
      firstname: firstname,
      realname: realname,
      username: username?.toString() ?? 'Usuário',
      nameFormat: nameFormat,
    );
  }

  /// ----------------------------------------------------------
  /// COMPATIBILIDADE COM CÓDIGO ANTIGO (HEAD)
  /// ----------------------------------------------------------
  static String getFriendlyName(
    String? rawName, {
    String? firstname,
    String? realname,
    String? username,
    int nameFormat = firstNameBefore,
  }) {

    // Se vier firstname/realname usa o novo sistema
    if (firstname != null || realname != null) {
      return formatName(
        firstname: firstname,
        realname: realname,
        username: username ?? rawName ?? 'Usuário',
        nameFormat: nameFormat,
      );
    }

    // Caso antigo (rawName)
    if (rawName != null && rawName.trim().isNotEmpty) {
      return _cleanUser(rawName);
    }

    return 'Desconhecido';
  }

  /// ----------------------------------------------------------
  /// REMOVE DOMÍNIO OU EMAIL (HEAD)
  /// ----------------------------------------------------------
  static String _cleanUser(String value) {
    final cleaned = value.trim();

    if (cleaned.contains('@')) {
      return cleaned.split('@').first;
    }

    if (cleaned.contains('\\')) {
      return cleaned.split('\\').last;
    }

    return cleaned;
  }

  /// ----------------------------------------------------------
  /// SANITIZA STRINGS
  /// ----------------------------------------------------------
  static String _sanitize(String? input) {
    if (input == null || input.isEmpty) return '';

    final trimmed = input.trim();

    if (trimmed.toLowerCase() == 'null') return '';

    return trimmed;
  }

  /// ----------------------------------------------------------
  /// UTILIDADES
  /// ----------------------------------------------------------
  static bool hasValidName({
    required String? firstname,
    required String? realname,
  }) {
    final cleanFirstname = _sanitize(firstname);
    final cleanRealname = _sanitize(realname);

    return cleanFirstname.isNotEmpty || cleanRealname.isNotEmpty;
  }

  static String getShortName({
    required String? firstname,
    required String? realname,
    required String username,
  }) {
    final cleanFirstname = _sanitize(firstname);

    if (cleanFirstname.isNotEmpty) {
      return cleanFirstname;
    }

    final cleanRealname = _sanitize(realname);
    if (cleanRealname.isNotEmpty) {
      return cleanRealname;
    }

    return _sanitize(username);
  }
}
