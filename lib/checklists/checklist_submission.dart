import 'checklist_catalog.dart';
import 'checklist_condition_engine.dart';

/// Submissao de checklist preparada localmente, sem rede.
///
/// Deriva, a partir do target FormCreator escolhido, a categoria final (148-152)
/// e a entidade destino (58 nos checklists atuais). Valida apenas as perguntas
/// VISIVEIS (condicoes resolvidas) e separa anexos (`file`) do payload textual.
class SisChecklistPreparedSubmission {
  const SisChecklistPreparedSubmission({
    required this.formId,
    required this.targetId,
    required this.categoryId,
    required this.entityId,
    required this.answers,
    required this.fileQuestionIds,
    required this.missingRequiredQuestionIds,
    required this.visibleQuestionIds,
  });

  final int formId;
  final int targetId;
  final int categoryId;
  final int entityId;
  final Map<int, dynamic> answers;
  final Set<int> fileQuestionIds;
  final List<int> missingRequiredQuestionIds;
  final List<int> visibleQuestionIds;

  bool get canReview => missingRequiredQuestionIds.isEmpty;
  bool get hasAttachments => fileQuestionIds.isNotEmpty;

  /// Payload no formato FormCreator (mantido para compatibilidade). Anexos
  /// (`file`) ficam de fora do JSON e sao tratados separadamente.
  Map<String, dynamic> toFormCreatorInput() {
    return {
      'plugin_formcreator_forms_id': formId,
      'add': '1',
      for (final entry in answers.entries)
        if (!fileQuestionIds.contains(entry.key))
          'formcreator_field_${entry.key}': entry.value,
    };
  }

  /// Conteudo HTML das respostas visiveis para o corpo do ticket GLPI.
  String toTicketContent(
    SisChecklistCatalog catalog, {
    String? formName,
    String? targetName,
  }) {
    final questionMap = {
      for (final q in catalog.questionsForForm(formId)) q.id: q,
    };
    final sectionMap = {
      for (final s in catalog.sectionsForForm(formId)) s.id: s,
    };

    final buffer = StringBuffer('<p>');
    if (formName != null) buffer.write('<b>Formulário:</b> $formName<br>');
    if (targetName != null) buffer.write('<b>Local de aplicação:</b> $targetName<br>');
    buffer.write('</p>');

    int? currentSection;
    for (final qId in visibleQuestionIds) {
      final q = questionMap[qId];
      if (q == null || fileQuestionIds.contains(qId)) continue;
      final value = answers[qId];
      if (value == null) continue;

      if (q.sectionId != currentSection) {
        if (currentSection != null) buffer.write('</ul>');
        final sName = sectionMap[q.sectionId]?.name ?? 'Seção';
        buffer.write('<p><b>$sName</b></p><ul>');
        currentSection = q.sectionId;
      }

      final displayValue = _formatValue(value);
      buffer.write('<li><b>${q.name}:</b> $displayValue</li>');
    }
    if (currentSection != null) buffer.write('</ul>');
    return buffer.toString();
  }

  static String _formatValue(dynamic value) {
    if (value is List) return value.join(', ');
    return '$value';
  }

  /// Payload para `POST /Ticket` quando FormCreator REST nao esta disponivel.
  Map<String, dynamic> toTicketInput({
    required SisChecklistCatalog catalog,
    String? formName,
    String? targetName,
  }) {
    final name = targetName != null ? 'Checklist $targetName' : 'Checklist SIS';
    return {
      'name': name,
      'content': toTicketContent(catalog, formName: formName, targetName: targetName),
      'entities_id': entityId,
      'itilcategories_id': categoryId,
      'type': 1,
    };
  }
}

class SisChecklistSubmissionPreparer {
  const SisChecklistSubmissionPreparer({
    required this.catalog,
    required this.conditionEngine,
  });

  final SisChecklistCatalog catalog;
  final SisChecklistConditionEngine conditionEngine;

  SisChecklistPreparedSubmission prepare({
    required int formId,
    required int targetId,
    required Map<int, dynamic> answers,
  }) {
    final target = catalog.targetById(targetId);
    if (target == null) {
      throw ArgumentError('target $targetId nao existe no catalogo de checklist');
    }
    if (target.formId != formId) {
      throw ArgumentError(
        'target $targetId nao pertence ao form $formId (form real: ${target.formId})',
      );
    }
    if (target.categoryId <= 0) {
      throw ArgumentError('target $targetId sem categoria derivavel (category_id <= 0)');
    }
    if (target.destinationEntityValue <= 0) {
      throw ArgumentError('target $targetId sem entidade destino derivavel');
    }

    final fileQuestionIds = <int>{};
    final missingRequired = <int>[];
    final visibleQuestionIds = <int>[];

    for (final question in catalog.questionsForForm(formId)) {
      if (!conditionEngine.isQuestionVisible(question, answers)) {
        continue;
      }
      visibleQuestionIds.add(question.id);
      if (question.isFile) {
        fileQuestionIds.add(question.id);
      }
      if (question.required && _isMissing(answers[question.id])) {
        missingRequired.add(question.id);
      }
    }

    return SisChecklistPreparedSubmission(
      formId: formId,
      targetId: targetId,
      categoryId: target.categoryId,
      entityId: target.destinationEntityValue,
      answers: Map<int, dynamic>.unmodifiable(answers),
      fileQuestionIds: Set<int>.unmodifiable(fileQuestionIds),
      missingRequiredQuestionIds: List<int>.unmodifiable(missingRequired),
      visibleQuestionIds: List<int>.unmodifiable(visibleQuestionIds),
    );
  }

  bool _isMissing(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }
}
