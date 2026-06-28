import 'dart:convert';

class FormCreatorAggregateSchema {
  final int formId;
  final FormCreatorQuestion controlQuestion;
  final List<FormCreatorServiceSection> serviceSections;

  const FormCreatorAggregateSchema({
    required this.formId,
    required this.controlQuestion,
    required this.serviceSections,
  });

  bool get isMultiService =>
      controlQuestion.normalizedFieldtype == 'multiselect' &&
      serviceSections.length > 1;

  List<String> get serviceLabels =>
      serviceSections.map((section) => section.label).toList(growable: false);

  FormCreatorServiceSection? sectionForLabel(String label) {
    final normalized = normalizeFormCreatorText(label);
    for (final section in serviceSections) {
      if (normalizeFormCreatorText(section.label) == normalized ||
          normalizeFormCreatorText(section.section.name) == normalized) {
        return section;
      }
    }
    return null;
  }

  static FormCreatorAggregateSchema? fromRaw({
    required int formId,
    required List<FormCreatorSection> sections,
    required Map<int, List<FormCreatorQuestion>> questionsBySection,
    required Map<int, List<FormCreatorCondition>> conditionsBySection,
  }) {
    final allQuestions = questionsBySection.values
        .expand((questions) => questions)
        .toList(growable: false);
    final multiselects = allQuestions.where(
      (question) =>
          question.normalizedFieldtype == 'multiselect' &&
          question.optionValues.length > 1,
    );

    FormCreatorAggregateSchema? best;
    for (final control in multiselects) {
      final optionsByNormalized = {
        for (final option in control.optionValues)
          normalizeFormCreatorText(option): option,
      };
      final serviceSections = <FormCreatorServiceSection>[];

      for (final section in sections) {
        if (section.id == control.sectionId) continue;
        final sectionQuestions = questionsBySection[section.id] ?? const [];
        if (sectionQuestions.isEmpty) continue;

        final conditions = conditionsBySection[section.id] ?? const [];
        FormCreatorCondition? matchingCondition;
        for (final condition in conditions) {
          if (condition.itemtype != 'PluginFormcreatorSection') continue;
          if (condition.itemsId != section.id) continue;
          if (condition.sourceQuestionId != control.id) continue;
          final normalizedValue = normalizeFormCreatorText(condition.showValue);
          if (optionsByNormalized.containsKey(normalizedValue)) {
            matchingCondition = condition;
            break;
          }
        }

        String? label;
        if (matchingCondition != null) {
          label =
              optionsByNormalized[normalizeFormCreatorText(
                matchingCondition.showValue,
              )] ??
              matchingCondition.showValue;
        } else {
          // Fallback para Workers ainda sem PluginFormcreatorCondition:
          // no FormCreator SIS, as seções de Múltiplas Demandas têm o mesmo
          // nome dos valores da pergunta multiselect.
          label = optionsByNormalized[normalizeFormCreatorText(section.name)];
        }

        if (label == null || label.trim().isEmpty) continue;
        serviceSections.add(
          FormCreatorServiceSection(
            label: label.trim(),
            section: section,
            questions: sectionQuestions,
            condition: matchingCondition,
          ),
        );
      }

      serviceSections.sort((a, b) {
        final orderCompare = a.section.order.compareTo(b.section.order);
        if (orderCompare != 0) return orderCompare;
        return a.label.compareTo(b.label);
      });

      final candidate = FormCreatorAggregateSchema(
        formId: formId,
        controlQuestion: control,
        serviceSections: List.unmodifiable(serviceSections),
      );
      if (candidate.isMultiService &&
          (best == null ||
              candidate.serviceSections.length > best.serviceSections.length)) {
        best = candidate;
      }
    }

    return best;
  }
}

class FormCreatorServiceSection {
  final String label;
  final FormCreatorSection section;
  final List<FormCreatorQuestion> questions;
  final FormCreatorCondition? condition;

  const FormCreatorServiceSection({
    required this.label,
    required this.section,
    required this.questions,
    this.condition,
  });

