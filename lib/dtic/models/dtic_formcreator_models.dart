import 'dart:convert';

import '../utils/dtic_text.dart';

class DticFormCatalog {
  const DticFormCatalog({
    required this.forms,
    required this.categories,
    required this.sections,
    required this.questions,
    required this.conditions,
    required this.targetTickets,
    this.profiles = const [],
    this.formProfiles = const [],
  });

  final List<DticForm> forms;
  final List<DticFormCategory> categories;
  final List<DticFormSection> sections;
  final List<DticFormQuestion> questions;
  final List<DticFormCondition> conditions;
  final List<DticTargetTicket> targetTickets;
  final List<DticProfile> profiles;
  final List<DticFormProfile> formProfiles;

  DticFormCatalog forActiveProfile(String? activeProfileName) {
    if (formProfiles.isEmpty) return this;

    final normalizedProfile = _normalize(activeProfileName);
    int? profileId;
    for (final profile in profiles) {
      if (_normalize(profile.name) == normalizedProfile) {
        profileId = profile.id;
        break;
      }
    }

    final restrictedFormIds = formProfiles.map((link) => link.formId).toSet();
    final filteredForms = forms.where((form) {
      if (!restrictedFormIds.contains(form.id)) return true;
      if (profileId == null) return false;
      return formProfiles.any(
        (link) => link.formId == form.id && link.profileId == profileId,
      );
    }).toList();

    return DticFormCatalog(
      forms: filteredForms,
      categories: categories,
      sections: sections,
      questions: questions,
      conditions: conditions,
      targetTickets: targetTickets,
      profiles: profiles,
      formProfiles: formProfiles,
    );
  }

  List<DticFormSection> sectionsForForm(int formId) {
    final sectionIds = questions
        .where((question) => question.formId == formId)
        .map((question) => question.sectionId)
        .toSet();

    final related = sections
        .where(
          (section) =>
              section.formId == formId || sectionIds.contains(section.id),
        )
        .toList();
    related.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      return a.id.compareTo(b.id);
    });
    return related;
  }

  List<DticFormQuestion> questionsForSection(int sectionId) {
    final related = questions
        .where((question) => question.sectionId == sectionId)
        .toList();
    related.sort((a, b) {
      final rowCompare = a.row.compareTo(b.row);
      if (rowCompare != 0) return rowCompare;
      final colCompare = a.col.compareTo(b.col);
      if (colCompare != 0) return colCompare;
      return a.id.compareTo(b.id);
    });
    return related;
  }

  int targetCountForForm(int formId) {
    return targetTickets.where((target) => target.formId == formId).length;
  }

  bool isSectionVisible(DticFormSection section, Map<int, dynamic> answers) {
    return _isItemVisible(
      itemType: DticFormCondition.sectionItemType,
      itemId: section.id,
      showRule: section.showRule,
      answers: answers,
    );
  }

  bool isQuestionVisible(DticFormQuestion question, Map<int, dynamic> answers) {
    return _isItemVisible(
      itemType: DticFormCondition.questionItemType,
      itemId: question.id,
      showRule: question.showRule,
      answers: answers,
    );
  }

  bool _isItemVisible({
    required String itemType,
    required int itemId,
    required int showRule,
    required Map<int, dynamic> answers,
  }) {
    if (showRule == 1) return true;

    final itemConditions =
        conditions
            .where(
              (condition) =>
                  condition.itemType == itemType && condition.itemId == itemId,
            )
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    if (itemConditions.isEmpty) {
      return showRule == 3;
    }

    final expressionMatches = _conditionsMatch(itemConditions, answers);
    if (showRule == 2) return expressionMatches;
    if (showRule == 3) return !expressionMatches;

    return true;
  }

  bool _conditionsMatch(
    List<DticFormCondition> itemConditions,
    Map<int, dynamic> answers,
  ) {
    bool? result;

    for (final condition in itemConditions) {
      final matches = condition.matches(answers[condition.sourceQuestionId]);
      if (result == null) {
        result = matches;
        continue;
      }

      if (condition.showLogic == 2) {
        result = result || matches;
      } else {
        result = result && matches;
      }
    }

    return result ?? false;
  }
}

class DticForm {
  const DticForm({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.isActive,
    required this.description,
  });

  final int id;
  final String name;
  final int? categoryId;
  final bool isActive;
  final String description;

  factory DticForm.fromJson(Map<String, dynamic> json) {
    return DticForm(
      id: _readInt(json['id']) ?? 0,
      name: _readText(json['name'], fallback: 'Formulario sem nome'),
      categoryId:
          _readInt(json['plugin_formcreator_categories_id']) ??
          _readLinkedId(json, 'PluginFormcreatorCategory'),
      isActive: _readBool(json['is_active'], fallback: true),
      description: DticText.stripHtml(json['description']),
    );
  }
}

class DticFormCategory {
  const DticFormCategory({
    required this.id,
    required this.name,
    required this.completename,
  });

  final int id;
  final String name;
  final String completename;

