import 'dart:io' show File;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../catalog/governed_service_catalog.dart';
import '../catalog/governed_submission_contract.dart';
import '../data/service_data.dart';

class GlpiTicketAttachment {
  const GlpiTicketAttachment({
    required this.bytes,
    required this.filename,
    this.mimeType,
  });

  final List<int> bytes;
  final String filename;
  final String? mimeType;
}

class GlpiTicketSupport {
  static String buildTicketContent(Map<String, dynamic> formData) {
    final descricaoBase = (formData['descricao'] ?? '').toString().trim();
    final atendimentoPara = (formData['atendimentoPara'] ?? '')
        .toString()
        .trim();
    final nomePessoa = (formData['nomePessoa'] ?? '').toString().trim();
    final telefone = (formData['telefone'] ?? '').toString().trim();
    final localizacao = _locationLabel(formData['localizacao']);
    final urgencia = (formData['urgencia'] ?? '').toString().trim();
    final tipo = (formData['tipo'] ?? '').toString().trim();
    final servico = (formData['serviceName'] ?? '').toString().trim();
    final campoExtra = (formData['CampoExtra'] ?? '').toString().trim();

    final buffer = StringBuffer();

    if (descricaoBase.isNotEmpty) {
      buffer.writeln(descricaoBase);
    }

    buffer.writeln('\n-- FORMULARIO DO APP');
    buffer.writeln('--------------------------------');

    if (servico.isNotEmpty) {
      buffer.writeln('Serviço: $servico');
    }
    if (atendimentoPara.isNotEmpty) {
      buffer.writeln('Atendimento para: $atendimentoPara');
    }
    if (nomePessoa.isNotEmpty) {
      buffer.writeln('Nome (outra pessoa): $nomePessoa');
    }
    if (telefone.isNotEmpty) {
      buffer.writeln('Telefone: $telefone');
    }
    if (localizacao.isNotEmpty) {
      buffer.writeln('Localização: $localizacao');
    }
    if (urgencia.isNotEmpty) {
      buffer.writeln('Urgência: $urgencia');
    }
    if (tipo.isNotEmpty) {
      buffer.writeln('Tipo: $tipo');
    }
    if (campoExtra.isNotEmpty) {
      buffer.writeln('Campo extra: $campoExtra');
    }

    final names = _extractAttachmentNames(formData);
    if (names.isNotEmpty) {
      if (names.length == 1) {
        buffer.writeln('Anexo: ${names.first}');
      } else {
        buffer.writeln('Anexos:');
        for (final name in names) {
          buffer.writeln('  - $name');
        }
      }
    }

    return buffer.toString().trim();
  }

  static String buildContactField(Map<String, dynamic> formData) {
    final telefone = (formData['telefone'] ?? '').toString().trim();
    final atendimentoPara = (formData['atendimentoPara'] ?? '')
        .toString()
        .trim();
    final nomePessoa = (formData['nomePessoa'] ?? '').toString().trim();

    final parts = <String>[];

    if (telefone.isNotEmpty) parts.add('Tel: $telefone');

    if (atendimentoPara == 'Para outra Pessoa' && nomePessoa.isNotEmpty) {
      parts.add('Para: $nomePessoa');
    }

    return parts.join(' | ');
  }

  static Map<String, dynamic> buildCreateTicketPayload(
    Map<String, dynamic> formData,
  ) {
    final contactInfo = buildContactField(formData);
    final entityId = _parseOptionalInt(formData['entities_id']);
    final governedActorFields = buildGovernedActorFields(formData);

    return {
      'input': {
        'name': formData['assunto'] ?? 'Sem assunto',
        'content': buildTicketContent(formData),
        'status': 1,
        'requesttypes_id': 1,
        if (entityId != null && entityId > 0) 'entities_id': entityId,
        'itilcategories_id':
            _parseOptionalInt(formData['governedCategoryId']) ??
            getCategoryId(formData['serviceName']),
        if (_hasGovernedLocation(
          formData['governedLocationId'] ?? formData['localizacao'],
        ))
          'locations_id': getLocationId(
            formData['governedLocationId'] ?? formData['localizacao'],
          ),
        if (formData['urgencia'] != null)
          'urgency': mapUrgency(formData['urgencia']),
        if (formData['tipo'] != null && formData['tipo'].toString().isNotEmpty)
          'type': mapType(formData['tipo']),
        if (contactInfo.isNotEmpty) 'contact': contactInfo,
        ...governedActorFields,
      },
    };
  }

