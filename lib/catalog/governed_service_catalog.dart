import 'dart:convert';

enum GovernedTicketAudience { paraMim, paraTerceiro }

class GovernedServiceCatalog {
  final String? schemaVersion;
  final String? consumerId;
  final String? instance;
  final List<GovernedServiceRecord> records;

  const GovernedServiceCatalog({
    required this.records,
    this.schemaVersion,
    this.consumerId,
    this.instance,
  });

  factory GovernedServiceCatalog.fromJson(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('governed catalog root must be an object');
    }
    final rawRecords = decoded['records'];
    if (rawRecords is! List || rawRecords.isEmpty) {
      throw const FormatException('governed catalog records must be non-empty');
    }

    return GovernedServiceCatalog(
      schemaVersion: decoded['schema_version']?.toString(),
      consumerId: decoded['consumer_id']?.toString(),
      instance: decoded['instance']?.toString(),
      records: List<GovernedServiceRecord>.unmodifiable(
        rawRecords
            .whereType<Map>()
            .map(
              (item) => GovernedServiceRecord.fromMap(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  GovernedServiceRecord? select({
    required String profileName,
    required String serviceLabel,
    GovernedTicketAudience audience = GovernedTicketAudience.paraMim,
  }) {
    final normalizedProfile = _normalize(profileName);
    final normalizedService = _normalize(serviceLabel);
    final normalizedAudience = audience == GovernedTicketAudience.paraMim
        ? 'para_mim'
        : 'para_terceiro';

    final candidates = records
        .where((record) {
          if (_normalize(record.serviceLabel) != normalizedService &&
              _normalize(record.serviceId) != normalizedService) {
            return false;
          }
          if (record.audience != normalizedAudience) return false;
          return record.profileVisibility.any(
            (profile) => _normalize(profile.name) == normalizedProfile,
          );
        })
        .toList(growable: false);

    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.single;

    // Stable deterministic tie-breaker: prefer the smallest form/target ids.
    candidates.sort((a, b) {
      final formCompare = a.formId.compareTo(b.formId);
      if (formCompare != 0) return formCompare;
      return a.targetTicketId.compareTo(b.targetTicketId);
    });
    return candidates.first;
  }
}

class GovernedServiceRecord {
  final String catalogRecordId;
  final String serviceId;
  final String serviceLabel;

  /// Sub-serviço dentro do card (UX fiel ao GLPI): em forms agregados
  /// (CONSERVAÇÃO/MANUTENÇÃO/...), cada alvo é um sub-serviço selecionável.
  /// Em forms por-serviço, é igual ao serviço.
  final String? subService;
  final bool isAggregateForm;
  final bool requiresSpecializedFlow;

  /// Atores que o FormCreator aplicaria (requester/observer/assigned). O app
  /// cria o Ticket direto via API, então deve replicá-los no payload.
  final List<GovernedActor> actors;
  final List<GovernedProfile> profileVisibility;
  final int formId;
  final String? formName;
  final int targetTicketId;
  final String? targetTicketName;
  final String audience;
  final int? destinationEntityCode;
  final String? destinationEntityMode;
  final int? destinationEntityValue;
  final int? categoryRule;
  final int? locationRule;
  final int? typeRule;
  final int? urgencyRule;
  final GovernedQuestion? categoryQuestion;
  final GovernedQuestion? locationQuestion;
  final GovernedExpectedGroup? expectedAssignmentGroup;
  final String? expectedDomain;
  final List<GovernedTaskTemplate> expectedBaseTaskTemplates;
  final String? attachmentProofRoute;
  final List<String> readbackContract;

  const GovernedServiceRecord({
    required this.catalogRecordId,
    required this.serviceId,
    required this.serviceLabel,
    required this.profileVisibility,
    this.subService,
    this.isAggregateForm = false,
    this.requiresSpecializedFlow = false,
    this.actors = const [],
    required this.formId,
    required this.targetTicketId,
    required this.audience,
    required this.expectedBaseTaskTemplates,
    required this.readbackContract,
    this.formName,
    this.targetTicketName,
    this.destinationEntityCode,
    this.destinationEntityMode,
    this.destinationEntityValue,
    this.categoryRule,
    this.locationRule,
    this.typeRule,
    this.urgencyRule,
    this.categoryQuestion,
    this.locationQuestion,
    this.expectedAssignmentGroup,
    this.expectedDomain,
    this.attachmentProofRoute,
  });

  factory GovernedServiceRecord.fromMap(Map<String, dynamic> map) {
    final form = _asMap(map['form']);
    final target = _asMap(map['targetticket']);
    final questions = _asMap(map['questions']);
    final expected = _asMap(map['expected_result']);
    final destination = _asMap(target['destination_entity']);
    final attachment = _asMap(expected['attachment_policy']);

    return GovernedServiceRecord(
      catalogRecordId: _string(map['catalog_record_id']) ?? '',
      serviceId: _string(map['service_id']) ?? '',
      serviceLabel: _string(map['service_label']) ?? '',
      subService: _string(map['sub_service']),
      isAggregateForm: map['is_aggregate_form'] == true,
      requiresSpecializedFlow: map['requires_specialized_flow'] == true,
      actors: _asList(map['actors'])
          .whereType<Map>()
          .map((item) => GovernedActor.fromMap(Map<String, dynamic>.from(item)))
          .toList(growable: false),
      profileVisibility: _asList(map['profile_visibility'])
          .whereType<Map>()
          .map(
            (item) => GovernedProfile.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      formId: _int(form['id']) ?? 0,
      formName: _string(form['name']),
      targetTicketId: _int(target['id']) ?? 0,
      targetTicketName: _string(target['name']),
      audience: _string(target['audience']) ?? 'para_mim',
      destinationEntityCode: _int(destination['code']),
      destinationEntityMode: _string(destination['mode']),
      destinationEntityValue: _int(target['destination_entity_value']),
      categoryRule: _int(target['category_rule']),
      locationRule: _int(target['location_rule']),
      typeRule: _int(target['type_rule']),
      urgencyRule: _int(target['urgency_rule']),
      categoryQuestion: GovernedQuestion.tryFrom(questions['category']),
      locationQuestion: GovernedQuestion.tryFrom(questions['location']),
      expectedDomain: _string(expected['domain']),
      expectedAssignmentGroup: GovernedExpectedGroup.tryFrom(
        expected['assignment_group'],
      ),
      expectedBaseTaskTemplates: _asList(expected['base_task_templates'])
          .whereType<Map>()
          .map(
            (item) =>
                GovernedTaskTemplate.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      attachmentProofRoute: _string(attachment['create_route']),
      readbackContract: _asList(
        expected['readback_contract'],
      ).map((item) => item.toString()).toList(growable: false),
    );
  }

  GovernedReadbackExpectation toReadbackExpectation({int? expectedEntityId}) {
    return GovernedReadbackExpectation(
      expectedEntityId: expectedEntityId,
      expectedGroupLabel: expectedAssignmentGroup?.label,
      expectedDomain: expectedDomain,
      expectedTaskTemplateLabels: expectedBaseTaskTemplates
          .map((template) => template.label)
          .whereType<String>()
          .toList(growable: false),
      attachmentProofRoute: attachmentProofRoute,
      readbackContract: readbackContract,
    );
  }
}

/// Ator do FormCreator: role=requester|observer|assigned;
/// type=author|validator|person|question_person|group|question_group.
/// Para question_person, `value` é o id da pergunta (a resposta é o usuário).
class GovernedActor {
  final String role;
  final String type;
  final int? value;

  const GovernedActor({required this.role, required this.type, this.value});

  factory GovernedActor.fromMap(Map<String, dynamic> map) {
    return GovernedActor(
      role: _string(map['role']) ?? '',
      type: _string(map['type']) ?? '',
      value: _int(map['value']),
    );
  }
}

class GovernedProfile {
  final int? id;
  final String name;

  const GovernedProfile({required this.name, this.id});

  factory GovernedProfile.fromMap(Map<String, dynamic> map) {
    return GovernedProfile(
      id: _int(map['id']),
      name: _string(map['name']) ?? '',
    );
  }
}

class GovernedQuestion {
  final int id;
  final String? name;
  final String? fieldType;
  final bool required;
  final int? rootId;
  final String? optionSource;
  final bool selectableTreeRoot;
  final List<GovernedOption> options;

  const GovernedQuestion({
    required this.id,
    required this.options,
    this.name,
    this.fieldType,
    this.required = false,
    this.rootId,
    this.optionSource,
    this.selectableTreeRoot = true,
  });

  static GovernedQuestion? tryFrom(dynamic raw) {
    if (raw is! Map) return null;
    return GovernedQuestion.fromMap(Map<String, dynamic>.from(raw));
  }

  /// Opções realmente SELECIONÁVEIS de uma questão de árvore (ITILCategory),
  /// fiel à semântica do GLPI: o nó raiz (`id == rootId`) não é selecionável
  /// quando `selectableTreeRoot == false`, e nós intermédios (que são ancestrais
  /// de outra opção via `fullLabel` "X > ...") são apenas agrupadores. Sobram as
  /// folhas. Para listas planas (sem hierarquia em `fullLabel`) todas as opções
  /// são folhas. A fonte é o catálogo governado (pré-resolvido), pois perfis
  /// Solicitante/GG não têm direito de ler /ITILCategory em runtime.
  List<GovernedOption> get selectableOptions {
    if (options.isEmpty) return const [];
    final fullLabels = options
        .map((o) => o.fullLabel?.trim() ?? '')
        .where((f) => f.isNotEmpty)
        .toList(growable: false);

    bool isAncestor(GovernedOption option) {
      final full = option.fullLabel?.trim() ?? '';
      if (full.isEmpty) return false;
      final prefix = '$full > ';
      return fullLabels.any((other) => other != full && other.startsWith(prefix));
    }

    return options.where((option) {
      if (!selectableTreeRoot && rootId != null && option.id == rootId) {
        return false;
      }
      if (isAncestor(option)) return false;
      return true;
    }).toList(growable: false);
  }

  factory GovernedQuestion.fromMap(Map<String, dynamic> map) {
    final rawValues = _asMap(map['raw_values']);
    return GovernedQuestion(
      id: _int(map['id']) ?? 0,
      name: _string(map['name']),
      fieldType: _string(map['fieldtype']),
      required: map['required'] == true || _int(map['required']) == 1,
      rootId: _int(map['root_id']),
      optionSource: _string(map['option_source']),
      selectableTreeRoot: _int(rawValues['selectable_tree_root']) != 0,
      options: _asList(map['options_sample'])
          .whereType<Map>()
          .map(
            (item) => GovernedOption.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

class GovernedOption {
  final int id;
  final String? label;
  final String? fullLabel;

  const GovernedOption({required this.id, this.label, this.fullLabel});

  factory GovernedOption.fromMap(Map<String, dynamic> map) {
    return GovernedOption(
      id: _int(map['id']) ?? 0,
      label: _string(map['label']),
      fullLabel: _string(map['full_label']),
    );
  }
}

class GovernedExpectedGroup {
  final int? id;
  final String? label;
  final int? sourceRuleId;

  const GovernedExpectedGroup({this.id, this.label, this.sourceRuleId});

  static GovernedExpectedGroup? tryFrom(dynamic raw) {
    if (raw is! Map) return null;
    return GovernedExpectedGroup.fromMap(Map<String, dynamic>.from(raw));
  }

  factory GovernedExpectedGroup.fromMap(Map<String, dynamic> map) {
    return GovernedExpectedGroup(
      id: _int(map['id']),
      label: _string(map['label']),
      sourceRuleId: _int(map['source_rule_id']),
    );
  }
}

class GovernedTaskTemplate {
  final int? id;
  final String? label;

  const GovernedTaskTemplate({this.id, this.label});

  factory GovernedTaskTemplate.fromMap(Map<String, dynamic> map) {
    return GovernedTaskTemplate(
      id: _int(map['id']),
      label: _string(map['label']),
    );
  }
}

class GovernedReadbackExpectation {
  final int? expectedEntityId;
  final String? expectedGroupLabel;
  final String? expectedDomain;
  final List<String> expectedTaskTemplateLabels;
  final String? attachmentProofRoute;
  final List<String> readbackContract;

  const GovernedReadbackExpectation({
    required this.expectedTaskTemplateLabels,
    required this.readbackContract,
    this.expectedEntityId,
    this.expectedGroupLabel,
    this.expectedDomain,
    this.attachmentProofRoute,
  });

  GovernedReadbackResult validate({
    required Map<String, dynamic> ticket,
    Iterable<String> taskLabels = const [],
    Iterable<String> documentIds = const [],
    bool requireAttachmentProof = true,
  }) {
    final failures = <String>[];

    final expectedEntity = expectedEntityId;
    if (expectedEntity != null && expectedEntity > 0) {
      final entityValues = _collectStrings(ticket, const {
        'entities_id',
        'entity_id',
        'entity',
        'entity_name',
        'entities',
        '80',
      });
      if (!_containsNormalized(entityValues, expectedEntity.toString())) {
        failures.add(
          'Entidade esperada não confirmada no read-back: $expectedEntity',
        );
      }
    }

    final expectedGroup = expectedGroupLabel?.trim();
    if (expectedGroup != null && expectedGroup.isNotEmpty) {
      final groupValues = _collectStrings(ticket, const {
        'groups',
        'group',
        'group_name',
        'group_label',
        'assignment_group',
        'assigned_group_name',
        'assigned_group_id',
        'groups_id',
        '8',
      });
      if (!_containsNormalized(groupValues, expectedGroup)) {
        failures.add(
          'Grupo esperado não confirmado no read-back: $expectedGroup',
        );
      }
    }

    final expectedDomainValue = expectedDomain?.trim();
    if (expectedDomainValue != null && expectedDomainValue.isNotEmpty) {
      final domainValues = _collectStrings(ticket, const {
        'domain',
        'domain_label',
        'category',
        'category_label',
        'itilcategories_id',
        '7',
      });
      if (!_containsNormalized(domainValues, expectedDomainValue)) {
        failures.add(
          'Domínio esperado não confirmado no read-back: $expectedDomainValue',
        );
      }
    }

    final normalizedTasks = taskLabels.map(_normalize).toSet();
    for (final task in expectedTaskTemplateLabels) {
      final expectedTask = task.trim();
      if (expectedTask.isEmpty) continue;
      if (!normalizedTasks.contains(_normalize(expectedTask))) {
        failures.add(
          'Tarefa esperada não confirmada no read-back: $expectedTask',
        );
      }
    }

    final requiresAttachmentProof =
        requireAttachmentProof &&
        attachmentProofRoute?.trim().isNotEmpty == true;
    if (requiresAttachmentProof &&
        documentIds.where((id) => id.trim().isNotEmpty).isEmpty) {
      failures.add('Anexo não confirmado por Document_Item no read-back');
    }

    return GovernedReadbackResult._(failures);
  }
}

class GovernedReadbackResult {
  final List<String> failures;

  const GovernedReadbackResult._(this.failures);

  bool get ok => failures.isEmpty;
}

Map<String, dynamic> _asMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const <String, dynamic>{};
}

List<dynamic> _asList(dynamic raw) {
  if (raw is List) return raw;
  return const <dynamic>[];
}

String? _string(dynamic raw) {
  final value = raw?.toString().trim();
  return value == null || value.isEmpty ? null : value;
}

int? _int(dynamic raw) {
  if (raw is int) return raw;
  return int.tryParse(raw?.toString() ?? '');
}

bool _containsNormalized(Iterable<String> values, String expected) {
  final normalizedExpected = _normalize(expected);
  return values.any((value) {
    final normalizedValue = _normalize(value);
    return normalizedValue == normalizedExpected ||
        normalizedValue.contains(normalizedExpected);
  });
}

List<String> _collectStrings(dynamic value, Set<String> matchingKeys) {
  final output = <String>[];

  void visit(dynamic current, [String? key]) {
    if (current == null) return;
    final keyMatches = key != null && matchingKeys.contains(key);

    if (current is String || current is num || current is bool) {
      if (keyMatches) output.add(current.toString());
      return;
    }

    if (current is List) {
      for (final item in current) {
        visit(item, key);
      }
      return;
    }

    if (current is Map) {
      if (keyMatches) {
        for (final candidateKey in const [
          'name',
          'label',
          'completename',
          'value',
          'id',
        ]) {
          final candidate = current[candidateKey];
          if (candidate != null) output.add(candidate.toString());
        }
      }
      current.forEach((childKey, childValue) {
        visit(childValue, childKey.toString());
      });
    }
  }

  visit(value);
  return output;
}

String _normalize(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');
}
