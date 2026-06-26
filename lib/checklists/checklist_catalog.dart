import 'dart:convert';

/// Modelo imutavel do catalogo read-only de checklists SIS (forms 48-52),
/// gerado por `tool/checklists/build_sis_checklists_catalog.mjs` a partir do
/// snapshot API de governanca GLPI.
///
/// Fidelidade ao GLPI SIS:
/// - cada form carrega `profileIds` (formcreator_forms_profiles) e `groupIds`
///   (PluginFormcreatorForm_Group) — gate OR: acesso por perfil OU por grupo;
/// - targets trazem `categoryId` (148-152) e entidade destino 58;
/// - condicoes preservam a semantica FormCreator usada na engine de visibilidade.
class SisChecklistCatalog {
  const SisChecklistCatalog({
    required this.schemaVersion,
    required this.sourceSnapshotSha256,
    required this.forms,
    required this.sections,
    required this.questions,
    required this.conditions,
    required this.targets,
    required this.categories,
  });

  final String schemaVersion;
  final String sourceSnapshotSha256;
  final List<SisChecklistForm> forms;
  final List<SisChecklistSection> sections;
  final List<SisChecklistQuestion> questions;
  final List<SisChecklistCondition> conditions;
  final List<SisChecklistTarget> targets;
  final List<SisChecklistCategory> categories;

