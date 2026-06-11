class GlpiTicket {
  final String serviceName;
  final String atendimentoPara;
  final String? nomePessoa;
  final int? beneficiaryUserId;
  final String? beneficiaryUserName;
  final int? beneficiaryEntityId;
  final int? loggedUserId;
  final List<Map<String, dynamic>> governedActors;
  final int? entitiesId;
  final String? entityName;
  final String localizacao;
  final String telefone;
  final String? urgencia;
  final String tipo;
  final String assunto;
  final String descricao;
  final String? anexoPath;
  final String? anexoName;

  GlpiTicket({
    required this.serviceName,
    required this.atendimentoPara,
    this.nomePessoa,
    this.beneficiaryUserId,
    this.beneficiaryUserName,
    this.beneficiaryEntityId,
    this.loggedUserId,
    this.governedActors = const [],
    this.entitiesId,
    this.entityName,
    required this.localizacao,
    required this.telefone,
    this.urgencia,
    required this.tipo,
    required this.assunto,
    required this.descricao,
    this.anexoPath,
    this.anexoName,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceName': serviceName,
      'atendimentoPara': atendimentoPara,
      'nomePessoa': nomePessoa,
      'beneficiaryUserId': beneficiaryUserId,
      'beneficiaryUserName': beneficiaryUserName,
      'beneficiaryEntityId': beneficiaryEntityId,
      'loggedUserId': loggedUserId,
      'governedActors': governedActors,
      'entities_id': entitiesId,
      'entityName': entityName,
      'localizacao': localizacao,
      'telefone': telefone,
      'urgencia': urgencia,
      'tipo': tipo,
      'assunto': assunto,
      'descricao': descricao,
      'anexoPath': anexoPath,
      'anexoName': anexoName,
    };
  }

  factory GlpiTicket.fromMap(Map<String, dynamic> map) {
    return GlpiTicket(
      serviceName: map['serviceName']?.toString() ?? '',
      atendimentoPara: map['atendimentoPara']?.toString() ?? '',
      nomePessoa: map['nomePessoa'] as String?,
      beneficiaryUserId: _parseOptionalInt(map['beneficiaryUserId']),
      beneficiaryUserName: map['beneficiaryUserName']?.toString(),
      beneficiaryEntityId: _parseOptionalInt(map['beneficiaryEntityId']),
      loggedUserId: _parseOptionalInt(map['loggedUserId']),
      governedActors: _parseActorMaps(map['governedActors']),
      entitiesId: _parseOptionalInt(map['entities_id']),
      entityName: map['entityName']?.toString(),
      localizacao: map['localizacao']?.toString() ?? '',
      telefone: map['telefone']?.toString() ?? '',
      urgencia: map['urgencia'] as String?,
      tipo: map['tipo']?.toString() ?? '',
      assunto: map['assunto']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      anexoPath: map['anexoPath'] as String?,
      anexoName: map['anexoName'] as String?,
    );
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static List<Map<String, dynamic>> _parseActorMaps(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