  factory DticFormCategory.fromJson(Map<String, dynamic> json) {
    return DticFormCategory(
      id: _readInt(json['id']) ?? 0,
      name: _readText(json['name'], fallback: 'Categoria'),
      completename: _readText(
        json['completename'] ?? json['name'],
        fallback: 'Categoria',
      ),
    );
  }
}

class DticProfile {
  const DticProfile({required this.id, required this.name});

  final int id;
  final String name;

  factory DticProfile.fromJson(Map<String, dynamic> json) {
    return DticProfile(
      id: _readInt(json['id']) ?? 0,
      name: _readText(json['name'], fallback: 'Perfil'),
    );
  }
}

class DticFormProfile {
  const DticFormProfile({
    required this.id,
    required this.formId,
    required this.profileId,
  });

  final int id;
  final int formId;
  final int profileId;

  factory DticFormProfile.fromJson(Map<String, dynamic> json) {
    return DticFormProfile(
      id: _readInt(json['id']) ?? 0,
      formId:
          _readInt(json['plugin_formcreator_forms_id']) ??
          _readLinkedId(json, 'PluginFormcreatorForm') ??
          0,
      profileId:
          _readInt(json['profiles_id']) ?? _readLinkedId(json, 'Profile') ?? 0,
    );
  }
}

class DticFormSection {
  const DticFormSection({
    required this.id,
    required this.formId,
    required this.name,
    required this.order,
    required this.showRule,
  });

  final int id;
  final int? formId;
  final String name;
  final int order;
  final int showRule;

  factory DticFormSection.fromJson(Map<String, dynamic> json) {
    return DticFormSection(
      id: _readInt(json['id']) ?? 0,
      formId:
          _readInt(json['plugin_formcreator_forms_id']) ??
          _readLinkedId(json, 'PluginFormcreatorForm'),
      name: _readText(json['name'], fallback: 'Secao'),
      order: _readInt(json['order']) ?? _readInt(json['rank']) ?? 0,
      showRule: _readInt(json['show_rule']) ?? 1,
    );
  }
}

class DticFormQuestion {
  const DticFormQuestion({
    required this.id,
    required this.formId,
    required this.sectionId,
    required this.name,
    required this.fieldType,
    required this.required,
    required this.description,
    required this.row,
    required this.col,
    required this.width,
    required this.showRule,
    required this.options,
    required this.defaultValue,
    required this.rawValues,
  });

  final int id;
  final int? formId;
  final int sectionId;
  final String name;
  final String fieldType;
  final bool required;
  final String description;
  final int row;
  final int col;
  final int width;
  final int showRule;
  final List<DticFormOption> options;
  final String defaultValue;
  final String rawValues;

  bool get isSupported {
    return const {
      'text',
      'textarea',
      'select',
      'integer',
      'date',
      'file',
      'hostname',
    }.contains(fieldType);
  }

  bool get isConditional => showRule != 1;
  bool get isRenderable => isSupported;

  String get blockReason {
    if (!isSupported) {
      return 'Este tipo de campo ainda nao esta disponivel no aplicativo.';
    }
    return '';
  }

  bool get isSelect => fieldType == 'select';
  bool get isTextArea => fieldType == 'textarea';
  bool get isFile => fieldType == 'file';

  factory DticFormQuestion.fromJson(Map<String, dynamic> json) {
    final rawValues = _readText(json['values']);
    final fieldType = _readText(
      json['fieldtype'],
      fallback: 'text',
    ).trim().toLowerCase();
    return DticFormQuestion(
      id: _readInt(json['id']) ?? 0,
      formId: _readInt(json['plugin_formcreator_forms_id']),
      sectionId:
          _readInt(json['plugin_formcreator_sections_id']) ??
          _readLinkedId(json, 'PluginFormcreatorSection') ??
          0,
      name: _readText(json['name'], fallback: 'Campo'),
      fieldType: fieldType,
      required: _readBool(json['required']),
      description: DticText.stripHtml(json['description']),
      row: _readInt(json['row']) ?? 0,
      col: _readInt(json['col']) ?? 0,
      width: _readInt(json['width']) ?? 0,
      showRule: _readInt(json['show_rule']) ?? 1,
      options: fieldType == 'select'
          ? DticFormOption.parseList(rawValues)
          : const [],
      defaultValue: _readText(json['default_values']),
      rawValues: rawValues,
    );
  }
}

class DticFormOption {
  const DticFormOption({required this.value, required this.label});

  final String value;
  final String label;