  FormCreatorQuestion? get typeQuestion => _questionNamed('tipo');
  FormCreatorQuestion? get subjectQuestion => _questionNamed('assunto');
  FormCreatorQuestion? get descriptionQuestion => _questionNamed('descricao');
  FormCreatorQuestion? get fileQuestion => questions
      .where((question) => question.normalizedFieldtype == 'file')
      .cast<FormCreatorQuestion?>()
      .firstWhere((question) => question != null, orElse: () => null);

  FormCreatorQuestion? _questionNamed(String normalizedName) {
    for (final question in questions) {
      if (normalizeFormCreatorText(question.name) == normalizedName) {
        return question;
      }
    }
    return null;
  }
}

class FormCreatorSection {
  final int id;
  final String name;
  final int formId;
  final int order;
  final int showRule;

  const FormCreatorSection({
    required this.id,
    required this.name,
    required this.formId,
    required this.order,
    required this.showRule,
  });

  factory FormCreatorSection.fromMap(Map<String, dynamic> map) {
    return FormCreatorSection(
      id: _int(map['id']) ?? 0,
      name: map['name']?.toString() ?? '',
      formId: _int(map['plugin_formcreator_forms_id']) ?? 0,
      order: _int(map['order']) ?? 0,
      showRule: _int(map['show_rule']) ?? 1,
    );
  }
}

class FormCreatorQuestion {
  final int id;
  final String name;
  final int sectionId;
  final String fieldtype;
  final bool required;
  final String? itemtype;
  final dynamic rawValues;
  final String? description;
  final int row;
  final int col;
  final int width;
  final int showRule;

  const FormCreatorQuestion({
    required this.id,
    required this.name,
    required this.sectionId,
    required this.fieldtype,
    required this.required,
    this.itemtype,
    this.rawValues,
    this.description,
    required this.row,
    required this.col,
    required this.width,
    required this.showRule,
  });

  String get normalizedFieldtype => fieldtype.trim().toLowerCase();

  List<String> get optionValues {
    final values = rawValues;
    if (values == null) return const [];
    if (values is List) {
      return values.map((value) => value.toString()).toList(growable: false);
    }
    final text = values.toString().trim();
    if (text.isEmpty) return const [];
    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded.map((value) => value.toString()).toList(growable: false);
      }
    } catch (_) {
      // Not a JSON list; many GLPI fields use JSON objects for tree config.
    }
    return const [];
  }

  factory FormCreatorQuestion.fromMap(Map<String, dynamic> map) {
    return FormCreatorQuestion(
      id: _int(map['id']) ?? 0,
      name: map['name']?.toString() ?? '',
      sectionId: _int(map['plugin_formcreator_sections_id']) ?? 0,
      fieldtype: map['fieldtype']?.toString() ?? '',
      required: _int(map['required']) == 1 || map['required'] == true,
      itemtype: map['itemtype']?.toString(),
      rawValues: map['values'],
      description: map['description']?.toString(),
      row: _int(map['row']) ?? 0,
      col: _int(map['col']) ?? 0,
      width: _int(map['width']) ?? 0,
      showRule: _int(map['show_rule']) ?? 1,
    );
  }
}

class FormCreatorCondition {
  final int id;
  final String itemtype;
  final int itemsId;
  final int sourceQuestionId;
  final int showCondition;
  final String showValue;
  final int showLogic;
  final int order;

  const FormCreatorCondition({
    required this.id,
    required this.itemtype,
    required this.itemsId,
    required this.sourceQuestionId,
    required this.showCondition,
    required this.showValue,
    required this.showLogic,
    required this.order,
  });

  factory FormCreatorCondition.fromMap(Map<String, dynamic> map) {
    return FormCreatorCondition(
      id: _int(map['id']) ?? 0,
      itemtype: map['itemtype']?.toString() ?? '',
      itemsId: _int(map['items_id']) ?? 0,
      sourceQuestionId: _int(map['plugin_formcreator_questions_id']) ?? 0,
      showCondition: _int(map['show_condition']) ?? 0,
      showValue: map['show_value']?.toString() ?? '',
      showLogic: _int(map['show_logic']) ?? 1,
      order: _int(map['order']) ?? 0,
    );
  }
}

String normalizeFormCreatorText(String value) {
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

int? _int(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
