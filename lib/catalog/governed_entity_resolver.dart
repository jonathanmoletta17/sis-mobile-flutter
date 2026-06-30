import 'governed_service_catalog.dart';

class GovernedEntityContext {
  final int? selectedTicketEntityId;
  final int? activeEntityId;
  final int? beneficiaryEntityId;

  /// Entidade PADRÃO do requerente (`User.entities_id` / `glpidefault_entity`).
  /// FormCreator `destination_entity` code 2 (REQUESTER) usa esta entidade, NÃO
  /// a entidade ativa da sessão. Sem isto, chamados de forms "para mim" iam para
  /// a entidade ativa (errada quando ativa != padrão).
  final int? requesterDefaultEntityId;

  const GovernedEntityContext({
    this.selectedTicketEntityId,
    this.activeEntityId,
    this.beneficiaryEntityId,
    this.requesterDefaultEntityId,
  });
}

class GovernedEntityResolution {
  final int? entityId;
  final String? blocker;

  const GovernedEntityResolution._({this.entityId, this.blocker});

  factory GovernedEntityResolution.resolved(int entityId) {
    return GovernedEntityResolution._(entityId: entityId);
  }

  factory GovernedEntityResolution.blocked(String blocker) {
    return GovernedEntityResolution._(blocker: blocker);
  }

  bool get ok => entityId != null && entityId! > 0 && blocker == null;
}

class GovernedEntityResolver {
  const GovernedEntityResolver._();

  static GovernedEntityResolution resolve({
    required GovernedServiceRecord record,
    required GovernedEntityContext context,
  }) {
    final selectedEntityId = _positiveInt(context.selectedTicketEntityId);
    final activeEntityId = _positiveInt(context.activeEntityId);
    final beneficiaryEntityId = _positiveInt(context.beneficiaryEntityId);
    final requesterDefaultEntityId = _positiveInt(
      context.requesterDefaultEntityId,
    );
    final targetValue = _positiveInt(record.destinationEntityValue);
    final mode = record.destinationEntityMode?.trim();

    switch (mode) {
      case 'requester_context_para_mim':
        // FormCreator code 2 (REQUESTER) = entidade PADRÃO do requerente
        // (User.entities_id), e SÓ cai para a ativa se a padrão não existir.
        return _resolveFirst(
          mode: mode!,
          candidates: [requesterDefaultEntityId, selectedEntityId, activeEntityId],
        );
      case 'maintenance_context_para_mim':
        return _resolveFirst(
          mode: mode!,
          candidates: [targetValue, selectedEntityId, activeEntityId],
        );
      case 'third_party_question':
        if (beneficiaryEntityId != null) {
          return GovernedEntityResolution.resolved(beneficiaryEntityId);
        }
        return GovernedEntityResolution.blocked(
          'modo third_party_question exige beneficiário GLPI resolvido; destination_entity_value=${record.destinationEntityValue ?? 0} é id da pergunta, não entidade final',
        );
      case 'fixed_or_direct':
        return _resolveFirst(
          mode: mode!,
          candidates: [targetValue, selectedEntityId, activeEntityId],
        );
      default:
        return GovernedEntityResolution.blocked(
          'modo de entidade governada desconhecido: ${mode == null || mode.isEmpty ? 'sem modo definido' : mode}',
        );
    }
  }

  static GovernedEntityResolution _resolveFirst({
    required String mode,
    required Iterable<int?> candidates,
  }) {
    for (final candidate in candidates) {
      final positive = _positiveInt(candidate);
      if (positive != null) return GovernedEntityResolution.resolved(positive);
    }
    return GovernedEntityResolution.blocked(
      'não foi possível resolver entidade GLPI para o modo $mode',
    );
  }

  static int? _positiveInt(int? value) {
    if (value == null || value <= 0) return null;
    return value;
  }
}
