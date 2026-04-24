class GlpiTicket {
  final String serviceName;
  final String atendimentoPara;
  final String? nomePessoa;
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
}