  static Map<String, dynamic> buildGovernedActorFields(
    Map<String, dynamic> formData,
  ) {
    final actors = _extractGovernedActors(formData);
    if (actors.isEmpty) return const {};

    final beneficiaryUserId = _parseOptionalInt(
      formData['beneficiaryUserId'] ?? formData['thirdPartyUserId'],
    );
    final loggedUserId = _parseOptionalInt(
      formData['loggedUserId'] ?? formData['authorUserId'],
    );
    final hasOtherRequester = actors.any((actor) {
      final role = actor.role.trim().toLowerCase();
      final type = actor.type.trim().toLowerCase();
      if (role != 'requester') return false;
      if (type == 'author') return false;
      return _actorCanResolve(actor, beneficiaryUserId: beneficiaryUserId);
    });

    final userRequesters = <int>[];
    final userObservers = <int>[];
    final userAssigned = <int>[];
    final groupRequesters = <int>[];
    final groupObservers = <int>[];
    final groupAssigned = <int>[];

    for (final actor in actors) {
      final role = actor.role.trim().toLowerCase();
      final type = actor.type.trim().toLowerCase();

      if (type == 'validator' || type == 'question_group') {
        // NOTA (2026-06-14): Ignorado propositalmente para MVP (escopo TODAY).
        // 'validator': atores que validam automaticamente (seria necessário
        //              capturar e atribuir automaticamente quem valida).
        // 'question_group': grupos baseados em resposta de pergunta (seria
        //                   necessário resolver grupo após resposta do usuário).
        // Se GLPI SIS começar a exigir esses tipos, descomentar e implementar
        // (estimado 1-2 dias de trabalho, não é bloqueante para MVP).
        continue;
      }

      if (type == 'group') {
        final groupId = _positiveInt(actor.value);
        if (groupId == null) continue;
        switch (role) {
          case 'assigned':
            _addUnique(groupAssigned, groupId);
            break;
          case 'requester':
            _addUnique(groupRequesters, groupId);
            break;
          case 'observer':
            _addUnique(groupObservers, groupId);
            break;
        }
        continue;
      }

      final userId = switch (type) {
        'question_person' => beneficiaryUserId,
        'author' =>
          role == 'requester' && !hasOtherRequester ? null : loggedUserId,
        'person' => _positiveInt(actor.value),
        _ => null,
      };
      final normalizedUserId = _positiveInt(userId);
      if (normalizedUserId == null) continue;

      switch (role) {
        case 'requester':
          _addUnique(userRequesters, normalizedUserId);
          break;
        case 'observer':
          _addUnique(userObservers, normalizedUserId);
          break;
        case 'assigned':
          _addUnique(userAssigned, normalizedUserId);
          break;
      }
    }

    return {
      if (userRequesters.isNotEmpty) '_users_id_requester': userRequesters,
      if (userObservers.isNotEmpty) '_users_id_observer': userObservers,
      if (userAssigned.isNotEmpty) '_users_id_assign': userAssigned,
      if (groupAssigned.isNotEmpty) '_groups_id_assign': groupAssigned,
      if (groupRequesters.isNotEmpty) '_groups_id_requester': groupRequesters,
      if (groupObservers.isNotEmpty) '_groups_id_observer': groupObservers,
    };
  }

  static List<GovernedActor> _extractGovernedActors(
    Map<String, dynamic> formData,
  ) {
    final contract = formData['governedContract'];
    if (contract is GovernedSubmissionContract) {
      return contract.record.actors;
    }

    final record = formData['governedRecord'];
    if (record is GovernedServiceRecord) {
      return record.actors;
    }

    final rawActors = formData['governedActors'];
    if (rawActors is! List) return const [];

    return rawActors
        .map((raw) {
          if (raw is GovernedActor) return raw;
          if (raw is Map) {
            return GovernedActor.fromMap(Map<String, dynamic>.from(raw));
          }
          return null;
        })
        .whereType<GovernedActor>()
        .toList(growable: false);
  }