  factory SisChecklistCatalog.fromJson(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('checklist catalog must be a JSON object');
    }
    return SisChecklistCatalog.fromMap(decoded);
  }

  factory SisChecklistCatalog.fromMap(Map<String, dynamic> map) {
    final formsRaw = map['forms'];
    if (formsRaw is! List || formsRaw.isEmpty) {
      throw const FormatException('checklist catalog forms must be non-empty');
    }

    final forms = formsRaw
        .whereType<Map<String, dynamic>>()
        .map(SisChecklistForm.fromMap)
        .toList(growable: false);

    final sections =
        (map['sections'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SisChecklistSection.fromMap)
            .toList()
          ..sort((a, b) {
            final byOrder = a.order.compareTo(b.order);
            return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
          });

    final questions =
        (map['questions'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(SisChecklistQuestion.fromMap)
            .toList()
          ..sort((a, b) {
            final byRow = a.row.compareTo(b.row);
            if (byRow != 0) return byRow;
            final byCol = a.col.compareTo(b.col);
            return byCol != 0 ? byCol : a.id.compareTo(b.id);
          });

    final conditions = (map['conditions'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SisChecklistCondition.fromMap)
        .toList(growable: false);

    final targets = (map['targets'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SisChecklistTarget.fromMap)
        .toList(growable: false);

    final categories = (map['categories'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(SisChecklistCategory.fromMap)
        .toList(growable: false);

    return SisChecklistCatalog(
      schemaVersion: _readText(map['schema_version']),
      sourceSnapshotSha256: _readText(map['source_snapshot_sha256']),
      forms: forms,
      sections: sections,
      questions: questions,
      conditions: conditions,
      targets: targets,
      categories: categories,
    );
  }

  SisChecklistForm? formById(int id) {
    for (final form in forms) {
      if (form.id == id) return form;
    }
    return null;
  }

  /// Forms que o usuario GLPI pode ver: perfil OU grupo (OR semantico, espelhando
  /// `access_rights=2` do FormCreator). Fonte dinamica: sem nomes hardcoded.
  /// Requer ao menos um target ativo para o form aparecer.
  List<SisChecklistForm> formsVisibleToUser(int? profileId, List<int> userGroupIds) {
    return forms
        .where((form) =>
            form.isVisibleToUser(profileId, userGroupIds) &&
            targetsForForm(form.id).isNotEmpty)
        .toList(growable: false);
  }

  /// Compat: gate so por perfil (use [formsVisibleToUser] sempre que grupos estiverem
  /// disponiveis na sessao).
  List<SisChecklistForm> formsVisibleToProfile(int? profileId) =>
      formsVisibleToUser(profileId, const []);

  List<SisChecklistTarget> targetsForForm(int formId) =>
      targets.where((target) => target.formId == formId).toList(growable: false);

  List<SisChecklistSection> sectionsForForm(int formId) =>
      sections.where((section) => section.formId == formId).toList(growable: false);

  List<SisChecklistQuestion> questionsForSection(int sectionId) => questions
      .where((question) => question.sectionId == sectionId)
      .toList(growable: false);

  List<SisChecklistQuestion> questionsForForm(int formId) =>
      questions.where((question) => question.formId == formId).toList(growable: false);

  SisChecklistTarget? targetById(int id) {
    for (final target in targets) {
      if (target.id == id) return target;
    }
    return null;
  }

  SisChecklistCategory? categoryById(int id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  /// Condicoes que governam a visibilidade de um item especifico.
  List<SisChecklistCondition> conditionsFor(String itemType, int itemId) =>
      conditions
          .where((condition) =>
              condition.itemType == itemType && condition.itemId == itemId)
          .toList(growable: false);
}

class SisChecklistForm {
  const SisChecklistForm({
    required this.id,
    required this.name,
    required this.isActive,
    required this.isVisible,
    required this.helpdeskHome,
    required this.profileIds,
    required this.groupIds,
  });

  final int id;
  final String name;
  final bool isActive;
  final bool isVisible;
  final bool helpdeskHome;

  /// Perfis GLPI (profiles_id) que enxergam este form via `formcreator_forms_profiles`.
  final List<int> profileIds;

  /// Grupos GLPI (groups_id) que enxergam este form via `PluginFormcreatorForm_Group`.
  final List<int> groupIds;

  /// Acesso OR: usuario ve o form se seu perfil OU um de seus grupos estiver na lista.
  bool isVisibleToUser(int? profileId, List<int> userGroupIds) {
    if (profileId != null && profileIds.contains(profileId)) return true;
    return userGroupIds.any(groupIds.contains);
  }

  bool isVisibleToProfile(int? profileId) => isVisibleToUser(profileId, const []);

  factory SisChecklistForm.fromMap(Map<String, dynamic> map) {
    return SisChecklistForm(
      id: _readInt(map['id']),
      name: _readText(map['name']),
      isActive: _readBool(map['is_active']),
      isVisible: _readBool(map['is_visible']),
      helpdeskHome: _readBool(map['helpdesk_home']),
      profileIds: (map['profile_ids'] as List? ?? const [])
          .map(_readInt)
          .where((id) => id > 0)
          .toList(growable: false),
      groupIds: (map['group_ids'] as List? ?? const [])
          .map(_readInt)
          .where((id) => id > 0)
          .toList(growable: false),
    );
  }
}

class SisChecklistSection {
  const SisChecklistSection({
    required this.id,
    required this.formId,
    required this.name,
    required this.order,
  });

  final int id;
  final int formId;
  final String name;
  final int order;

  factory SisChecklistSection.fromMap(Map<String, dynamic> map) {
    return SisChecklistSection(
      id: _readInt(map['id']),
      formId: _readInt(map['form_id']),
      name: _readText(map['name']),
      order: _readInt(map['order']),
    );
  }
}

class SisChecklistQuestion {
  const SisChecklistQuestion({
    required this.id,
    required this.formId,
    required this.sectionId,
    required this.name,
    required this.fieldType,
    required this.itemType,
    required this.required,
    required this.rawValues,
    required this.options,
    required this.defaultValues,
    required this.showRule,
    required this.row,
    required this.col,
    required this.width,
  });

  final int id;
  final int formId;
  final int sectionId;
  final String name;
  final String fieldType;
  final String itemType;
  final bool required;
  final String rawValues;
  final List<SisChecklistOption> options;
  final String defaultValues;
  final int showRule;
  final int row;
  final int col;
  final int width;

  bool get isConditional => showRule != 1;
  bool get isSelect => fieldType == 'select';
  bool get isRadios => fieldType == 'radios';
  bool get isMultiselect => fieldType == 'multiselect';
  bool get isTextArea => fieldType == 'textarea';
  bool get isFile => fieldType == 'file';
  bool get isGlpiSelect => fieldType == 'glpiselect';

  /// Tipos que o renderer especializado de checklist suporta.
  static const Set<String> supportedFieldTypes = {
    'select',
    'radios',
    'multiselect',
    'textarea',
    'text',
    'file',
    'glpiselect',
  };

  bool get isSupported => supportedFieldTypes.contains(fieldType);

  factory SisChecklistQuestion.fromMap(Map<String, dynamic> map) {
    final fieldType = _readText(map['fieldtype'], fallback: 'text').toLowerCase();
    final rawValues = _readValues(map['values']);
    return SisChecklistQuestion(
      id: _readInt(map['id']),
      formId: _readInt(map['form_id']),
      sectionId: _readInt(map['section_id']),
      name: _readText(map['name'], fallback: 'Campo'),
      fieldType: fieldType,
      itemType: _readText(map['itemtype']),
      required: _readBool(map['required']),
      rawValues: rawValues,
      options: (fieldType == 'select' ||
              fieldType == 'radios' ||
              fieldType == 'multiselect')
          ? SisChecklistOption.parseList(rawValues)
          : const [],
      defaultValues: _readValues(map['default_values']),
      showRule: _readInt(map['show_rule'], fallback: 1),
      row: _readInt(map['row']),
      col: _readInt(map['col']),
      width: _readInt(map['width']),
    );
  }
}

class SisChecklistOption {
  const SisChecklistOption({required this.value, required this.label});

  final String value;
  final String label;

  /// Espelha `DticFormOption.parseList`: aceita array JSON, objeto JSON ou
  /// fallback por linhas.
  static List<SisChecklistOption> parseList(String rawValues) {
    final trimmed = rawValues.trim();
    if (trimmed.isEmpty) return const [];

    try {
      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .map((value) => value?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
            .map((value) => SisChecklistOption(value: value, label: value))
            .toList(growable: false);
      }
      if (decoded is Map) {
        final entries = <SisChecklistOption>[];
        decoded.forEach((key, value) {
          final optionValue = key.toString().trim();
          final optionLabel = value?.toString().trim() ?? optionValue;
          if (optionValue.isNotEmpty || optionLabel.isNotEmpty) {
            entries.add(SisChecklistOption(
              value: optionValue.isEmpty ? optionLabel : optionValue,
              label: optionLabel.isEmpty ? optionValue : optionLabel,
            ));
          }
        });
        return entries;
      }
    } catch (_) {
      // Fall back to newline parsing below.
    }

    return trimmed
        .split(RegExp(r'\r?\n'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .map((value) => SisChecklistOption(value: value, label: value))
        .toList(growable: false);
  }
}

class SisChecklistCondition {
  const SisChecklistCondition({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.sourceQuestionId,
    required this.showCondition,
    required this.showValue,
    required this.showLogic,
    required this.order,
  });

  static const String questionItemType = 'PluginFormcreatorQuestion';
  static const String sectionItemType = 'PluginFormcreatorSection';
  static const String targetTicketItemType = 'PluginFormcreatorTargetTicket';

  final int id;
  final String itemType;
  final int itemId;
  final int sourceQuestionId;
  final int showCondition;
  final String showValue;
  final int showLogic;
  final int order;

  /// Espelha `DticFormCondition.matches`: showCondition 1 = igual, 2 = diferente.
  /// Respostas multiplas (Iterable) casam se qualquer valor casar.
  bool matches(dynamic answer) {
    final expected = _normalize(showValue);
    if (answer is Iterable) {
      final values = answer
          .map((value) => _normalize(value))
          .where((value) => value.isNotEmpty);
      return values.any((value) => _matchValue(value, expected));
    }
    final actual = _normalize(answer);
    if (actual.isEmpty) return false;
    return _matchValue(actual, expected);
  }

  bool _matchValue(String actual, String expected) {
    return switch (showCondition) {
      1 => actual == expected,
      2 => actual != expected,
      _ => false,
    };
  }

  factory SisChecklistCondition.fromMap(Map<String, dynamic> map) {
    return SisChecklistCondition(
      id: _readInt(map['id']),
      itemType: _readText(map['itemtype']),
      itemId: _readInt(map['items_id']),
      sourceQuestionId: _readInt(map['source_question_id']),
      showCondition: _readInt(map['show_condition'], fallback: 1),
      showValue: _readText(map['show_value']),
      showLogic: _readInt(map['show_logic'], fallback: 1),
      order: _readInt(map['order']),
    );
  }
}

class SisChecklistTarget {
  const SisChecklistTarget({
    required this.id,
    required this.formId,
    required this.name,
    required this.destinationEntityValue,
    required this.categoryRule,
    required this.categoryId,
    required this.locationRule,
    required this.urgencyRule,
    required this.typeRule,
    required this.showRule,
  });

  final int id;
  final int formId;
  final String name;
  final int destinationEntityValue;
  final int categoryRule;

  /// Categoria final do ticket (148-152), de `category_question` quando
  /// `category_rule=2`.
  final int categoryId;
  final int locationRule;
  final int urgencyRule;
  final int typeRule;
  final int showRule;

  factory SisChecklistTarget.fromMap(Map<String, dynamic> map) {
    return SisChecklistTarget(
      id: _readInt(map['id']),
      formId: _readInt(map['form_id']),
      name: _readText(map['name']),
      destinationEntityValue: _readInt(map['destination_entity_value']),
      categoryRule: _readInt(map['category_rule']),
      categoryId: _readInt(map['category_id']),
      locationRule: _readInt(map['location_rule']),
      urgencyRule: _readInt(map['urgency_rule']),
      typeRule: _readInt(map['type_rule']),
      showRule: _readInt(map['show_rule'], fallback: 1),
    );
  }
}

class SisChecklistCategory {
  const SisChecklistCategory({
    required this.id,
    required this.name,
    required this.completeName,
    required this.parentId,
    required this.level,
  });

  final int id;
  final String name;
  final String completeName;
  final int parentId;
  final int level;

  factory SisChecklistCategory.fromMap(Map<String, dynamic> map) {
    return SisChecklistCategory(
      id: _readInt(map['id']),
      name: _readText(map['name']),
      completeName: _readText(map['completename']),
      parentId: _readInt(map['parent_id']),
      level: _readInt(map['level']),
    );
  }
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

bool _readBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == '1' || normalized == 'true' || normalized == 'yes') return true;
  if (normalized == '0' || normalized == 'false' || normalized == 'no') return false;
  return fallback;
}

String _readText(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

/// `values`/`default_values` podem vir como String JSON ou ja decodificados.
/// Mantem como String para o parser de opcoes.
String _readValues(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return jsonEncode(value);
}

String _normalize(dynamic value) => _readText(value).toLowerCase().trim();
