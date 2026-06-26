import 'checklist_catalog.dart';

/// Avaliador de visibilidade de perguntas, secoes e targets de checklist.
///
/// Espelha exatamente a semantica ja provada em `DticFormCatalog._isItemVisible`
/// / `_conditionsMatch` / `DticFormCondition.matches`:
/// - `showRule == 1`: sempre visivel;
/// - `showRule == 2`: visivel quando a expressao de condicoes casa;
/// - `showRule == 3`: visivel quando a expressao NAO casa (esconde-se ao casar);
/// - sem condicoes: `showRule == 3` => visivel, caso contrario oculto;
/// - `showLogic == 2` combina como OR; qualquer outro valor combina como AND;
/// - `showCondition == 1` compara igualdade, `2` compara diferenca.
class SisChecklistConditionEngine {
  const SisChecklistConditionEngine(this.catalog);

  final SisChecklistCatalog catalog;

  bool isSectionVisible(
    SisChecklistSection section,
    Map<int, dynamic> answers,
  ) {
    return _isItemVisible(
      itemType: SisChecklistCondition.sectionItemType,
      itemId: section.id,
      showRule: 2, // secoes sao avaliadas por suas condicoes quando existem
      answers: answers,
      defaultWhenNoConditions: true,
    );
  }

  bool isQuestionVisible(
    SisChecklistQuestion question,
    Map<int, dynamic> answers,
  ) {
    // Pergunta so e visivel se a secao dela tambem for.
    final section = _sectionById(question.sectionId);
    if (section != null && !isSectionVisible(section, answers)) {
      return false;
    }
    return _isItemVisible(
      itemType: SisChecklistCondition.questionItemType,
      itemId: question.id,
      showRule: question.showRule,
      answers: answers,
      defaultWhenNoConditions: question.showRule == 1,
    );
  }

  bool isTargetVisible(SisChecklistTarget target, Map<int, dynamic> answers) {
    return _isItemVisible(
      itemType: SisChecklistCondition.targetTicketItemType,
      itemId: target.id,
      showRule: target.showRule,
      answers: answers,
      defaultWhenNoConditions: true,
    );
  }

  SisChecklistSection? _sectionById(int sectionId) {
    for (final section in catalog.sections) {
      if (section.id == sectionId) return section;
    }
    return null;
  }

  bool _isItemVisible({
    required String itemType,
    required int itemId,
    required int showRule,
    required Map<int, dynamic> answers,
    required bool defaultWhenNoConditions,
  }) {
    if (showRule == 1) return true;

    final itemConditions = catalog.conditionsFor(itemType, itemId)
      ..sort((a, b) => a.order.compareTo(b.order));

    if (itemConditions.isEmpty) {
      // Sem condicoes configuradas: showRule==3 mantem visivel; demais usam o
      // default do item (perguntas seguem o proprio showRule).
      if (showRule == 3) return true;
      return defaultWhenNoConditions;
    }

    final expressionMatches = _conditionsMatch(itemConditions, answers);
    if (showRule == 2) return expressionMatches;
    if (showRule == 3) return !expressionMatches;
    return true;
  }

  bool _conditionsMatch(
    List<SisChecklistCondition> itemConditions,
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
