class GlpiUserRef {
  const GlpiUserRef({
    required this.id,
    required this.displayName,
    this.login,
    this.realName,
    this.defaultEntityId,
  });

  final int id;
  final String displayName;
  final String? login;
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
      'realName': realName,
      'defaultEntityId': defaultEntityId,
    };
  }
}
