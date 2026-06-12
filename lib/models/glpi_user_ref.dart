import '../utils/glpi_name_formatter.dart';

class GlpiUserRef {
  const GlpiUserRef({
    required this.id,
    required this.displayName,
    this.login,
    this.firstName,
    this.realName,
    this.defaultEntityId,
  });

  final int id;
  final String displayName;
  final String? login;
  final String? firstName;
  final String? realName;

  /// GLPI `User.entities_id`: entidade default do usuário. Para o modo
  /// FormCreator destination_entity=8, esta é a aproximação disponível hoje
  /// para a entidade do beneficiário selecionado.
  final int? defaultEntityId;

  String get label {
    final loginText = login?.trim();
    if (loginText == null ||
        loginText.isEmpty ||
        loginText == displayName ||
        displayName.contains(loginText)) {
      return displayName;
    }
    return '$displayName ($loginText)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'login': login,
      'firstName': firstName,
      'realName': realName,
      'defaultEntityId': defaultEntityId,
    };
  }

  static GlpiUserRef? fromSearchRow(Map<String, dynamic> row) {
    final id = _parseGlpiId(row['2'] ?? row['id'] ?? row['ID']);
    if (id == null || id <= 0) return null;

    final login = _fieldText(row['1'] ?? row['name'] ?? row['login']);
    final firstName = _fieldText(
      row['9'] ?? row['firstname'] ?? row['first_name'],
    );
    final realName = _fieldText(
      row['34'] ?? row['realname'] ?? row['real_name'],
    );
    final displayName = GlpiNameFormatter.formatName(
      firstname: firstName,
      realname: realName,
      username: login ?? id.toString(),
    ).trim();

    return GlpiUserRef(
      id: id,
      displayName: displayName.isEmpty
          ? 'Usuário não identificado'
          : displayName,
      login: login,
      firstName: firstName,
      realName: realName,
    );
  }

  static int? _parseGlpiId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map) return _parseGlpiId(value['id'] ?? value['value']);
    return int.tryParse(value.toString().trim());
  }

  static String? _fieldText(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return _fieldText(
        value['name'] ?? value['label'] ?? value['completename'] ?? value['id'],
      );
    }
    final text = value.toString().trim();
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }
}