  static List<DticFormOption> parseList(String rawValues) {
    final trimmed = rawValues.trim();
    if (trimmed.isEmpty) return const [];

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .map((value) => value?.toString().trim() ?? '')
            .where((value) => value.isNotEmpty)
            .map((value) => DticFormOption(value: value, label: value))
            .toList();
      }
      if (decoded is Map) {
        final entries = <DticFormOption>[];
        decoded.forEach((key, value) {
          final optionValue = key.toString().trim();
          final optionLabel = value?.toString().trim() ?? optionValue;
          if (optionValue.isNotEmpty || optionLabel.isNotEmpty) {
            entries.add(
              DticFormOption(
                value: optionValue.isEmpty ? optionLabel : optionValue,
                label: optionLabel.isEmpty ? optionValue : optionLabel,
              ),
            );
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
        .map((value) => DticFormOption(value: value, label: value))
        .toList();
  }
}

class DticFormCondition {
  const DticFormCondition({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.sourceQuestionId,
    required this.showCondition,
    required this.showValue,
    required this.showLogic,
    required this.order,
  });

  static const questionItemType = 'PluginFormcreatorQuestion';
  static const sectionItemType = 'PluginFormcreatorSection';
  static const targetTicketItemType = 'PluginFormcreatorTargetTicket';

  final int id;
  final String itemType;
  final int itemId;
  final int sourceQuestionId;
  final int showCondition;
  final String showValue;
  final int showLogic;
  final int order;

  bool get targetsQuestion => itemType == questionItemType;
  bool get targetsSection => itemType == sectionItemType;

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

  factory DticFormCondition.fromJson(Map<String, dynamic> json) {
    final itemType = _readText(json['itemtype']);
    final targetIds = _readLinkedIds(json, itemType);
    final questionIds = _readLinkedIds(json, questionItemType);
    final sourceQuestionId =
        itemType == questionItemType && questionIds.length > 1
        ? questionIds[1]
        : questionIds.isNotEmpty
        ? questionIds.last
        : _readInt(json['plugin_formcreator_questions_id']) ?? 0;

    return DticFormCondition(
      id: _readInt(json['id']) ?? 0,
      itemType: itemType,
      itemId: targetIds.isNotEmpty
          ? targetIds.first
          : _readInt(json['items_id']) ?? 0,
      sourceQuestionId: sourceQuestionId,
      showCondition: _readInt(json['show_condition']) ?? 1,
      showValue: _readText(json['show_value']),
      showLogic: _readInt(json['show_logic']) ?? 1,
      order: _readInt(json['order']) ?? 0,
    );
  }
}

class DticTargetTicket {
  const DticTargetTicket({
    required this.id,
    required this.formId,
    required this.name,
    required this.hasContentTemplate,
  });

  final int id;
  final int? formId;
  final String name;
  final bool hasContentTemplate;

  factory DticTargetTicket.fromJson(Map<String, dynamic> json) {
    return DticTargetTicket(
      id: _readInt(json['id']) ?? 0,
      formId:
          _readInt(json['plugin_formcreator_forms_id']) ??
          _readLinkedId(json, 'PluginFormcreatorForm'),
      name: _readText(json['name'], fallback: 'Target ticket'),
      hasContentTemplate: _readBool(json['has_content_template']),
    );
  }
}

class DticPreparedSubmission {
  const DticPreparedSubmission({
    required this.formId,
    required this.answers,
    required this.missingRequiredQuestionIds,
    required this.hasUnsupportedQuestions,
  });

  final int formId;
  final Map<String, dynamic> answers;
  final List<int> missingRequiredQuestionIds;
  final bool hasUnsupportedQuestions;

  bool get canSubmitDryRun {
    return missingRequiredQuestionIds.isEmpty && !hasUnsupportedQuestions;
  }

  Map<String, dynamic> toFormCreatorInput() {
    return {
      'plugin_formcreator_forms_id': formId,
      'add': '1',
      for (final entry in answers.entries)
        'formcreator_field_${entry.key}': entry.value,
    };
  }
}

int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _readBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().trim().toLowerCase();
  if (normalized == '1' || normalized == 'true' || normalized == 'yes') {
    return true;
  }
  if (normalized == '0' || normalized == 'false' || normalized == 'no') {
    return false;
  }
  return fallback;
}

String _readText(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String _normalize(dynamic value) {
  return _readText(value).toLowerCase().trim();
}

int? _readLinkedId(Map<String, dynamic> json, String rel) {
  final links = json['links'];
  if (links is! List) return null;

  for (final link in links.whereType<Map>()) {
    if (link['rel']?.toString() != rel) continue;
    final href = link['href']?.toString();
    if (href == null || href.isEmpty) continue;
    final match = RegExp('/$rel/(\\d+)\$').firstMatch(href);
    if (match != null) return int.tryParse(match.group(1)!);
  }

  return null;
}

List<int> _readLinkedIds(Map<String, dynamic> json, String rel) {
  final links = json['links'];
  if (links is! List || rel.isEmpty) return const [];

  final ids = <int>[];
  for (final link in links.whereType<Map>()) {
    if (link['rel']?.toString() != rel) continue;
    final href = link['href']?.toString();
    if (href == null || href.isEmpty) continue;
    final match = RegExp('/$rel/(\\d+)\$').firstMatch(href);
    final id = match == null ? null : int.tryParse(match.group(1)!);
    if (id != null) ids.add(id);
  }
  return ids;
}
