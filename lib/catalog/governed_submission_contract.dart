import 'governed_entity_resolver.dart';
import 'governed_service_catalog.dart';

class GovernedSubmissionInput {
  final List<GovernedServiceRecord> records;
  final String profileName;
  final GovernedTicketAudience audience;
  final int? selectedCategoryId;
  final int? selectedLocationId;

  /// Sub-serviço escolhido dentro de um card agregado (UX fiel ao GLPI:
  /// CONSERVAÇÃO/MANUTENÇÃO/... têm um alvo por sub-serviço).
  final String? selectedSubService;
  final GovernedEntityContext entityContext;

  const GovernedSubmissionInput({
    required this.records,
    required this.profileName,
    required this.audience,
    required this.entityContext,
    this.selectedCategoryId,
    this.selectedLocationId,
    this.selectedSubService,
  });
}

class GovernedSubmissionContract {
  final GovernedServiceRecord record;
  final int entityId;
  final int? categoryId;
  final int? locationId;
  final GovernedReadbackExpectation readbackExpectation;

  const GovernedSubmissionContract({
    required this.record,
    required this.entityId,
    required this.readbackExpectation,
    this.categoryId,
    this.locationId,
  });
}

class GovernedSubmissionResolution {
  final GovernedSubmissionContract? contract;
  final String? blocker;

  const GovernedSubmissionResolution._({this.contract, this.blocker});

  factory GovernedSubmissionResolution.resolved(
    GovernedSubmissionContract contract,
  ) {
    return GovernedSubmissionResolution._(contract: contract);
  }

  factory GovernedSubmissionResolution.blocked(String blocker) {
    return GovernedSubmissionResolution._(blocker: blocker);
  }

  bool get ok => contract != null && blocker == null;
}

class GovernedSubmissionResolver {
  const GovernedSubmissionResolver._();

  static GovernedSubmissionResolution resolve(GovernedSubmissionInput input) {
    if (input.records.isEmpty) {
      return GovernedSubmissionResolution.blocked(
        'serviço sem registros no catálogo governado',
      );
    }

    final audience = input.audience == GovernedTicketAudience.paraMim
        ? 'para_mim'
        : 'para_terceiro';
    final profile = _normalize(input.profileName);

    var candidates = input.records
        .where((record) {
          if (record.audience != audience) return false;
          return record.profileVisibility.any(
            (visibleProfile) => _normalize(visibleProfile.name) == profile,
          );
        })
        .toList(growable: false);

    if (candidates.isEmpty) {
      if (audience == 'para_terceiro') {
        return GovernedSubmissionResolution.blocked(
          'serviço/perfil não permite atendimento para outra pessoa: '
          'não há contrato para_terceiro para o perfil "${input.profileName}"',
        );
      }
      return GovernedSubmissionResolution.blocked(
        'serviço sem contrato para perfil "${input.profileName}" e audiência "$audience"',
      );
    }

    final selectedSub = input.selectedSubService?.trim() ?? '';
    if (selectedSub.isNotEmpty) {
      final bySub = candidates
          .where(
            (record) =>
                _normalize(record.subService ?? '') == _normalize(selectedSub),
          )
          .toList(growable: false);
      if (bySub.isEmpty) {
        return GovernedSubmissionResolution.blocked(
          'sub-serviço "$selectedSub" sem contrato neste formulário',
        );
      }
      candidates = bySub;
    } else if (candidates.any((record) => record.isAggregateForm)) {
      final subServices = candidates
          .map((record) => record.subService ?? '')
          .where((sub) => sub.isNotEmpty)
          .toSet();
      if (subServices.length > 1) {
        return GovernedSubmissionResolution.blocked(
          'formulário agregado: selecione o serviço desejado '
          '(${subServices.length} opções) antes de enviar',
        );
      }
    }

    candidates = _filterByOption(
      candidates: candidates,
      selectedId: input.selectedCategoryId,
      selector: (record) => record.categoryQuestion,
    );
    candidates = _filterByOption(
      candidates: candidates,
      selectedId: input.selectedLocationId,
      selector: (record) => record.locationQuestion,
    );

    if (candidates.isEmpty) {
      return GovernedSubmissionResolution.blocked(
        'nenhum contrato governado compatível com categoria/localização selecionadas',
      );
    }

    final record = _singleOrBlock(candidates);
    if (record == null) {
      return GovernedSubmissionResolution.blocked(
        'contrato governado ambíguo: ${candidates.length} targettickets compatíveis; selecione categoria/localização que desambigue ou corrija o catálogo',
      );
    }
    if (record.requiresSpecializedFlow) {
      return GovernedSubmissionResolution.blocked(
        'formulário de checklist requer fluxo especializado; indisponível no app',
      );
    }

    final entityResolution = GovernedEntityResolver.resolve(
      record: record,
      context: input.entityContext,
    );
    if (!entityResolution.ok || entityResolution.entityId == null) {
      return GovernedSubmissionResolution.blocked(
        entityResolution.blocker ??
            'não foi possível resolver entidade GLPI para o contrato governado',
      );
    }

    return GovernedSubmissionResolution.resolved(
      GovernedSubmissionContract(
        record: record,
        entityId: entityResolution.entityId!,
        categoryId: input.selectedCategoryId,
        locationId: input.selectedLocationId,
        readbackExpectation: record.toReadbackExpectation(
          expectedEntityId: entityResolution.entityId,
        ),
      ),
    );
  }

  static GovernedServiceRecord? _singleOrBlock(
    List<GovernedServiceRecord> candidates,
  ) {
    if (candidates.length == 1) return candidates.single;

    final targetKeys = candidates
        .map((record) => '${record.formId}:${record.targetTicketId}')
        .toSet();
    if (targetKeys.length > 1) return null;

    return candidates.first;
  }

  static List<GovernedServiceRecord> _filterByOption({
    required List<GovernedServiceRecord> candidates,
    required int? selectedId,
    required GovernedQuestion? Function(GovernedServiceRecord) selector,
  }) {
    if (selectedId == null || selectedId <= 0) return candidates;

    // Fail-closed: se o usuário selecionou um id que não corresponde a
    // nenhuma opção do catálogo governado, bloqueia (via candidates.isEmpty
    // em resolve()) em vez de devolver os candidatos originais sem filtro.
    return candidates
        .where((record) {
          final question = selector(record);
          if (question == null || question.options.isEmpty) return true;
          return question.options.any((option) => option.id == selectedId);
        })
        .toList(growable: false);
  }

  static String _normalize(String value) {
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
}
