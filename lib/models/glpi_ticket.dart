import 'dart:typed_data';

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
  final List<List<int>> attachmentBytesList;
  final List<String> attachmentNameList;
  final List<String?> attachmentMimeList;
  final List<String> attachmentPathsList;

  /// Campos do formData original (ex.: `governedCategoryId`, `governedLocationId`,
  /// `governedEntityId`, `governedFormId`) que não têm campo dedicado nesta classe.
  /// Preservado para que a ressubmissão offline (`synchronizeTickets`) reconstrua
  /// o payload com os MESMOS IDs governados resolvidos originalmente, em vez de
  /// cair silenciosamente em busca legada por nome de serviço/string. Só guarda
  /// valores JSON-safe (instâncias de classe como `GovernedSubmissionContract`
  /// nunca sobrevivem ao round-trip local via SharedPreferences).
  final Map<String, dynamic> rawFormData;

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
    this.attachmentBytesList = const [],
    this.attachmentNameList = const [],
    this.attachmentMimeList = const [],
    this.attachmentPathsList = const [],
    this.rawFormData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      ...rawFormData,
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
      'attachmentBytesList': attachmentBytesList,
      'attachmentNameList': attachmentNameList,
      'attachmentMimeList': attachmentMimeList,
      'attachmentPathsList': attachmentPathsList,
    };
  }

  factory GlpiTicket.fromMap(Map<String, dynamic> map) {
    final attachmentBytes = _parseBytesList(
      map['attachmentBytesList'] ??
          map['attachmentsBytes'] ??
          map['attachmentBytesArray'],
    );
    final singleAttachmentBytes = _parseBytes(map['attachmentBytes']);
    final restoredBytes = attachmentBytes.isNotEmpty
        ? attachmentBytes
        : [if (singleAttachmentBytes != null) singleAttachmentBytes];

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
      attachmentBytesList: restoredBytes,
      attachmentNameList:
          _parseStringList(
            map['attachmentNameList'] ??
                map['attachmentNames'] ??
                map['attachmentsNames'],
          ).ifEmpty(
            map['attachmentName']?.toString() ?? map['anexoName']?.toString(),
          ),
      attachmentMimeList: _parseNullableStringList(
        map['attachmentMimeList'] ??
            map['attachmentMimes'] ??
            map['attachmentsMimes'],
      ).ifEmpty(map['attachmentMime']?.toString()),
      attachmentPathsList:
          _parseStringList(
            map['attachmentPathsList'] ??
                map['attachmentPathList'] ??
                map['attachmentPaths'],
          ).ifEmpty(
            map['attachmentPath']?.toString() ?? map['anexoPath']?.toString(),
          ),
      rawFormData: _jsonSafeSubset(map),
    );
  }

  static Map<String, dynamic> _jsonSafeSubset(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      if (_isJsonSafe(entry.value)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  static bool _isJsonSafe(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return true;
    }
    if (value is List) return value.every(_isJsonSafe);
    if (value is Map) {
      return value.keys.every((key) => key is String) &&
          value.values.every(_isJsonSafe);
    }
    return false;
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

  static List<List<int>> _parseBytesList(dynamic value) {
    if (value is! List) return const [];
    if (value.isEmpty) return const [];

    final single = _parseBytes(value);
    if (single != null) return [single];

    return value
        .map(_parseBytes)
        .whereType<List<int>>()
        .toList(growable: false);
  }

  static List<int>? _parseBytes(dynamic value) {
    if (value == null) return null;
    if (value is Uint8List) return value.toList(growable: false);
    if (value is List<int>) return List<int>.from(value);
    if (value is List) {
      final bytes = <int>[];
      for (final item in value) {
        final byte = item is int
            ? item
            : item is num
            ? item.toInt()
            : null;
        if (byte == null || byte < 0 || byte > 255) return null;
        bytes.add(byte);
      }
      return bytes;
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static List<String?> _parseNullableStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) {
          final text = item?.toString().trim();
          return text == null || text.isEmpty ? null : text;
        })
        .toList(growable: false);
  }
}

extension _StringListFallback on List<String> {
  List<String> ifEmpty(String? fallback) {
    final text = fallback?.trim();
    if (isNotEmpty || text == null || text.isEmpty) return this;
    return [text];
  }
}

extension _NullableStringListFallback on List<String?> {
  List<String?> ifEmpty(String? fallback) {
    final text = fallback?.trim();
    if (isNotEmpty || text == null || text.isEmpty) return this;
    return [text];
  }
}