  static bool _actorCanResolve(
    GovernedActor actor, {
    required int? beneficiaryUserId,
  }) {
    switch (actor.type.trim().toLowerCase()) {
      case 'question_person':
        return _positiveInt(beneficiaryUserId) != null;
      case 'person':
      case 'group':
        return _positiveInt(actor.value) != null;
      default:
        return false;
    }
  }

  static void _addUnique(List<int> values, int value) {
    if (!values.contains(value)) values.add(value);
  }

  static MediaType? parseMimeType(String? mime) {
    if (mime == null || mime.trim().isEmpty) return null;
    final parts = mime.split('/');
    if (parts.length != 2) return null;
    return MediaType(parts[0], parts[1]);
  }

  static String? guessMimeFromFilename(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    if (lower.endsWith('.txt')) return 'text/plain';
    if (lower.endsWith('.avif')) return 'image/avif';
    return null;
  }

  static int? _parseOptionalInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static int? _positiveInt(dynamic value) {
    final parsed = _parseOptionalInt(value);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  static void logMultipartBasics(
    String label,
    http.MultipartRequest req,
    void Function(String) debugLog,
  ) {
    debugLog('[$label] Multipart fields: ${req.fields}');
    if (req.files.isEmpty) {
      debugLog('[$label] Multipart files: (nenhum)');
      return;
    }
    for (final file in req.files) {
      debugLog(
        '[$label] File field="${file.field}", filename="${file.filename}", length=${file.length}',
      );
    }
  }

  static Future<List<GlpiTicketAttachment>> normalizeAttachments(
    Map<String, dynamic> formData, {
    void Function(String message)? debugLog,
  }) async {
    final dynamic bytesListAny =
        formData['attachmentBytesList'] ??
        formData['attachmentsBytes'] ??
        formData['attachmentBytesArray'];
    final dynamic namesListAny =
        formData['attachmentNameList'] ??
        formData['attachmentNames'] ??
        formData['attachmentsNames'];
    final dynamic mimesListAny =
        formData['attachmentMimeList'] ??
        formData['attachmentMimes'] ??
        formData['attachmentsMimes'];
    final dynamic pathsListAny =
        formData['attachmentPathsList'] ??
        formData['attachmentPathList'] ??
        formData['attachmentPaths'];

    final dynamic singleBytesAny = formData['attachmentBytes'];
    final String singleName =
        (formData['attachmentName'] ?? formData['anexoName'] ?? '')
            .toString()
            .trim();
    final String singleMime = (formData['attachmentMime'] ?? '')
        .toString()
        .trim();
    final String singlePath =
        (formData['attachmentPath'] ?? formData['anexoPath'] ?? '')
            .toString()
            .trim();

    final attachments = <GlpiTicketAttachment>[];

    Future<void> addOne(
      dynamic bytesAny,
      String name,
      String? mime, {
      String? path,
    }) async {
      final normalizedName = name.trim();
      if (normalizedName.isEmpty) return;

      List<int>? bytes;
      if (bytesAny is Uint8List) {
        bytes = bytesAny;
      } else if (bytesAny is List<int>) {
        bytes = bytesAny;
      }

      if ((bytes == null || bytes.isEmpty) &&
          path != null &&
          path.trim().isNotEmpty) {
        try {
          bytes = await File(path).readAsBytes();
        } catch (error) {
          debugLog?.call(
            'Nao foi possivel ler bytes do path "$path" para "$normalizedName": $error',
          );
          bytes = null;
        }
      }

      if (bytes == null || bytes.isEmpty) return;

      attachments.add(
        GlpiTicketAttachment(
          bytes: bytes,
          filename: normalizedName,
          mimeType: (mime != null && mime.trim().isNotEmpty)
              ? mime.trim()
              : null,
        ),
      );
    }

    if (bytesListAny is List && namesListAny is List) {
      final length = bytesListAny.length < namesListAny.length
          ? bytesListAny.length
          : namesListAny.length;

      for (var index = 0; index < length; index++) {
        final name = namesListAny[index]?.toString().trim() ?? '';
        final mime = (mimesListAny is List && index < mimesListAny.length)
            ? mimesListAny[index]?.toString()
            : null;
        final path = (pathsListAny is List && index < pathsListAny.length)
            ? pathsListAny[index]?.toString()
            : null;

        await addOne(bytesListAny[index], name, mime, path: path);
      }
    } else {
      await addOne(singleBytesAny, singleName, singleMime, path: singlePath);
    }

    return attachments;
  }

  static int getCategoryId(dynamic categoryName) {
    return resolveServiceCategoryId(categoryName);
  }

  static int getLocationId(dynamic location) {
    if (location is int) return location;
    if (location is LocationOption) return location.id;
    if (location is Map) {
      final id = _parseOptionalInt(
        location['id'] ?? location['location_id'] ?? location['locations_id'],
      );
      if (id != null && id > 0) return id;
    }

    final raw = location?.toString().trim() ?? '';
    final match = RegExp(r'Root (\d+)').firstMatch(raw);
    if (match != null) {
      final parsed = int.tryParse(match.group(1) ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }

    throw ArgumentError.value(
      location,
      'location',
      'Localizacao SIS sem ID GLPI governado; abortando para evitar fallback silencioso para o root 1.',
    );
  }

  static int mapUrgency(dynamic urgency) {
    if (urgency is int) return urgency;
    if (urgency is num) return urgency.toInt();

    final normalized = _normalizeLabel(urgency);
    if (normalized.isEmpty) return 3;

    final withoutLegacyPrefix = normalized.replaceFirst(
      RegExp(r'^\d+\s*-\s*'),
      '',
    );

    if (withoutLegacyPrefix.contains('muito baixa')) return 1;
    if (withoutLegacyPrefix.contains('baixa')) return 2;
    if (withoutLegacyPrefix.contains('media')) return 3;
    if (withoutLegacyPrefix.contains('muito alta') ||
        withoutLegacyPrefix.contains('urgente')) {
      return 5;
    }
    if (withoutLegacyPrefix.contains('alta')) return 4;

    final numeric = int.tryParse(normalized);
    if (numeric != null) return numeric;
    return 3;
  }

  static int mapType(dynamic ticketType) {
    if (ticketType is int) return ticketType;

    final normalized = _normalizeLabel(ticketType);
    if (normalized.contains('incidente')) return 1;
    if (normalized.contains('solicitacao') || normalized.contains('servico')) {
      return 2;
    }
    return 2;
  }

  static bool _hasGovernedLocation(dynamic location) {
    if (location == null) return false;
    if (location is int) return location > 0;
    if (location is LocationOption) return location.id > 0;
    if (location is Map) {
      return _parseOptionalInt(
            location['id'] ??
                location['location_id'] ??
                location['locations_id'],
          ) !=
          null;
    }

    final raw = location.toString().trim();
    if (raw.isEmpty || raw == 'Não Informado' || raw == 'Não Aplicável') {
      return false;
    }
    return true;
  }

  static String _locationLabel(dynamic location) {
    if (location is LocationOption) return location.label.trim();
    if (location is Map) {
      final label =
          (location['label'] ?? location['full_label'] ?? location['name'])
              ?.toString()
              .trim() ??
          '';
      if (label.isNotEmpty) return label;
    }
    return (location ?? '').toString().trim();
  }

  static List<String> _extractAttachmentNames(Map<String, dynamic> formData) {
    final dynamic namesAny =
        formData['attachmentNameList'] ?? formData['attachmentNames'];
    final singleName =
        (formData['attachmentName'] ?? formData['anexoName'] ?? '')
            .toString()
            .trim();

    final names = <String>[];
    if (namesAny is List) {
      for (final item in namesAny) {
        final name = item?.toString().trim() ?? '';
        if (name.isNotEmpty) names.add(name);
      }
    } else if (singleName.isNotEmpty) {
      names.add(singleName);
    }

    return names;
  }

  static String _normalizeLabel(dynamic value) {
    return (value?.toString() ?? '')
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }
}
